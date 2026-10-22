import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/nearby_mosque_model.dart';

/// Yakındaki Camileri Arama ve Harita Navigasyon Servisi
class NearbyMosquesService {
  static final NearbyMosquesService instance = NearbyMosquesService._internal();
  factory NearbyMosquesService() => instance;
  NearbyMosquesService._internal();

  static const String _prefCachedMosquesKey = 'beyan_cached_real_mosques_v3';

  // Gerçek yerel camilerin bellek içi önbelleği (kesintisiz stabilite için)
  static final List<NearbyMosque> _inMemoryRealCache = [];
  static DateTime? _lastNetworkFetch;
  static double? _lastCachedLat;
  static double? _lastCachedLng;

  /// Önbelleğe alınmış gerçek yerel camileri kullanıcı koordinatlarına göre yeniden hesaplar
  List<NearbyMosque> _getCachedRealMosques(double userLat, double userLng, double radiusMeters) {
    if (_inMemoryRealCache.isEmpty) return [];

    final list = _inMemoryRealCache.map((m) {
      final dist = NearbyMosque.calculateDistanceMeters(userLat, userLng, m.latitude, m.longitude);
      final bearing = NearbyMosque.calculateBearing(userLat, userLng, m.latitude, m.longitude);
      return m.copyWith(distanceMeters: dist, bearingDegrees: bearing);
    }).where((m) => m.distanceMeters <= radiusMeters && !m.isCuratedFallback).toList();

    list.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return list;
  }

  /// Yeni bulunan gerçek camileri önbelleğe ekler ve mesafeleri günceller
  void _saveToCache(List<NearbyMosque> newMosques, double userLat, double userLng) {
    final realMosques = newMosques.where((m) => !m.isCuratedFallback).toList();
    if (realMosques.isEmpty) return;

    for (final nm in realMosques) {
      final exists = _inMemoryRealCache.any((em) =>
          em.id == nm.id ||
          (em.name.toLowerCase() == nm.name.toLowerCase() &&
              NearbyMosque.calculateDistanceMeters(em.latitude, em.longitude, nm.latitude, nm.longitude) < 60));
      if (!exists) {
        _inMemoryRealCache.add(nm);
      }
    }

    _lastNetworkFetch = DateTime.now();
    _lastCachedLat = userLat;
    _lastCachedLng = userLng;

    _persistCacheAsync();
  }

  /// Kalıcı depolamaya arka planda JSON olarak kaydet
  Future<void> _persistCacheAsync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _inMemoryRealCache.take(60).map((m) => m.toJson()).toList();
      await prefs.setString(_prefCachedMosquesKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  /// Uygulama ilk açıldığında kalıcı önbellekten camileri yükle
  Future<void> _loadCacheFromPrefs() async {
    if (_inMemoryRealCache.isNotEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefCachedMosquesKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>? ?? [];
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            final m = NearbyMosque.fromJson(item);
            if (!m.isCuratedFallback && !_inMemoryRealCache.any((x) => x.id == m.id)) {
              _inMemoryRealCache.add(m);
            }
          }
        }
      }
    } catch (_) {}
  }

  /// Verilen koordinatlar etrafındaki camileri bulur.
  /// Arama Sırası:
  /// 1. Gerçek cami önbelleği kontrolü (peş peşe yenilemelerde mesafe zıplamasını ve 429'u önler)
  /// 2. Google Places API (yalnızca geçerli bir Google Maps API anahtarı sağlandıysa)
  /// 3. OpenStreetMap Nominatim Bounded API (kesin koordinat sınırlı, hızlı ve yerel camiler)
  /// 4. Komoot Photon POI API (hızlı OSM arama motoru yedeği)
  /// 5. OpenStreetMap Overpass API (POST istekli harita sunucu yedeği)
  /// 6. Çevrimdışı zengin cami veritabanı (yalnızca hiçbir gerçek cami bulunamazsa)
  Future<List<NearbyMosque>> findNearbyMosques({
    required double userLat,
    required double userLng,
    double radiusMeters = 5000,
    String? googleApiKey,
    bool forceRefresh = false,
  }) async {
    // 0. Kalıcı önbelleği belleğe yükle
    if (_inMemoryRealCache.isEmpty) {
      await _loadCacheFromPrefs();
    }

    final localCached = _getCachedRealMosques(userLat, userLng, radiusMeters);

    // KULLANICI "YENİLE" BUTONUNA BASTIĞINDA:
    // Yalnızca son 10 saniye içinde aynı noktada (<35m) arama yapılmışsa VE
    // önbellekte gerçekten 1.5 km içinde yakın mahalle camileri varsa önbellekten dön:
    final hasCloseMosqueInCache = localCached.any((m) => m.distanceMeters < 1500);
    final hasRecentCache = _lastNetworkFetch != null &&
        DateTime.now().difference(_lastNetworkFetch!).inSeconds < 10 &&
        _lastCachedLat != null &&
        _lastCachedLng != null &&
        NearbyMosque.calculateDistanceMeters(userLat, userLng, _lastCachedLat!, _lastCachedLng!) < 35;

    if (!forceRefresh && hasRecentCache && hasCloseMosqueInCache) {
      return localCached;
    }

    final mergedMap = <String, NearbyMosque>{};

    void addMosques(List<NearbyMosque> list) {
      for (final m in list) {
        if (m.distanceMeters > radiusMeters) continue;
        // 55 metre içindeki mükerrer kayıtları birleştir
        final duplicateKey = mergedMap.keys.cast<String?>().firstWhere(
          (k) {
            final existing = mergedMap[k]!;
            final d = NearbyMosque.calculateDistanceMeters(
              existing.latitude,
              existing.longitude,
              m.latitude,
              m.longitude,
            );
            return d < 55;
          },
          orElse: () => null,
        );
        if (duplicateKey == null) {
          mergedMap[m.id] = m;
        } else {
          final existing = mergedMap[duplicateKey]!;
          // Daha detaylı isme veya adrese sahip olanı tercih et
          if ((existing.name == 'Cami' && m.name != 'Cami') ||
              (existing.address == null && m.address != null)) {
            mergedMap[duplicateKey] = m;
          }
        }
      }
    }

    // 1. Google Places API (Yalnızca geçerli bir Places anahtarı sağlandıysa)
    if (googleApiKey != null && googleApiKey.trim().isNotEmpty && !googleApiKey.startsWith('AIzaSy')) {
      try {
        final googleMosques = await _fetchFromGooglePlaces(userLat, userLng, radiusMeters, googleApiKey.trim());
        addMosques(googleMosques);
      } catch (_) {}
    }

    // 2. TÜM KAYNAKLARI PARALEL ÇALIŞTIR VE BİRLEŞTİR!
    // (Dar yarıçaplı Nominatim + Photon Yakınlık Motoru ("camii", "cami", "mescit") + Overpass BBox)
    // Böylece tek bir kaynağın 4 km ötedeki ünlü camileri döndürüp mahalle camilerini atlaması %100 önlenir.
    try {
      final parallelBatches = await Future.wait<List<NearbyMosque>>([
        _fetchFromNominatim(userLat, userLng, radiusMeters),
        _fetchFromPhoton(userLat, userLng, radiusMeters),
        _fetchFromOverpass(userLat, userLng, radiusMeters),
      ]);
      for (final batch in parallelBatches) {
        addMosques(batch);
      }
    } catch (_) {}

    final liveResults = mergedMap.values.toList()
      ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));

    // 5. SONUÇLARI DEĞERLENDİRME & MESAFE ZIPLAMA KORUMASI:
    if (liveResults.isNotEmpty) {
      _saveToCache(liveResults, userLat, userLng);
      final finalCombined = _getCachedRealMosques(userLat, userLng, radiusMeters);
      if (finalCombined.isNotEmpty) {
        return finalCombined;
      }
      return liveResults;
    }

    // AĞ HATASI / 429 RATE LIMIT / ZAMAN AŞIMI DURUMUNDA:
    // Eğer önbellekte daha önce bulunmuş gerçek yerel camiler varsa,
    // ASLA 4 km uzaktaki seçkin cami listesine düşme! Gerçek camileri koru:
    if (localCached.isNotEmpty) {
      return localCached;
    }

    // 6. Yalnızca ilk açılışta ve hiçbir gerçek veri bulunamadıysa çalışan seçkin camiler
    final fallbackList = _getCuratedFallbackMosques(userLat, userLng);
    fallbackList.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return fallbackList;
  }

  /// Bir yerin gerçek bir cami/mescid olup olmadığını filtreler; kilise, havra, sokak ve dükkanları eler
  static bool isMosqueCandidate(String name, String? addressOrDisplayName, {bool isConfirmedWorshipPlace = false}) {
    final lowerName = name.toLowerCase().trim();
    final combined = '$lowerName ${addressOrDisplayName?.toLowerCase() ?? ''}';

    // Gayrimüslim ibadethaneleri, mezarlık/hazire ve cami isimli dükkan/duraklar elenir
    const excludeTerms = [
      'kilise', 'kilisesi', 'church', 'sinagog', 'sinagogu', 'synagogue',
      'havra', 'patrikhane', 'metropolit', 'şapel', 'chapel', 'monastery',
      'manastır', 'katedral', 'cathedral', 'cemevi', 'haziresi', 'mezarlığı',
      'türbesi', 'türbe', 'kafe', 'cafe', 'kahve', 'restoran', 'lokanta',
      'market', 'bakkal', 'eczane', 'ecza', 'otopark', 'durağı', 'istasyonu',
      'apartmanı', 'sitesi', 'ilkokulu', 'ortaokulu', 'lisesi'
    ];
    for (final term in excludeTerms) {
      if (lowerName.contains(term) || combined.contains(term)) return false;
    }

    // Doğrudan isimde İslami ibadethane terimi geçiyorsa kabul et
    const includeTerms = [
      'cami', 'camii', 'mescid', 'mescit', 'mescidi', 'mosque', 'masjid',
      'namazgâh', 'namazgah', 'külliye', 'külliyesi'
    ];
    for (final term in includeTerms) {
      if (lowerName.contains(term)) return true;
    }

    // OSM'de doğrudan place_of_worship olarak işaretlenmişse ve gayrimüslim değilse kabul et
    if (isConfirmedWorshipPlace && lowerName.isNotEmpty) {
      return true;
    }

    return false;
  }

  /// Google Places API (Nearby Search) ile resmi Google cami verilerini alma
  Future<List<NearbyMosque>> _fetchFromGooglePlaces(
    double lat,
    double lng,
    double radiusMeters,
    String apiKey,
  ) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);
    try {
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=$radiusMeters&type=mosque&language=tr&key=$apiKey',
      );
      final request = await client.getUrl(uri);
      final response = await request.close().timeout(const Duration(seconds: 6));
      if (response.statusCode != HttpStatus.ok) return [];

      final responseBody = await response.transform(utf8.decoder).join();
      final data = jsonDecode(responseBody) as Map<String, dynamic>;
      final status = data['status'] as String? ?? '';
      if (status != 'OK') return [];

      final results = data['results'] as List<dynamic>? ?? [];
      final mosques = <NearbyMosque>[];

      for (final item in results) {
        if (item is! Map<String, dynamic>) continue;
        final geom = item['geometry'] as Map<String, dynamic>?;
        final loc = geom?['location'] as Map<String, dynamic>?;
        final mLat = (loc?['lat'] as num?)?.toDouble();
        final mLng = (loc?['lng'] as num?)?.toDouble();
        if (mLat == null || mLng == null) continue;

        final name = (item['name'] as String? ?? 'Cami').trim();
        final address = (item['vicinity'] as String? ?? item['formatted_address'] as String?)?.trim();
        if (!isMosqueCandidate(name, address)) continue;

        final dist = NearbyMosque.calculateDistanceMeters(lat, lng, mLat, mLng);
        final bearing = NearbyMosque.calculateBearing(lat, lng, mLat, mLng);
        final placeId = (item['place_id'] as String?) ?? '$mLat,$mLng';

        mosques.add(
          NearbyMosque(
            id: placeId,
            name: name,
            latitude: mLat,
            longitude: mLng,
            distanceMeters: dist,
            address: address,
            bearingDegrees: bearing,
          ),
        );
      }
      return mosques;
    } catch (_) {
      return [];
    } finally {
      client.close();
    }
  }

  /// OpenStreetMap Nominatim Kademeli (Önce 1.4 km Dar Mahalle Kutusu, Sonra 4 km Kutu) Sorgusu
  Future<List<NearbyMosque>> _fetchFromNominatim(double lat, double lng, double radiusMeters) async {
    final cosLat = math.cos(lat * math.pi / 180.0);
    final safeCos = cosLat.abs() < 0.001 ? 1.0 : cosLat.abs();

    // 1. Kademe: Kullanıcının hemen etrafındaki 1.4 km'lik mahalle kutusu!
    // (Böylece Nominatim 4 km ötedeki büyük camileri değil, 50m-1km içindeki tüm mahalle camilerini döndürür)
    const tightDeltaLat = 1.4 / 111.0;
    final tightDeltaLng = 1.4 / (111.0 * safeCos);

    // 2. Kademe: 3.8 km'lik orta kutu
    final medKm = math.min(radiusMeters / 1000.0, 3.8);
    final medDeltaLat = medKm / 111.0;
    final medDeltaLng = medKm / (111.0 * safeCos);

    final urls = <String>[
      // Dar 1.4 km kutuda tüm ibadethaneler (en yakın mahalle cami ve mescitleri):
      'https://nominatim.openstreetmap.org/search?format=json&q=[amenity=place_of_worship]&limit=50'
          '&viewbox=${lng - tightDeltaLng},${lat + tightDeltaLat},${lng + tightDeltaLng},${lat - tightDeltaLat}&bounded=1&addressdetails=1',
      // Orta 3.8 km kutuda "camii" ve "cami":
      'https://nominatim.openstreetmap.org/search?format=json&q=camii&limit=50'
          '&viewbox=${lng - medDeltaLng},${lat + medDeltaLat},${lng + medDeltaLng},${lat - medDeltaLat}&bounded=1&addressdetails=1',
    ];

    final allResults = <NearbyMosque>[];
    for (int i = 0; i < urls.length; i++) {
      if (i > 0) {
        await Future.delayed(const Duration(milliseconds: 950));
      }
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);
      try {
        final request = await client.getUrl(Uri.parse(urls[i]));
        request.headers.set('User-Agent', 'BeyanIslamicApp/2.0 (https://beyan.app)');
        final response = await request.close().timeout(const Duration(seconds: 6));
        if (response.statusCode == HttpStatus.ok) {
          final responseBody = await response.transform(utf8.decoder).join();
          final list = jsonDecode(responseBody) as List<dynamic>? ?? [];
          allResults.addAll(_parseNominatimResults(list, lat, lng));
        }
      } catch (_) {
      } finally {
        client.close();
      }
    }
    return allResults;
  }

  List<NearbyMosque> _parseNominatimResults(List<dynamic> list, double lat, double lng) {
    final results = <NearbyMosque>[];
    final seenIds = <String>{};

    for (final el in list) {
      if (el is! Map<String, dynamic>) continue;
      final osmClass = (el['class'] as String? ?? '').toLowerCase();
      final osmType = (el['type'] as String? ?? '').toLowerCase();
      if (osmClass == 'highway' || osmClass == 'shop' || osmClass == 'public_transport') {
        continue;
      }

      final rawLat = el['lat'];
      final rawLng = el['lon'];
      if (rawLat == null || rawLng == null) continue;

      final mLat = double.tryParse('$rawLat');
      final mLng = double.tryParse('$rawLng');
      if (mLat == null || mLng == null || (mLat == 0.0 && mLng == 0.0)) continue;

      final rawName = (el['name'] as String? ?? '').trim();
      final displayName = (el['display_name'] as String? ?? '').trim();
      final name = rawName.isNotEmpty
          ? rawName
          : (displayName.split(',').first.trim().isNotEmpty ? displayName.split(',').first.trim() : 'Cami');

      final isWorship = osmType == 'place_of_worship' || osmType == 'mosque';
      if (!isMosqueCandidate(name, displayName, isConfirmedWorshipPlace: isWorship)) continue;

      // Detaylı adres ayrıştırma
      String? address;
      final addrMap = el['address'] as Map<String, dynamic>?;
      if (addrMap != null) {
        final parts = <String>[];
        if (addrMap['road'] != null) parts.add('${addrMap['road']}');
        if (addrMap['neighbourhood'] != null) {
          parts.add('${addrMap['neighbourhood']}');
        } else if (addrMap['suburb'] != null) {
          parts.add('${addrMap['suburb']}');
        }
        if (addrMap['city_district'] != null) {
          parts.add('${addrMap['city_district']}');
        } else if (addrMap['city'] != null) {
          parts.add('${addrMap['city']}');
        }
        if (parts.isNotEmpty) address = parts.join(', ');
      }
      if (address == null || address.isEmpty) {
        final parts = displayName.split(',');
        if (parts.length > 1) {
          address = parts.skip(1).take(2).map((s) => s.trim()).join(', ');
        }
      }

      final dist = NearbyMosque.calculateDistanceMeters(lat, lng, mLat, mLng);
      final bearing = NearbyMosque.calculateBearing(lat, lng, mLat, mLng);
      final id = '${el['place_id'] ?? '${mLat.toStringAsFixed(4)},${mLng.toStringAsFixed(4)}'}';

      if (seenIds.add(id)) {
        results.add(
          NearbyMosque(
            id: id,
            name: name,
            latitude: mLat,
            longitude: mLng,
            distanceMeters: dist,
            address: address,
            bearingDegrees: bearing,
          ),
        );
      }
    }
    return results;
  }

  /// Komoot Photon POI API Sorgusu ("camii", "cami", "mescit", "mosque" paralel yakınlık araması)
  /// Not: Türkiye'de camilerin %90'ı "X Camii" (çift i) olarak kayıtlı olduğundan hem "camii" hem "cami" sorgulanır!
  Future<List<NearbyMosque>> _fetchFromPhoton(double lat, double lng, double radiusMeters) async {
    const queries = ['camii', 'cami', 'mescit', 'mescidi', 'mosque'];
    final results = <NearbyMosque>[];
    final seenIds = <String>{};

    final batches = await Future.wait<List<dynamic>>(
      queries.map((q) async {
        final client = HttpClient()..connectionTimeout = const Duration(seconds: 4);
        try {
          final uri = Uri.parse('https://photon.komoot.io/api/?q=$q&lat=$lat&lon=$lng&limit=50');
          final request = await client.getUrl(uri);
          request.headers.set('User-Agent', 'BeyanIslamicApp/2.0 (https://beyan.app)');
          final response = await request.close().timeout(const Duration(seconds: 5));
          if (response.statusCode != HttpStatus.ok) return const [];
          final body = await response.transform(utf8.decoder).join();
          final data = jsonDecode(body) as Map<String, dynamic>;
          return data['features'] as List<dynamic>? ?? const [];
        } catch (_) {
          return const [];
        } finally {
          client.close();
        }
      }),
    );

    for (final features in batches) {
      for (final f in features) {
        if (f is! Map<String, dynamic>) continue;
        final geom = f['geometry'] as Map<String, dynamic>?;
        final coords = geom?['coordinates'] as List<dynamic>?;
        if (coords == null || coords.length < 2) continue;

        final mLng = (coords[0] as num).toDouble();
        final mLat = (coords[1] as num).toDouble();
        final props = f['properties'] as Map<String, dynamic>? ?? {};

        final osmKey = (props['osm_key'] as String? ?? '').toLowerCase();
        final osmValue = (props['osm_value'] as String? ?? '').toLowerCase();
        // "Cami Sokak" gibi sokakları, otobüs duraklarını ve dükkanları ele
        if (osmKey == 'highway' || osmKey == 'shop' || osmKey == 'railway' || osmKey == 'public_transport') {
          continue;
        }

        final name = (props['name'] as String? ?? '').trim();
        if (name.isEmpty) continue;
        final street = props['street'] as String?;
        final district = props['district'] as String? ?? props['city'] as String?;
        final address = street != null ? '$street, ${district ?? ''}'.trim() : district;

        final isWorship = osmValue == 'place_of_worship' || osmValue == 'mosque';
        if (!isMosqueCandidate(name, address, isConfirmedWorshipPlace: isWorship)) continue;

        final dist = NearbyMosque.calculateDistanceMeters(lat, lng, mLat, mLng);
        if (dist > radiusMeters) continue;

        final bearing = NearbyMosque.calculateBearing(lat, lng, mLat, mLng);
        final id = '${props['osm_id'] ?? '${mLat.toStringAsFixed(4)},${mLng.toStringAsFixed(4)}'}';

        if (seenIds.add(id)) {
          results.add(
            NearbyMosque(
              id: id,
              name: name,
              latitude: mLat,
              longitude: mLng,
              distanceMeters: dist,
              address: address,
              bearingDegrees: bearing,
            ),
          );
        }
      }
    }
    return results;
  }

  /// OpenStreetMap Overpass API sorgusu (Hızlı Bounding-Box ile 2.5 km içindeki tüm cami ve mescitler)
  Future<List<NearbyMosque>> _fetchFromOverpass(double lat, double lng, double radius) async {
    final boxKm = math.min(radius / 1000.0, 2.5);
    final dLat = boxKm / 111.0;
    final cosLat = math.cos(lat * math.pi / 180.0);
    final dLng = boxKm / (111.0 * (cosLat.abs() < 0.001 ? 1.0 : cosLat.abs()));
    final minLat = (lat - dLat).toStringAsFixed(5);
    final minLng = (lng - dLng).toStringAsFixed(5);
    final maxLat = (lat + dLat).toStringAsFixed(5);
    final maxLng = (lng + dLng).toStringAsFixed(5);

    final query = '[out:json][timeout:4];(nwr["amenity"="place_of_worship"]($minLat,$minLng,$maxLat,$maxLng););out center 60;';

    final endpoints = [
      'https://overpass-api.de/api/interpreter',
      'https://overpass.kumi.systems/api/interpreter',
    ];

    for (final ep in endpoints) {
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 3);
      try {
        final request = await client.postUrl(Uri.parse(ep));
        request.headers.set('User-Agent', 'BeyanIslamicApp/2.0 (https://beyan.app)');
        request.headers.set('Content-Type', 'application/x-www-form-urlencoded');
        request.write('data=${Uri.encodeQueryComponent(query)}');

        final response = await request.close().timeout(const Duration(seconds: 4));
        if (response.statusCode != HttpStatus.ok) continue;

        final responseBody = await response.transform(utf8.decoder).join();
        final data = jsonDecode(responseBody) as Map<String, dynamic>;
        final elements = data['elements'] as List<dynamic>? ?? [];
        final result = <NearbyMosque>[];

        for (final el in elements) {
          if (el is! Map<String, dynamic>) continue;
          final tags = el['tags'] as Map<String, dynamic>? ?? {};
          final religion = (tags['religion'] as String? ?? '').toLowerCase();
          if (religion.isNotEmpty && religion != 'muslim' && religion != 'islam') continue;

          final name = (tags['name'] as String? ?? tags['name:tr'] as String? ?? 'Cami').trim();
          final street = tags['addr:street'] as String?;
          final district = tags['addr:district'] as String? ?? tags['addr:city'] as String?;
          final address = street != null ? '$street, ${district ?? ''}'.trim() : district;

          if (!isMosqueCandidate(name, address, isConfirmedWorshipPlace: true)) continue;

          double mLat = 0.0;
          double mLng = 0.0;
          if (el['lat'] != null && el['lon'] != null) {
            mLat = (el['lat'] as num).toDouble();
            mLng = (el['lon'] as num).toDouble();
          } else if (el['center'] != null) {
            mLat = (el['center']['lat'] as num).toDouble();
            mLng = (el['center']['lon'] as num).toDouble();
          }
          if (mLat == 0.0 || mLng == 0.0) continue;

          final dist = NearbyMosque.calculateDistanceMeters(lat, lng, mLat, mLng);
          if (dist > radius) continue;
          final bearing = NearbyMosque.calculateBearing(lat, lng, mLat, mLng);

          result.add(
            NearbyMosque(
              id: '${el['id']}',
              name: name,
              latitude: mLat,
              longitude: mLng,
              distanceMeters: dist,
              address: address,
              bearingDegrees: bearing,
            ),
          );
        }

        if (result.isNotEmpty) return result;
      } catch (_) {
      } finally {
        client.close();
      }
    }
    return [];
  }

  /// Google Haritalar veya Apple Haritalar uygulamasında çevredeki tüm camileri arama
  Future<void> openAllNearbyMosquesInMaps({
    required double userLat,
    required double userLng,
  }) async {
    // 1. Google Maps uygulaması yüklüyse doğrudan aç
    final googleAppUri = Uri.parse('comgooglemaps://?q=cami&center=$userLat,$userLng&zoom=15');
    if (await canLaunchUrl(googleAppUri)) {
      await launchUrl(googleAppUri, mode: LaunchMode.externalApplication);
      return;
    }

    // 2. Google Maps evrensel web URL'si
    final googleMapsUri = Uri.parse('https://www.google.com/maps/search/cami/@$userLat,$userLng,15z');
    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
      return;
    }

    // 3. Apple Maps arama (iOS Haritalar doğrudan çevredeki camileri döker)
    final appleMapsUri = Uri.parse('maps://?q=cami&sll=$userLat,$userLng');
    if (await canLaunchUrl(appleMapsUri)) {
      await launchUrl(appleMapsUri, mode: LaunchMode.externalApplication);
      return;
    }

    // 4. Web Apple Maps evrensel bağlantı
    final webMapsUri = Uri.parse('https://maps.apple.com/?q=cami&sll=$userLat,$userLng');
    if (await canLaunchUrl(webMapsUri)) {
      await launchUrl(webMapsUri, mode: LaunchMode.externalApplication);
    }
  }

  /// Google Haritalar'da çevredeki tüm camileri doğrudan canlı arama
  Future<void> openGoogleMapsNearby({
    required double userLat,
    required double userLng,
  }) async {
    await openAllNearbyMosquesInMaps(userLat: userLat, userLng: userLng);
  }

  /// Haritalarda Belli Bir Camiye Yürüme Rotası Açma (Önce Google Maps, sonra Apple Maps)
  Future<void> openWalkingDirections({
    required double lat,
    required double lng,
    required String mosqueName,
  }) async {
    // 1. Google Maps uygulaması yüklüyse
    final googleAppUri = Uri.parse('comgooglemaps://?daddr=$lat,$lng&directionsmode=walking');
    if (await canLaunchUrl(googleAppUri)) {
      await launchUrl(googleAppUri, mode: LaunchMode.externalApplication);
      return;
    }

    // 2. Google Maps evrensel web navigasyon linki
    final googleMapsUri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=walking');
    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
      return;
    }

    // 3. Apple Maps yürüme rotası: maps://?daddr=lat,lng&dirflg=w
    final appleMapsUri = Uri.parse('maps://?daddr=$lat,$lng&dirflg=w');
    if (await canLaunchUrl(appleMapsUri)) {
      await launchUrl(appleMapsUri, mode: LaunchMode.externalApplication);
      return;
    }

    // 4. Web tabanlı harita linki
    final webMapsUri = Uri.parse('https://maps.apple.com/?daddr=$lat,$lng&dirflg=w');
    if (await canLaunchUrl(webMapsUri)) {
      await launchUrl(webMapsUri, mode: LaunchMode.externalApplication);
    }
  }

  /// İnternet olmasa dahi çalışan zengin seçkin cami veritabanı (isCuratedFallback: true)
  List<NearbyMosque> _getCuratedFallbackMosques(double userLat, double userLng) {
    const rawList = [
      {'name': 'Süleymaniye Camii', 'lat': 41.0162, 'lng': 28.9644, 'addr': 'Fatih, İstanbul'},
      {'name': 'Sultanahmet Camii (Mavi Cami)', 'lat': 41.0054, 'lng': 28.9768, 'addr': 'Sultanahmet, İstanbul'},
      {'name': 'Ayasofya-i Kebîr Cami-i Şerîfi', 'lat': 41.0086, 'lng': 28.9802, 'addr': 'Fatih, İstanbul'},
      {'name': 'Büyük Çamlıca Camii', 'lat': 41.0345, 'lng': 29.0682, 'addr': 'Üsküdar, İstanbul'},
      {'name': 'Eyüp Sultan Camii', 'lat': 41.0478, 'lng': 28.9341, 'addr': 'Eyüpsultan, İstanbul'},
      {'name': 'Fatih Camii', 'lat': 41.0197, 'lng': 28.9499, 'addr': 'Fatih, İstanbul'},
      {'name': 'Ortaköy Camii (Büyük Mecidiye)', 'lat': 41.0472, 'lng': 29.0270, 'addr': 'Beşiktaş, İstanbul'},
      {'name': 'Mihrimah Sultan Camii', 'lat': 41.0268, 'lng': 29.0155, 'addr': 'Üsküdar, İstanbul'},
      {'name': 'Osman Ağa Camii', 'lat': 40.9908, 'lng': 29.0261, 'addr': 'Kadıköy, İstanbul'},
      {'name': 'Şakirin Camii', 'lat': 41.0119, 'lng': 29.0287, 'addr': 'Karacaahmet, Üsküdar, İstanbul'},
      {'name': 'Kocatepe Camii', 'lat': 39.9167, 'lng': 32.8608, 'addr': 'Kızılay, Ankara'},
      {'name': 'Hacı Bayram Camii', 'lat': 39.9444, 'lng': 32.8581, 'addr': 'Ulus, Ankara'},
      {'name': 'Ahmet Hamdi Akseki Camii', 'lat': 39.9077, 'lng': 32.7601, 'addr': 'Çankaya, Ankara'},
      {'name': 'Melike Hatun Camii', 'lat': 39.9372, 'lng': 32.8569, 'addr': 'Altındağ, Ankara'},
      {'name': 'İzmir Konak Camii (Yalı Camii)', 'lat': 38.4189, 'lng': 27.1287, 'addr': 'Konak, İzmir'},
      {'name': 'Hisar Camii', 'lat': 38.4239, 'lng': 27.1325, 'addr': 'Kemeraltı, İzmir'},
      {'name': 'Bursa Ulu Camii', 'lat': 40.1834, 'lng': 29.0620, 'addr': 'Osmangazi, Bursa'},
      {'name': 'Yeşil Camii', 'lat': 40.1816, 'lng': 29.0744, 'addr': 'Yıldırım, Bursa'},
      {'name': 'Selimiye Camii', 'lat': 41.6781, 'lng': 26.5594, 'addr': 'Merkez, Edirne'},
      {'name': 'Konya Mevlana Mescidi', 'lat': 37.8707, 'lng': 32.5050, 'addr': 'Karatay, Konya'},
      {'name': 'Alaaddin Camii', 'lat': 37.8732, 'lng': 32.4931, 'addr': 'Meram, Konya'},
      {'name': 'Sabancı Merkez Camii', 'lat': 36.9914, 'lng': 35.3344, 'addr': 'Seyhan, Adana'},
      {'name': 'Antalya Yivli Minare Camii', 'lat': 36.8866, 'lng': 30.7045, 'addr': 'Muratpaşa, Antalya'},
      {'name': 'Trabzon Ayasofya Camii', 'lat': 41.0028, 'lng': 39.6961, 'addr': 'Ortahisar, Trabzon'},
      {'name': 'Gaziantep Kurtuluş Camii', 'lat': 37.0601, 'lng': 37.3789, 'addr': 'Şahinbey, Gaziantep'},
      {'name': 'Diyarbakır Ulu Camii', 'lat': 37.9136, 'lng': 40.2372, 'addr': 'Sur, Diyarbakır'},
      {'name': 'Eskişehir Reşadiye Camii', 'lat': 39.7719, 'lng': 30.5186, 'addr': 'Odunpazarı, Eskişehir'},
      {'name': 'Mescid-i Haram (Kâbe)', 'lat': 21.4225, 'lng': 39.8262, 'addr': 'Mekke-i Mükerreme'},
      {'name': 'Mescid-i Nebevi', 'lat': 24.4672, 'lng': 39.6111, 'addr': 'Medine-i Münevvere'},
      {'name': 'Mescid-i Aksâ', 'lat': 31.7761, 'lng': 35.2358, 'addr': 'Kudüs-ü Şerif'},
    ];

    return rawList.map((item) {
      final mLat = item['lat'] as double;
      final mLng = item['lng'] as double;
      final dist = NearbyMosque.calculateDistanceMeters(userLat, userLng, mLat, mLng);
      final bearing = NearbyMosque.calculateBearing(userLat, userLng, mLat, mLng);

      return NearbyMosque(
        id: item['name'] as String,
        name: item['name'] as String,
        latitude: mLat,
        longitude: mLng,
        distanceMeters: dist,
        address: item['addr'] as String,
        bearingDegrees: bearing,
        isCuratedFallback: true,
      );
    }).toList();
  }
}

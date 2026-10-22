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

  static const String _prefCachedMosquesKey = 'beyan_cached_real_mosques';

  // Gerçek yerel camilerin bellek içi önbelleği (kesintisiz stabilite için)
  static final List<NearbyMosque> _inMemoryRealCache = [];
  static DateTime? _lastNetworkFetch;
  static double? _lastCachedLat;
  static double? _lastCachedLng;
  static DateTime? _lastNominatimCallTime;

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
    // Eğer son 15 saniye içinde aynı konum (<60m) taranmış ve gerçek camiler bulunmuşsa;
    // Nominatim'in 429 hatası vermesini ve camilerin 4 km'ye zıplamasını engellemek için
    // gerçek camilerin mesafesini anlık koordinata göre güncelleyip anında döneriz.
    final hasRecentCache = _lastNetworkFetch != null &&
        DateTime.now().difference(_lastNetworkFetch!).inSeconds < 15 &&
        _lastCachedLat != null &&
        _lastCachedLng != null &&
        NearbyMosque.calculateDistanceMeters(userLat, userLng, _lastCachedLat!, _lastCachedLng!) < 60;

    if (!forceRefresh && hasRecentCache && localCached.isNotEmpty) {
      return localCached;
    }

    List<NearbyMosque> liveResults = [];

    // 1. Google Places API (Yalnızca geçerli bir Places anahtarı sağlandıysa)
    if (googleApiKey != null && googleApiKey.trim().isNotEmpty && !googleApiKey.startsWith('AIzaSy')) {
      try {
        final googleMosques = await _fetchFromGooglePlaces(userLat, userLng, radiusMeters, googleApiKey.trim());
        if (googleMosques.isNotEmpty) {
          liveResults = googleMosques;
        }
      } catch (_) {}
    }

    // 2. OpenStreetMap Nominatim Bounded Arama API (Hızlı, güncel ve kesin koordinat kutulu)
    if (liveResults.isEmpty) {
      try {
        // Nominatim 1 saniyede 1 istek kuralı: peş peşe istekleri 800ms geciktir
        if (_lastNominatimCallTime != null) {
          final elapsed = DateTime.now().difference(_lastNominatimCallTime!).inMilliseconds;
          if (elapsed < 1000) {
            await Future.delayed(Duration(milliseconds: 1000 - elapsed));
          }
        }
        _lastNominatimCallTime = DateTime.now();

        final mosques = await _fetchFromNominatim(userLat, userLng, radiusMeters);
        if (mosques.isNotEmpty) {
          liveResults = mosques;
        }
      } catch (_) {}
    }

    // 3. Komoot Photon POI API (Alternatif ultra-hızlı OSM cami arama motoru)
    if (liveResults.isEmpty) {
      try {
        final mosques = await _fetchFromPhoton(userLat, userLng, radiusMeters);
        if (mosques.isNotEmpty) {
          liveResults = mosques;
        }
      } catch (_) {}
    }

    // 4. OpenStreetMap Overpass API (POST sorgulu ayna sunucular)
    if (liveResults.isEmpty) {
      try {
        final mosques = await _fetchFromOverpass(userLat, userLng, radiusMeters);
        if (mosques.isNotEmpty) {
          liveResults = mosques;
        }
      } catch (_) {}
    }

    // 5. SONUÇLARI DEĞERLENDİRME & MESAFE ZIPLAMA KORUMASI:
    if (liveResults.isNotEmpty) {
      _saveToCache(liveResults, userLat, userLng);
      final finalCombined = _getCachedRealMosques(userLat, userLng, radiusMeters);
      if (finalCombined.isNotEmpty) {
        return finalCombined;
      }
      liveResults.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
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

  /// Bir yerin cami/mescid olup olmadığını filtreler, kilise ve havraları eler
  static bool isMosqueCandidate(String name, String? addressOrDisplayName) {
    final combined = '${name.toLowerCase()} ${addressOrDisplayName?.toLowerCase() ?? ''}';

    // Gayrimüslim ibadethaneleri elenir
    const excludeTerms = [
      'kilise', 'kilisesi', 'church', 'sinagog', 'sinagogu', 'synagogue',
      'havra', 'patrikhane', 'metropolit', 'şapel', 'chapel', 'monastery',
      'manastır', 'katedral', 'cathedral'
    ];
    for (final term in excludeTerms) {
      if (combined.contains(term)) return false;
    }

    // İslami ibadethane terimleri
    const includeTerms = [
      'cami', 'camii', 'mescid', 'mescidi', 'mosque', 'masjid', 'namazgâh',
      'namazgah', 'külliye', 'kulliye', 'dergâh', 'dergah', 'tekke', 'ibadethane'
    ];
    for (final term in includeTerms) {
      if (combined.contains(term)) return true;
    }

    // Başlıkta açıkça cami/mescit kelimesi varsa kabul et
    return name.trim().isNotEmpty && !combined.contains('church') && !combined.contains('synagogue');
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

  /// OpenStreetMap Nominatim Bounded Arama Sorgusu (Kesin Sınırlı ve Hızlı)
  Future<List<NearbyMosque>> _fetchFromNominatim(double lat, double lng, double radiusMeters) async {
    // Arama yarıçapını 3.5 km - 5 km arasına sınırla (daha hızlı ve yerel sonuç için)
    final effectiveRadius = math.min(radiusMeters, 5000.0);
    final deltaKm = effectiveRadius / 1000.0;
    final deltaLat = deltaKm / 111.0;
    final cosLat = math.cos(lat * math.pi / 180.0);
    final deltaLng = deltaKm / (111.0 * (cosLat.abs() < 0.001 ? 1.0 : cosLat.abs()));

    final minLat = lat - deltaLat;
    final maxLat = lat + deltaLat;
    final minLng = lng - deltaLng;
    final maxLng = lng + deltaLng;

    final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);
    try {
      // 1. Türkçe odaklı cami sorgusu
      final uriCami = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=cami&limit=40&viewbox=$minLng,$maxLat,$maxLng,$minLat&bounded=1&addressdetails=1',
      );
      final request = await client.getUrl(uriCami);
      request.headers.set('User-Agent', 'BeyanApp/1.0 (contact@beyanapp.com)');
      final response = await request.close().timeout(const Duration(seconds: 6));

      if (response.statusCode == HttpStatus.ok) {
        final responseBody = await response.transform(utf8.decoder).join();
        final list = jsonDecode(responseBody) as List<dynamic>? ?? [];
        final mosques = _parseNominatimResults(list, lat, lng);
        if (mosques.isNotEmpty) return mosques;
      }
    } catch (_) {
    } finally {
      client.close();
    }

    // 2. Yurt dışı veya uluslararası etiketli camiler için (mosque)
    final client2 = HttpClient()..connectionTimeout = const Duration(seconds: 5);
    try {
      final uriMosque = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=mosque&limit=40&viewbox=$minLng,$maxLat,$maxLng,$minLat&bounded=1&addressdetails=1',
      );
      final request = await client2.getUrl(uriMosque);
      request.headers.set('User-Agent', 'BeyanApp/1.0 (contact@beyanapp.com)');
      final response = await request.close().timeout(const Duration(seconds: 6));

      if (response.statusCode == HttpStatus.ok) {
        final responseBody = await response.transform(utf8.decoder).join();
        final list = jsonDecode(responseBody) as List<dynamic>? ?? [];
        final mosques = _parseNominatimResults(list, lat, lng);
        if (mosques.isNotEmpty) return mosques;
      }
    } catch (_) {
    } finally {
      client2.close();
    }

    return [];
  }

  List<NearbyMosque> _parseNominatimResults(List<dynamic> list, double lat, double lng) {
    final results = <NearbyMosque>[];
    final seenIds = <String>{};

    for (final el in list) {
      if (el is! Map<String, dynamic>) continue;
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

      if (!isMosqueCandidate(name, displayName)) continue;

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

  /// Komoot Photon POI API Sorgusu (Ultra-hızlı OSM arama motoru)
  Future<List<NearbyMosque>> _fetchFromPhoton(double lat, double lng, double radiusMeters) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 4);
    try {
      final uri = Uri.parse('https://photon.komoot.io/api/?q=cami&lat=$lat&lon=$lng&limit=30');
      final request = await client.getUrl(uri);
      request.headers.set('User-Agent', 'BeyanApp/1.0 (contact@beyanapp.com)');
      final response = await request.close().timeout(const Duration(seconds: 5));

      if (response.statusCode != HttpStatus.ok) return [];

      final body = await response.transform(utf8.decoder).join();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final features = data['features'] as List<dynamic>? ?? [];
      final results = <NearbyMosque>[];
      final seenIds = <String>{};

      for (final f in features) {
        if (f is! Map<String, dynamic>) continue;
        final geom = f['geometry'] as Map<String, dynamic>?;
        final coords = geom?['coordinates'] as List<dynamic>?;
        if (coords == null || coords.length < 2) continue;

        final mLng = (coords[0] as num).toDouble();
        final mLat = (coords[1] as num).toDouble();
        final props = f['properties'] as Map<String, dynamic>? ?? {};

        final name = (props['name'] as String? ?? 'Cami').trim();
        final street = props['street'] as String?;
        final district = props['district'] as String? ?? props['city'] as String?;
        final address = street != null ? '$street, ${district ?? ''}'.trim() : district;

        if (!isMosqueCandidate(name, address)) continue;

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
      return results;
    } catch (_) {
      return [];
    } finally {
      client.close();
    }
  }

  /// OpenStreetMap Overpass API sorgusu (POST istekli ve ayna sunuculu)
  Future<List<NearbyMosque>> _fetchFromOverpass(double lat, double lng, double radius) async {
    final queryRadius = math.min(radius, 3500.0).round();
    final query = '''
[out:json][timeout:5];
(
  node["amenity"="place_of_worship"]["religion"="muslim"](around:$queryRadius,$lat,$lng);
  way["amenity"="place_of_worship"]["religion"="muslim"](around:$queryRadius,$lat,$lng);
);
out center 35;
''';

    final endpoints = [
      'https://overpass.kumi.systems/api/interpreter',
      'https://overpass-api.de/api/interpreter',
      'https://maps.mail.ru/osm/tools/overpass/api/interpreter',
    ];

    for (final ep in endpoints) {
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 4);
      try {
        final request = await client.postUrl(Uri.parse(ep));
        request.headers.set('User-Agent', 'BeyanApp/1.0 (contact@beyanapp.com)');
        request.headers.set('Content-Type', 'application/x-www-form-urlencoded');
        request.write('data=${Uri.encodeQueryComponent(query)}');

        final response = await request.close().timeout(const Duration(seconds: 5));
        if (response.statusCode != HttpStatus.ok) continue;

        final responseBody = await response.transform(utf8.decoder).join();
        final data = jsonDecode(responseBody) as Map<String, dynamic>;
        final elements = data['elements'] as List<dynamic>? ?? [];
        final result = <NearbyMosque>[];

        for (final el in elements) {
          if (el is! Map<String, dynamic>) continue;
          final tags = el['tags'] as Map<String, dynamic>? ?? {};
          final name = tags['name'] as String? ?? tags['name:tr'] as String? ?? 'Cami';

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
          final bearing = NearbyMosque.calculateBearing(lat, lng, mLat, mLng);
          final street = tags['addr:street'] as String?;
          final district = tags['addr:district'] as String? ?? tags['addr:city'] as String?;
          final address = street != null ? '$street, ${district ?? ''}'.trim() : district;

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

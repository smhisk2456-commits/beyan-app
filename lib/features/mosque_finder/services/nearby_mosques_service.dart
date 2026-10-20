import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';
import '../../../core/utils/app_constants.dart';
import '../models/nearby_mosque_model.dart';

/// Yakındaki Camileri Arama ve Harita Navigasyon Servisi
class NearbyMosquesService {
  static final NearbyMosquesService instance = NearbyMosquesService._internal();
  factory NearbyMosquesService() => instance;
  NearbyMosquesService._internal();

  /// Verilen koordinatlar etrafındaki camileri bulur (Önce Google Places API, sonra hızlı Nominatim API, sonra Overpass, hata halinde yedek zengin veri)
  Future<List<NearbyMosque>> findNearbyMosques({
    required double userLat,
    required double userLng,
    double radiusMeters = 8000,
    String? googleApiKey,
  }) async {
    // 1. Google Places API (Google Cloud'da Places API etkinse doğrudan resmi Google verisi çeker)
    final key = googleApiKey ?? AppConstants.defaultGeminiApiKey;
    if (key.isNotEmpty) {
      try {
        final googleMosques = await _fetchFromGooglePlaces(userLat, userLng, radiusMeters, key);
        if (googleMosques.isNotEmpty) {
          googleMosques.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
          return googleMosques;
        }
      } catch (_) {}
    }

    // 2. OpenStreetMap Nominatim Arama API (Hızlı, güncel ve kesintisiz)
    try {
      final mosques = await _fetchFromNominatim(userLat, userLng, radiusMeters);
      if (mosques.isNotEmpty) {
        mosques.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
        return mosques;
      }
    } catch (_) {}

    // 3. OpenStreetMap Overpass API (Alternatif yedek motor)
    try {
      final mosques = await _fetchFromOverpass(userLat, userLng, radiusMeters);
      if (mosques.isNotEmpty) {
        mosques.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
        return mosques;
      }
    } catch (_) {}

    // 4. Fallback: Çevredeki bilinen camileri filtrele ve mesafeye göre sırala
    final fallbackList = _getCuratedFallbackMosques(userLat, userLng);
    fallbackList.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return fallbackList;
  }

  /// Google Places API (Nearby Search) ile resmi Google cami verilerini alma
  Future<List<NearbyMosque>> _fetchFromGooglePlaces(
    double lat,
    double lng,
    double radiusMeters,
    String apiKey,
  ) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 6);
    try {
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=$radiusMeters&type=mosque&language=tr&key=$apiKey',
      );
      final request = await client.getUrl(uri);
      final response = await request.close().timeout(const Duration(seconds: 7));
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

  /// OpenStreetMap Nominatim Arama Sorgusu
  Future<List<NearbyMosque>> _fetchFromNominatim(double lat, double lng, double radiusMeters) async {
    final deltaKm = radiusMeters / 1000.0;
    final deltaLat = deltaKm / 111.0;
    final cosLat = math.cos(lat * math.pi / 180.0);
    final deltaLng = deltaKm / (111.0 * (cosLat.abs() < 0.001 ? 1.0 : cosLat.abs()));

    final minLat = lat - deltaLat;
    final maxLat = lat + deltaLat;
    final minLng = lng - deltaLng;
    final maxLng = lng + deltaLng;

    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/search?format=json&q=cami&limit=50&viewbox=$minLng,$maxLat,$maxLng,$minLat&bounded=0&addressdetails=1',
    );

    final client = HttpClient()..connectionTimeout = const Duration(seconds: 7);
    try {
      final request = await client.getUrl(uri);
      request.headers.set('User-Agent', 'BeyanApp/1.0 (smhisk2456@gmail.com)');
      final response = await request.close().timeout(const Duration(seconds: 8));

      if (response.statusCode != HttpStatus.ok) return [];

      final responseBody = await response.transform(utf8.decoder).join();
      final list = jsonDecode(responseBody) as List<dynamic>? ?? [];

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
    } finally {
      client.close();
    }
  }

  /// OpenStreetMap Overpass API sorgusu
  Future<List<NearbyMosque>> _fetchFromOverpass(double lat, double lng, double radius) async {
    final query = '''
[out:json][timeout:10];
(
  node["amenity"="place_of_worship"]["religion"="muslim"](around:$radius,$lat,$lng);
  way["amenity"="place_of_worship"]["religion"="muslim"](around:$radius,$lat,$lng);
  relation["amenity"="place_of_worship"]["religion"="muslim"](around:$radius,$lat,$lng);
  node["building"="mosque"](around:$radius,$lat,$lng);
  way["building"="mosque"](around:$radius,$lat,$lng);
);
out center 45;
''';

    final endpoints = [
      'https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(query)}',
      'https://overpass.kumi.systems/api/interpreter?data=${Uri.encodeComponent(query)}',
    ];

    for (final ep in endpoints) {
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 7);
      try {
        final request = await client.getUrl(Uri.parse(ep));
        request.headers.set('User-Agent', 'BeyanApp/1.0 (smhisk2456@gmail.com)');
        final response = await request.close().timeout(const Duration(seconds: 8));

        if (response.statusCode != HttpStatus.ok) {
          continue;
        }

        final responseBody = await response.transform(utf8.decoder).join();
        final data = jsonDecode(responseBody);
        final elements = data['elements'] as List<dynamic>? ?? [];

        final result = <NearbyMosque>[];

      for (final el in elements) {
        final tags = el['tags'] as Map<String, dynamic>? ?? {};
        final name = tags['name'] as String? ?? tags['name:tr'] as String? ?? 'Cami / Mescid';

        double mLat = 0.0;
        double mLng = 0.0;

        if (el['lat'] != null && el['lon'] != null) {
          mLat = (el['lat'] as num).toDouble();
        } else if (el['center'] != null) {
          mLat = (el['center']['lat'] as num).toDouble();
        }

        if (el['lon'] != null) {
          mLng = (el['lon'] as num).toDouble();
        } else if (el['center'] != null) {
          mLng = (el['center']['lon'] as num).toDouble();
        }

        if (mLat == 0.0 || mLng == 0.0) continue;

        final dist = NearbyMosque.calculateDistanceMeters(lat, lng, mLat, mLng);
        final bearing = NearbyMosque.calculateBearing(lat, lng, mLat, mLng);
        final street = tags['addr:street'] as String?;
        final district = tags['addr:district'] as String? ?? tags['addr:city'] as String?;
        final address = street != null ? '$street ${district ?? ''}'.trim() : district;

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

        if (result.isNotEmpty) {
          return result;
        }
      } catch (_) {
        // Hata durumunda bir sonraki aynayı/sunucuyu dene
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

  /// İnternet olmasa dahi çalışan zengin cami veritabanı
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
      {'name': 'Kocatepe Camii', 'lat': 39.9167, 'lng': 32.8608, 'addr': 'Kızılay, Ankara'},
      {'name': 'Hacı Bayram Camii', 'lat': 39.9444, 'lng': 32.8581, 'addr': 'Ulus, Ankara'},
      {'name': 'Ahmet Hamdi Akseki Camii', 'lat': 39.9077, 'lng': 32.7601, 'addr': 'Çankaya, Ankara'},
      {'name': 'İzmir Konak Camii (Yalı Camii)', 'lat': 38.4189, 'lng': 27.1287, 'addr': 'Konak, İzmir'},
      {'name': 'Bursa Ulu Camii', 'lat': 40.1834, 'lng': 29.0620, 'addr': 'Osmangazi, Bursa'},
      {'name': 'Selimiye Camii', 'lat': 41.6781, 'lng': 26.5594, 'addr': 'Merkez, Edirne'},
      {'name': 'Konya Mevlana Mescidi', 'lat': 37.8707, 'lng': 32.5050, 'addr': 'Karatay, Konya'},
      {'name': 'Sabancı Merkez Camii', 'lat': 36.9914, 'lng': 35.3344, 'addr': 'Seyhan, Adana'},
      {'name': 'Trabzon Ayasofya Camii', 'lat': 41.0028, 'lng': 39.6961, 'addr': 'Ortahisar, Trabzon'},
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
      );
    }).toList();
  }
}

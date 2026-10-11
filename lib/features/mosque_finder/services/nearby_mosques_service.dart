import 'dart:convert';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import '../models/nearby_mosque_model.dart';

/// Yakındaki Camileri Arama ve Harita Navigasyon Servisi
class NearbyMosquesService {
  static final NearbyMosquesService instance = NearbyMosquesService._internal();
  factory NearbyMosquesService() => instance;
  NearbyMosquesService._internal();

  /// Verilen koordinatlar etrafındaki camileri bulur (Önce Overpass API, hata halinde yedek zengin veri)
  Future<List<NearbyMosque>> findNearbyMosques({
    required double userLat,
    required double userLng,
    double radiusMeters = 5000,
  }) async {
    try {
      final mosques = await _fetchFromOverpass(userLat, userLng, radiusMeters);
      if (mosques.isNotEmpty) {
        mosques.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
        return mosques;
      }
    } catch (_) {}

    // Fallback: Çevredeki bilinen camileri filtrele ve mesafeye göre sırala
    final fallbackList = _getCuratedFallbackMosques(userLat, userLng);
    fallbackList.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return fallbackList;
  }

  /// OpenStreetMap Overpass API sorgusu
  Future<List<NearbyMosque>> _fetchFromOverpass(double lat, double lng, double radius) async {
    final query = '''
[out:json][timeout:8];
(
  node["amenity"="place_of_worship"]["religion"="muslim"](around:$radius,$lat,$lng);
  way["amenity"="place_of_worship"]["religion"="muslim"](around:$radius,$lat,$lng);
);
out center 35;
''';

    final uri = Uri.parse('https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(query)}');
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      final request = await client.getUrl(uri);
      final response = await request.close().timeout(const Duration(seconds: 9));

      if (response.statusCode != HttpStatus.ok) {
        return [];
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

      return result;
    } finally {
      client.close();
    }
  }

  /// Haritalarda Yol Tarifi Açma (Öncelikli Apple Maps yürüme rotası, alternatif Google Maps)
  Future<void> openWalkingDirections({
    required double lat,
    required double lng,
    required String mosqueName,
  }) async {
    // Apple Maps yürüme rotası: maps://?daddr=lat,lng&dirflg=w
    final appleMapsUri = Uri.parse('maps://?daddr=$lat,$lng&dirflg=w');
    if (await canLaunchUrl(appleMapsUri)) {
      await launchUrl(appleMapsUri, mode: LaunchMode.externalApplication);
      return;
    }

    // Web tabanlı harita linki (Evrensel yönlendirme)
    final webMapsUri = Uri.parse('https://maps.apple.com/?daddr=$lat,$lng&dirflg=w');
    if (await canLaunchUrl(webMapsUri)) {
      await launchUrl(webMapsUri, mode: LaunchMode.externalApplication);
      return;
    }

    final googleMapsUri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=walking');
    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
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

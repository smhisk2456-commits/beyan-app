import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/features/mosque_finder/models/nearby_mosque_model.dart';
import 'package:islamic_app/features/mosque_finder/services/nearby_mosques_service.dart';

void main() {
  group('NearbyMosque Model Tests', () {
    test('formattedDistance formats meters and kilometers accurately', () {
      const mosqueNear = NearbyMosque(
        id: '1',
        name: 'Sultanahmet Camii',
        latitude: 41.0054,
        longitude: 28.9768,
        distanceMeters: 450,
      );
      expect(mosqueNear.formattedDistance, '450 m');

      const mosqueFar = NearbyMosque(
        id: '2',
        name: 'Çamlıca Camii',
        latitude: 41.0344,
        longitude: 29.0681,
        distanceMeters: 8400,
      );
      expect(mosqueFar.formattedDistance, '8.4 km');
    });

    test('estimatedWalkingMinutes calculates reasonable walking time', () {
      const mosque = NearbyMosque(
        id: '1',
        name: 'Test Cami',
        latitude: 41.0,
        longitude: 29.0,
        distanceMeters: 500, // ~6 minutes at 5 km/h
      );
      expect(mosque.estimatedWalkingMinutes, 6);

      const mosqueVeryClose = NearbyMosque(
        id: '2',
        name: 'Yan Mescid',
        latitude: 41.0,
        longitude: 29.0,
        distanceMeters: 30,
      );
      expect(mosqueVeryClose.estimatedWalkingMinutes, 1);
    });

    test('compassDirection returns correct cardinal and ordinal directions', () {
      const northMosque = NearbyMosque(
        id: '1',
        name: 'Kuzey Cami',
        latitude: 41.0,
        longitude: 29.0,
        distanceMeters: 100,
        bearingDegrees: 10,
      );
      expect(northMosque.compassDirection, 'Kuzey (K)');

      const eastMosque = NearbyMosque(
        id: '2',
        name: 'Doğu Cami',
        latitude: 41.0,
        longitude: 29.0,
        distanceMeters: 100,
        bearingDegrees: 90,
      );
      expect(eastMosque.compassDirection, 'Doğu (D)');

      const southMosque = NearbyMosque(
        id: '3',
        name: 'Güney Cami',
        latitude: 41.0,
        longitude: 29.0,
        distanceMeters: 100,
        bearingDegrees: 180,
      );
      expect(southMosque.compassDirection, 'Güney (G)');

      const westMosque = NearbyMosque(
        id: '4',
        name: 'Batı Cami',
        latitude: 41.0,
        longitude: 29.0,
        distanceMeters: 100,
        bearingDegrees: 270,
      );
      expect(westMosque.compassDirection, 'Batı (B)');
    });

    test('calculateDistanceMeters Haversine formula calculation', () {
      // Sultanahmet (41.0054, 28.9768) to Ayasofya (41.0086, 28.9802)
      final distance = NearbyMosque.calculateDistanceMeters(
        41.0054,
        28.9768,
        41.0086,
        28.9802,
      );
      // Roughly ~450 meters
      expect(distance, greaterThan(350));
      expect(distance, lessThan(600));
    });

    test('calculateBearing calculates valid compass angle (0-360)', () {
      final bearing = NearbyMosque.calculateBearing(
        41.0054,
        28.9768,
        41.0086,
        28.9802,
      );
      expect(bearing, greaterThanOrEqualTo(0));
      expect(bearing, lessThan(360));
    });
  });

  group('NearbyMosquesService Tests', () {
    test('isMosqueCandidate identifies mosques and filters out non-Muslim worship places', () {
      expect(NearbyMosquesService.isMosqueCandidate('Osman Ağa Cami', 'Kadıköy'), isTrue);
      expect(NearbyMosquesService.isMosqueCandidate('Süleymaniye Camii', 'Fatih'), isTrue);
      expect(NearbyMosquesService.isMosqueCandidate('Kocatepe Mescidi', 'Ankara'), isTrue);
      expect(NearbyMosquesService.isMosqueCandidate('East London Mosque', 'London'), isTrue);
      expect(NearbyMosquesService.isMosqueCandidate('Al-Haram Masjid', 'Mecca'), isTrue);

      // Non-mosque places should be rejected
      expect(NearbyMosquesService.isMosqueCandidate('Aya Triada Rum Ortodoks Kilisesi', 'Kadıköy'), isFalse);
      expect(NearbyMosquesService.isMosqueCandidate('Hemdat Israel Sinagogu', 'Yeldeğirmeni'), isFalse);
      expect(NearbyMosquesService.isMosqueCandidate('St. Pierre Church', 'Antakya'), isFalse);
      expect(NearbyMosquesService.isMosqueCandidate('Surp Kevork Ermeni Kilisesi', 'Samatya'), isFalse);
    });

    test('NearbyMosque model respects isCuratedFallback property', () {
      const fallbackMosque = NearbyMosque(
        id: '1',
        name: 'Süleymaniye Camii',
        latitude: 41.0162,
        longitude: 28.9644,
        distanceMeters: 1200,
        isCuratedFallback: true,
      );
      expect(fallbackMosque.isCuratedFallback, isTrue);

      const liveMosque = NearbyMosque(
        id: '2',
        name: 'Mahalle Camii',
        latitude: 41.0150,
        longitude: 28.9630,
        distanceMeters: 150,
        isCuratedFallback: false,
      );
      expect(liveMosque.isCuratedFallback, isFalse);
    });

    test('NearbyMosque copyWith, toJson and fromJson serialization works correctly', () {
      const original = NearbyMosque(
        id: 'osm_123',
        name: 'Moda Camii',
        latitude: 40.9850,
        longitude: 29.0270,
        distanceMeters: 250.0,
        address: 'Caferağa, Kadıköy',
        bearingDegrees: 180.0,
        isCuratedFallback: false,
      );

      final updated = original.copyWith(
        distanceMeters: 280.0,
        bearingDegrees: 185.0,
      );
      expect(updated.id, original.id);
      expect(updated.name, original.name);
      expect(updated.distanceMeters, 280.0);
      expect(updated.bearingDegrees, 185.0);

      final json = updated.toJson();
      expect(json['id'], 'osm_123');
      expect(json['dist'], 280.0);

      final restored = NearbyMosque.fromJson(json);
      expect(restored.id, 'osm_123');
      expect(restored.name, 'Moda Camii');
      expect(restored.distanceMeters, 280.0);
      expect(restored.isCuratedFallback, isFalse);
    });

    test('Service returns distance-sorted fallback mosques without network', () async {
      final service = NearbyMosquesService.instance;
      final mosques = await service.findNearbyMosques(
        userLat: 41.0082,
        userLng: 28.9784,
      );

      expect(mosques, isNotEmpty);
      for (int i = 0; i < mosques.length - 1; i++) {
        expect(mosques[i].distanceMeters, lessThanOrEqualTo(mosques[i + 1].distanceMeters));
      }
    });

    test('Peş peşe yenilemelerde (rapid refresh) önbellek mesafeleri anlık koordinata göre doğru günceller', () async {
      final service = NearbyMosquesService.instance;

      // 1. İlk sorgu
      final firstResults = await service.findNearbyMosques(
        userLat: 40.9900,
        userLng: 29.0290,
      );
      expect(firstResults, isNotEmpty);
      final firstClosestDist = firstResults.first.distanceMeters;

      // 2. Kullanıcı sadece 10 metre yürüdüğünde ve anında yenilediğinde
      final secondResults = await service.findNearbyMosques(
        userLat: 40.9901,
        userLng: 29.0291,
      );
      expect(secondResults, isNotEmpty);

      // En yakın caminin mesafesi 4 km'ye zıplamamalı, 10-20 metre civarında sabit ve tutarlı kalmalı!
      final secondClosestDist = secondResults.first.distanceMeters;
      final diff = (secondClosestDist - firstClosestDist).abs();
      expect(diff, lessThan(200), reason: 'Mesafe 4 km zıplamadan sabit kalmalıdır');
    });
  });
}

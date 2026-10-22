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
  });
}

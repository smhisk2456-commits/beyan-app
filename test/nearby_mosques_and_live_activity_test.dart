import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/features/mosque_finder/models/nearby_mosque_model.dart';
import 'package:islamic_app/features/mosque_finder/services/nearby_mosques_service.dart';
import 'package:islamic_app/features/widget_service/services/live_activity_service.dart';

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

  group('LiveActivityService Tests', () {
    test('LiveActivityService singleton instance is accessible', () {
      final service1 = LiveActivityService.instance;
      final service2 = LiveActivityService();
      expect(identical(service1, service2), isTrue);
      expect(service1.isSupported, isA<bool>());
    });
  });
}

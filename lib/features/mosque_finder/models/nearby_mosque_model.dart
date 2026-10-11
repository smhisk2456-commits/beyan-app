import 'dart:math' as math;

/// Yakındaki Cami Modeli
class NearbyMosque {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double distanceMeters;
  final String? address;
  final double bearingDegrees; // Kullanıcıdan camiye olan pusula açısı

  const NearbyMosque({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
    this.address,
    this.bearingDegrees = 0.0,
  });

  /// Formatlı mesafe metni (Örn: "450 m" veya "1.8 km")
  String get formattedDistance {
    if (distanceMeters < 1000) {
      return '${distanceMeters.round()} m';
    } else {
      return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
    }
  }

  /// Tahmini yürüme süresi (ortalama 5 km/s hız ile)
  int get estimatedWalkingMinutes {
    final minutes = (distanceMeters / 83.33).round();
    return minutes < 1 ? 1 : minutes;
  }

  /// Pusula yönü metni (K, KD, D, GD, G, GB, B, KB)
  String get compassDirection {
    final d = (bearingDegrees + 360) % 360;
    if (d >= 337.5 || d < 22.5) return 'Kuzey (K)';
    if (d >= 22.5 && d < 67.5) return 'Kuzeydoğu (KD)';
    if (d >= 67.5 && d < 112.5) return 'Doğu (D)';
    if (d >= 112.5 && d < 157.5) return 'Güneydoğu (GD)';
    if (d >= 157.5 && d < 202.5) return 'Güney (G)';
    if (d >= 202.5 && d < 247.5) return 'Güneybatı (GB)';
    if (d >= 247.5 && d < 292.5) return 'Batı (B)';
    return 'Kuzeybatı (KB)';
  }

  /// Haversine formülü ile iki koordinat arası metre hesabı
  static double calculateDistanceMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = 6371000.0; // Dünya yarıçapı (metre)
    final dLat = (lat2 - lat1) * math.pi / 180.0;
    final dLon = (lon2 - lon1) * math.pi / 180.0;

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180.0) *
            math.cos(lat2 * math.pi / 180.0) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  /// İki nokta arası pusula açısı hesabı (Bearing)
  static double calculateBearing(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final phi1 = lat1 * math.pi / 180.0;
    final phi2 = lat2 * math.pi / 180.0;
    final deltaLambda = (lon2 - lon1) * math.pi / 180.0;

    final y = math.sin(deltaLambda) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);

    final theta = math.atan2(y, x);
    return (theta * 180.0 / math.pi + 360.0) % 360.0;
  }
}

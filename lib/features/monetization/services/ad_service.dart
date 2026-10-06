import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Google AdMob Reklam Yönetim Servisi
class AdService {
  static final AdService instance = AdService._internal();
  factory AdService() => instance;
  AdService._internal();

  bool _isInitialized = false;

  /// AdMob SDK'sını başlatır.
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('AdMob SDK başarıyla başlatıldı.');
    } catch (e) {
      debugPrint('AdMob başlatma hatası: $e');
    }
  }

  static const String iosTestBannerId = 'ca-app-pub-3940256099942544/2934735716';
  static const String androidTestBannerId = 'ca-app-pub-3940256099942544/6300978111';

  /// Resmi Google Test Banner Ad Unit ID'si
  String get testBannerAdUnitId {
    if (Platform.isAndroid) return androidTestBannerId;
    if (Platform.isIOS) return iosTestBannerId;
    return '';
  }

  /// Platforma göre Banner Reklam Birimi Kimliği (Ad Unit ID).
  /// Not: Geliştirme ve test aşamasında Google'ın resmi test kimlikleri kullanılır.
  String get bannerAdUnitId {
    if (kDebugMode) {
      return testBannerAdUnitId;
    }

    // Canlı Prodüksiyon ID'leri
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-1904469452707859/3170946984';
    }
    return '';
  }
}

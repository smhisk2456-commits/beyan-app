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

  /// Platforma göre Banner Reklam Birimi Kimliği (Ad Unit ID).
  /// Not: Geliştirme ve test aşamasında Google'ın resmi test kimlikleri kullanılır.
  String get bannerAdUnitId {
    if (kDebugMode) {
      // Google Resmi Test Banner ID'leri
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2934735716';
      }
    }

    // Canlı Prodüksiyon ID'leri (Kullanıcı kendi AdMob hesabını bağladığında burayı güncelleyebilir)
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    return '';
  }
}

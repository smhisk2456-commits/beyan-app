import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Google AdMob Reklam Yönetim Servisi
/// Premium aboneler için %100 reklamsız deneyim sağlar.
class AdService {
  static final AdService instance = AdService._internal();
  factory AdService() => instance;
  AdService._internal();

  bool _isInitialized = false;

  /// v1.0 sürümünde reklamlar tamamen kapalıdır (reklamsız manevi deneyim).
  static const bool kAdsEnabled = false;

  /// Kullanıcının reklamsız deneyim hakkı var mı?
  /// Premium üyelik sahibi olan kullanıcılara hiçbir reklam gösterilmez.
  bool isAdFree = false;

  /// Premium durumuna göre reklamsız deneyimi günceller.
  void updateAdFreeStatus(bool premium) {
    isAdFree = premium;
  }

  /// AdMob SDK'sını başlatır ve İslami / Aile dostu filtreleri uygular.
  /// Eğer kullanıcı Premium aboneyse veya reklamlar devre dışıysa AdMob SDK başlatılmaz.
  Future<void> initialize() async {
    if (_isInitialized || isAdFree || !kAdsEnabled) {
      debugPrint('[AdService] Reklamlar kapalı: %100 Reklamsız Deneyim aktif, AdMob SDK başlatılmadı.');
      return;
    }
    try {
      // 🛡️ Manevi Koruma & Aile Güvenliği Filtreleri:
      // Google AdMob seviyesinde yetişkin (+18), kumar, flört vb. hassas kategorileri tamamen engeller.
      final configuration = RequestConfiguration(
        maxAdContentRating: MaxAdContentRating.g, // "G" = General Audiences (Yalnızca Genel İzleyici / Çocuk & Aile)
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
        tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.yes,
      );
      await MobileAds.instance.updateRequestConfiguration(configuration);

      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('AdMob SDK başarıyla başlatıldı (Manevi & Aile Dostu Filtre: G Seviyesi Aktif).');
    } catch (e) {
      debugPrint('AdMob başlatma hatası: $e');
    }
  }

  static const String iosTestBannerId = 'ca-app-pub-3940256099942544/2934735716';
  static const String androidTestBannerId = 'ca-app-pub-3940256099942544/6300978111';

  /// Resmi Google Test Banner Ad Unit ID'si
  String get testBannerAdUnitId {
    if (isAdFree) return '';
    if (Platform.isAndroid) return androidTestBannerId;
    if (Platform.isIOS) return iosTestBannerId;
    return '';
  }

  /// Platforma göre Banner Reklam Birimi Kimliği (Ad Unit ID).
  /// Not: Geliştirme ve test aşamasında Google'ın resmi test kimlikleri kullanılır.
  String get bannerAdUnitId {
    if (isAdFree) return '';
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

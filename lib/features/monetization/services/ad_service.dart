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

  /// Beyân reklam sistemi (Manevi & Aile Dostu G Seviyesi)
  static const bool kAdsEnabled = true;

  /// Kullanıcının reklamsız deneyim hakkı var mı?
  /// Premium üyelik sahibi olan kullanıcılara hiçbir reklam gösterilmez.
  bool _isPremium = false;
  DateTime? _temporaryAdFreeUntil;

  bool get isAdFree {
    if (_isPremium) return true;
    if (_temporaryAdFreeUntil != null && DateTime.now().isBefore(_temporaryAdFreeUntil!)) {
      return true;
    }
    return false;
  }

  /// Premium durumuna göre reklamsız deneyimi günceller.
  void updateAdFreeStatus(bool premium) {
    _isPremium = premium;
    if (!premium && !_isInitialized && kAdsEnabled) {
      initialize();
    }
  }

  /// Kullanıcıya geçici reklamsız kullanım hakkı verir (Örn: Ödüllü video izleme karşılığı)
  void grantTemporaryAdFree(Duration duration) {
    _temporaryAdFreeUntil = DateTime.now().add(duration);
    debugPrint('Geçici reklamsız kullanım süresi tanımlandı: $_temporaryAdFreeUntil');
  }

  /// AdMob SDK'sını başlatır ve İslami / Aile dostu filtreleri uygular.
  Future<void> initialize() async {
    if (_isInitialized || !kAdsEnabled) {
      return;
    }

    if (!Platform.isAndroid && !Platform.isIOS) {
      _isInitialized = true;
      return;
    }

    try {
      // 🛡️ Manevi Koruma & Aile Güvenliği Filtreleri:
      // Google AdMob seviyesinde yetişkin (+18), kumar, flört vb. hassas kategorileri tamamen engeller.
      final configuration = RequestConfiguration(
        maxAdContentRating: MaxAdContentRating.g, // "G" = General Audiences (Yalnızca Genel İzleyici / Çocuk & Aile)
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.no,
        tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.no,
      );
      await MobileAds.instance.updateRequestConfiguration(configuration);

      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('AdMob SDK başarıyla başlatıldı (Manevi & Aile Dostu Filtre: G Seviyesi Aktif).');

      // Ödüllü geçiş reklamını arka planda önceden yükle
      loadRewardedInterstitialAd();
    } catch (e) {
      debugPrint('AdMob başlatma hatası: $e');
    }
  }

  // ── BANNER REKLAM KİMLİKLERİ ───────────────────────────────────────────────
  static const String iosTestBannerId = 'ca-app-pub-3940256099942544/2934735716';
  static const String androidTestBannerId = 'ca-app-pub-3940256099942544/6300978111';

  /// Resmi Google Test Banner Ad Unit ID'si
  String get testBannerAdUnitId {
    if (Platform.isAndroid) return androidTestBannerId;
    if (Platform.isIOS) return iosTestBannerId;
    return '';
  }

  /// Platforma göre Banner Reklam Birimi Kimliği (Ad Unit ID).
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

  // ── YEREL GELİŞMİŞ (NATIVE ADVANCED) REKLAM KİMLİKLERİ ───────────────────────
  static const String iosTestNativeId = 'ca-app-pub-3940256099942544/3986624511';
  static const String androidTestNativeId = 'ca-app-pub-3940256099942544/2247696110';
  static const String iosNativeAdUnitId = 'ca-app-pub-1904469452707859/3374454909';

  /// Resmi Google Test Yerel Reklam Ad Unit ID'si
  String get testNativeAdUnitId {
    if (Platform.isAndroid) return androidTestNativeId;
    if (Platform.isIOS) return iosTestNativeId;
    return '';
  }

  /// Platforma göre Yerel Gelişmiş Reklam Birimi Kimliği (Ad Unit ID).
  String get nativeAdUnitId {
    if (kDebugMode) {
      return testNativeAdUnitId;
    }

    // Canlı Prodüksiyon ID'leri
    if (Platform.isAndroid) {
      return androidTestNativeId;
    } else if (Platform.isIOS) {
      return iosNativeAdUnitId;
    }
    return '';
  }

  // ── ÖDÜLLÜ GEÇİŞ (REWARDED INTERSTITIAL) REKLAM KİMLİKLERİ ──────────────────
  static const String iosTestRewardedInterstitialId = 'ca-app-pub-3940256099942544/6978759866';
  static const String androidTestRewardedInterstitialId = 'ca-app-pub-3940256099942544/5354046379';
  static const String iosRewardedInterstitialId = 'ca-app-pub-1904469452707859/4068589472';

  /// Resmi Google Test Ödüllü Geçiş Ad Unit ID'si
  String get testRewardedInterstitialAdUnitId {
    if (Platform.isAndroid) return androidTestRewardedInterstitialId;
    if (Platform.isIOS) return iosTestRewardedInterstitialId;
    return '';
  }

  /// Platforma göre Ödüllü Geçiş Reklam Birimi Kimliği (Ad Unit ID).
  String get rewardedInterstitialAdUnitId {
    if (kDebugMode) {
      return testRewardedInterstitialAdUnitId;
    }

    // Canlı Prodüksiyon ID'leri
    if (Platform.isAndroid) {
      return androidTestRewardedInterstitialId;
    } else if (Platform.isIOS) {
      return iosRewardedInterstitialId;
    }
    return '';
  }

  // ── ÖDÜLLÜ GEÇİŞ YÖNETİMİ ──────────────────────────────────────────────────
  RewardedInterstitialAd? _rewardedInterstitialAd;
  bool _isRewardedInterstitialLoading = false;

  bool get isRewardedInterstitialLoaded => _rewardedInterstitialAd != null;

  /// Ödüllü geçiş reklamını arka planda yükler.
  void loadRewardedInterstitialAd() {
    if (isAdFree || _isRewardedInterstitialLoading || _rewardedInterstitialAd != null) {
      return;
    }
    if (!Platform.isAndroid && !Platform.isIOS) {
      return;
    }
    _isRewardedInterstitialLoading = true;
    RewardedInterstitialAd.load(
      adUnitId: rewardedInterstitialAdUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (RewardedInterstitialAd ad) {
          debugPrint('Ödüllü geçiş reklamı başarıyla yüklendi.');
          _rewardedInterstitialAd = ad;
          _isRewardedInterstitialLoading = false;

          _rewardedInterstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedInterstitialAd = null;
              loadRewardedInterstitialAd(); // Bir sonraki kullanım için ön yükleme yap
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('Ödüllü geçiş reklamı gösterilemedi: $error');
              ad.dispose();
              _rewardedInterstitialAd = null;
              loadRewardedInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('Ödüllü geçiş reklamı yükleme hatası: $error');
          _rewardedInterstitialAd = null;
          _isRewardedInterstitialLoading = false;
        },
      ),
    );
  }

  /// Ödüllü geçiş reklamını gösterir. Kullanıcı izlemeyi tamamlarsa [onUserEarnedReward] tetiklenir.
  Future<bool> showRewardedInterstitialAd({
    required VoidCallback onUserEarnedReward,
    VoidCallback? onAdDismissed,
  }) async {
    if (isAdFree) {
      onUserEarnedReward();
      return true;
    }

    if (_rewardedInterstitialAd != null) {
      await _rewardedInterstitialAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          debugPrint('Kullanıcı ödülü kazandı: ${reward.amount} ${reward.type}');
          onUserEarnedReward();
        },
      );
      return true;
    } else {
      loadRewardedInterstitialAd();
      return false;
    }
  }
}

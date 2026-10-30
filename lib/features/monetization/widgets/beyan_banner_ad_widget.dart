import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../providers/premium_provider.dart';
import '../services/ad_service.dart';

/// Şık ve Manevi Arayüze Uygun Koyu Renkli Banner Reklam Panosu
/// Premium kullanıcıda veya reklam kapalıyken otomatik sıfır yer kaplar.
class BeyanBannerAdWidget extends ConsumerStatefulWidget {
  const BeyanBannerAdWidget({super.key});

  @override
  ConsumerState<BeyanBannerAdWidget> createState() => _BeyanBannerAdWidgetState();
}

class _BeyanBannerAdWidgetState extends ConsumerState<BeyanBannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndLoad();
    });
  }

  void _checkAndLoad() {
    final isPremium = ref.read(premiumProvider).isPremium;
    if (isPremium || !AdService.kAdsEnabled) {
      _cleanAd();
      return;
    }
    if (_bannerAd == null && !_isLoading) {
      _loadAd(isFallback: false);
    }
  }

  void _cleanAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    if (mounted && (_isLoaded || _isLoading)) {
      setState(() {
        _isLoaded = false;
        _isLoading = false;
      });
    }
  }

  void _loadAd({bool isFallback = false}) {
    final isPremium = ref.read(premiumProvider).isPremium;
    if (isPremium || !AdService.kAdsEnabled) return;

    final adUnitId = isFallback
        ? AdService.instance.testBannerAdUnitId
        : AdService.instance.bannerAdUnitId;

    if (adUnitId.isEmpty) return;

    _isLoading = true;
    _bannerAd?.dispose();
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('BeyanBannerAdWidget başarıyla yüklendi (fallback: $isFallback).');
          if (mounted) {
            setState(() {
              _isLoaded = true;
              _isLoading = false;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BeyanBannerAdWidget yüklenemedi (fallback: $isFallback): $error');
          ad.dispose();
          _bannerAd = null;
          if (mounted) {
            if (!isFallback) {
              // Canlı reklam birimi TestFlight veya bölgede no-fill verirse
              // anında resmi Google test reklamına geçerek alanın dolu kalmasını sağla:
              _loadAd(isFallback: true);
            } else {
              setState(() {
                _isLoaded = false;
                _isLoading = false;
              });
            }
          }
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Premium durumu değiştikçe (örneğin Ücretsiz Moda geçildiğinde) anında tepki ver
    ref.listen<bool>(premiumProvider.select((s) => s.isPremium), (prev, isPrem) {
      if (isPrem) {
        _cleanAd();
      } else {
        _checkAndLoad();
      }
    });

    final isPremium = ref.watch(premiumProvider).isPremium;
    if (isPremium || !_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    final effectivePalette = ref.watch(effectivePaletteProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = effectivePalette.accentGold;

    final bgColor = isDark
        ? (effectivePalette == AppThemePalette.oledBlack
            ? const Color(0xFF000000)
            : effectivePalette.darkSurface)
        : Colors.white;

    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(top: 2, bottom: 4),
      padding: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(
            color: gold.withValues(alpha: 0.25),
            width: 0.8,
          ),
          bottom: BorderSide(
            color: gold.withValues(alpha: 0.25),
            width: 0.8,
          ),
        ),
      ),
      child: SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}

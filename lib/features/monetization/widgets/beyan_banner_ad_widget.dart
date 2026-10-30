import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../core/theme/beyan_colors.dart';
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

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final isPremium = ref.read(premiumProvider).isPremium;
    if (isPremium || !AdService.kAdsEnabled) return;

    final adUnitId = AdService.instance.bannerAdUnitId;
    if (adUnitId.isEmpty) return;

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() => _isLoaded = true);
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) {
            setState(() {
              _bannerAd = null;
              _isLoaded = false;
            });
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
    final isPremium = ref.watch(premiumProvider).isPremium;
    if (isPremium || !_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? BeyanColors.tone(0xFF03221D) : BeyanColors.tone(0xFFF3F7F5),
        border: Border(
          top: BorderSide(
            color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.2),
            width: 0.8,
          ),
          bottom: BorderSide(
            color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.2),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../providers/premium_provider.dart';
import '../services/ad_service.dart';

/// Saygı ve huzur odaklı alt Banner Reklam Widget'ı.
///
/// Eğer kullanıcı Premium aboneyse veya reklam yüklenemezse hiçbir alan kaplamadan gizlenir (`SizedBox.shrink()`).
class BannerAdWidget extends ConsumerStatefulWidget {
  const BannerAdWidget({super.key});

  @override
  ConsumerState<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends ConsumerState<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _attemptedTestFallback = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd({bool isFallback = false}) {
    final isPremium = ref.read(premiumProvider).isPremium;
    if (isPremium) return;

    final unitId = isFallback
        ? AdService.instance.testBannerAdUnitId
        : AdService.instance.bannerAdUnitId;

    if (unitId.isEmpty) return;

    _bannerAd = BannerAd(
      adUnitId: unitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() => _isLoaded = true);
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner reklam yüklenemedi (fallback: $isFallback): $error');
          ad.dispose();
          if (mounted) {
            // Eğer canlı reklam henüz onaylanmadıysa veya no-fill (kod 3) verdiyse,
            // uygulamanın test edilmesi için resmi test banner'ına geri düş
            if (!isFallback && !_attemptedTestFallback) {
              _attemptedTestFallback = true;
              debugPrint('AdMob: Canlı reklam doluluk/onay beklemesinde. Test reklam birimine geçiliyor...');
              _loadAd(isFallback: true);
              return;
            }

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

    // Premium ise veya henüz yüklenmediyse yer kaplamaz
    if (isPremium || !_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF071F1B) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Küçük, kibar etiket
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                'REKLAM',
                style: TextStyle(
                  fontSize: 8,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white38 : Colors.grey.shade500,
                ),
              ),
            ),
            SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
          ],
        ),
      ),
    );
  }
}

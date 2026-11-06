import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../core/theme/beyan_colors.dart';
import '../providers/premium_provider.dart';
import '../services/ad_service.dart';

/// Beyân Arayüzüne Tam Uyumlu Yerel Gelişmiş (Native Advanced) Reklam Kartı
/// Zümrüt yeşili, altın sarısı ve buzlu cam paletiyle liste akışında organik durur.
/// Premium kullanıcılarda sıfır piksel yer kaplar.
class BeyanNativeAdCard extends ConsumerStatefulWidget {
  /// true ise kompakt liste öğesi boyutu (96px), false ise zengin kart boyutu (340px)
  final bool isSmall;
  final EdgeInsetsGeometry? margin;

  const BeyanNativeAdCard({
    super.key,
    this.isSmall = false,
    this.margin,
  });

  @override
  ConsumerState<BeyanNativeAdCard> createState() => _BeyanNativeAdCardState();
}

class _BeyanNativeAdCardState extends ConsumerState<BeyanNativeAdCard> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;
  bool _isLoading = false;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNativeAd();
    });
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _retryTimer = null;
    _nativeAd?.dispose();
    _nativeAd = null;
    super.dispose();
  }

  void _loadNativeAd({bool isFallback = false}) {
    if (!mounted) return;
    final isPremium = ref.read(premiumProvider).isPremium;
    if (isPremium || !AdService.kAdsEnabled || AdService.instance.isAdFree) {
      return;
    }

    if (!Platform.isAndroid && !Platform.isIOS) {
      return;
    }

    if (_nativeAd != null || _isLoading) return;
    _isLoading = true;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final adUnitId = (isFallback || kDebugMode)
        ? AdService.instance.testNativeAdUnitId
        : AdService.instance.nativeAdUnitId;

    if (adUnitId.isEmpty) {
      _isLoading = false;
      return;
    }

    _nativeAd = NativeAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: widget.isSmall ? TemplateType.small : TemplateType.medium,
        mainBackgroundColor: isDark ? const Color(0xFF022B24) : Colors.white,
        cornerRadius: 16.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: const Color(0xFF01201D),
          backgroundColor: const Color(0xFFFFDF7A),
          style: NativeTemplateFontStyle.bold,
          size: 13.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: isDark ? Colors.white : const Color(0xFF1B2B28),
          style: NativeTemplateFontStyle.bold,
          size: 14.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: isDark ? Colors.white70 : Colors.black87,
          size: 12.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: isDark ? Colors.white60 : Colors.black54,
          size: 11.0,
        ),
      ),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          debugPrint('BeyanNativeAdCard başarıyla yüklendi (isFallback: $isFallback).');
          if (mounted) {
            setState(() {
              _isLoaded = true;
              _isLoading = false;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BeyanNativeAdCard yükleme hatası (isFallback: $isFallback): $error');
          ad.dispose();
          _nativeAd = null;
          if (mounted) {
            setState(() {
              _isLoaded = false;
              _isLoading = false;
            });

            // Canlı ID AdMob'da yeni oluşturulduğunda ilk birkaç saat No-Fill verebilir.
            // Bu durumda test ID ile kartın görünürlüğünü garantiye al.
            if (!isFallback) {
              _loadNativeAd(isFallback: true);
            }
          }
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(premiumProvider).isPremium;
    if (isPremium || AdService.instance.isAdFree || !_isLoaded || _nativeAd == null) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final height = widget.isSmall ? 96.0 : 340.0;

    return Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: height,
      decoration: BoxDecoration(
        color: isDark ? BeyanColors.tone(0xFF022B24) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.25)
              : BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.25),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: AdWidget(ad: _nativeAd!),
    );
  }
}

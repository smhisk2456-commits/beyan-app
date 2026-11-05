import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// App Store / Google Play Uygulama İçi Puanlama Servisi
class AppReviewService {
  AppReviewService._();
  static final AppReviewService instance = AppReviewService._();

  static const String _appStoreId = '6820956134';
  static const String _reviewRequestCountKey = 'app_review_prompt_count';
  static const String _lastReviewRequestKey = 'app_review_last_timestamp';
  static const String _appOpenCountKey = 'app_launch_count';

  final InAppReview _inAppReview = InAppReview.instance;

  /// Kullanıcı uygulamayı her açtığında sayaç artırılır
  Future<void> recordAppOpen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt(_appOpenCountKey) ?? 0;
      await prefs.setInt(_appOpenCountKey, current + 1);
    } catch (e) {
      debugPrint('[AppReviewService] recordAppOpen error: $e');
    }
  }

  /// Ayarlardan veya butondan doğrudan tetiklenen puanlama:
  /// Önce Apple'ın uygulama içi yerel puanlama penceresini (SKStoreReviewController) açmayı dener.
  /// Mümkün değilse veya hata verirse doğrudan App Store inceleme sayfasına yönlendirir.
  Future<void> requestReviewOrOpenStore({bool forceStore = false}) async {
    try {
      if (!forceStore && await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
        return;
      }
    } catch (e) {
      debugPrint('[AppReviewService] requestReview error: $e');
    }

    // Yedek senaryo: Doğrudan App Store ürün sayfasındaki yorum yazma ekranını aç
    try {
      final directStoreUri = Uri.parse(
        'https://apps.apple.com/app/id$_appStoreId?action=write-review',
      );
      if (await canLaunchUrl(directStoreUri)) {
        await launchUrl(directStoreUri, mode: LaunchMode.externalApplication);
      } else {
        await _inAppReview.openStoreListing(appStoreId: _appStoreId);
      }
    } catch (e) {
      debugPrint('[AppReviewService] openStoreListing fallback error: $e');
    }
  }

  /// Uygun manevi anlarda (ör. 3 günlük ibadet serisi veya günün tüm namazları kılındığında)
  /// kullanıcıyı rahatsız etmeden yerel puanlama penceresini gösterir.
  Future<bool> requestReviewIfAppropriate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final promptCount = prefs.getInt(_reviewRequestCountKey) ?? 0;
      final lastPrompt = prefs.getInt(_lastReviewRequestKey) ?? 0;
      final openCount = prefs.getInt(_appOpenCountKey) ?? 0;

      // Kullanıcı en az 3 kez uygulamayı açmış olmalı
      if (openCount < 3) return false;

      // Yılda en fazla 3 kez gösterilir (Apple SKStoreReviewController kuralı)
      if (promptCount >= 3) return false;

      // İki istek arasında en az 7 gün geçmiş olmalı
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - lastPrompt < const Duration(days: 7).inMilliseconds) {
        return false;
      }

      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
        await prefs.setInt(_reviewRequestCountKey, promptCount + 1);
        await prefs.setInt(_lastReviewRequestKey, now);
        return true;
      }
    } catch (e) {
      debugPrint('[AppReviewService] requestReviewIfAppropriate error: $e');
    }
    return false;
  }
}

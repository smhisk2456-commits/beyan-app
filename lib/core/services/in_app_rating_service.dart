import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// App Store / Google Play Akıllı Puanlama ve Değerlendirme Yöneticisi
class InAppRatingService {
  static final InAppRatingService instance = InAppRatingService._internal();
  factory InAppRatingService() => instance;
  InAppRatingService._internal();

  static const String _keyCompletedDhikrCount = 'rating_dhikr_completed_count';
  static const String _keyHasRated = 'rating_user_has_rated';
  static const String _appStoreUrl = 'https://apps.apple.com/app/id6820956134?action=write-review';

  /// Kullanıcı zikir veya tesbihat bitirdiğinde çağrılır
  Future<void> onDhikrCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_keyHasRated) ?? false) return;

      int count = (prefs.getInt(_keyCompletedDhikrCount) ?? 0) + 1;
      await prefs.setInt(_keyCompletedDhikrCount, count);

      // Kullanıcı 3 kez zikir tamamlayıp mutlu olduğunda yönlendir
      if (count == 3) {
        debugPrint('[RatingService] 3. zikir tamamlandı, değerlendirme eşiğine ulaşıldı.');
      }
    } catch (_) {}
  }

  /// App Store Değerlendirme Sayfasını doğrudan açar
  Future<void> openAppStoreReview() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyHasRated, true);

      final uri = Uri.parse(_appStoreUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('[RatingService] Store açma hatası: $e');
    }
  }
}

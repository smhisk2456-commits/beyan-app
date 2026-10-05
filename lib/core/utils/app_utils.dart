import 'package:intl/intl.dart';

/// Tarih/saat formatlama ve genel yardımcı fonksiyonlar.
abstract class AppUtils {
  /// Zamanı "HH:mm" formatında döner (ör: 05:30)
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  /// Tarihi Türkçe formatta döner (ör: 29 Eylül 2026, Salı)
  static String formatDateTurkish(DateTime dateTime) {
    return DateFormat('d MMMM yyyy, EEEE', 'tr_TR').format(dateTime);
  }

  /// İki zaman arasındaki farkı "Xsa Ydak" formatında döner
  static String formatDuration(Duration duration) {
    if (duration.isNegative) return '00:00';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}s ${minutes.toString().padLeft(2, '0')}dk';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Kalan süreyi hesaplar (hedef saat - şu an)
  static Duration timeUntil(DateTime target) {
    final now = DateTime.now();
    if (target.isBefore(now)) return Duration.zero;
    return target.difference(now);
  }
}

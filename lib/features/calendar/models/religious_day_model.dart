/// Beyân - Dini Günler ve Kandiller Modeli
/// Diyanet İşleri Başkanlığı takvimine tam uyumlu dini günler.
class ReligiousDay {
  final String id;
  final String title;
  final String hijriDate;
  final DateTime gregorianDate;
  final String description;
  final bool isMajor; // Kandil veya Bayram mı

  const ReligiousDay({
    required this.id,
    required this.title,
    required this.hijriDate,
    required this.gregorianDate,
    required this.description,
    this.isMajor = true,
  });

  /// Kalan gün sayısı
  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(gregorianDate.year, gregorianDate.month, gregorianDate.day);
    return target.difference(today).inDays;
  }

  /// Geçmiş gün mü
  bool get isPast => daysRemaining < 0;

  /// Bugün mü
  bool get isToday => daysRemaining == 0;
}

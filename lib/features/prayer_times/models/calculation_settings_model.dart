import 'package:adhan/adhan.dart';

enum PrayerCalculationMethod {
  diyanet('Diyanet İşleri Başkanlığı (Türkiye)', 'Diyanet (Turkey)', 'رئاسة الشؤون الدينية التركية'),
  mwl('Dünya İslam Birliği (MWL)', 'Muslim World League', 'رابطة العالم الإسلامي'),
  isna('ISNA (Kuzey Amerika)', 'ISNA (North America)', 'الجمعية الإسلامية لأمريكا الشمالية'),
  ummAlQura('Ümmü\'l-Kurâ (Mekke-i Mükerreme)', 'Umm al-Qura (Makkah)', 'جامعة أم القرى بمكة المكرمة'),
  egyptian('Mısır Genel Heyeti (Egyptian)', 'Egyptian General Authority', 'الهيئة المصرية العامة للمساحة'),
  karachi('Karaçi İslam İlimleri (Karachi)', 'University of Islamic Sciences, Karachi', 'جامعة العلوم الإسلامية بكراتشي');

  final String trName;
  final String enName;
  final String arName;

  const PrayerCalculationMethod(this.trName, this.enName, this.arName);

  CalculationParameters getAdhanParameters() {
    switch (this) {
      case PrayerCalculationMethod.diyanet:
        final p = CalculationMethod.turkey.getParameters();
        p.madhab = Madhab.hanafi;
        return p;
      case PrayerCalculationMethod.mwl:
        final p = CalculationMethod.muslim_world_league.getParameters();
        p.madhab = Madhab.hanafi;
        return p;
      case PrayerCalculationMethod.isna:
        final p = CalculationMethod.north_america.getParameters();
        p.madhab = Madhab.hanafi;
        return p;
      case PrayerCalculationMethod.ummAlQura:
        final p = CalculationMethod.umm_al_qura.getParameters();
        p.madhab = Madhab.hanafi;
        return p;
      case PrayerCalculationMethod.egyptian:
        final p = CalculationMethod.egyptian.getParameters();
        p.madhab = Madhab.hanafi;
        return p;
      case PrayerCalculationMethod.karachi:
        final p = CalculationMethod.karachi.getParameters();
        p.madhab = Madhab.hanafi;
        return p;
    }
  }
}

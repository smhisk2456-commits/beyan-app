import '../../../core/localization/app_strings.dart';

/// Abdest türü
enum WuduType {
  /// Namaz Abdesti (Küçük Hükmî Temizlik)
  namaz,

  /// Gusül Abdesti (Boy Abdesti - Büyük Hükmî Temizlik)
  ghusl,

  /// Teyemmüm Abdesti (Toprak ile Manevi Temizlik)
  tayammum,

  /// Abdesti Bozan & Bozmayan Durumlar
  nullifiers,
}

/// Abdest rehberi adım modeli
class WuduStep {
  final int stepNumber;
  final String title;
  final String description;
  final bool isFard; // Farz mı, Sünnet mi?
  final String? arabicDua;
  final String? transliteration;
  final String? duaMeaning;
  final String? tip;

  const WuduStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    this.isFard = false,
    this.arabicDua,
    this.transliteration,
    this.duaMeaning,
    this.tip,
  });
}

/// Diyanet İşleri Başkanlığı ve Ehl-i Sünnet ölçülerine göre doğrulanmış Abdest Rehberi
class WuduGuideData {
  WuduGuideData._();

  /// Namaz Abdestinin 8 Adımı (Farzlar ve Sünnetler)
  static List<WuduStep> getNamazWuduSteps(AppLanguage lang) {
    return [
      const WuduStep(
        stepNumber: 1,
        title: 'Niyet ve Elleri Yıkamak',
        description: 'Eûzü-Besmele çekilerek "Niyet ettim Allah rızası için abdest almaya" diye kalpten niyet edilir. Eller bileklere kadar parmak araları hilallenerek üç defa güzelce yıkanır.',
        isFard: false,
        arabicDua: 'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّح۪يمِ',
        transliteration: 'Bismillâhirrahmânirrahîm.',
        duaMeaning: 'Rahmân ve Rahîm olan Allah\'ın adıyla.',
        tip: 'Varsa parmaktaki yüzük oynatılarak altına su geçmesi sağlanır.',
      ),
      const WuduStep(
        stepNumber: 2,
        title: 'Ağza Su Vermek (Mazmaza)',
        description: 'Sağ avuçla ağza üç defa bolca su alınıp ağız içi çalkalanır ve tükürülür. Varsa misvak veya parmakla dişler temizlenir.',
        isFard: false,
        tip: 'Oruçlu olunmadığında suyun boğaza kadar ulaşmasına (mübalağa) özen gösterilir.',
      ),
      const WuduStep(
        stepNumber: 3,
        title: 'Burna Su Çekmek (İstinşak)',
        description: 'Sağ avuçla burna üç defa su çekilir ve sol elle sümkürülerek burun içi iyice temizlenir.',
        isFard: false,
        tip: 'Suyu burna çekerken genzi yakmayacak derecede çekmek sünnettir.',
      ),
      const WuduStep(
        stepNumber: 4,
        title: 'Yüzü Yıkamak (1. FARZ)',
        description: 'Alında saçların bittiği yerden çene altına ve bir kulak memesinden diğer kulak memesine kadar yüzün tamamı üç defa yıkanır.',
        isFard: true,
        tip: 'Yüzde kuru iğne ucu yer kalmamalıdır. Sakal gür ise altı ıslatılıp hilallenir.',
      ),
      const WuduStep(
        stepNumber: 5,
        title: 'Kolları Dirseklerle Yıkamak (2. FARZ)',
        description: 'Önce sağ kol, parmak uçlarından dirseğin biraz yukarısına kadar üç defa yıkanır. Ardından aynı şekilde sol kol dirsekle birlikte yıkanır.',
        isFard: true,
        tip: 'Dirsek kemiklerinin arkasının tam ıslandığından emin olunmalıdır.',
      ),
      const WuduStep(
        stepNumber: 6,
        title: 'Başı Mesh Etmek (3. FARZ)',
        description: 'Eller yeni bir suyla ıslatılır; sağ elin içi ve parmaklarıyla başın en az dörtte biri (tercihen tamamı kaplama şeklinde) ıslak elle bir defa mesh edilir.',
        isFard: true,
        tip: 'Mesh ederken başı yıkamak gerekmez; ıslak elin başa sürülmesi yeterlidir.',
      ),
      const WuduStep(
        stepNumber: 7,
        title: 'Kulakları ve Boynu Mesh Etmek',
        description: 'Eller tekrar ıslatılmadan, şehadet parmakları kulak deliklerine, başparmaklar kulak arkasına sürülerek kulaklar mesh edilir. Elin dışı ile de boyun mesh edilir.',
        isFard: false,
        tip: 'Boğazı mesh etmek mekruhtur; sadece ense ve boyun yanları mesh edilir.',
      ),
      const WuduStep(
        stepNumber: 8,
        title: 'Ayakları Topuklarla Yıkamak (4. FARZ)',
        description: 'Önce sağ ayak, parmak uçlarından başlanıp topuk kemikleriyle ve aşık kemikleri dahil üç defa yıkanır. Parmak araları sol elin serçe parmağıyla hilallenir. Ardından sol ayak aynı şekilde yıkanır.',
        isFard: true,
        tip: 'Topukların arka kısımları genellikle kuru kalabildiği için özellikle dikkat edilir.',
      ),
    ];
  }

  /// Gusül (Boy Abdesti) Farzları ve Adımları
  static List<WuduStep> getGhuslSteps(AppLanguage lang) {
    return [
      const WuduStep(
        stepNumber: 1,
        title: 'Niyet ve Avret Yerlerinin Temizliği',
        description: 'Eûzü-Besmele ile "Niyet ettim Allah rızası için boy abdesti (gusül) almaya" denir. Vücuttaki kirler ve avret mahalli temizlenir.',
        isFard: false,
      ),
      const WuduStep(
        stepNumber: 2,
        title: 'Namaz Abdesti Almak',
        description: 'Tıpkı namaz kılacakmış gibi tam bir abdest alınır. Eğer suyun biriktiği bir yerde yıkanılıyorsa ayakların yıkanması guslün sonuna bırakılabilir.',
        isFard: false,
      ),
      const WuduStep(
        stepNumber: 3,
        title: 'Ağza Dolu Dolu Su Vermek (1. FARZ - Mazmaza)',
        description: 'Ağza bolca su alınıp boğaza kadar gargara yapılarak çalkalanır ve üç defa tekrarlanır (oruçlu değilse gargara yapılır).',
        isFard: true,
      ),
      const WuduStep(
        stepNumber: 4,
        title: 'Burna Genze Kadar Su Çekmek (2. FARZ - İstinşak)',
        description: 'Burna su çekilerek genze kadar ulaşması sağlanır ve sümkürülür; üç defa tekrarlanır.',
        isFard: true,
      ),
      const WuduStep(
        stepNumber: 5,
        title: 'Bütün Vücudu Yıkamak (3. FARZ)',
        description: 'Önce başa üç defa, sonra sağ omuza üç defa, sonra sol omuza üç defa su dökülür. Göbek deliği, kulak kıvrımları, saç dipleri ve tırnak dipleri dahil iğne ucu kadar kuru yer bırakılmaksızın bütün beden ovularak yıkanır.',
        isFard: true,
        tip: 'Saçların diplerine suyun ulaşması farzdır. Küpe deliği varsa ıslatılmalıdır.',
      ),
    ];
  }

  /// Teyemmüm Abdesti Adımları (Toprak ile)
  static List<WuduStep> getTayammumSteps(AppLanguage lang) {
    return [
      const WuduStep(
        stepNumber: 1,
        title: 'Niyet ve Besmele',
        description: 'Su bulunamadığında veya suyu kullanmaya engel bir hastalık/mazeret olduğunda temiz toprak, kum veya taş cinsinden bir maddeye yönelinir. "Niyet ettim Allah rızası için teyemmüm almaya" denir.',
        isFard: true,
      ),
      const WuduStep(
        stepNumber: 2,
        title: 'Yüzü Mesh Etmek (1. Vuruş & Farz)',
        description: 'İki elin içi parmaklar açık olarak temiz toprağa veya taşa vurulur, ileri-geri hareket ettirilir. Eller kaldırılıp birbirine hafifçe vurularak tozları silkelenir; ardından ellerin içiyle yüzün tamamı bir defa mesh edilir.',
        isFard: true,
      ),
      const WuduStep(
        stepNumber: 3,
        title: 'Kolları Mesh Etmek (2. Vuruş & Farz)',
        description: 'İki el tekrar toprağa vurulup silkelenir. Sol elin içiyle sağ kolun dışı ve içi dirseğe kadar mesh edilir. Ardından sağ elin içiyle sol kol aynı şekilde dirseğe kadar mesh edilir.',
        isFard: true,
      ),
    ];
  }

  /// Abdesti Bozan Başlıca Durumlar
  static const List<String> nullifiers = [
    'Ön veya arkadan idrar, dışkı veya gaz çıkması.',
    'Vücudun herhangi bir yerinden kan, irin veya sarı su çıkıp yara kenarından taşarak akması.',
    'Ağız dolusu kusmak.',
    'Yan yatarak, sırtüstü uzanarak veya bir şeye dayanarak uyumak.',
    'Aklı başından gideren baygınlık, delirme, sarhoşluk veya sara nöbeti geçirmek.',
    'Rükûlu ve secdeli namazlarda yanındakinin duyabileceği şekilde sesli gülmek.',
  ];

  /// Abdesti Bozmayan Yanılgılar
  static const List<String> nonNullifiers = [
    'Ağlamak veya gözden yaş gelmesi abdesti bozmaz.',
    'Tırnak kesmek veya saç/bıyık traşı olmak abdesti bozmaz.',
    'Kan akmaksızın derinin soyulması veya kabuğun düşmesi bozmaz.',
    'Ağız dolusu olmayan az miktardaki kusuntu bozmaz.',
    'Oturur vaziyette başı hafifçe öne düşerek dalıp uyanmak bozmaz.',
  ];
}

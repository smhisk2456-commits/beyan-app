import '../../../core/localization/app_strings.dart';
import 'prayer_time_model.dart';

/// Namazın kılınışındaki tek bir adım (Niyet, Tekbir, Kıyam, Rükû, Secde...).
class PrayerHowToStep {
  final String title;
  final String description;

  /// Okunacak duanın Arapça metni (varsa).
  final String? arabic;

  /// Latin harfli okunuşu (varsa).
  final String? transliteration;

  /// Türkçe/İngilizce/Endonezce anlamı (varsa).
  final String? meaning;

  /// Kadınlar için farklılık veya ek not (varsa).
  final String? note;

  const PrayerHowToStep({
    required this.title,
    required this.description,
    this.arabic,
    this.transliteration,
    this.meaning,
    this.note,
  });

  bool get hasRecitation => arabic != null;
}

/// Namaz kılınış rehberi (Hanefî mezhebine göre, Diyanet ile uyumlu).
class PrayerHowToGuide {
  PrayerHowToGuide._();

  /// Örnek olarak gösterilecek namazın farz rekat sayısı.
  static int exampleRakats(PrayerName p) {
    switch (p) {
      case PrayerName.fajr:
      case PrayerName.sunrise:
        return 2;
      case PrayerName.maghrib:
        return 3;
      case PrayerName.dhuhr:
      case PrayerName.asr:
      case PrayerName.isha:
        return 4;
    }
  }

  static String _l(AppLanguage lang, String tr, String en, String id, String ar) {
    switch (lang) {
      case AppLanguage.turkish:
        return tr;
      case AppLanguage.indonesian:
        return id;
      case AppLanguage.arabic:
        return ar;
      default:
        return en;
    }
  }

  /// Arapça arayüzde okunuş ve meal gösterilmez (metin zaten Arapça).
  static String? _translit(AppLanguage lang, String tr, String en) {
    if (lang == AppLanguage.arabic) return null;
    return lang == AppLanguage.turkish ? tr : en;
  }

  static String? _meaning(AppLanguage lang, String tr, String en, String id) {
    if (lang == AppLanguage.arabic) return null;
    return _l(lang, tr, en, id, '');
  }

  static String _prayerNameForNiyet(PrayerName p, AppLanguage lang) {
    switch (p) {
      case PrayerName.fajr:
        return _l(lang, 'sabah', 'Fajr', 'Subuh', 'الفجر');
      case PrayerName.sunrise:
        return _l(lang, 'kuşluk (duhâ)', 'Duha', 'Dhuha', 'الضحى');
      case PrayerName.dhuhr:
        return _l(lang, 'öğle', 'Dhuhr', 'Zuhur', 'الظهر');
      case PrayerName.asr:
        return _l(lang, 'ikindi', 'Asr', 'Ashar', 'العصر');
      case PrayerName.maghrib:
        return _l(lang, 'akşam', 'Maghrib', 'Maghrib', 'المغرب');
      case PrayerName.isha:
        return _l(lang, 'yatsı', 'Isha', 'Isya', 'العشاء');
    }
  }

  static String _capitalizeTr(String s) {
    if (s.isEmpty) return s;
    final first = s[0] == 'i' ? 'İ' : s[0].toUpperCase();
    return '$first${s.substring(1)}';
  }

  /// Rehberin üstünde gösterilen açıklama ("Örnek: Sabah namazının 2 rekat farzı").
  static String exampleCaption(PrayerName p, AppLanguage lang) {
    final n = exampleRakats(p);
    final name = _prayerNameForNiyet(p, lang);
    if (p == PrayerName.sunrise) {
      return _l(
        lang,
        'Örnek: $n rekatlık kuşluk (nafile) namazının kılınışı',
        'Example: How to pray $n rak\'ahs of Duha (voluntary)',
        'Contoh: Tata cara shalat Dhuha $n rakaat (sunnah)',
        'مثال: كيفية صلاة الضحى ركعتين (نافلة)',
      );
    }
    return _l(
      lang,
      'Örnek: ${_capitalizeTr(name)} namazının $n rekat farzı. '
          'Sünnetler de aynı şekilde kılınır.',
      'Example: The $n rak\'ah Fard of $name. Sunnah prayers are performed the same way.',
      'Contoh: $n rakaat Fardhu $name. Shalat sunnah dilakukan dengan cara yang sama.',
      'مثال: فرض $name ($n ركعات). وتُصلّى السنن بالطريقة نفسها.',
    );
  }

  // ── Ortak Dua Metinleri ─────────────────────────────────────────────

  static const _arSubhaneke =
      'سُبْحَانَكَ اللّٰهُمَّ وَبِحَمْدِكَ وَتَبَارَكَ اسْمُكَ وَتَعَالَى جَدُّكَ وَلَا إِلٰهَ غَيْرُكَ';
  static const _arEuzuBesmele =
      'أَعُوذُ بِاللّٰهِ مِنَ الشَّيْطَانِ الرَّجِيمِ\nبِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيمِ';
  static const _arBesmele = 'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيمِ';
  static const _arFatiha =
      'الْحَمْدُ لِلّٰهِ رَبِّ الْعَالَمِينَ ۝ الرَّحْمٰنِ الرَّحِيمِ ۝ مَالِكِ يَوْمِ الدِّينِ ۝ '
      'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ ۝ اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ ۝ '
      'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ';
  static const _arIhlas =
      'قُلْ هُوَ اللّٰهُ أَحَدٌ ۝ اللّٰهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ';
  static const _arRuku = 'سُبْحَانَ رَبِّيَ الْعَظِيمِ';
  static const _arKavme = 'سَمِعَ اللّٰهُ لِمَنْ حَمِدَهُ\nرَبَّنَا لَكَ الْحَمْدُ';
  static const _arSecde = 'سُبْحَانَ رَبِّيَ الْأَعْلَى';
  static const _arTehiyyat =
      'التَّحِيَّاتُ لِلّٰهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ، السَّلَامُ عَلَيْكَ أَيُّهَا النَّبِيُّ '
      'وَرَحْمَةُ اللّٰهِ وَبَرَكَاتُهُ، السَّلَامُ عَلَيْنَا وَعَلَى عِبَادِ اللّٰهِ الصَّالِحِينَ، '
      'أَشْهَدُ أَنْ لَا إِلٰهَ إِلَّا اللّٰهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ';
  static const _arSalliBarik =
      'اللّٰهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ '
      'وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ\n'
      'اللّٰهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ '
      'وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ';
  static const _arRabbena =
      'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ\n'
      'رَبَّنَا اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ يَوْمَ يَقُومُ الْحِسَابُ';
  static const _arSelam = 'السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللّٰهِ';

  // ── Adım Üreticileri ────────────────────────────────────────────────

  static PrayerHowToStep _fatihaStep(AppLanguage lang, {required String title, required String desc}) {
    return PrayerHowToStep(
      title: title,
      description: desc,
      arabic: _arFatiha,
      transliteration: _translit(
        lang,
        'Elhamdü lillâhi rabbil\'âlemîn. Errahmânir\'rahîm. Mâliki yevmiddîn. '
            'İyyâke na\'büdü ve iyyâke neste\'în. İhdinas\'sırâtel müstakîm. '
            'Sırâtellezîne en\'amte aleyhim ğayril mağdûbi aleyhim ve leddâllîn. (Âmîn)',
        'Al-hamdu lillahi rabbil-\'alamin. Ar-rahmanir-rahim. Maliki yawmid-din. '
            'Iyyaka na\'budu wa iyyaka nasta\'in. Ihdinas-siratal-mustaqim. '
            'Siratal-ladhina an\'amta \'alayhim ghayril-maghdubi \'alayhim wa lad-dallin. (Amin)',
      ),
      meaning: _meaning(
        lang,
        'Hamd, âlemlerin Rabbi, Rahmân ve Rahîm, din gününün sahibi Allah\'a mahsustur. '
            'Yalnız Sana ibadet eder, yalnız Senden yardım dileriz. Bizi doğru yola ilet; '
            'nimet verdiklerinin yoluna, gazaba uğrayanların ve sapanların yoluna değil.',
        'All praise is for Allah, Lord of the worlds, the Most Gracious, the Most Merciful, '
            'Master of the Day of Judgment. You alone we worship and You alone we ask for help. '
            'Guide us to the straight path, the path of those You have blessed, '
            'not of those who earned Your anger nor of those who went astray.',
        'Segala puji bagi Allah, Tuhan seluruh alam, Yang Maha Pengasih, Maha Penyayang, '
            'Pemilik hari pembalasan. Hanya kepada-Mu kami menyembah dan hanya kepada-Mu kami memohon pertolongan. '
            'Tunjukilah kami jalan yang lurus, jalan orang-orang yang Engkau beri nikmat, '
            'bukan jalan mereka yang dimurkai dan bukan pula jalan mereka yang sesat.',
      ),
    );
  }

  static PrayerHowToStep _zammStep(AppLanguage lang, String title) {
    return PrayerHowToStep(
      title: title,
      description: _l(
        lang,
        'Fâtiha\'dan sonra Kur\'an\'dan en az üç kısa âyet veya bir kısa sûre okunur. Örnek: İhlâs Sûresi.',
        'After Al-Fatiha, recite at least three short verses or a short surah. Example: Surah Al-Ikhlas.',
        'Setelah Al-Fatihah, bacalah minimal tiga ayat pendek atau satu surah pendek. Contoh: Surah Al-Ikhlas.',
        'بعد الفاتحة تُقرأ ثلاث آيات قصيرة على الأقل أو سورة قصيرة. مثال: سورة الإخلاص.',
      ),
      arabic: _arIhlas,
      transliteration: _translit(
        lang,
        'Kul hüvallâhü ehad. Allâhüssamed. Lem yelid ve lem yûled. Ve lem yekün lehû küfüven ehad.',
        'Qul huwallahu ahad. Allahus-samad. Lam yalid wa lam yulad. Wa lam yakun lahu kufuwan ahad.',
      ),
      meaning: _meaning(
        lang,
        'De ki: O, Allah\'tır, bir tektir. Allah Samed\'dir (her şey O\'na muhtaçtır). '
            'O doğurmamış ve doğurulmamıştır. Hiçbir şey O\'na denk değildir.',
        'Say: He is Allah, the One. Allah, the Eternal Refuge. He neither begets nor is born, '
            'and there is none comparable to Him.',
        'Katakanlah: Dialah Allah, Yang Maha Esa. Allah tempat meminta segala sesuatu. '
            'Dia tidak beranak dan tidak diperanakkan, dan tidak ada sesuatu pun yang setara dengan-Nya.',
      ),
    );
  }

  static PrayerHowToStep _rukuStep(AppLanguage lang) {
    return PrayerHowToStep(
      title: _l(lang, 'Rükû', 'Ruku (Bowing)', 'Rukuk', 'الركوع'),
      description: _l(
        lang,
        '"Allâhu Ekber" diyerek eğilinir. Eller dizlere konur, sırt ve baş düz tutulur. '
            'Gözler ayak uçlarına bakar ve en az 3 kez okunur:',
        'Say "Allahu Akbar" and bow. Place your hands on your knees, keep your back and head level, '
            'look at your feet and recite at least 3 times:',
        'Ucapkan "Allahu Akbar" lalu membungkuk. Letakkan tangan di lutut, punggung dan kepala lurus, '
            'pandangan ke ujung kaki, lalu baca minimal 3 kali:',
        'يُكبّر وينحني واضعًا يديه على ركبتيه مستوي الظهر والرأس، وينظر إلى قدميه ويقول ثلاثًا على الأقل:',
      ),
      arabic: _arRuku,
      transliteration: _translit(lang, 'Sübhâne rabbiyel azîm (3 kez)', 'Subhana rabbiyal-\'azim (3 times)'),
      meaning: _meaning(
        lang,
        'Yüce Rabbimi her türlü noksanlıktan tenzih ederim.',
        'Glory be to my Lord, the Magnificent.',
        'Maha Suci Tuhanku Yang Maha Agung.',
      ),
      note: _l(
        lang,
        'Kadınlar erkeklere göre daha az eğilir; parmaklar bitişik olarak dizler üzerine konur.',
        'Women bow slightly less deeply, with fingers together on the knees.',
        'Perempuan membungkuk sedikit lebih ringan, dengan jari-jari rapat di atas lutut.',
        'تنحني المرأة أقل من الرجل، وتضع يديها على ركبتيها مضمومة الأصابع.',
      ),
    );
  }

  static PrayerHowToStep _kavmeStep(AppLanguage lang) {
    return PrayerHowToStep(
      title: _l(lang, 'Rükûdan Doğrulma (Kavme)', 'Rising from Ruku (Qawmah)', 'I\'tidal', 'الرفع من الركوع'),
      description: _l(
        lang,
        'Rükûdan kalkarken "Semi\'allâhü limen hamideh" denir, tam doğrulunca "Rabbenâ lekel hamd" denir.',
        'While rising say "Sami\'allahu liman hamidah", and once fully upright say "Rabbana lakal-hamd".',
        'Saat bangkit ucapkan "Sami\'allahu liman hamidah", setelah tegak sempurna ucapkan "Rabbana lakal-hamd".',
        'يقول عند الرفع: سمع الله لمن حمده، فإذا استوى قائمًا قال: ربنا لك الحمد.',
      ),
      arabic: _arKavme,
      transliteration: _translit(
        lang,
        'Semi\'allâhü limen hamideh. Rabbenâ lekel hamd.',
        'Sami\'allahu liman hamidah. Rabbana lakal-hamd.',
      ),
      meaning: _meaning(
        lang,
        'Allah, kendisine hamd edeni işitir. Rabbimiz! Hamd yalnız Sana mahsustur.',
        'Allah hears the one who praises Him. Our Lord, all praise is Yours.',
        'Allah mendengar orang yang memuji-Nya. Ya Tuhan kami, segala puji bagi-Mu.',
      ),
    );
  }

  static PrayerHowToStep _secdeStep(AppLanguage lang) {
    return PrayerHowToStep(
      title: _l(lang, 'İki Secde', 'Two Prostrations (Sujud)', 'Dua Kali Sujud', 'السجدتان'),
      description: _l(
        lang,
        '"Allâhu Ekber" diyerek secdeye varılır: önce dizler, sonra eller, sonra burun ve alın yere konur. '
            'En az 3 kez okunur. Sonra "Allâhu Ekber" ile oturulur (celse), bir an durulur ve ikinci secdeye '
            'varılıp aynı tesbih tekrar okunur.',
        'Say "Allahu Akbar" and prostrate: knees first, then hands, then nose and forehead on the ground. '
            'Recite at least 3 times. Then sit up briefly with "Allahu Akbar" (jalsah) and perform the second '
            'prostration in the same way.',
        'Ucapkan "Allahu Akbar" lalu sujud: lutut dulu, kemudian tangan, lalu hidung dan dahi menyentuh lantai. '
            'Baca minimal 3 kali. Lalu duduk sejenak dengan "Allahu Akbar" dan lakukan sujud kedua dengan cara yang sama.',
        'يكبّر ويسجد واضعًا ركبتيه ثم يديه ثم أنفه وجبهته، ويسبّح ثلاثًا على الأقل، ثم يجلس مكبّرًا '
            'جلسة خفيفة، ثم يسجد السجدة الثانية كالأولى.',
      ),
      arabic: _arSecde,
      transliteration: _translit(lang, 'Sübhâne rabbiyel a\'lâ (3 kez)', 'Subhana rabbiyal-a\'la (3 times)'),
      meaning: _meaning(
        lang,
        'En yüce olan Rabbimi her türlü noksanlıktan tenzih ederim.',
        'Glory be to my Lord, the Most High.',
        'Maha Suci Tuhanku Yang Maha Tinggi.',
      ),
      note: _l(
        lang,
        'Erkekler kollarını yanlardan ayırır; kadınlar kollarını yanlarına ve karınlarını uyluklarına yaklaştırarak secde eder.',
        'Men keep their arms away from their sides; women keep their arms close and abdomen near the thighs.',
        'Laki-laki merenggangkan lengan dari lambung; perempuan merapatkan lengan dan perut ke paha.',
        'يُجافي الرجل عضديه عن جنبيه، وتضمّ المرأة عضديها وتُلصق بطنها بفخذيها.',
      ),
    );
  }

  static PrayerHowToStep _tehiyyatStep(AppLanguage lang, {required bool isFinal}) {
    return PrayerHowToStep(
      title: isFinal
          ? _l(lang, 'Son Oturuş (Ka\'de-i Âhire)', 'Final Sitting (Tashahhud)', 'Tasyahud Akhir', 'القعود الأخير')
          : _l(lang, 'İlk Oturuş (Ka\'de-i Ûlâ)', 'First Sitting (Tashahhud)', 'Tasyahud Awal', 'القعود الأول'),
      description: isFinal
          ? _l(
              lang,
              'Son rekatın ikinci secdesinden sonra oturulur ve sırasıyla Ettehiyyâtü, Allâhümme Salli, '
                  'Allâhümme Bârik ve Rabbenâ duaları okunur.',
              'After the second prostration of the last rak\'ah, sit and recite At-Tahiyyat, '
                  'then the Salawat (Allahumma Salli & Barik) and the Rabbana supplications.',
              'Setelah sujud kedua di rakaat terakhir, duduk lalu membaca Tahiyyat, Shalawat '
                  '(Allahumma Shalli & Barik), dan doa Rabbana.',
              'بعد السجدة الثانية من الركعة الأخيرة يجلس ويقرأ التحيات ثم الصلاة الإبراهيمية ثم دعاء ربنا.',
            )
          : _l(
              lang,
              '2. rekatın ikinci secdesinden sonra oturulur ve SADECE Ettehiyyâtü okunur. '
                  'Ardından "Allâhu Ekber" diyerek 3. rekata kalkılır.',
              'After the second prostration of the 2nd rak\'ah, sit and recite ONLY At-Tahiyyat, '
                  'then stand up for the 3rd rak\'ah saying "Allahu Akbar".',
              'Setelah sujud kedua di rakaat ke-2, duduk dan HANYA membaca Tahiyyat, '
                  'lalu berdiri untuk rakaat ke-3 sambil mengucapkan "Allahu Akbar".',
              'بعد السجدة الثانية من الركعة الثانية يجلس ويقرأ التحيات فقط، ثم يقوم إلى الثالثة مكبّرًا.',
            ),
      arabic: _arTehiyyat,
      transliteration: _translit(
        lang,
        'Ettehiyyâtü lillâhi vessalevâtü vettayyibât. Esselâmü aleyke eyyühen\'nebiyyü ve rahmetullâhi ve '
            'berakâtüh. Esselâmü aleynâ ve alâ ibâdillâhis\'sâlihîn. Eşhedü en lâ ilâhe illallâh ve eşhedü '
            'enne Muhammeden abdühû ve rasûlüh.',
        'At-tahiyyatu lillahi was-salawatu wat-tayyibat. As-salamu \'alayka ayyuhan-nabiyyu wa rahmatullahi '
            'wa barakatuh. As-salamu \'alayna wa \'ala \'ibadillahis-salihin. Ash-hadu an la ilaha illallah, '
            'wa ash-hadu anna Muhammadan \'abduhu wa rasuluh.',
      ),
      meaning: _meaning(
        lang,
        'Bütün tahiyyeler, dualar ve güzel sözler Allah\'a mahsustur. Ey Peygamber! Allah\'ın selâmı, rahmeti '
            've bereketi senin üzerine olsun. Selâm bizim ve Allah\'ın salih kullarının üzerine olsun. '
            'Şahitlik ederim ki Allah\'tan başka ilah yoktur ve yine şahitlik ederim ki Muhammed O\'nun kulu ve elçisidir.',
        'All greetings, prayers and good words are for Allah. Peace be upon you, O Prophet, and the mercy of Allah '
            'and His blessings. Peace be upon us and upon the righteous servants of Allah. I bear witness that there '
            'is no god but Allah, and I bear witness that Muhammad is His servant and messenger.',
        'Segala penghormatan, shalawat dan kebaikan hanya milik Allah. Semoga keselamatan, rahmat dan berkah Allah '
            'tercurah kepadamu wahai Nabi. Semoga keselamatan tercurah kepada kami dan hamba-hamba Allah yang saleh. '
            'Aku bersaksi tiada tuhan selain Allah dan aku bersaksi bahwa Muhammad adalah hamba dan utusan-Nya.',
      ),
      note: _l(
        lang,
        'Erkekler sol ayağı yatırıp üzerine oturur, sağ ayağı dikerler. Kadınlar ayaklarını sağ taraftan çıkararak otururlar.',
        'Men sit on the left foot with the right foot upright; women sit with both feet extended to the right.',
        'Laki-laki duduk di atas kaki kiri dengan kaki kanan ditegakkan; perempuan duduk dengan kedua kaki dikeluarkan ke kanan.',
        'يفترش الرجل رجله اليسرى وينصب اليمنى، وتجلس المرأة متورّكة مخرجةً رجليها من الجانب الأيمن.',
      ),
    );
  }

  /// Seçilen vakte göre adım adım namaz kılınışını döndürür.
  static List<PrayerHowToStep> steps(PrayerName p, AppLanguage lang) {
    final rakats = exampleRakats(p);
    final name = _prayerNameForNiyet(p, lang);
    final isNafile = p == PrayerName.sunrise;

    final niyetTr = isNafile
        ? 'Niyet ettim Allah rızası için kuşluk namazı kılmaya.'
        : 'Niyet ettim Allah rızası için bugünkü $name namazının farzını kılmaya.';
    final niyetEn = isNafile
        ? '"I intend to pray 2 rak\'ahs of Duha for the sake of Allah."'
        : '"I intend to pray the $rakats rak\'ah Fard of $name for the sake of Allah."';
    final niyetId = isNafile
        ? '"Aku berniat shalat Dhuha 2 rakaat karena Allah Ta\'ala."'
        : '"Aku berniat shalat fardhu $name $rakats rakaat karena Allah Ta\'ala."';

    final list = <PrayerHowToStep>[
      // 1. Hazırlık
      PrayerHowToStep(
        title: _l(lang, 'Hazırlık: Abdest & Kıble', 'Preparation: Wudu & Qibla', 'Persiapan: Wudhu & Kiblat', 'التهيؤ: الوضوء والقبلة'),
        description: _l(
          lang,
          'Abdestli olarak, temiz bir yerde, avret yerleri örtülü şekilde kıbleye dönülür. Vaktin girmiş olduğundan emin olunur.',
          'Make sure you have wudu, your body and place are clean, your \'awrah is covered, the prayer time has entered, and face the Qibla.',
          'Pastikan dalam keadaan berwudhu, badan dan tempat suci, aurat tertutup, waktu shalat telah masuk, lalu menghadap kiblat.',
          'يتوضأ ويستر عورته ويتأكد من طهارة المكان ودخول الوقت، ثم يستقبل القبلة.',
        ),
      ),
      // 2. Niyet
      PrayerHowToStep(
        title: _l(lang, 'Niyet', 'Intention (Niyyah)', 'Niat', 'النية'),
        description: _l(
          lang,
          'Hangi namazı kılacağınızı kalben belirlersiniz. Dil ile söylemek de güzeldir: "$niyetTr"',
          'Make the intention in your heart for the prayer you are about to perform, e.g. $niyetEn',
          'Niatkan di dalam hati shalat yang akan dikerjakan, misalnya: $niyetId',
          'ينوي بقلبه الصلاة التي يريد أداءها، كأن ينوي صلاة $name.',
        ),
        note: _l(
          lang,
          'Cemaatle kılınıyorsa "Uydum hazır olan imama" diye eklenir.',
          'If praying in congregation, also intend to follow the imam.',
          'Jika berjamaah, niatkan juga mengikuti imam (makmum).',
          'إن كان مأمومًا نوى الاقتداء بالإمام.',
        ),
      ),
      // 3. İftitah Tekbiri
      PrayerHowToStep(
        title: _l(lang, 'İftitah (Başlangıç) Tekbiri', 'Opening Takbir', 'Takbiratul Ihram', 'تكبيرة الإحرام'),
        description: _l(
          lang,
          'Eller kaldırılır; erkekler başparmaklarını kulak memelerine değdirir, kadınlar ellerini omuz hizasına kaldırır '
              've "Allâhu Ekber" denilerek namaza başlanır.',
          'Raise your hands (men: thumbs to earlobes; women: to shoulder level) and say "Allahu Akbar" to begin the prayer.',
          'Angkat kedua tangan (laki-laki: ibu jari menyentuh daun telinga; perempuan: sejajar bahu) dan ucapkan "Allahu Akbar".',
          'يرفع يديه (الرجل إلى شحمتي أذنيه والمرأة إلى منكبيها) ويقول: الله أكبر.',
        ),
        arabic: 'اللّٰهُ أَكْبَرُ',
        transliteration: _translit(lang, 'Allâhu Ekber', 'Allahu Akbar'),
        meaning: _meaning(lang, 'Allah en büyüktür.', 'Allah is the Greatest.', 'Allah Maha Besar.'),
      ),
      // 4. Kıyam + Sübhaneke
      PrayerHowToStep(
        title: _l(lang, 'Kıyam & Sübhaneke', 'Standing & Opening Supplication', 'Berdiri & Doa Iftitah', 'القيام ودعاء الاستفتاح'),
        description: _l(
          lang,
          'Erkekler sağ eli sol elin üzerine koyarak göbek altında bağlar; kadınlar ellerini göğüs üzerinde bağlar. '
              'Gözler secde yerine bakar ve Sübhaneke okunur.',
          'Men place the right hand over the left below the navel; women place them on the chest. '
              'Look at the place of prostration and recite the Thana:',
          'Laki-laki meletakkan tangan kanan di atas tangan kiri di bawah pusar; perempuan di atas dada. '
              'Pandangan ke tempat sujud dan membaca doa iftitah (Tsana):',
          'يضع الرجل يمينه على شماله تحت السرة، والمرأة على صدرها، وينظر إلى موضع سجوده ويقرأ الثناء:',
        ),
        arabic: _arSubhaneke,
        transliteration: _translit(
          lang,
          'Sübhânekellâhümme ve bi hamdik ve tebârekesmük ve teâlâ ceddük ve lâ ilâhe ğayrük.',
          'Subhanakallahumma wa bihamdika wa tabarakasmuka wa ta\'ala jadduka wa la ilaha ghayruk.',
        ),
        meaning: _meaning(
          lang,
          'Allah\'ım! Seni her türlü eksiklikten tenzih eder, Sana hamd ederim. Senin adın mübarektir, '
              'şanın yücedir. Senden başka ilah yoktur.',
          'Glory be to You, O Allah, and praise be to You. Blessed is Your name and exalted is Your majesty. '
              'There is no god but You.',
          'Maha Suci Engkau ya Allah, dengan memuji-Mu. Maha Berkah nama-Mu, Maha Tinggi keagungan-Mu, '
              'dan tiada tuhan selain Engkau.',
        ),
      ),
      // 5. Eûzü-Besmele
      PrayerHowToStep(
        title: _l(lang, 'Eûzü - Besmele', 'Ta\'awwudh & Basmalah', 'Ta\'awudz & Basmalah', 'التعوذ والبسملة'),
        description: _l(
          lang,
          'Sübhaneke\'den sonra sessizce Eûzü ve Besmele çekilir.',
          'After the Thana, silently seek refuge in Allah and say the Basmalah.',
          'Setelah doa iftitah, baca ta\'awudz dan basmalah secara pelan.',
          'بعد الثناء يتعوّذ ويبسمل سرًّا.',
        ),
        arabic: _arEuzuBesmele,
        transliteration: _translit(
          lang,
          'Eûzü billâhi mineş\'şeytânir\'racîm. Bismillâhir\'rahmânir\'rahîm.',
          'A\'udhu billahi minash-shaytanir-rajim. Bismillahir-rahmanir-rahim.',
        ),
        meaning: _meaning(
          lang,
          'Kovulmuş şeytandan Allah\'a sığınırım. Rahmân ve Rahîm olan Allah\'ın adıyla.',
          'I seek refuge in Allah from the accursed Satan. In the name of Allah, the Most Gracious, the Most Merciful.',
          'Aku berlindung kepada Allah dari setan yang terkutuk. Dengan nama Allah Yang Maha Pengasih lagi Maha Penyayang.',
        ),
      ),
      // 6. Fâtiha
      _fatihaStep(
        lang,
        title: _l(lang, '1. Rekat: Fâtiha Sûresi', '1st Rak\'ah: Al-Fatiha', 'Rakaat 1: Al-Fatihah', 'الركعة الأولى: الفاتحة'),
        desc: _l(
          lang,
          'Fâtiha Sûresi okunur ve sonunda sessizce "Âmîn" denir.',
          'Recite Surah Al-Fatiha and say "Amin" silently at the end.',
          'Baca Surah Al-Fatihah dan ucapkan "Amin" di akhir.',
          'يقرأ سورة الفاتحة ويقول في آخرها: آمين.',
        ),
      ),
      // 7. Zamm-ı Sûre
      _zammStep(lang, _l(lang, '1. Rekat: Zamm-ı Sûre', '1st Rak\'ah: Additional Surah', 'Rakaat 1: Surah Pendek', 'الركعة الأولى: سورة قصيرة')),
      // 8-10. Rükû, Kavme, Secde
      _rukuStep(lang),
      _kavmeStep(lang),
      _secdeStep(lang),
      // 11. 2. Rekat
      PrayerHowToStep(
        title: _l(lang, '2. Rekat', '2nd Rak\'ah', 'Rakaat 2', 'الركعة الثانية'),
        description: _l(
          lang,
          '"Allâhu Ekber" diyerek ayağa kalkılır. Sübhaneke ve Eûzü okunmaz; Besmele çekilip Fâtiha ve bir zamm-ı sûre '
              '(örn. Felak veya Nâs) okunur. Ardından 1. rekattaki gibi rükû ve iki secde yapılır.',
          'Stand up saying "Allahu Akbar". Do not recite the Thana or Ta\'awwudh; say the Basmalah, recite Al-Fatiha '
              'and another short surah (e.g. Al-Falaq or An-Nas), then perform ruku and two prostrations as before.',
          'Berdiri sambil mengucapkan "Allahu Akbar". Tidak membaca doa iftitah dan ta\'awudz; baca basmalah, Al-Fatihah '
              'dan surah pendek (mis. Al-Falaq atau An-Nas), lalu rukuk dan dua kali sujud seperti rakaat pertama.',
          'يقوم مكبّرًا، ولا يقرأ الثناء ولا التعوذ، بل يبسمل ويقرأ الفاتحة وسورة قصيرة (كالفلق أو الناس)، '
              'ثم يركع ويسجد سجدتين كالركعة الأولى.',
        ),
        arabic: _arBesmele,
        transliteration: _translit(lang, 'Bismillâhir\'rahmânir\'rahîm', 'Bismillahir-rahmanir-rahim'),
      ),
    ];

    if (rakats == 2) {
      list.add(_tehiyyatStep(lang, isFinal: true));
    } else {
      list.add(_tehiyyatStep(lang, isFinal: false));
      list.add(
        PrayerHowToStep(
          title: rakats == 3
              ? _l(lang, '3. Rekat', '3rd Rak\'ah', 'Rakaat 3', 'الركعة الثالثة')
              : _l(lang, '3. ve 4. Rekatlar', '3rd & 4th Rak\'ahs', 'Rakaat 3 & 4', 'الركعتان الثالثة والرابعة'),
          description: _l(
            lang,
            'Ayağa kalkılır, Besmele çekilip SADECE Fâtiha okunur (farzlarda zamm-ı sûre eklenmez). '
                'Rükû ve iki secde yapılır.${rakats == 4 ? ' 4. rekat da aynı şekilde kılınır.' : ''}',
            'Stand up, say the Basmalah and recite ONLY Al-Fatiha (no additional surah in Fard rak\'ahs). '
                'Perform ruku and two prostrations.${rakats == 4 ? ' The 4th rak\'ah is performed the same way.' : ''}',
            'Berdiri, baca basmalah dan HANYA Al-Fatihah (tanpa surah pendek pada rakaat fardhu). '
                'Lalu rukuk dan dua kali sujud.${rakats == 4 ? ' Rakaat ke-4 dilakukan dengan cara yang sama.' : ''}',
            'يقوم ويبسمل ويقرأ الفاتحة فقط (بلا سورة في الفرض)، ثم يركع ويسجد سجدتين.'
                '${rakats == 4 ? ' والركعة الرابعة مثلها.' : ''}',
          ),
          note: _l(
            lang,
            'Sünnet namazlarda 3. ve 4. rekatlarda da Fâtiha\'dan sonra zamm-ı sûre okunur.',
            'In Sunnah prayers, an additional surah is also recited after Al-Fatiha in the 3rd and 4th rak\'ahs.',
            'Pada shalat sunnah, surah pendek tetap dibaca setelah Al-Fatihah di rakaat ke-3 dan ke-4.',
            'في السنن تُقرأ سورة بعد الفاتحة في الركعتين الثالثة والرابعة أيضًا.',
          ),
        ),
      );
      list.add(_tehiyyatStep(lang, isFinal: true));
    }

    list.addAll([
      PrayerHowToStep(
        title: _l(lang, 'Salli - Bârik Duaları', 'Salawat (Salli & Barik)', 'Shalawat Ibrahimiyah', 'الصلاة الإبراهيمية'),
        description: _l(
          lang,
          'Son oturuşta Ettehiyyâtü\'den sonra okunur.',
          'Recited in the final sitting after At-Tahiyyat.',
          'Dibaca pada tasyahud akhir setelah Tahiyyat.',
          'تُقرأ في القعود الأخير بعد التحيات.',
        ),
        arabic: _arSalliBarik,
        transliteration: _translit(
          lang,
          'Allâhümme salli alâ Muhammedin ve alâ âli Muhammed. Kemâ salleyte alâ İbrâhîme ve alâ âli İbrâhîm. '
              'İnneke hamîdün mecîd.\nAllâhümme bârik alâ Muhammedin ve alâ âli Muhammed. Kemâ bârekte alâ '
              'İbrâhîme ve alâ âli İbrâhîm. İnneke hamîdün mecîd.',
          'Allahumma salli \'ala Muhammadin wa \'ala ali Muhammad, kama sallayta \'ala Ibrahima wa \'ala ali Ibrahim, '
              'innaka hamidun majid.\nAllahumma barik \'ala Muhammadin wa \'ala ali Muhammad, kama barakta \'ala '
              'Ibrahima wa \'ala ali Ibrahim, innaka hamidun majid.',
        ),
        meaning: _meaning(
          lang,
          'Allah\'ım! İbrahim\'e ve ailesine rahmet ettiğin gibi Muhammed\'e ve ailesine de rahmet et; '
              'İbrahim\'e ve ailesine bereket verdiğin gibi Muhammed\'e ve ailesine de bereket ver. '
              'Şüphesiz Sen övülmeye layık ve şanı yüce olansın.',
          'O Allah, send prayers upon Muhammad and his family as You sent prayers upon Ibrahim and his family, '
              'and bless Muhammad and his family as You blessed Ibrahim and his family. Truly You are Praiseworthy, Glorious.',
          'Ya Allah, limpahkanlah shalawat dan keberkahan kepada Muhammad dan keluarganya sebagaimana Engkau '
              'limpahkan kepada Ibrahim dan keluarganya. Sungguh Engkau Maha Terpuji lagi Maha Mulia.',
        ),
      ),
      PrayerHowToStep(
        title: _l(lang, 'Rabbenâ Duaları', 'Rabbana Supplications', 'Doa Rabbana', 'دعاء ربنا'),
        description: _l(
          lang,
          'Salli-Bârik\'ten sonra Rabbenâ âtinâ ve Rabbenağfirlî duaları okunur.',
          'After the Salawat, recite the Rabbana supplications.',
          'Setelah shalawat, bacalah doa Rabbana.',
          'بعد الصلاة الإبراهيمية يدعو بدعاء ربنا آتنا وربنا اغفر لي.',
        ),
        arabic: _arRabbena,
        transliteration: _translit(
          lang,
          'Rabbenâ âtinâ fid\'dünyâ haseneten ve fil\'âhirati haseneten ve kınâ azâben\'nâr.\n'
              'Rabbenağfirlî ve li vâlideyye ve lil mü\'minîne yevme yekûmül hısâb.',
          'Rabbana atina fid-dunya hasanatan wa fil-akhirati hasanatan wa qina \'adhaban-nar.\n'
              'Rabbanaghfirli wa liwalidayya wa lil-mu\'minina yawma yaqumul-hisab.',
        ),
        meaning: _meaning(
          lang,
          'Rabbimiz! Bize dünyada da iyilik ver, ahirette de iyilik ver ve bizi ateş azabından koru. '
              'Rabbimiz! Hesap gününde beni, anne-babamı ve bütün müminleri bağışla.',
          'Our Lord, give us good in this world and good in the Hereafter, and protect us from the punishment of the Fire. '
              'Our Lord, forgive me, my parents and the believers on the Day of Reckoning.',
          'Ya Tuhan kami, berilah kami kebaikan di dunia dan kebaikan di akhirat, dan lindungilah kami dari azab neraka. '
              'Ya Tuhan kami, ampunilah aku, kedua orang tuaku dan orang-orang beriman pada hari perhitungan.',
        ),
      ),
      PrayerHowToStep(
        title: _l(lang, 'Selâm', 'Salam (Ending the Prayer)', 'Salam', 'التسليم'),
        description: _l(
          lang,
          'Önce baş sağa çevrilip "Esselâmü aleyküm ve rahmetullâh" denir, sonra sola çevrilip aynısı söylenir. '
              'Böylece namaz tamamlanır.',
          'Turn your head to the right saying "As-salamu \'alaykum wa rahmatullah", then to the left saying the same. '
              'The prayer is now complete.',
          'Palingkan kepala ke kanan sambil mengucapkan "Assalamu\'alaikum wa rahmatullah", lalu ke kiri dengan ucapan yang sama. '
              'Shalat telah selesai.',
          'يلتفت يمينًا قائلًا: السلام عليكم ورحمة الله، ثم يسارًا كذلك، وبذلك تتم الصلاة.',
        ),
        arabic: _arSelam,
        transliteration: _translit(lang, 'Esselâmü aleyküm ve rahmetullâh', 'As-salamu \'alaykum wa rahmatullah'),
        meaning: _meaning(
          lang,
          'Allah\'ın selâmı ve rahmeti üzerinize olsun.',
          'Peace and the mercy of Allah be upon you.',
          'Semoga keselamatan dan rahmat Allah tercurah kepada kalian.',
        ),
      ),
      PrayerHowToStep(
        title: _l(lang, 'Tesbihat (Namaz Sonrası)', 'Dhikr after Prayer', 'Dzikir Setelah Shalat', 'الأذكار بعد الصلاة'),
        description: _l(
          lang,
          'Selamdan sonra Âyetü\'l-Kürsî okunur; 33 kez Sübhânallâh, 33 kez Elhamdülillâh, 33 kez Allâhu Ekber '
              'denir ve dua edilir.',
          'After salam, recite Ayat al-Kursi, then say SubhanAllah 33 times, Alhamdulillah 33 times, '
              'Allahu Akbar 33 times, and make du\'a.',
          'Setelah salam, baca Ayat Kursi, lalu Subhanallah 33 kali, Alhamdulillah 33 kali, '
              'Allahu Akbar 33 kali, kemudian berdoa.',
          'بعد السلام يقرأ آية الكرسي، ثم يسبّح ثلاثًا وثلاثين، ويحمد ثلاثًا وثلاثين، ويكبّر ثلاثًا وثلاثين، ثم يدعو.',
        ),
        arabic: 'سُبْحَانَ اللّٰهِ ۝ الْحَمْدُ لِلّٰهِ ۝ اللّٰهُ أَكْبَرُ',
        transliteration: _translit(
          lang,
          'Sübhânallâh (33) • Elhamdülillâh (33) • Allâhu Ekber (33)',
          'SubhanAllah (33) • Alhamdulillah (33) • Allahu Akbar (33)',
        ),
      ),
    ]);

    return list;
  }
}

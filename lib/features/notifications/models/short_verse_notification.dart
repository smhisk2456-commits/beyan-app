import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// Kısa, Öz ve İlham Verici Âyet Bildirim Modeli (TR, EN, AR)
class ShortVerseNotification {
  final String surahNameTr;
  final String surahNameEn;
  final String surahNameAr;
  final String verseReference;
  final String arabicText;
  final String textTr;
  final String textEn;
  final String textAr;

  const ShortVerseNotification({
    required this.surahNameTr,
    required this.surahNameEn,
    required this.surahNameAr,
    required this.verseReference,
    required this.arabicText,
    required this.textTr,
    required this.textEn,
    required this.textAr,
  });

  /// Seçili dile göre kısa ve vurucu meal metnini döner
  String localizedText(String langCode) {
    if (langCode == 'en') return textEn;
    if (langCode == 'ar') return textAr;
    return textTr;
  }

  /// Seçili dile göre bildirim başlığını döner
  String localizedTitle(String langCode, {bool isEvening = false}) {
    if (isEvening) {
      if (langCode == 'en') return 'Evening Reflection 🌙 $verseReference';
      if (langCode == 'ar') return 'تأمل المساء 🌙 $verseReference';
      return 'Akşam Tefekkürü 🌙 $verseReference';
    }
    if (langCode == 'en') return 'Verse of the Day 📖 $verseReference';
    if (langCode == 'ar') return 'آية اليوم 📖 $verseReference';
    return 'Günün Âyeti 📖 $verseReference';
  }

  static int _rotationCounter = 0;

  /// Test veya anlık gönderimlerde her tıklamada kesinlikle FARKLI bir ayet seçer.
  static Future<ShortVerseNotification> getNextRotatingVerse() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int lastIndex = prefs.getInt('beyan_last_verse_notif_idx') ?? Random().nextInt(pool.length);
      // Farklı bir indexe geç (en az 1, en fazla 5 atlayarak rastgele çeşitlendir)
      final step = 1 + Random().nextInt(4);
      final nextIndex = (lastIndex + step) % pool.length;
      await prefs.setInt('beyan_last_verse_notif_idx', nextIndex);
      return pool[nextIndex];
    } catch (_) {
      _rotationCounter = (_rotationCounter + 1) % pool.length;
      return pool[_rotationCounter];
    }
  }

  /// Belirli bir indeksteki kısa ayeti döner (zamanlamalar için)
  static ShortVerseNotification getByIndex(int index) {
    return pool[index.abs() % pool.length];
  }

  /// 40 Adet Doğrulanmış, Kısa, Vurucu ve Kalbe Dokunan Âyet Havuzu
  static const List<ShortVerseNotification> pool = [
    ShortVerseNotification(
      surahNameTr: 'İnşirâh Suresi',
      surahNameEn: 'Surah Ash-Sharh',
      surahNameAr: 'سورة الشرح',
      verseReference: 'İnşirâh 94:5-6',
      arabicText: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا ﴿٥﴾ إِنَّ مَعَ الْعُسْرِ يُسْرًا',
      textTr: 'Şüphesiz zorlukla beraber bir kolaylık vardır; evet, zorlukla beraber kesinlikle bir kolaylık vardır.',
      textEn: 'Indeed, with hardship comes ease; truly, with hardship comes ease.',
      textAr: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا ﴿٥﴾ إِنَّ مَعَ الْعُسْرِ يُسْرًا',
    ),
    ShortVerseNotification(
      surahNameTr: 'Bakara Suresi',
      surahNameEn: 'Surah Al-Baqarah',
      surahNameAr: 'سورة البقرة',
      verseReference: 'Bakara 2:152',
      arabicText: 'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
      textTr: 'Beni anın ki Ben de sizi anayım. Bana şükredin ve nankörlük etmeyin.',
      textEn: 'Remember Me; I will remember you. Be grateful to Me, and do not deny Me.',
      textAr: 'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
    ),
    ShortVerseNotification(
      surahNameTr: 'Ra\'d Suresi',
      surahNameEn: 'Surah Ar-Ra\'d',
      surahNameAr: 'سورة الرعد',
      verseReference: 'Ra\'d 13:28',
      arabicText: 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
      textTr: 'İyi bilin ki, kalpler ancak Allah\'ın zikriyle huzur bulur.',
      textEn: 'Unquestionably, by the remembrance of Allah hearts are assured.',
      textAr: 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
    ),
    ShortVerseNotification(
      surahNameTr: 'Bakara Suresi',
      surahNameEn: 'Surah Al-Baqarah',
      surahNameAr: 'سورة البقرة',
      verseReference: 'Bakara 2:186',
      arabicText: 'وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ ۖ أُجِيبُ دَعْوَةَ الدَّاعِ إِذَا دَعَانِ',
      textTr: 'Kullarım Beni sana soracak olursa bilsinler ki Ben şüphesiz onlara çok yakınım; dua edenin duasına icabet ederim.',
      textEn: 'And when My servants ask you concerning Me, indeed I am near. I respond to the caller when he calls upon Me.',
      textAr: 'وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ ۖ أُجِيبُ دَعْوَةَ الدَّاعِ إِذَا دَعَانِ',
    ),
    ShortVerseNotification(
      surahNameTr: 'Talâk Suresi',
      surahNameEn: 'Surah At-Talaq',
      surahNameAr: 'سورة الطلاق',
      verseReference: 'Talâk 65:3',
      arabicText: 'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ',
      textTr: 'Kim Allah\'a tevekkül ederse, O kendisine yeter.',
      textEn: 'And whoever relies upon Allah – then He is sufficient for him.',
      textAr: 'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ',
    ),
    ShortVerseNotification(
      surahNameTr: 'Âl-i İmrân Suresi',
      surahNameEn: 'Surah Ali \'Imran',
      surahNameAr: 'سورة آل عمران',
      verseReference: 'Âl-i İmrân 3:139',
      arabicText: 'وَلَا تَهِنُوا وَلَا تَحْزَنُوا وَأَنتُمُ الْأَعْلَوْنَ إِن كُنتُم مُّؤْمِنِينَ',
      textTr: 'Gevşemeyin, hüzünlenmeyin; eğer gerçekten inanıyorsanız en üstün olan sizsiniz.',
      textEn: 'Do not weaken and do not grieve, for you are superior if you are true believers.',
      textAr: 'وَلَا تَهِنُوا وَلَا تَحْزَنُوا وَأَنتُمُ الْأَعْلَوْنَ إِن كُنتُم مُّؤْمِنِينَ',
    ),
    ShortVerseNotification(
      surahNameTr: 'Duhâ Suresi',
      surahNameEn: 'Surah Ad-Duha',
      surahNameAr: 'سورة الضحى',
      verseReference: 'Duhâ 93:5',
      arabicText: 'وَلَسَوْفَ يُعْطِيكَ رَبُّكَ فَتَرْضَىٰ',
      textTr: 'Rabbin sana pek yakında verecek ve sen razı olacaksın.',
      textEn: 'And your Lord is going to give you, and you will be satisfied.',
      textAr: 'وَلَسَوْفَ يُعْطِيكَ رَبُّكَ فَتَرْضَىٰ',
    ),
    ShortVerseNotification(
      surahNameTr: 'İbrahim Suresi',
      surahNameEn: 'Surah Ibrahim',
      surahNameAr: 'سورة إبراهيم',
      verseReference: 'İbrahim 14:7',
      arabicText: 'لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ',
      textTr: 'Eğer şükrederseniz, elbette size (nimetimi) artırırım.',
      textEn: 'If you are grateful, I will surely increase you in favor.',
      textAr: 'لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ',
    ),
    ShortVerseNotification(
      surahNameTr: 'Tâhâ Suresi',
      surahNameEn: 'Surah Ta-Ha',
      surahNameAr: 'سورة طه',
      verseReference: 'Tâhâ 20:114',
      arabicText: 'وَقُل رَّبِّ زِدْنِي عِلْمًا',
      textTr: 'De ki: Rabbim! Benim ilmimi artır.',
      textEn: 'And say: My Lord, increase me in knowledge.',
      textAr: 'وَقُل رَّبِّ زِدْنِي عِلْمًا',
    ),
    ShortVerseNotification(
      surahNameTr: 'Zümer Suresi',
      surahNameEn: 'Surah Az-Zumar',
      surahNameAr: 'سورة الزمر',
      verseReference: 'Zümer 39:53',
      arabicText: 'لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ ۚ إِنَّ اللَّهَ يَغْفِرُ الذُّنُوبَ جَمِيعًا',
      textTr: 'Allah\'ın rahmetinden ümidinizi kesmeyin. Şüphesiz Allah bütün günahları bağışlar.',
      textEn: 'Do not despair of the mercy of Allah. Indeed, Allah forgives all sins.',
      textAr: 'لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ ۚ إِنَّ اللَّهَ يَغْفِرُ الذُّنُوبَ جَمِيعًا',
    ),
    ShortVerseNotification(
      surahNameTr: 'Kasas Suresi',
      surahNameEn: 'Surah Al-Qasas',
      surahNameAr: 'سورة القصص',
      verseReference: 'Kasas 28:24',
      arabicText: 'رَبِّ إِنِّي لِمَا أَنزَلْتَ إِلَيَّ مِنْ خَيْرٍ فَقِيرٌ',
      textTr: 'Rabbim! Doğrusu bana indireceğin her hayra muhtacım.',
      textEn: 'My Lord, indeed I am, for whatever good You would send down to me, in need.',
      textAr: 'رَبِّ إِنِّي لِمَا أَنزَلْتَ إِلَيَّ مِنْ خَيْرٍ فَقِيرٌ',
    ),
    ShortVerseNotification(
      surahNameTr: 'Enfâl Suresi',
      surahNameEn: 'Surah Al-Anfal',
      surahNameAr: 'سورة الأنفال',
      verseReference: 'Enfâl 8:46',
      arabicText: 'وَاصْبِرُوا ۚ إِنَّ اللَّهَ مَعَ الصَّابِرِينَ',
      textTr: 'Sabredin; çünkü Allah sabredenlerle beraberdir.',
      textEn: 'And be patient. Indeed, Allah is with the patient.',
      textAr: 'وَاصْبِرُوا ۚ إِنَّ اللَّهَ مَعَ الصَّابِرِينَ',
    ),
    ShortVerseNotification(
      surahNameTr: 'Bakara Suresi',
      surahNameEn: 'Surah Al-Baqarah',
      surahNameAr: 'سورة البقرة',
      verseReference: 'Bakara 2:286',
      arabicText: 'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا',
      textTr: 'Allah hiçbir kimseye gücünün yettiğinden fazlasını yüklemez.',
      textEn: 'Allah does not burden a soul beyond that it can bear.',
      textAr: 'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا',
    ),
    ShortVerseNotification(
      surahNameTr: 'Hadîd Suresi',
      surahNameEn: 'Surah Al-Hadid',
      surahNameAr: 'سورة الحديد',
      verseReference: 'Hadîd 57:4',
      arabicText: 'وَهُوَ مَعَكُمْ أَيْنَ مَا كُنتُمْ',
      textTr: 'Nerede olursanız olun, O daima sizinle beraberdir.',
      textEn: 'And He is with you wherever you are.',
      textAr: 'وَهُوَ مَعَكُمْ أَيْنَ مَا كُنتُمْ',
    ),
    ShortVerseNotification(
      surahNameTr: 'Kâf Suresi',
      surahNameEn: 'Surah Qaf',
      surahNameAr: 'سورة ق',
      verseReference: 'Kâf 50:16',
      arabicText: 'وَنَحْنُ أَقْرَبُ إِلَيْهِ مِنْ حَبْلِ الْوَرِيدِ',
      textTr: 'Biz insana şah damarından daha yakınız.',
      textEn: 'And We are closer to him than his jugular vein.',
      textAr: 'وَنَحْنُ أَقْرَبُ إِلَيْهِ مِنْ حَبْلِ الْوَرِيدِ',
    ),
    ShortVerseNotification(
      surahNameTr: 'Âl-i İmrân Suresi',
      surahNameEn: 'Surah Ali \'Imran',
      surahNameAr: 'سورة آل عمران',
      verseReference: 'Âl-i İmrân 3:173',
      arabicText: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
      textTr: 'Allah bize yeter, O ne güzel vekildir!',
      textEn: 'Sufficient for us is Allah, and He is the best Disposer of affairs.',
      textAr: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
    ),
    ShortVerseNotification(
      surahNameTr: 'Fâtiha Suresi',
      surahNameEn: 'Surah Al-Fatihah',
      surahNameAr: 'سورة الفاتحة',
      verseReference: 'Fâtiha 1:5',
      arabicText: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
      textTr: 'Yalnız Sana kulluk eder ve yalnız Senden yardım dileriz.',
      textEn: 'It is You we worship and You we ask for help.',
      textAr: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
    ),
    ShortVerseNotification(
      surahNameTr: 'Rahmân Suresi',
      surahNameEn: 'Surah Ar-Rahman',
      surahNameAr: 'سورة الرحمن',
      verseReference: 'Rahmân 55:60',
      arabicText: 'هَلْ جَزَاءُ الْإِحْسَانِ إِلَّا الْإِحْسَانُ',
      textTr: 'İyiliğin mükâfatı, ancak iyilik değil midir?',
      textEn: 'Is the reward for good anything but good?',
      textAr: 'هَلْ جَزَاءُ الْإِحْسَانِ إِلَّا الْإِحْسَانُ',
    ),
    ShortVerseNotification(
      surahNameTr: 'Talâk Suresi',
      surahNameEn: 'Surah At-Talaq',
      surahNameAr: 'سورة الطلاق',
      verseReference: 'Talâk 65:2',
      arabicText: 'وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا',
      textTr: 'Kim Allah\'tan sakınırsa, O ona bir çıkış yolu ihsan eder.',
      textEn: 'And whoever fears Allah – He will make for him a way out.',
      textAr: 'وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا',
    ),
    ShortVerseNotification(
      surahNameTr: 'Şûrâ Suresi',
      surahNameEn: 'Surah Ash-Shura',
      surahNameAr: 'سورة الشورى',
      verseReference: 'Şûrâ 42:19',
      arabicText: 'اللَّهُ لَطِيفٌ بِعِبَادِهِ يَرْزُقُ مَن يَشَاءُ',
      textTr: 'Allah kullarına çok lütufkârdır; dilediğini rızıklandırır.',
      textEn: 'Allah is subtle with His servants; He gives provision to whom He wills.',
      textAr: 'اللَّهُ لَطِيفٌ بِعِبَادِهِ يَرْزُقُ مَن يَشَاءُ',
    ),
    ShortVerseNotification(
      surahNameTr: 'Yûnus Suresi',
      surahNameEn: 'Surah Yunus',
      surahNameAr: 'سورة يونس',
      verseReference: 'Yûnus 10:62',
      arabicText: 'أَلَا إِنَّ أَوْلِيَاءَ اللَّهِ لَا خَوْفٌ عَلَيْهِمْ وَلَا هُمْ يَحْزَنُونَ',
      textTr: 'Bilesiniz ki, Allah\'ın dostlarına korku yoktur ve onlar üzülmeyeceklerdir.',
      textEn: 'Unquestionably, for the allies of Allah there will be no fear concerning them, nor will they grieve.',
      textAr: 'أَلَا إِنَّ أَوْلِيَاءَ اللَّهِ لَا خَوْفٌ عَلَيْهِمْ وَلَا هُمْ يَحْزَنُونَ',
    ),
    ShortVerseNotification(
      surahNameTr: 'İsrâ Suresi',
      surahNameEn: 'Surah Al-Isra',
      surahNameAr: 'سورة الإسراء',
      verseReference: 'İsrâ 17:82',
      arabicText: 'وَنُنَزِّلُ مِنَ الْقُرْآنِ مَا هُوَ شِفَاءٌ وَرَحْمَةٌ لِّلْمُؤْمِنِينَ',
      textTr: 'Biz Kur\'an\'dan müminler için şifa ve rahmet olan şeyler indiriyoruz.',
      textEn: 'And We send down of the Quran that which is healing and mercy for the believers.',
      textAr: 'وَنُنَزِّلُ مِنَ الْقُرْآنِ مَا هُوَ شِفَاءٌ وَرَحْمَةٌ لِّلْمُؤْمِنِينَ',
    ),
    ShortVerseNotification(
      surahNameTr: 'Tevbe Suresi',
      surahNameEn: 'Surah At-Tawbah',
      surahNameAr: 'سورة التوبة',
      verseReference: 'Tevbe 9:129',
      arabicText: 'حَسْبِيَ اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ ۖ عَلَيْهِ تَوَكَّلْتُ',
      textTr: 'De ki: Allah bana yeter. O\'ndan başka ilah yoktur. Ben O\'na tevekkül ettim.',
      textEn: 'Say: Sufficient for me is Allah; there is no deity except Him. On Him I have relied.',
      textAr: 'حَسْبِيَ اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ ۖ عَلَيْهِ تَوَكَّلْتُ',
    ),
    ShortVerseNotification(
      surahNameTr: 'Enbiyâ Suresi',
      surahNameEn: 'Surah Al-Anbiya',
      surahNameAr: 'سورة الأنبياء',
      verseReference: 'Enbiyâ 21:87',
      arabicText: 'لَّا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ',
      textTr: 'Senden başka hiçbir ilah yoktur; Seni tenzih ederim. Şüphesiz ben haksızlık edenlerden oldum.',
      textEn: 'There is no deity except You; exalted are You. Indeed, I have been of the wrongdoers.',
      textAr: 'لَّا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ',
    ),
    ShortVerseNotification(
      surahNameTr: 'Nahl Suresi',
      surahNameEn: 'Surah An-Nahl',
      surahNameAr: 'سورة النحل',
      verseReference: 'Nahl 16:128',
      arabicText: 'إِنَّ اللَّهَ مَعَ الَّذِينَ اتَّقَوا وَّالَّذِينَ هُم مُّحْسِنُونَ',
      textTr: 'Şüphesiz Allah, takva sahipleriyle ve daima iyilik edenlerle beraberdir.',
      textEn: 'Indeed, Allah is with those who fear Him and those who are doers of good.',
      textAr: 'إِنَّ اللَّهَ مَعَ الَّذِينَ اتَّقَوا وَّالَّذِينَ هُم مُّحْسِنُونَ',
    ),
    ShortVerseNotification(
      surahNameTr: 'Müzzemmil Suresi',
      surahNameEn: 'Surah Al-Muzzammil',
      surahNameAr: 'سورة المزمل',
      verseReference: 'Müzzemmil 73:8',
      arabicText: 'وَاذْكُرِ اسْمَ رَبِّكَ وَتَبَتَّلْ إِلَيْهِ تَبْتِيلًا',
      textTr: 'Rabbinin adını an ve bütün varlığınla O\'na yönel.',
      textEn: 'And remember the name of your Lord and devote yourself to Him with complete devotion.',
      textAr: 'وَاذْكُرِ اسْمَ رَبِّكَ وَتَبَتَّلْ إِلَيْهِ تَبْتِيلًا',
    ),
    ShortVerseNotification(
      surahNameTr: 'Lokmân Suresi',
      surahNameEn: 'Surah Luqman',
      surahNameAr: 'سورة لقمان',
      verseReference: 'Lokmân 31:17',
      arabicText: 'أَقِمِ الصَّلَاةَ وَأْمُرْ بِالْمَعْرُوفِ وَانْهَ عَنِ الْمُنكَرِ وَاصْبِرْ عَلَىٰ مَا أَصَابَكَ',
      textTr: 'Namazı dosdoğru kıl, iyiliği emret, kötülükten sakındır ve başına gelene sabret.',
      textEn: 'Establish prayer, enjoin what is right, forbid what is wrong, and be patient over what befalls you.',
      textAr: 'أَقِمِ الصَّلَاةَ وَأْمُرْ بِالْمَعْرُوفِ وَانْهَ عَنِ الْمُنكَرِ وَاصْبِرْ عَلَىٰ مَا أَصَابَكَ',
    ),
    ShortVerseNotification(
      surahNameTr: 'Ankebût Suresi',
      surahNameEn: 'Surah Al-Ankabut',
      surahNameAr: 'سورة العنكبوت',
      verseReference: 'Ankebût 29:69',
      arabicText: 'وَالَّذِينَ جَاهَدُوا فِينَا لَنَهْدِيَنَّهُمْ سُبُلَنَا ۚ وَإِنَّ اللَّهَ لَمَعَ الْمُحْسِنِينَ',
      textTr: 'Bizim uğrumuzda gayret gösterenleri elbette yollarımıza eriştiririz. Şüphesiz Allah iyilik edenlerle beraberdir.',
      textEn: 'And those who strive for Us – We will surely guide them to Our ways. And indeed, Allah is with the doers of good.',
      textAr: 'وَالَّذِينَ جَاهَدُوا فِينَا لَنَهْدِيَنَّهُمْ سُبُلَنَا ۚ وَإِنَّ اللَّهَ لَمَعَ الْمُحْسِنِينَ',
    ),
    ShortVerseNotification(
      surahNameTr: 'Mülk Suresi',
      surahNameEn: 'Surah Al-Mulk',
      surahNameAr: 'سورة الملك',
      verseReference: 'Mülk 67:2',
      arabicText: 'الَّذِي خَلَقَ الْمَوْتَ وَالْحَيَاةَ لِيَبْلُوَكُمْ أَيُّكُمْ أَحْسَنُ عَمَلًا',
      textTr: 'O, hanginizin daha güzel amel işleyeceğini sınamak için ölümü ve hayatı yaratandır.',
      textEn: 'He who created death and life to test you as to which of you is best in deed.',
      textAr: 'الَّذِي خَلَقَ الْمَوْتَ وَالْحَيَاةَ لِيَبْلُوَكُمْ أَيُّكُمْ أَحْسَنُ عَمَلًا',
    ),
    ShortVerseNotification(
      surahNameTr: 'Hicr Suresi',
      surahNameEn: 'Surah Al-Hijr',
      surahNameAr: 'سورة الحجر',
      verseReference: 'Hicr 15:98-99',
      arabicText: 'فَسَبِّحْ بِحَمْدِ رَبِّكَ وَكُن مِّنَ السَّاجِدِينَ ﴿٩٨﴾ وَاعْبُدْ رَبَّكَ حَتَّىٰ يَأْتِيَكَ الْيَقِينُ',
      textTr: 'Rabbini hamd ile tesbih et, secde edenlerden ol ve sana ölüm gelinceye kadar Rabbine ibadet et.',
      textEn: 'So exalt with praise of your Lord and be of those who prostrate, and worship your Lord until certainty comes.',
      textAr: 'فَسَبِّحْ بِحَمْدِ رَبِّكَ وَكُن مِّنَ السَّاجِدِينَ ﴿٩٨﴾ وَاعْبُدْ رَبَّكَ حَتَّىٰ يَأْتِيَكَ الْيَقِينُ',
    ),
  ];
}

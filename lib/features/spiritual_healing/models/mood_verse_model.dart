import 'package:flutter/material.dart';

/// Kullanıcının Ruh Hali / Duygu Durumu Modeli
enum SpiritualMood {
  huzunlu,    // Hüzünlü / Kederli
  yalniz,     // Yalnız / Kimsesiz
  endiseli,   // Endişeli / Kaygılı
  sukurlu,    // Şükür Dolu / Mutlu
  ofkeli,     // Öfkeli / Gergin
  kararsiz,   // Kararsız / Çıkmazda
  umutsuz,    // Umutsuz / Yorgun
  huzur,      // Huzur Arayan
}

class MoodVerseData {
  final SpiritualMood mood;
  final String titleTr;
  final String titleEn;
  final String titleAr;
  final String emoji;
  final Color accentColor;
  final String surahRef;
  final int surahId;
  final int verseNumber;
  final String arabicText;
  final String translationTr;
  final String translationEn;
  final String translationAr;
  final String propheticDua;
  final String reflectionTr;
  final String reflectionEn;
  final String reflectionAr;

  const MoodVerseData({
    required this.mood,
    required this.titleTr,
    required this.titleEn,
    required this.titleAr,
    required this.emoji,
    required this.accentColor,
    required this.surahRef,
    required this.surahId,
    required this.verseNumber,
    required this.arabicText,
    required this.translationTr,
    required this.translationEn,
    required this.translationAr,
    required this.propheticDua,
    required this.reflectionTr,
    required this.reflectionEn,
    required this.reflectionAr,
  });

  String localizedTitle(String langCode) {
    if (langCode == 'en') return titleEn;
    if (langCode == 'ar') return titleAr;
    return titleTr;
  }

  String localizedTranslation(String langCode) {
    if (langCode == 'en') return translationEn;
    if (langCode == 'ar') return translationAr;
    return translationTr;
  }

  String localizedReflection(String langCode) {
    if (langCode == 'en') return reflectionEn;
    if (langCode == 'ar') return reflectionAr;
    return reflectionTr;
  }

  static const List<MoodVerseData> list = [
    MoodVerseData(
      mood: SpiritualMood.huzunlu,
      titleTr: 'Hüzünlü',
      titleEn: 'Sad',
      titleAr: 'حزين',
      emoji: '😔',
      accentColor: Color(0xFF64B5F6),
      surahRef: 'İnşirâh 94:5-6',
      surahId: 94,
      verseNumber: 5,
      arabicText: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا ﴿٥﴾ إِنَّ مَعَ الْعُسْرِ يُسْرًا ﴿٦﴾',
      translationTr: 'Şüphesiz her güçlükle beraber bir kolaylık vardır. Evet, her güçlükle beraber mutlaka bir kolaylık vardır.',
      translationEn: 'For indeed, with hardship [will be] ease. Indeed, with hardship [will be] ease.',
      translationAr: 'فإن مع العسر يسراً، إن مع العسر يسراً.',
      propheticDua: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ (Allah\'ım! Kederden ve hüzünden Sana sığınırım.)',
      reflectionTr: 'Gecenin en karanlık anı, şafağın en yakın olduğu andır. Allah Teâlâ bir zorluğun peşine iki kolaylık müjdelemiştir. Bu hüzün geçici, Rabbinin lütfu ise bâkidir.',
      reflectionEn: 'The darkest hour of the night is just before dawn. Allah promises ease alongside every difficulty. This sorrow is temporary, His grace is eternal.',
      reflectionAr: 'إن أشد ساعات الليل ظلمة هي التي تسبق الفجر مباشرة. وعدك الله باليسر، وهذا الحزن سيمضي برحمته.',
    ),
    MoodVerseData(
      mood: SpiritualMood.yalniz,
      titleTr: 'Yalnız',
      titleEn: 'Lonely',
      titleAr: 'وحيد',
      emoji: '🤲',
      accentColor: Color(0xFFFFD54F),
      surahRef: 'Kâf 50:16',
      surahId: 50,
      verseNumber: 16,
      arabicText: 'وَنَحْنُ أَقْرَبُ إِلَيْهِ مِنْ حَبْلِ الْوَرِيدِ',
      translationTr: 'Andolsun insanı Biz yarattık ve nefsinin ona ne fısıldadığını biliriz. Biz ona şah damarından daha yakınız.',
      translationEn: 'And We are closer to him than [his] jugular vein.',
      translationAr: 'ونحن أقرب إليه من حبل الوريد.',
      propheticDua: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ (Allah bize yeter; O ne güzel vekildir.)',
      reflectionTr: 'Dünyadaki herkes seni terk etse bile, seni yoktan var eden Rabbin bir an bile yalnız bırakmaz. Kalbini O\'na aç, O seni işitendir.',
      reflectionEn: 'Even if the entire world turns away, the One who created you never leaves you alone. Whisper your pain to Him, for He is ever near.',
      reflectionAr: 'حتى لو تخلى عنك الجميع، فإن ربك الذي خلقك لم يتركك طرفة عين. اقترب منه يسمعك ويؤنس وحدتك.',
    ),
    MoodVerseData(
      mood: SpiritualMood.endiseli,
      titleTr: 'Endişeli / Kaygılı',
      titleEn: 'Anxious',
      titleAr: 'قلق',
      emoji: '😰',
      accentColor: Color(0xFF81C784),
      surahRef: 'Ra\'d 13:28',
      surahId: 13,
      verseNumber: 28,
      arabicText: 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
      translationTr: 'Bilin ki, kalpler ancak Allah\'ı anmakla huzur ve sükûna kavuşur.',
      translationEn: 'Unquestionably, by the remembrance of Allah hearts are assured.',
      translationAr: 'ألا بذكر الله تطمئن القلوب.',
      propheticDua: 'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ (Ey Hayy ve Kayyûm olan Allah\'ım! Rahmetinle yardımını dilerim.)',
      reflectionTr: 'Gelecek henüz gelmedi, geçmiş ise geçti. Şu anın sahibi Allah\'tır. Zihnini yoran endişeleri O\'nun sonsuz kudretine ve takdirine teslim et.',
      reflectionEn: 'The future hasn\'t arrived, and the past is gone. Surrender the burdens on your heart to Allah’s infinite mercy and care.',
      reflectionAr: 'المستقبل بيد الله والماضي مضى. سلّم أمرك لمن يدبّر الأمر من السماء إلى الأرض، واستأنس بذكره.',
    ),
    MoodVerseData(
      mood: SpiritualMood.sukurlu,
      titleTr: 'Şükür Dolu',
      titleEn: 'Grateful',
      titleAr: 'شاكر',
      emoji: '🌸',
      accentColor: Color(0xFFF48FB1),
      surahRef: 'İbrâhîm 14:7',
      surahId: 14,
      verseNumber: 7,
      arabicText: 'لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ',
      translationTr: 'Andolsun, eğer şükrederseniz elbette size (nimetimi) artırırım.',
      translationEn: 'If you are grateful, I will surely increase you [in favor].',
      translationAr: 'لئن شكرتم لأزيدنكم.',
      propheticDua: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ عَلَى كُلِّ حَالٍ (Her hâlimiz için Âlemlerin Rabbi Allah\'a hamd olsun.)',
      reflectionTr: 'Şükür, sahip olduğun nimetlerin bereket anahtarıdır. Dilin elhamdülillah derken, kalbin de Rabbinin sayısız lütfunu hissetsin.',
      reflectionEn: 'Gratitude multiplies every blessing. When your tongue says Alhamdulillah, let your soul embrace the beauty of His gifts.',
      reflectionAr: 'الشكر مفتاح المزيد وقيد النعم. الحمد لله الذي بنعمته تتم الصالحات.',
    ),
    MoodVerseData(
      mood: SpiritualMood.ofkeli,
      titleTr: 'Öfkeli / Gergin',
      titleEn: 'Angry / Stressed',
      titleAr: 'غاضب',
      emoji: '⚡',
      accentColor: Color(0xFFFF8A65),
      surahRef: 'Âl-i İmrân 3:134',
      surahId: 3,
      verseNumber: 134,
      arabicText: 'وَالْكَاظِمِينَ الْغَيْظَ وَالْعَافِينَ عَنِ النَّاسِ ۗ وَاللَّهُ يُحِبُّ الْمُحْسِنِينَ',
      translationTr: 'Onlar öfkelerini yutarlar ve insanları affederler. Allah ise iyilik ve ihsan sahiplerini sever.',
      translationEn: 'And who restrain anger and who pardon the people - and Allah loves the doers of good.',
      translationAr: 'والكاظمين الغيظ والعافين عن الناس والله يحب المحسنين.',
      propheticDua: 'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ (Kovulmuş şeytandan Allah\'a sığınırım.)',
      reflectionTr: 'Öfke ateştendir, onu serinletecek olan ise abdest, sabır ve derin bir tefekkürdür. Affetmek, kalbe yük olan prangaları çözmektir.',
      reflectionEn: 'Anger is a fire quenched by wudu, silence, and patience. Forgiving others frees your own heart from spiritual burdens.',
      reflectionAr: 'الغضب جمرة تطفئها الاستعاذة والوضوء والحلم. من كظم غيظاً ملأ الله قلبه أمناً وإيماناً.',
    ),
    MoodVerseData(
      mood: SpiritualMood.kararsiz,
      titleTr: 'Kararsız / Çıkmazda',
      titleEn: 'Confused',
      titleAr: 'حائر',
      emoji: '💭',
      accentColor: Color(0xFFBA68C8),
      surahRef: 'Talâk 65:3',
      surahId: 65,
      verseNumber: 3,
      arabicText: 'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ ۚ إِنَّ اللَّهَ بَالِغُ أَمْرِهِ',
      translationTr: 'Kim Allah\'a tevekkül ederse, O ona yeter. Şüphesiz Allah, emrini yerine getirendir.',
      translationEn: 'And whoever relies upon Allah - then He is sufficient for him. Indeed, Allah will accomplish His purpose.',
      translationAr: 'ومن يتوكل على الله فهو حسبه، إن الله بالغ أمره.',
      propheticDua: 'اللَّهُمَّ خِرْ لِي وَاخْتَرْ لِي (Allah\'ım! Benim için en hayırlısını kıl ve benim için Sen seç.)',
      reflectionTr: 'Yollar tıkandığında istihâre ve duayla Allah\'a yönel. O, kuluna hiç ummadığı kapıları açmaya kâdirdir.',
      reflectionEn: 'When paths seem blocked, turn to Istikhara and Dua. Allah is able to open doors where you thought there were only walls.',
      reflectionAr: 'استخر الله وتوكل عليه؛ فمن فوّض أمره إلى الله كفاه ما أهمّه وأرشده إلى خير سبيله.',
    ),
    MoodVerseData(
      mood: SpiritualMood.umutsuz,
      titleTr: 'Umutsuz / Yorgun',
      titleEn: 'Despairing',
      titleAr: 'يائس',
      emoji: '🤍',
      accentColor: Color(0xFF4DB6AC),
      surahRef: 'Zümer 39:53',
      surahId: 39,
      verseNumber: 53,
      arabicText: 'لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ ۚ إِنَّ اللَّهَ يَغْفِرُ الذُّنُوبَ جَمِيعًا',
      translationTr: 'De ki: "Ey nefisleri aleyhine haddi aşan kullarım! Allah\'ın rahmetinden ümidinizi kesmeyin. Muhakkak ki Allah bütün günahları bağışlar."',
      translationEn: 'Do not despair of the mercy of Allah. Indeed, Allah forgives all sins. Indeed, it is He who is the Forgiving, the Merciful.',
      translationAr: 'لا تقنطوا من رحمة الله، إن الله يغفر الذنوب جميعاً.',
      propheticDua: 'يَا مُقَلِّبَ الْقُلُوبِ ثَبِّتْ قَلْبِي عَلَى دِينِكَ (Ey kalpleri evirip çeviren Allah\'ım! Kalbimi dinin üzere sabit kıl.)',
      reflectionTr: 'Tüm kapılar yüzüne kapansa da Allah\'ın rahmet kapısı kıyamete kadar açıktır. Tövbe et, derin bir nefes al ve yeniden başla.',
      reflectionEn: 'Even if all doors close, the gate of Divine Mercy never shuts. Repent, breathe deeply, and begin again with hope.',
      reflectionAr: 'رحمة الله وسعت كل شيء، وبابه مفتوح لمن ناداه. استغفر وابدأ من جديد فإن الله معك.',
    ),
    MoodVerseData(
      mood: SpiritualMood.huzur,
      titleTr: 'Huzur Arayan',
      titleEn: 'Seeking Peace',
      titleAr: 'باحث عن السكينة',
      emoji: '🕊️',
      accentColor: Color(0xFF26A69A),
      surahRef: 'Fecr 89:27-28',
      surahId: 89,
      verseNumber: 27,
      arabicText: 'يَا أَيَّتُهَا النَّفْسُ الْمُطْمَئِنَّةُ ﴿٢٧﴾ ارْجِعِي إِلَىٰ رَبِّكِ رَاضِيَةً مَّرْضِيَّةً ﴿٢٨﴾',
      translationTr: 'Ey huzura kavuşmuş nefis! Sen O\'ndan razı, O da senden razı olarak Rabbine dön!',
      translationEn: '[To the righteous it will be said], "O reassured soul, Return to your Lord, well-pleased and pleasing [to Him]."',
      translationAr: 'يا أيتها النفس المطمئنة، ارجعي إلى ربك راضية مرضية.',
      propheticDua: 'اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالإِكْرَامِ (Allah\'ım! Selam Sensin, selamet ancak Sen\'dendir.)',
      reflectionTr: 'Gerçek huzur dış dünyada değil, secdeye eğilen kalptedir. Dünyanın gürültüsünü sustur ve Rabbinin kelamıyla dinlen.',
      reflectionEn: 'True peace is found not in the outside world, but in prostration before the Divine. Let Quran be the sanctuary of your soul.',
      reflectionAr: 'السكينة تنزل في السجود ومناجاة الله. اترك ضجيج الحياة واقترب من كتاب الله ترتاح روحك.',
    ),
  ];
}

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
    if (langCode == 'id') {
      switch (mood) {
        case SpiritualMood.huzunlu: return 'Sedih';
        case SpiritualMood.yalniz: return 'Kesepian';
        case SpiritualMood.endiseli: return 'Cemas';
        case SpiritualMood.sukurlu: return 'Bersyukur';
        case SpiritualMood.ofkeli: return 'Marah';
        case SpiritualMood.kararsiz: return 'Bingung';
        case SpiritualMood.umutsuz: return 'Putus Asa';
        case SpiritualMood.huzur: return 'Mencari Ketenangan';
      }
    }
    if (langCode == 'ar') return titleAr;
    if (langCode != 'tr') return titleEn;
    return titleTr;
  }

  String localizedTranslation(String langCode) {
    if (langCode == 'id') {
      switch (mood) {
        case SpiritualMood.huzunlu:
          return 'Maka sesungguhnya bersama kesulitan ada kemudahan, sesungguhnya bersama kesulitan ada kemudahan.';
        case SpiritualMood.yalniz:
          return 'Dan Kami lebih dekat kepadanya daripada urat lehernya.';
        case SpiritualMood.endiseli:
          return 'Ingatlah, hanya dengan mengingat Allah hati menjadi tenteram.';
        case SpiritualMood.sukurlu:
          return 'Sesungguhnya jika kamu bersyukur, niscaya Aku akan menambah (nikmat) kepadamu.';
        case SpiritualMood.ofkeli:
          return 'Dan orang-orang yang menahan amarahnya dan memaafkan (kesalahan) orang lain. Dan Allah mencintai orang yang berbuat kebaikan.';
        case SpiritualMood.kararsiz:
          return 'Dan barangsiapa bertawakal kepada Allah, niscaya Allah akan mencukupkannya. Sesungguhnya Allah melaksanakan urusan-Nya.';
        case SpiritualMood.umutsuz:
          return 'Janganlah kamu berputus asa dari rahmat Allah. Sesungguhnya Allah mengampuni dosa-dosa semuanya.';
        case SpiritualMood.huzur:
          return 'Wahai jiwa yang tenang! Kembalilah kepada Tuhanmu dengan hati yang ridha lagi diridhai-Nya.';
      }
    }
    if (langCode == 'ar') return translationAr;
    if (langCode != 'tr') return translationEn;
    return translationTr;
  }

  String localizedReflection(String langCode) {
    if (langCode == 'id') {
      switch (mood) {
        case SpiritualMood.huzunlu:
          return 'Malam yang paling gelap adalah saat menjelang fajar. Allah berjanji kemudahan menyertai setiap kesulitan. Kesedihan ini sementara, rahmat-Nya abadi.';
        case SpiritualMood.yalniz:
          return 'Bahkan jika seluruh dunia menjauh, Tuhan yang menciptakanmu tidak pernah meninggalkanmu. Bisikkan doamu kepada-Nya, karena Dia sangat dekat.';
        case SpiritualMood.endiseli:
          return 'Masa depan belum tiba, dan masa lalu telah berlalu. Serahkan beban hatimu kepada kasih sayang dan penjagaan Allah Yang Maha Kuasa.';
        case SpiritualMood.sukurlu:
          return 'Rasa syukur melipatgandakan setiap nikmat. Saat lisanmu mengucap Alhamdulillah, biarkan jiwamu meresapi keindahan anugerah-Nya.';
        case SpiritualMood.ofkeli:
          return 'Amarah adalah api yang dipadamkan dengan wudhu, diam, dan sabar. Memaafkan orang lain membebaskan hatimu sendiri dari beban batin.';
        case SpiritualMood.kararsiz:
          return 'Saat jalan terasa buntu, berserahlah dengan Istikharah dan Doa. Allah mampu membukakan pintu kebaikan dari arah yang tak terduga.';
        case SpiritualMood.umutsuz:
          return 'Meski semua pintu dunia tertutup, pintu Rahmat Ilahi tidak pernah terkunci. Bertaubatlah dan mulailah kembali dengan penuh harapan.';
        case SpiritualMood.huzur:
          return 'Ketenangan sejati bukan ditemukan di dunia luar, melainkan dalam sujud. Jadikan Al-Qur\'an tempat perlindungan terindah jiwamu.';
      }
    }
    if (langCode == 'ar') return reflectionAr;
    if (langCode != 'tr') return reflectionEn;
    return reflectionTr;
  }

  String localizedPropheticDua(String langCode) {
    if (langCode == 'id') {
      switch (mood) {
        case SpiritualMood.huzunlu:
          return 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ\n(Ya Allah, aku berlindung kepada-Mu dari rasa gundah dan sedih.)';
        case SpiritualMood.yalniz:
          return 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ\n(Cukuplah Allah menjadi Penolong kami dan sebaik-baik Pelindung.)';
        case SpiritualMood.endiseli:
          return 'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ\n(Wahai Yang Maha Hidup, wahai Yang Berdiri Sendiri, dengan rahmat-Mu aku memohon pertolongan.)';
        case SpiritualMood.sukurlu:
          return 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ عَلَى كُلِّ حَالٍ\n(Segala puji bagi Allah, Tuhan semesta alam, dalam setiap keadaan.)';
        case SpiritualMood.ofkeli:
          return 'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ\n(Aku berlindung kepada Allah dari godaan setan yang terkutuk.)';
        case SpiritualMood.kararsiz:
          return 'اللَّهُمَّ خِرْ لِي وَاخْتَرْ لِي\n(Ya Allah, pilihlah untukku dan tentukan yang terbaik bagiku.)';
        case SpiritualMood.umutsuz:
          return 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ الْعَلِيِّ الْعَظِيمِ\n(Tiada daya dan kekuatan melainkan dengan pertolongan Allah Yang Maha Tinggi lagi Maha Agung.)';
        case SpiritualMood.huzur:
          return 'اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ\n(Ya Allah, Engkaulah Kedamaian dan dari-Mu datangnya keselamatan.)';
      }
    }
    if (langCode == 'ar') {
      switch (mood) {
        case SpiritualMood.huzunlu:
          return 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ';
        case SpiritualMood.yalniz:
          return 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ';
        case SpiritualMood.endiseli:
          return 'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ';
        case SpiritualMood.sukurlu:
          return 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ عَلَى كُلِّ حَالٍ';
        case SpiritualMood.ofkeli:
          return 'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ';
        case SpiritualMood.kararsiz:
          return 'اللَّهُمَّ خِرْ لِي وَاخْتَرْ لِي';
        case SpiritualMood.umutsuz:
          return 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ الْعَلِيِّ الْعَظِيمِ';
        case SpiritualMood.huzur:
          return 'اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ';
      }
    }
    if (langCode != 'tr') {
      switch (mood) {
        case SpiritualMood.huzunlu:
          return 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ\n(O Allah, I seek refuge in You from grief and sadness.)';
        case SpiritualMood.yalniz:
          return 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ\n(Sufficient for us is Allah, and He is the best Disposer of affairs.)';
        case SpiritualMood.endiseli:
          return 'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ\n(O Ever-Living, O Sustainer, by Your mercy I seek assistance.)';
        case SpiritualMood.sukurlu:
          return 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ عَلَى كُلِّ حَالٍ\n(All praise is due to Allah, Lord of the worlds, in all circumstances.)';
        case SpiritualMood.ofkeli:
          return 'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ\n(I seek refuge in Allah from Satan the outcast.)';
        case SpiritualMood.kararsiz:
          return 'اللَّهُمَّ خِرْ لِي وَاخْتَرْ لِي\n(O Allah, make a good choice for me and choose what is best for me.)';
        case SpiritualMood.umutsuz:
          return 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ الْعَلِيِّ الْعَظِيمِ\n(There is no might nor power except with Allah, the Most High, the Almighty.)';
        case SpiritualMood.huzur:
          return 'اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ\n(O Allah, You are Peace and from You comes peace.)';
      }
    }
    return propheticDua;
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

/// Duvar Kağıdı ve Hikaye Stüdyosu İçin Seçilmiş Estetik Âyet & Dua Modeli
class CuratedVersePreset {
  final String category;
  final String reference;
  final String arabic;
  final String meaning;

  const CuratedVersePreset({
    required this.category,
    required this.reference,
    required this.arabic,
    required this.meaning,
  });

  static const List<CuratedVersePreset> presets = [
    // ── Huzur & Şifa ──────────────────────────────────────────
    CuratedVersePreset(
      category: 'Huzur & Şifa',
      reference: 'İnşirâh 94:6',
      arabic: 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
      meaning: 'Şüphesiz her güçlükle beraber bir kolaylık vardır.',
    ),
    CuratedVersePreset(
      category: 'Huzur & Şifa',
      reference: 'Ra\'d 13:28',
      arabic: 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
      meaning: 'Bilesiniz ki, kalpler ancak Allah\'ı anmakla huzur bulur.',
    ),
    CuratedVersePreset(
      category: 'Huzur & Şifa',
      reference: 'Kâf 50:16',
      arabic: 'وَنَحْنُ أَقْرَبُ إِلَيْهِ مِنْ حَبْلِ الْوَرِيدِ',
      meaning: 'Biz ona şah damarından daha yakınız.',
    ),
    CuratedVersePreset(
      category: 'Huzur & Şifa',
      reference: 'Bakara 2:286',
      arabic: 'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا',
      meaning: 'Allah hiçbir kimseye gücünün yettiğinden fazlasını yüklemez.',
    ),

    // ── Dua & Münâcât ─────────────────────────────────────────
    CuratedVersePreset(
      category: 'Dua & Münâcât',
      reference: 'Tâhâ 20:25-26',
      arabic: 'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي',
      meaning: 'Rabbim! Gönlüme ferahlık ver ve işimi bana kolaylaştır.',
    ),
    CuratedVersePreset(
      category: 'Dua & Münâcât',
      reference: 'Enbiyâ 21:87',
      arabic: 'لَا إِلَٰهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
      meaning: 'Senden başka ilah yoktur. Seni tenzih ederim. Şüphesiz ben nefsimi haksızlığa uğratanlardan oldum.',
    ),
    CuratedVersePreset(
      category: 'Dua & Münâcât',
      reference: 'Bakara 2:201',
      arabic: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً',
      meaning: 'Rabbimiz! Bize dünyada da iyilik ver, ahirette de iyilik ver ve bizi cehennem azabından koru.',
    ),
    CuratedVersePreset(
      category: 'Dua & Münâcât',
      reference: 'İbrâhîm 14:40',
      arabic: 'رَبِّ اجْعَلْنِي مُقِيمَ الصَّلَاةِ وَمِنْ ذُرِّيَّتِي رَبَّنَا وَتَقَبَّلْ دُعَاءِ',
      meaning: 'Rabbim! Beni ve zürriyetimi namazı dosdoğru kılanlardan eyle. Rabbimiz, duamı kabul buyur.',
    ),

    // ── Umut & Rahmet ─────────────────────────────────────────
    CuratedVersePreset(
      category: 'Umut & Rahmet',
      reference: 'Zümer 39:53',
      arabic: 'لَا تَقْنَطُوا مِنْ رَحْمَةِ اللَّهِ إِنَّ اللَّهَ يَغْفِرُ الذُّنُوبَ جَمِيعًا',
      meaning: 'Allah\'ın rahmetinden ümidinizi kesmeyin. Şüphesiz Allah bütün günahları bağışlayandır.',
    ),
    CuratedVersePreset(
      category: 'Umut & Rahmet',
      reference: 'Talâk 65:3',
      arabic: 'وَمَنْ يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ',
      meaning: 'Kim Allah\'a tevekkül ederse, O ona yeter.',
    ),
    CuratedVersePreset(
      category: 'Umut & Rahmet',
      reference: 'Duhâ 93:5',
      arabic: 'وَلَسَوْفَ يُعْطِيكَ رَبُّكَ فَتَرْضَىٰ',
      meaning: 'Rabbin sana verecek ve sen hoşnut olacaksın.',
    ),
    CuratedVersePreset(
      category: 'Umut & Rahmet',
      reference: 'Tevbe 9:129',
      arabic: 'حَسْبِيَ اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ',
      meaning: 'Bana Allah yeter. O\'ndan başka ilah yoktur. Ben yalnız O\'na güvenip dayandım.',
    ),

    // ── Sabır & Tevekkül ──────────────────────────────────────
    CuratedVersePreset(
      category: 'Sabır & Tevekkül',
      reference: 'Bakara 2:153',
      arabic: 'يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ إِنَّ اللَّهَ مَعَ الصَّابِرِينَ',
      meaning: 'Ey iman edenler! Sabır ve namazla Allah\'tan yardım dileyin. Şüphesiz Allah sabredenlerle beraberdir.',
    ),
    CuratedVersePreset(
      category: 'Sabır & Tevekkül',
      reference: 'Âl-i İmrân 3:173',
      arabic: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
      meaning: 'Allah bize yeter, O ne güzel vekildir.',
    ),
    CuratedVersePreset(
      category: 'Sabır & Tevekkül',
      reference: 'Tevbe 9:51',
      arabic: 'قُلْ لَنْ يُصِيبَنَا إِلَّا مَا كَتَبَ اللَّهُ لَنَا هُوَ مَوْلَانَا',
      meaning: 'De ki: Allah\'ın bizim için yazdığından başkası bize asla erişmez. O bizim Mevlâmızdır.',
    ),
    CuratedVersePreset(
      category: 'Sabır & Tevekkül',
      reference: 'Yûsuf 12:86',
      arabic: 'إِنَّمَا أَشْكُو بَثِّي وَحُزْنِي إِلَى اللَّهِ',
      meaning: 'Ben keder ve hüznümü sadece Allah\'a arz ederim.',
    ),

    // ── Âyet-el Kürsî & Muhafaza ──────────────────────────────
    CuratedVersePreset(
      category: 'Muhafaza',
      reference: 'Bakara 2:255 (Âyet-el Kürsî)',
      arabic: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ',
      meaning: 'Allah O\'dur ki, O\'ndan başka ilah yoktur. Hayy\'dır, Kayyûm\'dur. O\'nu ne bir uyuklama ne de bir uyku tutar.',
    ),
    CuratedVersePreset(
      category: 'Muhafaza',
      reference: 'İhlâs 112:1-2',
      arabic: 'قُلْ هُوَ اللَّهُ أَحَدٌ • اللَّهُ الصَّمَدُ',
      meaning: 'De ki: O Allah tektir. Allah Samed\'dir (her şey O\'na muhtaçtır).',
    ),
  ];
}

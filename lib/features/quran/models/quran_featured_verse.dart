/// Kur'an-ı Kerim'deki Meşhur ve Faziletli Âyetler / Âyet Duaları Modeli
class QuranFeaturedVerse {
  final String id;
  final String title;
  final int surahId;
  final String surahName;
  final int verseNumber;
  final String verseRange;
  final String subtitle;
  final String arabicSnippet;
  final String turkishMeaning;
  final List<String> searchKeywords;

  const QuranFeaturedVerse({
    required this.id,
    required this.title,
    required this.surahId,
    required this.surahName,
    required this.verseNumber,
    required this.verseRange,
    required this.subtitle,
    required this.arabicSnippet,
    required this.turkishMeaning,
    required this.searchKeywords,
  });

  bool matchesQuery(String query) {
    if (query.trim().isEmpty) return false;
    final q = normalize(query);
    if (normalize(title).contains(q)) return true;
    if (normalize(surahName).contains(q)) return true;
    if (normalize(subtitle).contains(q)) return true;
    if (normalize(turkishMeaning).contains(q)) return true;
    for (final kw in searchKeywords) {
      if (normalize(kw).contains(q) || q.contains(normalize(kw))) return true;
    }
    return false;
  }

  static String normalize(String s) {
    var str = s.toLowerCase();
    str = str.replaceAll('â', 'a').replaceAll('Â', 'a')
             .replaceAll('î', 'i').replaceAll('Î', 'i')
             .replaceAll('û', 'u').replaceAll('Û', 'u')
             .replaceAll('ı', 'i').replaceAll('İ', 'i').replaceAll('I', 'i')
             .replaceAll('ğ', 'g').replaceAll('Ğ', 'g')
             .replaceAll('ü', 'u').replaceAll('Ü', 'u')
             .replaceAll('ş', 's').replaceAll('Ş', 's')
             .replaceAll('ö', 'o').replaceAll('Ö', 'o')
             .replaceAll('ç', 'c').replaceAll('Ç', 'c');
    return str.replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}

/// Kur'an-ı Kerim'in En Faziletli ve En Çok Okunan 13 Âyeti & Duası
final List<QuranFeaturedVerse> featuredQuranicVersesList = [
  const QuranFeaturedVerse(
    id: 'ayetel_kursi',
    title: 'Âyetü\'l-Kürsî',
    surahId: 2,
    surahName: 'Bakara',
    verseNumber: 255,
    verseRange: '255',
    subtitle: 'Kur\'an\'ın en azametli ayeti, Tevhid ve ilahi muhafaza kalkanı',
    arabicSnippet: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ...',
    turkishMeaning: 'Allah, O\'ndan başka ilah yoktur; diridir, her şeyin varlığı Kendisine bağlı ve dayalıdır. Ne uyuklama tutar O\'nu ne de uyku...',
    searchKeywords: ['aye', 'ayet', 'kursi', 'ayetel kursi', 'ayetulkursi', 'bakara 255', 'koruma', 'tevhid', 'muhafaza'],
  ),
  const QuranFeaturedVerse(
    id: 'amenerrasulu',
    title: 'Âmenerresûlü',
    surahId: 2,
    surahName: 'Bakara',
    verseNumber: 285,
    verseRange: '285-286',
    subtitle: 'Mirac gecesi hediyesi; gece okuyana her hayır için kafi gelir',
    arabicSnippet: 'آمَنَ الرَّسُولُ بِمَا أُنزِلَ إِلَيْهِ مِن رَّبِّهِ وَالْمُؤْمِنُونَ...',
    turkishMeaning: 'Peygamber, Rabbinden kendisine indirilene iman etti, müminler de. Hepsi Allah\'a, meleklerine, kitaplarına ve peygamberlerine iman etti...',
    searchKeywords: ['amenerrasulu', 'amenerresulu', 'amenerresul', 'bakara son iki ayet', 'yatsi', 'dua'],
  ),
  const QuranFeaturedVerse(
    id: 'fatiha',
    title: 'Fâtiha Suresi (Ümmü\'l-Kitap)',
    surahId: 1,
    surahName: 'Fâtiha',
    verseNumber: 1,
    verseRange: '1-7',
    subtitle: 'Namazın esası, Kur\'an\'ın fatihi ve bedene-ruha şifa (eş-Şâfiye)',
    arabicSnippet: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ۝ الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ...',
    turkishMeaning: 'Hamd âlemlerin Rabbi, Rahmân, Rahîm, hesap gününün sahibi olan Allah\'a mahsustur. Yalnız Sana ibadet eder, yalnız Senden yardım dileriz...',
    searchKeywords: ['fatiha', 'elham', 'fatiha suresi', 'sifa', 'namaz'],
  ),
  const QuranFeaturedVerse(
    id: 'insirah',
    title: 'İnşirâh Suresi (Elem Neşrah)',
    surahId: 94,
    surahName: 'İnşirâh',
    verseNumber: 1,
    verseRange: '1-8',
    subtitle: 'Her zorlukla beraber bir kolaylık; kalbe ve ruha ferahlık',
    arabicSnippet: 'أَلَمْ نَشْرَحْ لَكَ صَدْرَكَ ۝ وَوَضَعْنَا عَنكَ وِزْرَكَ...',
    turkishMeaning: 'Senin göğsünü açıp genişletmedik mi? Belini büken yükünü üzerinden indirmedik mi? Şüphesiz zorlukla beraber bir kolaylık vardır...',
    searchKeywords: ['insirah', 'elem nesrah', 'elemneşrah', 'ferahlik', 'kolaylik', 'kalp genisligi'],
  ),
  const QuranFeaturedVerse(
    id: 'lev_enzelna',
    title: 'Hüvallâhüllezî (Lev Enzelnâ)',
    surahId: 59,
    surahName: 'Haşr',
    verseNumber: 21,
    verseRange: '21-24',
    subtitle: 'Haşr Suresi son 4 ayet; Esma-i Hüsna ve 70 bin meleğin istiğfarı',
    arabicSnippet: 'لَوْ أَنزَلْنَا هَٰذَا الْقُرْآنَ عَلَىٰ جَبَلٍ لَّرَأَيْتَهُ خَاشِعًا مُّتَصَدِّعًا مِّنْ خَشْيَةِ اللَّهِ...',
    turkishMeaning: 'Eğer biz bu Kur\'an\'ı bir dağa indirseydik, muhakkak onu Allah korkusundan boyun eğmiş, parça parça olmuş görürdün...',
    searchKeywords: ['lev enzelna', 'huvallahullezi', 'hasr', 'hasr son ayetler', 'esmaul husna'],
  ),
  const QuranFeaturedVerse(
    id: 'nazar_ayeti',
    title: 'Nazar Âyeti (Ve İn Yekâd)',
    surahId: 68,
    surahName: 'Kalem',
    verseNumber: 51,
    verseRange: '51-52',
    subtitle: 'Kem göz, enjoysuz bakış ve hasede karşı Kur\'an kalkanı',
    arabicSnippet: 'وَإِن يَكَادُ الَّذِينَ كَفَرُوا لَيُزْلِقُونَكَ بِأَبْصَارِهِمْ لَمَّا سَمِعُوا الذِّكْرَ...',
    turkishMeaning: 'O inkârcılar Kur\'an\'ı işittikleri zaman, neredeyse seni gözleriyle yıkıp devireceklerdi...',
    searchKeywords: ['nazar', 'nazar duasi', 've in yekad', 've inyekad', 'kalem', 'goz degmesi', 'haset'],
  ),
  const QuranFeaturedVerse(
    id: 'rabbena_atina',
    title: 'Rabbena Âtina & Rabbenağfirli',
    surahId: 2,
    surahName: 'Bakara',
    verseNumber: 201,
    verseRange: '201',
    subtitle: 'Dünya ve ahiretin bütün hayırlarını toplayan en kapsamlı Kur\'an duası',
    arabicSnippet: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ...',
    turkishMeaning: 'Rabbimiz! Bize dünyada da iyilik ve güzellik ver, ahirette de iyilik ve güzellik ver ve bizi cehennem azabından koru...',
    searchKeywords: ['rabbena', 'atina', 'rabbena atina', 'rabbenagfirli', 'namaz sonu', 'bakara 201'],
  ),
  const QuranFeaturedVerse(
    id: 'hz_yunus',
    title: 'Hz. Yûnus\'un Sıkıntı Zikri',
    surahId: 21,
    surahName: 'Enbiyâ',
    verseNumber: 87,
    verseRange: '87',
    subtitle: 'Karanlıkları aydınlığa çeviren, darlıktan halas eden münacat',
    arabicSnippet: 'لَّا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ...',
    turkishMeaning: 'Senden başka hiçbir ilah yoktur; Seni tenzih ederim. Şüphesiz ben nefsimi zalimlerden kılmıştım...',
    searchKeywords: ['yunus', 'la ilahe illa ente subhaneke', 'sikinti duasi', 'ferahlik', 'enbiya 87'],
  ),
  const QuranFeaturedVerse(
    id: 'hz_eyyub_sifa',
    title: 'Hz. Eyyûb\'un Şifa Niyazı',
    surahId: 21,
    surahName: 'Enbiyâ',
    verseNumber: 83,
    verseRange: '83',
    subtitle: 'Büyük musibet ve hastalıklara karşı sabır ve tam teslimiyet',
    arabicSnippet: 'أَنِّي مَسَّنِيَ الضُّرُّ وَأَنتَ أَرْحَمُ الرَّاحِمِينَ...',
    turkishMeaning: 'Başıma bu dert geldi, Sen ise merhametlilerin en merhametlisisin...',
    searchKeywords: ['sifa', 'hastalik', 'eyyub', 'enbiya 83', 'sifa ayeti', 'sabir'],
  ),
  const QuranFeaturedVerse(
    id: 'rabbi_yessir_taha',
    title: 'Tâhâ Duası (Rabbişrah lî Sadrî)',
    surahId: 20,
    surahName: 'Tâhâ',
    verseNumber: 25,
    verseRange: '25-28',
    subtitle: 'Sınav, hitabet, zor görevler ve zihin açıklığı için Hz. Musa\'nın duası',
    arabicSnippet: 'رَبِّ اشْرَحْ لِي صَدْرِي ۝ وَيَسِّرْ لِي أَمْرِي ۝ وَاحْلُلْ عُقْدَةً مِّن لِّسَانِي...',
    turkishMeaning: 'Rabbim! Göğsümü genişlet, işimi bana kolaylaştır, dilimin bağını çöz ki sözümü anlasınlar...',
    searchKeywords: ['rabbi yessir', 'rabbisrah li sadri', 'taha', 'sinav', 'zihin acikligi', 'konusma'],
  ),
  const QuranFeaturedVerse(
    id: 'ihlas_felak_nas',
    title: 'Muavvizeteyn (İhlâs, Felak, Nâs)',
    surahId: 112,
    surahName: 'İhlâs',
    verseNumber: 1,
    verseRange: '1-4',
    subtitle: 'Şeytanların, karanlığın, büyücülerin ve vesvesenin şerrinden sığınma',
    arabicSnippet: 'قُلْ هُوَ اللَّهُ أَحَدٌ ۝ قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۝ قُلْ أَعُوذُ بِرَبِّ النَّاسِ...',
    turkishMeaning: 'De ki: O Allah tektir... De ki: Yarattığı şeylerin şerrinden sabahın Rabbine sığınırım... İnsanların Rabbine, Melikine, İlahına sığınırım...',
    searchKeywords: ['ihlas', 'felak', 'nas', 'muavvizeteyn', 'kul huvallahu', 'siginma', 'vesvese'],
  ),
  const QuranFeaturedVerse(
    id: 'sayyid_istiğfar_furkan',
    title: 'Salih Eş ve Nesil Duası',
    surahId: 25,
    surahName: 'Furkân',
    verseNumber: 74,
    verseRange: '74',
    subtitle: 'Huzurlu bir yuva, göz aydınlığı evlatlar ve takva önderliği',
    arabicSnippet: 'رَبَّنَا هَبْ لَنَا مِنْ أَزْوَاجِنَا وَذُرِّيَّاتِنَا قُرَّةَ أَعْيُنٍ وَاجْعَلْنَا لِلْمُتَّقِينَ إِمَامًا...',
    turkishMeaning: 'Rabbimiz! Bize eşlerimizden ve soyumuzdan göz aydınlığı olacak kimseler bağışla ve bizi takva sahiplerine önder kıl...',
    searchKeywords: ['es', 'aile', 'evlat', 'cocuk', 'furkan 74', 'yuva', 'huzur'],
  ),
];

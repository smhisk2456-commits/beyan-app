/// Sabah ve Akşam Virdi (Hısnu'l-Müslim) Veri Modeli
enum AdhkarTimeType {
  morning,
  evening,
  both,
}

class AdhkarItem {
  final String id;
  final String titleTr;
  final String titleEn;
  final String titleAr;
  final String arabicText;
  final String transliteration;
  final String meaningTr;
  final String meaningEn;
  final String virtueTr;
  final String virtueEn;
  final String source;
  final int targetCount;
  final AdhkarTimeType timeType;

  const AdhkarItem({
    required this.id,
    required this.titleTr,
    required this.titleEn,
    required this.titleAr,
    required this.arabicText,
    required this.transliteration,
    required this.meaningTr,
    required this.meaningEn,
    required this.virtueTr,
    required this.virtueEn,
    required this.source,
    required this.targetCount,
    required this.timeType,
  });

  String localizedTitle(String langCode) {
    if (langCode == 'ar') return titleAr;
    if (langCode == 'en') return titleEn;
    return titleTr;
  }

  String localizedMeaning(String langCode) {
    if (langCode == 'en') return meaningEn;
    return meaningTr;
  }

  String localizedVirtue(String langCode) {
    if (langCode == 'en') return virtueEn;
    return virtueTr;
  }
}

/// Sahih Hadis Kaynaklı Sabah ve Akşam Zikirleri Havuzu
final List<AdhkarItem> verifiedMorningEveningAdhkar = [
  // 1. Ayetü'l-Kürsî
  const AdhkarItem(
    id: 'adhkar_ayetel_kursi',
    titleTr: "Âyetü'l-Kürsî (Bakara 255)",
    titleEn: 'Ayat al-Kursi (Al-Baqarah 255)',
    titleAr: 'آية الكرسي',
    arabicText: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
    transliteration: 'Allâhu lâ ilâhe illâ hüvel-hayyül-kayyûm. Lâ te’huzühû sinetün ve lâ nevm. Lehû mâ fis-semâvâti ve mâ fil-ard...',
    meaningTr: 'Allah, O’ndan başka ilah yoktur; diridir, her şeyin varlığı O’na bağlıdır ve düzenleyicisidir. O’nu ne uyuklama tutar ne de uyku. Göklerde ve yerde ne varsa hepsi O’nundur.',
    meaningEn: 'Allah - there is no deity except Him, the Ever-Living, the Sustainer of all existence. Neither drowsiness overtakes Him nor sleep.',
    virtueTr: 'Sabah okuyan akşama kadar, akşam okuyan sabaha kadar cin ve şeytan şerrinden ilahi muhafaza altına alınır.',
    virtueEn: 'Whoever recites it in the morning will be protected until the evening, and whoever recites it in the evening will be protected until the morning.',
    source: 'Hâkim (el-Müstedrek, 1/562)',
    targetCount: 1,
    timeType: AdhkarTimeType.both,
  ),

  // 2. İhlâs, Felak, Nâs Sureleri
  const AdhkarItem(
    id: 'adhkar_muavvizeteyn',
    titleTr: 'İhlâs, Felak ve Nâs Sureleri',
    titleEn: 'Al-Ikhlas, Al-Falaq & An-Nas',
    titleAr: 'الإخلاص والمعوذتين',
    arabicText: 'قُلْ هُوَ اللَّهُ أَحَدٌ ۞ قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۞ قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
    transliteration: 'Kul hüvallâhu ehad... Kul e‘ûzü birabbi’l-felak... Kul e‘ûzü birabbi’n-nâs...',
    meaningTr: 'De ki: O Allah tektir... De ki: Yarattığı şeylerin şerrinden sabahın Rabbine sığınırım... De ki: İnsanların Rabbine sığınırım...',
    meaningEn: 'Say: He is Allah, the One... Say: I seek refuge in the Lord of daybreak... Say: I seek refuge in the Lord of mankind...',
    virtueTr: 'Peygamberimiz (s.a.v.): "Sabah ve akşam bunları üçer defa oku, seni her türlü kötülükten korumaya yeter" buyurmuştur.',
    virtueEn: 'The Prophet (pbuh) said: "Recite them three times in the morning and evening, and they will suffice you against everything."',
    source: 'Ebû Dâvûd (5082), Tirmizî (3575)',
    targetCount: 3,
    timeType: AdhkarTimeType.both,
  ),

  // 3. Seyyidü'l-İstiğfar (Tevbelerin Efendisi)
  const AdhkarItem(
    id: 'adhkar_seyyidul_istigfar',
    titleTr: "Seyyidü'l-İstiğfar (Tevbelerin Efendisi)",
    titleEn: 'Sayyid al-Istighfar (The Master of Repentance)',
    titleAr: 'سيد الاستغفار',
    arabicText: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ لَكَ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
    transliteration: 'Allâhümme ente Rabbî lâ ilâhe illâ ente, halaktenî ve ene abduke, ve ene alâ ahdike ve va’dike mesteta‘tü, e‘ûzü bike min şerri mâ sana‘tü, ebû’u leke bini‘metike aleyye ve ebû’u bizenbî fağfirlî fe innehû lâ yağfiruz-zünûbe illâ ente.',
    meaningTr: 'Allahım! Sen benim Rabbimsin. Senden başka ilah yoktur. Beni Sen yarattın, ben Senin kulunum. Gücüm yettiğince Sana verdiğim söz ve ahid üzerindeyim. Yaptıklarımın şerrinden Sana sığınırım. Bana verdiğin nimetleri itiraf eder, günahlarımı kabul ederim. Beni bağışla, şüphesiz günahları ancak Sen bağışlarsın.',
    meaningEn: 'O Allah, You are my Lord, there is no deity except You. You created me and I am Your servant, and I am faithful to my covenant and promise to You as much as I can...',
    virtueTr: 'Peygamberimiz (s.a.v.): "Kim inanarak sabah okur da o gün akşama kadar vefat ederse cennet ehlindendir; akşam okur da sabaha kadar vefat ederse yine cennet ehlindendir" buyurmuştur.',
    virtueEn: 'Whoever says it with firm faith during the day and dies before evening will be of Paradise, and whoever says it at night and dies before morning will be of Paradise.',
    source: 'Buhârî (Daavât, 2)',
    targetCount: 1,
    timeType: AdhkarTimeType.both,
  ),

  // 4. Bismillâhillezî Lâ Yedurru
  const AdhkarItem(
    id: 'adhkar_bismillahillezi',
    titleTr: 'Bismillâhillezî Lâ Yedurru',
    titleEn: 'Bismillahil-ladhi la yadurru',
    titleAr: 'بسم الله الذي لا يضر مع اسمه شيء',
    arabicText: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
    transliteration: 'Bismillâhillezî lâ yedurru measmihî şey’ün fil-ardı ve lâ fis-semâ’i ve hüves-Semî‘ul-‘Alîm.',
    meaningTr: 'İsmiyle yerde ve gökte hiçbir şeyin zarar veremeyeceği Allah’ın adıyla! O her şeyi hakkıyla işitendir, hakkıyla bilendir.',
    meaningEn: 'In the name of Allah, with whose name nothing on earth or in heaven can cause harm, and He is the All-Hearing, the All-Knowing.',
    virtueTr: 'Sabah ve akşam 3 defa okuyana hiçbir bela, musibet, kaza ve zehir zarar veremez.',
    virtueEn: 'Whoever recites it three times morning and evening will not be harmed by anything.',
    source: 'Ebû Dâvûd (5088), Tirmizî (3388)',
    targetCount: 3,
    timeType: AdhkarTimeType.both,
  ),

  // 5. Radîtü Billâhi Rabben
  const AdhkarItem(
    id: 'adhkar_raditu_billah',
    titleTr: 'Radîtü Billâhi Rabben',
    titleEn: 'Raditu billahi Rabba',
    titleAr: 'رضيت بالله رباً',
    arabicText: 'رَضِيتُ بِاللَّهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ نَبِيًّا',
    transliteration: 'Radîtü billâhi Rabben ve bil-İslâmi dînen ve bi-Muhammedin sallallâhu aleyhi ve selleme nebiyyâ.',
    meaningTr: 'Rab olarak Allah’tan, din olarak İslâm’dan, peygamber olarak Hz. Muhammed (s.a.v.)’den razı oldum.',
    meaningEn: 'I am pleased with Allah as my Lord, with Islam as my religion, and with Muhammad (pbuh) as my Prophet.',
    virtueTr: 'Sabah ve akşam 3 defa okuyan kimseyi kıyamet gününde razı ve memnun etmek Allah üzerine bir haktır.',
    virtueEn: 'Whoever says it three times in the morning and evening, it is a duty upon Allah to please him on the Day of Judgment.',
    source: 'Tirmizî (3389), Ebû Dâvûd (5072)',
    targetCount: 3,
    timeType: AdhkarTimeType.both,
  ),

  // 6. Hasbiyallâhü Lâ İlâhe İllâ Hû
  const AdhkarItem(
    id: 'adhkar_hasbiyallah',
    titleTr: 'Hasbiyallâhü Lâ İlâhe İllâ Hû',
    titleEn: 'Hasbiyallahu la ilaha illa Huwa',
    titleAr: 'حسبي الله لا إله إلا هو',
    arabicText: 'حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ ۖ عَلَيْهِ تَوَكَّلْتُ ۖ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
    transliteration: 'Hasbiyallâhu lâ ilâhe illâ hûve ‘aleyhi tevekkeltü ve hüve Rabbül-‘arşil-‘azîm.',
    meaningTr: 'Allah bana yeter! O’ndan başka ilah yoktur. Ben yalnız O’na tevekkül ettim ve O, yüce Arş’ın Rabbidir.',
    meaningEn: 'Sufficient for me is Allah; there is no deity except Him. On Him I have relied, and He is the Lord of the Great Throne.',
    virtueTr: 'Sabah ve akşam 7 defa okuyan kimsenin dünya ve ahiret gam ve kederlerine Allah kafi gelir.',
    virtueEn: 'Whoever recites it seven times morning and evening, Allah will suffice him against what concerns him in this life and the hereafter.',
    source: 'Ebû Dâvûd (5081)',
    targetCount: 7,
    timeType: AdhkarTimeType.both,
  ),

  // 7. Sabah Duası: Asbahnâ ve Asbahal-Mülkü Lillâh
  const AdhkarItem(
    id: 'adhkar_sabah_asbahna',
    titleTr: 'Sabah Duası (Asbahnâ ve Asbahal-Mülk)',
    titleEn: 'Morning Prayer (Asbahna wa Asbahal-Mulk)',
    titleAr: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ',
    arabicText: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
    transliteration: 'Asbahnâ ve asbahal-mülkü lillâhi vel-hamdü lillâh, lâ ilâhe illallâhu vahdehû lâ şerîke leh, lehül-mülkü ve lehül-hamdü ve hüve alâ külli şey’in kadîr.',
    meaningTr: 'Biz de sabahladık, mülk de Allah için sabahladı. Hamd Allah’a mahsustur. Allah’tan başka ilah yoktur; O tektir, ortağı yoktur. Mülk O’nundur, hamd O’nadır ve O her şeye kadirdir.',
    meaningEn: 'We have entered the morning and kingdom belongs to Allah. Praise is to Allah. There is no deity except Allah alone, without partner...',
    virtueTr: 'Günün hayrını, fethini, nurunu ve bereketini celbeder.',
    virtueEn: 'Brings forth the blessings, light, and guidance of the day.',
    source: 'Müslim (Zikir, 75)',
    targetCount: 1,
    timeType: AdhkarTimeType.morning,
  ),

  // 8. Akşam Duası: Emseynâ ve Emseyal-Mülkü Lillâh
  const AdhkarItem(
    id: 'adhkar_aksam_emseyna',
    titleTr: 'Akşam Duası (Emseynâ ve Emseyal-Mülk)',
    titleEn: 'Evening Prayer (Amseyna wa Amsal-Mulk)',
    titleAr: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ',
    arabicText: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
    transliteration: 'Emseynâ ve emseyal-mülkü lillâhi vel-hamdü lillâh, lâ ilâhe illallâhu vahdehû lâ şerîke leh, lehül-mülkü ve lehül-hamdü ve hüve alâ külli şey’in kadîr.',
    meaningTr: 'Biz de akşama erdik, mülk de Allah için akşama erdi. Hamd Allah’a mahsustur. Allah’tan başka ilah yoktur; O tektir, ortağı yoktur. Mülk O’nundur, hamd O’nadır.',
    meaningEn: 'We have entered the evening and kingdom belongs to Allah. Praise is to Allah. There is no deity except Allah alone...',
    virtueTr: 'Gecenin şerrinden, tembellikten ve azaptan koruyucu kaledir.',
    virtueEn: 'A stronghold against the evils of the night, laziness, and punishment.',
    source: 'Müslim (Zikir, 76)',
    targetCount: 1,
    timeType: AdhkarTimeType.evening,
  ),

  // 9. Akşam Korunma Duası: Eûzü bikelimâtillâhit-tâmmât
  const AdhkarItem(
    id: 'adhkar_aksam_euzu_tamat',
    titleTr: 'Akşam Korunma Duası (Kelimâtillâhit-Tâmmât)',
    titleEn: 'Evening Protection (Words of Allah)',
    titleAr: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
    arabicText: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
    transliteration: 'E‘ûzü bikelimâtillâhit-tâmmâti min şerri mâ halak.',
    meaningTr: 'Yarattığı şeylerin şerrinden Allah’ın tam ve eksiksiz kelimelerine sığınırım.',
    meaningEn: 'I seek refuge in the perfect words of Allah from the evil of what He has created.',
    virtueTr: 'Akşam 3 kez okuyan kimseye o gece sabaha kadar hiçbir haşere, akrep veya zehirli canlı zarar veremez.',
    virtueEn: 'Whoever recites it three times in the evening will not be harmed by any poison, insect or scorpion that night.',
    source: 'Müslim (Zikir, 54)',
    targetCount: 3,
    timeType: AdhkarTimeType.evening,
  ),

  // 10. Yâ Hayyu Yâ Kayyûm
  const AdhkarItem(
    id: 'adhkar_ya_hayyu_ya_kayyum',
    titleTr: 'Yâ Hayyu Yâ Kayyûm İstiğâse',
    titleEn: 'Ya Hayyu Ya Qayyum',
    titleAr: 'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ',
    arabicText: 'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ، وَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ',
    transliteration: 'Yâ Hayyu Yâ Kayyûm birahmetike esteğîs, aslih lî şe’nî küllehû ve lâ tekilnî ilâ nefsî tarfete ‘ayn.',
    meaningTr: 'Ey Hayy (daima diri) ve Kayyûm (her şeyi ayakta tutan) Allahım! Rahmetinle yardımını dilerim. Bütün işlerimi ıslah et, düzelt ve beni göz açıp kapayıncaya kadar bile olsa nefsimin eline bırakma!',
    meaningEn: 'O Ever-Living, O Sustainer, by Your mercy I seek assistance. Rectify all of my affairs and do not leave me to myself even for the blink of an eye.',
    virtueTr: 'İnsanın manevi dengesini kurar, ruhani ferahlık ve teslimiyet kazandırır.',
    virtueEn: 'Establishes inner tranquility and divine reliance throughout the day.',
    source: 'Hâkim (1/545), Nesâî (el-Kübrâ, 10405)',
    targetCount: 1,
    timeType: AdhkarTimeType.both,
  ),

  // 11. Sübhânallâhi ve Bihamdihî (100x veya 10x)
  const AdhkarItem(
    id: 'adhkar_subhanallah_bihamdihi',
    titleTr: 'Sübhânallâhi ve Bihamdihî',
    titleEn: 'SubhanAllahi wa bihamdihi',
    titleAr: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
    arabicText: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
    transliteration: 'Sübhânallâhi ve bihamdihî.',
    meaningTr: 'Allah’ı hamd ile tesbih ederim; O’nu her türlü eksiklikten tenzih ederim.',
    meaningEn: 'Glory be to Allah and praise Him.',
    virtueTr: 'Günde 100 defa okuyanın günahları deniz köpüğü kadar olsa da bağışlanır. Kıyamet günü bundan daha faziletli bir amelle gelen olmaz.',
    virtueEn: 'Whoever says it 100 times a day, his sins will be wiped away even if they were like the foam of the sea.',
    source: 'Buhârî (6405), Müslim (2691)',
    targetCount: 10,
    timeType: AdhkarTimeType.both,
  ),
];

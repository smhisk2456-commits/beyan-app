/// Namaz Duaları ve Sureleri Modeli (Sesli Tilavet ve Türkçe Açıklamalı)
class NamazDuaItem {
  final String id;
  final String title;
  final String subtitle;
  final String arabic;
  final String transliteration;
  final String meaning;
  final String? virtue;
  final String? audioUrl; // Sesli tilavet linki
  final String whereRead; // Namazda nerede okunur?

  const NamazDuaItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    required this.whereRead,
    this.virtue,
    this.audioUrl,
  });

  static const List<NamazDuaItem> allDuas = [
    NamazDuaItem(
      id: 'subhaneke',
      title: 'Sübhâneke Duası',
      subtitle: 'Namazın İlk Açılış Duası',
      whereRead: 'Her namazın 1. rekatında iftitah tekbirinden sonra okunur.',
      arabic: 'سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ وَتَبَارَكَ اسْمُكَ وَتَعَالَى جَدُّكَ وَلَا إِلَهَ غَيْرُكَ',
      transliteration: 'Sübhânekellâhümme ve bi hamdik ve tebârakesmük ve teâlâ ceddük ve lâ ilâhe ğayrük.',
      meaning: 'Allah\'ım! Sen her türlü noksanlıktan münezzehsin, Seni hamdinle tesbih ederim. Senin ismin mübarektir, şanın yücedir ve Senden başka hiçbir ilah yoktur.',
      virtue: 'Peygamberimiz (s.a.v.) namaza başladığında ilk olarak bu dua ile Rabbini tesbih ederdi.',
      audioUrl: 'https://download.quranicaudio.com/qdc/mishari_al_afasy/murattal/1.mp3',
    ),
    NamazDuaItem(
      id: 'ettehiyyatu',
      title: 'Ettehiyyâtü Duası',
      subtitle: 'Mirac Hediyesi & Teşehhüd',
      whereRead: 'Namazların ilk ve son oturuşlarında (ka\'de) okunur.',
      arabic: 'التَّحِيَّاتُ لِلَّهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ، السَّلَامُ عَلَيْكَ أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ، السَّلَامُ عَلَيْنَا وَعَلَى عِبَادِ اللَّهِ الصَّالِحِينَ، أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ',
      transliteration: 'Et-tahiyyâtü lillâhi ve\'s-salavâtü ve\'t-tayyibât. Es-selâmü aleyke eyyühe\'n-nebiyyü ve rahmetullâhi ve berekâtüh. Es-selâmü aleynâ ve alâ ibâdillâhi\'s-sâlihîn. Eşhedü en lâ ilâhe illallâh ve eşhedü enne Muhammeden abdühû ve rasûlüh.',
      meaning: 'Bütün dualar, senalar, bedenî ve mâlî ibadetler Allah Teâlâ\'ya mahsustur. Ey Peygamber! Selâm, Allah\'ın rahmet ve bereketleri senin üzerine olsun. Selâm bizim ve Allah\'ın salih kullarının üzerine olsun. Şahitlik ederim ki Allah\'tan başka ilah yoktur ve yine şahitlik ederim ki Muhammed O\'nun kulu ve elçisidir.',
      virtue: 'Peygamberimiz (s.a.v.) Mirac gecesi Cenâb-ı Hak ile olan mukaddes mükâlemesini ümmetine teşehhüd olarak hediye etmiştir.',
    ),
    NamazDuaItem(
      id: 'salli',
      title: 'Allâhümme Salli',
      subtitle: 'Peygamber Efendimiz\'e Salât',
      whereRead: 'Son oturuşta Ettehiyyâtü\'den sonra okunur.',
      arabic: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ',
      transliteration: 'Allâhümme salli alâ Muhammedin ve alâ âli Muhammed, kemâ salleyte alâ İbrâhîme ve alâ âli İbrâhîm, inneke hamîdün mecîd.',
      meaning: 'Allah\'ım! İbrâhim\'e ve âline salât ettiğin gibi, Muhammed\'e ve âline de salât et. Şüphesiz Sen çok övülensin, şanı pek yüce olansın.',
      virtue: 'Namazı tamamlayan en faziletli salavat-ı şerifedir.',
    ),
    NamazDuaItem(
      id: 'barik',
      title: 'Allâhümme Bârik',
      subtitle: 'Peygamber Efendimiz\'e Bereket Duası',
      whereRead: 'Allâhümme Salli\'den hemen sonra okunur.',
      arabic: 'اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ',
      transliteration: 'Allâhümme bârik alâ Muhammedin ve alâ âli Muhammed, kemâ bârakte alâ İbrâhîme ve alâ âli İbrâhîm, inneke hamîdün mecîd.',
      meaning: 'Allah\'ım! İbrâhim\'e ve âline bereket ihsan ettiğin gibi, Muhammed\'e ve âline de bereket ihsan eyle. Şüphesiz Sen çok övülensin, şanı pek yüce olansın.',
      virtue: 'Kulun ömrüne, ibadetine ve nesline bereket niyazıdır.',
    ),
    NamazDuaItem(
      id: 'rabbena_atina',
      title: 'Rabbenâ Âtinâ & Rabbenâğfirlî',
      subtitle: 'Dünya ve Ahiret Kurtuluş Duası',
      whereRead: 'Son oturuşta selâm vermeden önce okunur.',
      arabic: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ ۝ رَبَّنَا اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ يَوْمَ يَقُومُ الْحِسَابُ',
      transliteration: 'Rabbenâ âtinâ fi\'d-dünyâ haseneten ve fi\'l-âhireti haseneten ve kınâ azâbe\'n-nâr. Rabbenâğfirlî ve li-vâlideyye ve li\'l-mü\'minîne yevme yekûmü\'l-hisâb.',
      meaning: 'Ey Rabbimiz! Bize dünyada da iyilik ve güzellik ver, ahirette de iyilik ve güzellik ver ve bizi cehennem ateşinin azabından koru! Ey Rabbimiz! Hesabın görüleceği günde beni, anamı-babamı ve bütün inananları bağışla!',
      virtue: 'Kur\'an-ı Kerim\'deki en kapsamlı ve en çok okunan dua ayetlerindendir (Bakara 201, İbrahim 41).',
    ),
    NamazDuaItem(
      id: 'kunut_1',
      title: 'Kunut Duası - 1',
      subtitle: 'Vitir Namazı Özel Duası',
      whereRead: 'Yatsıdan sonra kılınan Vitir namazının 3. rekatında tekbir alınıp okunur.',
      arabic: 'اللَّهُمَّ إِنَّا نَسْتَعِينُكَ وَنَسْتَغْفِرُكَ وَنَسْتَهْدِيكَ، وَنُؤْمِنُ بِكَ وَنَتُوبُ إِلَيْكَ، وَنَتَوَكَّلُ عَلَيْكَ وَنُثْنِي عَلَيْكَ الْخَيْرَ كُلَّهُ، نَشْكُرُكَ وَلَا نَكْفُرُكَ، وَنَخْلَعُ وَنَتْرُكُ مَنْ يَفْجُرُكَ',
      transliteration: 'Allâhümme innâ neste\'înüke ve nestağfirüke ve nestehdîk, ve nü\'minü bike ve netûbü ileyk, ve netevekkelü aleyke ve nüsnî aleyke\'l-hayra külleh, neşkürüke ve lâ nekfürük, ve nahle\'u ve netrükü men yefcürük.',
      meaning: 'Allah\'ım! Senden yardım isteriz, günahlarımızı bağışlamanı dileriz, bize hidayet vermeni niyaz ederiz. Sana iman eder, Sana tevbe ederiz. Sana güvenir, her türlü hayırla Seni överiz. Sana şükreder, nankörlük etmeyiz. Sana isyan edenleri terk eder, onlardan uzak dururuz.',
      virtue: 'Vitir namazının vacip olan en mühim rüknüdür.',
    ),
    NamazDuaItem(
      id: 'kunut_2',
      title: 'Kunut Duası - 2',
      subtitle: 'Vitir Namazı İkinci Kunut',
      whereRead: 'Kunut 1 duasından hemen sonra okunur.',
      arabic: 'اللَّهُمَّ إِيَّاكَ نَعْبُدُ وَلَكَ نُصَلِّي وَنَسْجُدُ، وَإِلَيْكَ نَسْعَى وَنَحْفِدُ، نَرْجُو رَحْمَتَكَ وَنَخْشَى عَذَابَكَ، إِنَّ عَذَابَكَ بِالْكُفَّارِ مُلْحَقٌ',
      transliteration: 'Allâhümme iyyâke na\'büdü ve leke nüsallî ve nescüd, ve ileyke nes\'â ve nahfid, nercû rahmeteke ve nahşâ azâbek, inne azâbeke bi\'l-küffâri mülhık.',
      meaning: 'Allah\'ım! Biz yalnız Sana kulluk eder, yalnız Senin rızan için namaz kılar ve secde ederiz. Yalnız Sana yönelir ve koşarız. Rahmetini umar, azabından korkarız. Şüphesiz Senin azabın kâfirlere mutlaka erişecektir.',
      virtue: 'Kulun Cenâb-ı Hakk\'a tam teslimiyetinin ve ilticasının ifadesidir.',
    ),
    NamazDuaItem(
      id: 'fatiha',
      title: 'Fâtiha Sûresi',
      subtitle: 'Kur\'an\'ın Özü ve Namazın Direği',
      whereRead: 'Namazların her rekatında kıyamda iken okunması farzdır/vaciptir.',
      arabic: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ۝ الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ ۝ الرَّحْمَٰنِ الرَّحِيمِ ۝ مَالِكِ يَوْمِ الدِّينِ ۝ إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ ۝ اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ ۝ صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
      transliteration: 'Bismillâhirrahmânirrahîm. El-hamdü lillâhi rabbi\'l-âlemîn. Er-rahmâni\'r-rahîm. Mâliki yevmi\'d-dîn. İyyâke na\'büdü ve iyyâke neste\'în. İhdine\'s-sırâta\'l-müstekîm. Sırâtallezîne en\'amte aleyhim ğayri\'l-mağdûbi aleyhim veleddâllîn. Âmîn.',
      meaning: 'Rahman ve Rahim olan Allah\'ın adıyla. Hamd, âlemlerin Rabbi olan Allah\'a mahsustur. O, Rahmândır, Rahîmdir. Din (hesap ve mükâfat) gününün sahibidir. Ancak Sana kulluk eder, yalnız Senden yardım dileriz. Bizi doğru yola; kendilerine nimet verdiğin kimselerin yoluna ilet. Gazaba uğrayanların ve sapıtanların yoluna değil.',
      virtue: 'Peygamberimiz (s.a.v.): "Fâtiha sûresini okumayanın namazı olmaz" buyurmuştur (Buhârî, Ezân 95).',
    ),
    NamazDuaItem(
      id: 'ihlas',
      title: 'İhlâs Sûresi',
      subtitle: 'Tevhidin Zirvesi',
      whereRead: 'Fâtiha\'dan sonra zamm-ı sûre olarak okunur.',
      arabic: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ۝ قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ',
      transliteration: 'Bismillâhirrahmânirrahîm. Kul hüvallâhu ehad. Allâhü\'s-samed. Lem yelid ve lem yûled. Ve lem yekün lehû küfüven ehad.',
      meaning: 'De ki: O Allah birdir. Allah Samed\'dir (her şey O\'na muhtaçtır, O hiçbir şeye muhtaç değildir). O doğurmamış ve doğmamıştır. Hiçbir şey O\'na denk ve benzer değildir.',
      virtue: 'Kur\'an-ı Kerim\'in üçte birine (1/3) denktir.',
    ),
    NamazDuaItem(
      id: 'kevser',
      title: 'Kevser Sûresi',
      subtitle: 'Tükenmez Hayır ve Bereket',
      whereRead: 'Fâtiha\'dan sonra zamm-ı sûre olarak okunur.',
      arabic: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ۝ إِنَّا أَعْطَيْنَاكَ الْكَوْثَرَ ۝ فَصَلِّ لِرَبِّكَ وَانْحَرْ ۝ إِنَّ شَانِئَكَ هُوَ الْأَبْتَرُ',
      transliteration: 'Bismillâhirrahmânirrahîm. İnnâ a\'taynâke\'l-kevser. Fesalli li-rabbike venhar. İnne şânieke hüve\'l-ebter.',
      meaning: 'Şüphesiz biz sana Kevser\'i (bitip tükenmez nimetleri ve Kevser havuzunu) verdik. Şimdi sen Rabbin için namaz kıl ve kurban kes! Asıl sonu kesik olan, sana buğzeden (düşmanın)dir.',
      virtue: 'Kur\'an\'ın en kısa ama en müjdeli sûrelerindendir.',
    ),
    NamazDuaItem(
      id: 'felak',
      title: 'Felak Sûresi',
      subtitle: 'Karanlıkların Şerrinden Sığınma',
      whereRead: 'Fâtiha\'dan sonra zamm-ı sûre olarak okunur.',
      arabic: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ۝ قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۝ مِنْ شَرِّ مَا خَلَقَ ۝ وَمِنْ شَرِّ غَاسِقٍ إِذَا وَقَبَ ۝ وَمِنْ شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ۝ وَمِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَ',
      transliteration: 'Bismillâhirrahmânirrahîm. Kul e\'ûzü bi-rabbi\'l-felak. Min şerri mâ halak. Ve min şerri ğâsikın izâ vekab. Ve min şerri\'n-neffâsâti fi\'l-ukad. Ve min şerri hâsidin izâ hased.',
      meaning: 'De ki: Sabahın Rabbine sığınırım; yarattığı şeylerin şerrinden, karanlığı çöktüğü zaman gecenin şerrinden, düğümlere üfleyen büyücülerin şerrinden ve haset ettiği zaman hasetçinin şerrinden.',
      virtue: 'Manevi zırh ve nazar/şerlerden korunma sûresidir.',
    ),
    NamazDuaItem(
      id: 'nas',
      title: 'Nâs Sûresi',
      subtitle: 'Vesveselere Karşı İlahi Kalkan',
      whereRead: 'Fâtiha\'dan sonra zamm-ı sûre olarak okunur.',
      arabic: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ۝ قُلْ أَعُوذُ بِرَبِّ النَّاسِ ۝ مَلِكِ النَّاسِ ۝ إِلَٰهِ النَّاسِ ۝ مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ۝ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ۝ مِنَ الْجِنَّةِ وَالنَّاسِ',
      transliteration: 'Bismillâhirrahmânirrahîm. Kul e\'ûzü bi-rabbi\'n-nâs. Meliki\'n-nâs. İlâhi\'n-nâs. Min şerri\'l-vesvâsi\'l-hannâs. Ellezî yüvesvisü fî sudûri\'n-nâs. Mine\'l-cinneti ve\'n-nâs.',
      meaning: 'De ki: İnsanların Rabbine, insanların hükümdarına, insanların ilahına sığınırım; sinsi vesvesecinin şerrinden. O ki insanların göğüslerine vesvese verir; gerek cinlerden gerek insanlardan!',
      virtue: 'Namazdan sonra ve yatmadan önce okunması tavsiye edilir.',
    ),
    NamazDuaItem(
      id: 'ayetel_kursi',
      title: 'Âyete\'l-Kürsî',
      subtitle: 'Ayetlerin Efendisi',
      whereRead: 'Farz namazların selâmından ve tesbihattan hemen sonra okunur.',
      arabic: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
      transliteration: 'Allâhü lâ ilâhe illâ hüve\'l-hayyü\'l-kayyûm. Lâ te\'huzühû sinetün ve lâ nevm. Lehû mâ fi\'s-semâvâti ve mâ fi\'l-ard. Men zellezî yeşfe\'u indehû illâ bi-iznih. Ya\'lemü mâ beyne eydîhim ve mâ halfehüm. Ve lâ yuhîtûne bi-şey\'in min ilmihî illâ bimâ şâ\'. Vesi\'a kürsiyyühü\'s-semâvâti ve\'l-ard. Ve lâ yeûdühû hıfzuhümâ ve hüve\'l-aliyyü\'l-azîm.',
      meaning: 'Allah, O\'ndan başka ilah olmayandır; Hayy\'dır (diridir), Kayyûm\'dur (tüm varlığı yönetendir). O\'nu ne bir uyuklama ne de bir uyku tutar. Göklerde ve yerde ne varsa hepsi O\'nundur. İzni olmadan O\'nun katında kim şefaat edebilir? O, kullarının önlerindekini de arkalarındakini de (yaptıklarını ve yapacaklarını) bilir. O\'nun ilminden, dilediği kadarından başka hiçbir şeyi kavrayamazlar. O\'nun kürsüsü gökleri ve yeri kuşatmıştır. Onları koruyup gözetmek O\'na asla ağır gelmez. O, çok yücedir, çok büyüktür.',
      virtue: 'Peygamberimiz (s.a.v.): "Her farz namazın arkasından Âyete\'l-Kürsî\'yi okuyan kimsenin cennete girmesine ancak ölüm mani olur" buyurmuştur (Neseî).',
    ),
  ];
}

/// Vakit Namazı Rehberi Modeli
class PrayerGuideVakit {
  final String id;
  final String name;
  final String totalRakats;
  final String rakatsBreakdown;
  final String timeWindow;
  final String intentionSample;
  final List<PrayerRakatFlow> rakats;

  const PrayerGuideVakit({
    required this.id,
    required this.name,
    required this.totalRakats,
    required this.rakatsBreakdown,
    required this.timeWindow,
    required this.intentionSample,
    required this.rakats,
  });

  static const List<PrayerGuideVakit> allPrayers = [
    PrayerGuideVakit(
      id: 'sabah',
      name: 'Sabah Namazı',
      totalRakats: '4 Rekat',
      rakatsBreakdown: '2 Rekat Sünnet + 2 Rekat Farz',
      timeWindow: 'İmsak vaktinden Güneş doğuncaya kadar',
      intentionSample: 'Niyet ettim Allah rızası için bugünkü sabah namazının sünnetini/farzını kılmaya.',
      rakats: [
        PrayerRakatFlow(
          rakatNumber: 1,
          rakatTitle: '1. Rekat',
          steps: [
            'Niyet edilir ve "Allâhu Ekber" denilerek iftitah tekbiri alınır, eller göbek altında/göğüste bağlanır.',
            'Sübhâneke duası okunur.',
            'Eûzü Besmele çekilir, Fâtiha sûresi okunur ve "Âmîn" denir.',
            'Bir zamm-ı sûre (Örn: Kevser veya İhlâs) okunur.',
            '"Allâhu Ekber" diyerek rükûya eğilinir. Rükûda 3 defa "Sübhâne Rabbiye\'l-Azîm" denir.',
            '"Semi\'allâhu li-men hamideh" diyerek doğrulunur ve ayakta "Rabbenâ leke\'l-hamd" denir.',
            '"Allâhu Ekber" diyerek secdeye varılır. Secdede 3 defa "Sübhâne Rabbiye\'l-A\'lâ" denir.',
            '"Allâhu Ekber" diyerek oturulur, kısa bir an beklenir ve tekrar "Allâhu Ekber" ile 2. secdeye gidilir (3 defa tesbih).',
            '"Allâhu Ekber" diyerek 2. rekata kalkılır.',
          ],
        ),
        PrayerRakatFlow(
          rakatNumber: 2,
          rakatTitle: '2. Rekat & Selâm',
          steps: [
            'Ayakta Besmele çekilir, Fâtiha sûresi okunur ve "Âmîn" denir.',
            'Bir zamm-ı sûre (Örn: Felak veya Nâs) okunur.',
            'Rükûya varılır (3 defa tesbih), doğrulunur.',
            'Peş peşe iki defa secde yapılır.',
            'İkinci secdeden sonra oturulur (Ka\'de-i ahîre).',
            'Sırasıyla: Ettehiyyâtü, Allâhümme Salli, Allâhümme Bârik ve Rabbenâ duaları okunur.',
            'Önce sağa: "Es-selâmu aleyküm ve rahmetullâh", sonra sola: "Es-selâmu aleyküm ve rahmetullâh" denilerek selâm verilir.',
          ],
        ),
      ],
    ),
    PrayerGuideVakit(
      id: 'ogle',
      name: 'Öğle Namazı',
      totalRakats: '10 Rekat',
      rakatsBreakdown: '4 İlk Sünnet + 4 Farz + 2 Son Sünnet',
      timeWindow: 'Güneş tam tepe noktasını geçtikten İkindi vaktine kadar',
      intentionSample: 'Niyet ettim Allah rızası için bugünkü öğle namazının ilk sünnetini/farzını/son sünnetini kılmaya.',
      rakats: [
        PrayerRakatFlow(
          rakatNumber: 1,
          rakatTitle: '1. ve 2. Rekat',
          steps: [
            'İftitah tekbiri ile başlanır, Sübhâneke, Fatiha ve zamm-ı sûre okunur.',
            'Rükû ve iki secde yapılarak 2. rekata kalkılır.',
            '2. rekatta Fatiha ve zamm-ı sûre okunur, rükû ve iki secdeden sonra ilk oturuşa (İlk Ka\'de) geçilir.',
            'İlk oturuşta sadece Ettehiyyâtü okunur ve 3. rekata kalkılır.',
          ],
        ),
        PrayerRakatFlow(
          rakatNumber: 2,
          rakatTitle: '3. ve 4. Rekat & Selâm',
          steps: [
            'Farzda: 3. ve 4. rekatta sadece Fatiha okunur (zamm-ı sûre okunmaz).',
            'Sünnette: 3. ve 4. rekatta Fatiha ile birlikte zamm-ı sûre de okunur.',
            'Rükû ve iki secdeler tamamlanır.',
            'Son oturuşta: Ettehiyyâtü, Salli, Bârik ve Rabbenâ duaları okunarak her iki tarafa selâm verilir.',
          ],
        ),
      ],
    ),
    PrayerGuideVakit(
      id: 'ikindi',
      name: 'İkindi Namazı',
      totalRakats: '8 Rekat',
      rakatsBreakdown: '4 Sünnet (Gayr-i Müekkede) + 4 Farz',
      timeWindow: 'İkindi vaktinden Güneş batıncaya kadar',
      intentionSample: 'Niyet ettim Allah rızası için bugünkü ikindi namazının sünnetini/farzını kılmaya.',
      rakats: [
        PrayerRakatFlow(
          rakatNumber: 1,
          rakatTitle: '4 Rekat Sünnet Özel Notu',
          steps: [
            'İkindi sünneti gayr-i müekkede olduğu için 1. oturuşta Ettehiyyâtü\'den sonra Allâhümme Salli ve Bârik de okunur.',
            '3. rekata kalkıldığında önce Sübhâneke, ardından Eûzü Besmele ve Fatiha okunur.',
            '4 rekatlık farzı ise tıpkı öğle namazının farzı gibi kılınır.',
          ],
        ),
      ],
    ),
    PrayerGuideVakit(
      id: 'aksam',
      name: 'Akşam Namazı',
      totalRakats: '5 Rekat',
      rakatsBreakdown: '3 Rekat Farz + 2 Rekat Sünnet',
      timeWindow: 'Güneş battıktan Yatsı vaktine kadar',
      intentionSample: 'Niyet ettim Allah rızası için bugünkü akşam namazının farzını/sünnetini kılmaya.',
      rakats: [
        PrayerRakatFlow(
          rakatNumber: 1,
          rakatTitle: '3 Rekat Farzın Kılınışı',
          steps: [
            'Önce farz kılınır: 1. ve 2. rekatta Fatiha ve zamm-ı sûre okunur.',
            '2. rekat sonunda oturulup sadece Ettehiyyâtü okunur ve 3. rekata kalkılır.',
            '3. rekatta sadece Besmele ile Fatiha okunur (zamm-ı sûre okunmaz), rükû ve secdelerden sonra oturulur.',
            'Ettehiyyâtü, Salli, Bârik ve Rabbenâ duaları okunup selâm verilir.',
            'Ardından 2 rekat akşam namazının sünneti tıpkı sabahın sünneti gibi eda edilir.',
          ],
        ),
      ],
    ),
    PrayerGuideVakit(
      id: 'yatsi',
      name: 'Yatsı & Vitir Namazı',
      totalRakats: '13 Rekat',
      rakatsBreakdown: '4 İlk Sünnet + 4 Farz + 2 Son Sünnet + 3 Vitir Vacip',
      timeWindow: 'Yatsı vaktinden İmsak vaktine kadar',
      intentionSample: 'Niyet ettim Allah rızası için bugünkü yatsı namazının farzını / vitir namazını kılmaya.',
      rakats: [
        PrayerRakatFlow(
          rakatNumber: 1,
          rakatTitle: 'Vitir Namazı (3 Rekat Vacip)',
          steps: [
            '1. ve 2. rekatta Fatiha ve zamm-ı sûre okunur, ilk oturuşta sadece Ettehiyyâtü okunur.',
            '3. rekata kalkılır: Besmele, Fatiha ve zamm-ı sûre okunur.',
            'Rükûya gitmeden önce eller kulak hizasına/göğse kaldırılıp "Allâhu Ekber" diye Kunut tekbiri alınır ve eller tekrar bağlanır.',
            'Kunut duaları (Kunut 1 ve Kunut 2) okunur.',
            '"Allâhu Ekber" diyerek rükûya varılır, secdeler tamamlanır ve son oturuşta dualar okunup selâm verilir.',
          ],
        ),
      ],
    ),
  ];
}

class PrayerRakatFlow {
  final int rakatNumber;
  final String rakatTitle;
  final List<String> steps;

  const PrayerRakatFlow({
    required this.rakatNumber,
    required this.rakatTitle,
    required this.steps,
  });
}

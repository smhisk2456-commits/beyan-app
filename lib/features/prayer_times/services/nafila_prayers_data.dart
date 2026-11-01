import '../models/nafila_prayer_model.dart';

/// Önemli ve Nafile Namazlar Veri Kaynağı (Diyanet ve Ehl-i Sünnet Fıkhına Uygun)
class NafilaPrayersData {
  NafilaPrayersData._();

  static List<NafilaPrayer> getAllPrayers() {
    return [
      _teveccuhPrayer,
      _teheccudPrayer,
      _duhaPrayer,
      _evvabinPrayer,
      _istiharePrayer,
      _hacetPrayer,
      _tesbihPrayer,
      _tovbePrayer,
      _tahiyyetulMescidPrayer,
      _sukurPrayer,
      _seferPrayer,
      _cumaPrayer,
      _bayramPrayer,
      _teravihPrayer,
      _kusufPrayer,
    ];
  }

  static NafilaPrayer? getPrayerById(String id) {
    try {
      return getAllPrayers().firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // 1. TEVECCÜH NAMAZI (Kullanıcının Özel İsteği)
  // ════════════════════════════════════════════════════════════════════════════
  static const _teveccuhPrayer = NafilaPrayer(
    id: 'teveccuh',
    title: 'Teveccüh Namazı',
    arabicTitle: 'صَلَاةُ التَّوَجُّهِ وَالْإِقْبَالِ عَلَى اللّٰهِ',
    category: NafilaCategory.spiritualNight,
    rakats: '2 veya 4 Rekat (İkişer rekatta selamla)',
    timing: 'Kerahet vakitleri dışındaki her vakitte kılınabilir. Özellikle gece vakti, yatsıdan sonra, seher vaktinde veya manevi zikir, rabıta ve sohbet meclislerinden önce kılınması çok faziletlidir.',
    conditions: '1. Tam bir abdest ve beden/elbise temizliği (taharet).\n'
        '2. Kalbi dünya meşgalelerinden, gaflet ve endişelerden arındırmak (masivayı terk etmek).\n'
        '3. Tenha, sakin ve loş bir mekanda bulunmak.\n'
        '4. Kıbleye yönelerek ihlas, tevazu ve acziyet şuuruyla Cenâb-ı Hakk\'ın huzuruna durmak.\n'
        '5. Namaz boyunca zihni ve kalbi yalnızca Allah Teâlâ\'nın azamet ve cemaline bağlamak.',
    virtues: 'Teveccüh namazı, kulun bütün benliği, ruhu ve kalbiyle fani dünyadan yüz çevirip bizzat Hâlık-ı Zülcelâl\'e yönelmesi (teveccüh etmesi) maksadıyla kılınan müstesna bir manevi rabıta ve huzur namazıdır. '
        'Kalpteki katılığın silinmesine, nefsin vesveselerinin kırılmasına, iç huzurun teminine ve ilahi feyiz kapılarının açılmasına vesile olur. Büyük İslam âlimleri ve arifler, manevi terbiyede kalbin uyanması için bu namazı tavsiye etmişlerdir.',
    rewards: [
      'Masivadan Arınma & Kalp Diriliği: Kalpteki katılık, vesvese ve dünya hırsları silinir; ruh manevi uyanıklığa (yakaza) kavuşur.',
      'İlâhi Kurbiyet (Yakınlık): Cenâb-ı Hakk\'a tam bir teslimiyetle yönelen kul, "Bana bir karış yaklaşana Ben bir arşın yaklaşırım" sırrına erer.',
      'İç Huzuru ve Sekînet: Zikir, rabıta ve sohbet meclislerinden önce kılındığında ibadetin feyzini ve huşûunu kat kat artırır.',
      'Gaflet Perdesinin Kalkması: Kulun acziyetini anlayıp Rabbine boyun bükmesiyle nefsin kibri kırılır, ihlas makamı nasip olur.',
    ],
    niyyah: 'Niyet ettim Allah rızası için Teveccüh namazı kılmaya.',
    shortSummary: 'Kalbi masivadan arındırıp Cenâb-ı Hakk\'a tam bir teslimiyet ve aşk ile yönelmek için kılınan 2 rekatlık manevi huzur namazı.',
    isFeatured: true,
    recommendedSurahs: [
      '1. Rekat: Fâtiha ve Kâfirûn Sûresi (veya Âyetü\'l-Kürsî)',
      '2. Rekat: Fâtiha ve İhlâs Sûresi (veya Felak & Nâs)',
    ],
    steps: [
      NafilaStep(
        title: 'Niyet ve İftitah Tekbiri',
        description: 'Tenha bir yerde kıbleye dönülür, kalben "Niyet ettim rıza-i ilâhî için Teveccüh namazı kılmaya" denir. '
            'Erkekler ellerini kulak memesi hizasına, kadınlar göğüs hizasına kaldırarak "Allâhu Ekber" diyerek namaza başlar.',
        recitationArabic: 'اللّٰهُ أَكْبَرُ',
        recitationTranslit: 'Allâhu Ekber',
        recitationMeaning: 'Allah en büyüktür.',
      ),
      NafilaStep(
        title: '1. Rekat: Kıyam ve Kıraat',
        description: 'Sübhaneke duası okunur. Ardından Eûzü-Besmele çekilerek Fâtiha-i Şerîfe okunur. '
            'Zamm-ı sûre olarak kalbi şirk ve riyadan arındıran Kâfirûn Sûresi veya ilahi tevhidi anlatan Âyetü\'l-Kürsî okunur.',
        recitationArabic: 'قُلْ يَا أَيُّهَا الْكَافِرُونَ ۝ لَا أَعْبُدُ مَا تَعْبُدُونَ ۝ وَلَا أَنْتُمْ عَابِدُونَ مَا أَعْبُدُ...',
        recitationTranslit: 'Kul yâ eyyühel kâfirûn. Lâ a\'büdü mâ ta\'büdûn...',
        recitationMeaning: 'De ki: Ey kâfirler! Ben sizin taptıklarınıza tapmam...',
      ),
      NafilaStep(
        title: 'Rükû ve Secdeler',
        description: 'Allâhu Ekber diyerek rükûya varılır, huşu ile 3 defa "Sübhâne rabbiyel azîm" denir. Doğrulup "Semi\'allâhü limen hamideh, Rabbenâ lekel hamd" denir. '
            'Ardından secdelere varılarak her secdede kalben teslimiyetle en az 3 defa "Sübhâne rabbiyel a\'lâ" tesbihi okunur.',
      ),
      NafilaStep(
        title: '2. Rekat: Fâtiha ve İhlâs',
        description: 'İkinci rekata kalkılır. Besmele çekilip Fâtiha Sûresi okunur. Zamm-ı sûre olarak İhlâs Sûresi okunarak tevhid pekiştirilir. '
            'Rükû ve iki secde aynı huşû ile tamamlanır.',
        recitationArabic: 'قُلْ هُوَ اللّٰهُ أَحَدٌ ۝ اللّٰهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ',
        recitationTranslit: 'Kul hüvallâhü ehad. Allâhüssamed. Lem yelid ve lem yûled. Ve lem yekün lehû küfüven ehad.',
        recitationMeaning: 'De ki: O Allah birdir. Allah Samed\'dir (her şey O\'na muhtaçtır). Doğurmamış ve doğurulmamıştır. O\'na hiçbir şey denk değildir.',
      ),
      NafilaStep(
        title: 'Son Oturuş (Ka\'de-i Âhire) ve Selâm',
        description: 'İkinci secdeden sonra oturulur. Sırasıyla Ettehiyyâtü, Allâhümme Salli, Allâhümme Bârik ve Rabbenâ duaları okunur. '
            'Önce sağa, sonra sola "Esselâmü aleyküm ve rahmetullâh" denilerek selâm verilir.',
      ),
      NafilaStep(
        title: 'Namaz Sonrası Teveccüh & Rabıta Edebi',
        description: 'Selam verildikten sonra hemen yerinden kalkılmaz. Kıbleye karşı diz üstü veya bağdaş kurarak oturulur. '
            'Gözler hafifçe kapatılır, derin bir nefes alınıp 25 veya 33 defa kalben İstiğfar-ı Şerif çekilir. '
            'Ardından 1 Fatiha, 3 İhlas okunup Peygamberimiz (s.a.v.)\'in ruhuna hediye edilir ve Cenab-ı Hakk\'a kalben teveccüh ile münacat edilir.',
      ),
    ],
    specialDuas: [
      NafilaSpecialDua(
        title: 'Teveccüh Sonrası İstiğfar-ı Şerîf (25 veya 33 Kez)',
        arabic: 'أَسْتَغْفِرُ اللّٰهَ الْعَظِيمَ وَأَتُوبُ إِلَيْهِ',
        transliteration: 'Estağfirullâhe\'l-Azîm ve etûbü ileyh.',
        meaning: 'Azamet sahibi yüce Allah\'tan bağışlanma diler ve tövbe ile yalnızca O\'na dönerim.',
        note: 'Kalpteki dünya tortularını ve gaflet tozlarını temizlemek niyetiyle okunur.',
      ),
      NafilaSpecialDua(
        title: 'Cenâb-ı Hakk\'a Teveccüh & İlticâ Duası',
        arabic: 'اللّٰهُمَّ إِنِّي وَجَّهْتُ وَجْهِيَ إِلَيْكَ، وَفَوَّضْتُ أَمْرِي إِلَيْكَ، وَأَلْجَأْتُ ظَهْرِي إِلَيْكَ، رَغْبَةً وَرَهْبَةً إِلَيْكَ، لَا مَلْجَأَ وَلَا مَنْجَا مِنْكَ إِلَّا إِلَيْكَ.',
        transliteration: 'Allâhümme innî veccehtü vechiye ileyke, ve fevvadtü emrî ileyke, ve elce\'tü zahrî ileyke, rağbeten ve rehbeten ileyke, lâ melce\'e ve lâ mencâ minke illâ ileyke.',
        meaning: 'Allah\'ım! Bütün benliğim ve yüzümle Sana yöneldim. İşimi Sana havale ettim, sırtımı Sana dayadım. Senden umarak ve Senden korkarak kapına geldim. Senden kaçıp sığınılacak hiçbir merci yoktur, sığınak ancak Sensin.',
        note: 'Peygamberimiz (s.a.v.)\'in tavsiye buyurduğu tam teslimiyet ve teveccüh duasıdır.',
      ),
    ],
  );

  // ════════════════════════════════════════════════════════════════════════════
  // 2. TEHECCÜD NAMAZI (Gece Namazı)
  // ════════════════════════════════════════════════════════════════════════════
  static const _teheccudPrayer = NafilaPrayer(
    id: 'teheccud',
    title: 'Teheccüd Namazı',
    arabicTitle: 'صَلَاةُ التَّهَجُّدِ (قِيَامُ اللَّيْلِ)',
    category: NafilaCategory.spiritualNight,
    rakats: '2 ile 8 Rekat (İkişer rekatta bir selam verilmesi efdaldir)',
    timing: 'Yatsı namazından sonra bir miktar uyuyup gecenin son üçte birinde (imsak vaktine kadar) uyanılarak kılınır. Uykusuz kılınan gece namazına "Kıyâm-ı Leyl", uykudan uyanıp kılınana ise "Teheccüd" denir.',
    conditions: '1. Yatsı namazını ve tercihen vitir namazını kılmış olmak (Vitir namazı teheccüdden sonraya da bırakılabilir).\n'
        '2. Bir miktar uyuduktan sonra gece vakti uyanmak.\n'
        '3. Abdest alıp misvak veya fırça ile ağzı temizlemek.',
    virtues: 'Kur\'an-ı Kerim\'de: "Gecenin bir kısmında uyanarak, sana mahsus bir nafile olmak üzere teheccüd namazı kıl. Umulur ki Rabbin seni Makam-ı Mahmud\'a ulaştırır." (İsrâ, 79) buyrulmuştur.\n'
        'Peygamberimiz (s.a.v.): "Farz namazlardan sonra en faziletli namaz, gece kılınan teheccüd namazıdır." (Müslim) buyurmuştur.',
    rewards: [
      'Farzlardan Sonraki En Üstün Ecir: Peygamberimiz (s.a.v.) buyurur: "Farz namazlardan sonra en faziletli namaz, gece kılınan namazdır." (Müslim, Sıyâm 202).',
      'Makam-ı Mahmûd Şefaati: Kur\'an-ı Kerim\'de doğrudan teheccüdle müjdelenen en yüce derece: "Gecenin bir kısmında uyanıp teheccüd kıl; Rabbin seni Makam-ı Mahmud\'a ulaştırsın." (İsrâ, 79).',
      'Duaların Geri Çevrilmediği İcabet Vakti: "Rabbimiz her gece son üçte birinde dünya semasına tecelli eder ve \'Yok mu dua eden icabet edeyim, yok mu af dileyen bağışlayayım\' buyurur." (Buhârî, Teheccüd 14).',
      'Cennetin Şeffaf Köşkleri: "Cennette öyle köşkler vardır ki içi dışından, dışı içinden görünür. Bunlar tatlı dilli olan, selamı yayan ve insanlar uyurken namaz kılanlar içindir." (Tirmizî, Birr 53).',
      'Salihlerin Şiarı & Dertlere Şifa: "Gece ibadetine devam edin; çünkü o sizden önceki salihlerin âdetidir, günahlara kefarettir ve bedenden hastalıkları kovar." (Tirmizî, Deavât 101).',
    ],
    niyyah: 'Niyet ettim Allah rızası için Teheccüd namazı kılmaya.',
    shortSummary: 'Gecenin sükunetinde uykuyu bölerek kılınan, Makam-ı Mahmud\'a vesile en faziletli nafile namaz.',
    isFeatured: true,
    recommendedSurahs: [
      'Secde Sûresi, Mülk Sûresi, İhlâs, Felak ve Nâs Sûreleri',
      'Kıraati uzun tutmak ve ayetleri tefekkür ederek yavaş okumak sünnettir.',
    ],
    steps: [
      NafilaStep(
        title: 'Gece Uyanış ve Misvak',
        description: 'Uykudan kalkınca yüz yıkanır, Besmele ile abdest alınır. İkişer rekat halinde kılınması tavsiye edilir.',
      ),
      NafilaStep(
        title: '1. Rekat',
        description: 'Niyet edilir, İftitah tekbiri alınır. Sübhaneke, Eûzü-Besmele, Fâtiha ve bir zamm-ı sûre okunur. Rükû ve secdeler uzun ve huşû ile yapılır.',
      ),
      NafilaStep(
        title: '2. Rekat ve Selam',
        description: 'Besmele, Fâtiha ve zamm-ı sûre okunur. Rükû ve secdelerden sonra oturulup Ettehiyyâtü, Salli-Bârik, Rabbenâ okunarak selâm verilir. '
            'İstenirse bu şekilde 4, 6 veya 8 rekata tamamlanır.',
      ),
    ],
    specialDuas: [
      NafilaSpecialDua(
        title: 'Peygamber Efendimiz (s.a.v.)\'in Teheccüd Duası',
        arabic: 'اللّٰهُمَّ لَكَ الْحَمْدُ أَنْتَ نُورُ السَّمَاوَاتِ وَالْأَرْضِ وَمَنْ فِيهِنَّ، وَلَكَ الْحَمْدُ أَنْتَ قَيِّمُ السَّمَاوَاتِ وَالْأَرْضِ وَمَنْ فِيهِنَّ، أَنْتَ الْحَقُّ وَوَعْدُكَ الْحَقُّ...',
        transliteration: 'Allâhümme lekel hamdü ente nûrus-semâvâti vel ardı ve men fîhinne, ve lekel hamdü ente kayyımüs-semâvâti vel ardı ve men fîhinne, entel hakku ve va\'dükel hakk...',
        meaning: 'Allah\'ım! Hamd Sana mahsustur; Sen göklerin, yerin ve bunlardaki her şeyin nurusun. Hamd Sana mahsustur; Sen göklerin ve yerin yegâne hâkimi ve sahibisin. Sen Hak\'sın, vaadin haktır...',
        note: 'Buhârî ve Müslim rivayeti; teheccüd sonrası okunacak en kıymetli münacatlardandır.',
      ),
    ],
  );

  // ════════════════════════════════════════════════════════════════════════════
  // 3. KUŞLUK (DUHÂ / İŞRÂK) NAMAZI
  // ════════════════════════════════════════════════════════════════════════════
  static const _duhaPrayer = NafilaPrayer(
    id: 'duha',
    title: 'Kuşluk (Duhâ & İşrâk) Namazı',
    arabicTitle: 'صَلَاةُ الضُّحَى وَالْإِشْرَاقِ',
    category: NafilaCategory.dailySunnah,
    rakats: '2, 4, 8 veya 12 Rekat (En az 2, ideali 4 rekat)',
    timing: 'Güneş doğduktan sonra kerahet vaktinin çıkmasıyla (yaklaşık 45-50 dakika sonra) başlar, öğle ezanına yaklaşık 35-40 dakika kalana (istiva / zeval vaktine) kadar kılınabilir. İlk vaktinde kılınana İşrâk, güneş yükseldikten sonra kılınana Duhâ denir.',
    conditions: 'Kerahet vaktinin tamamen çıkmış olması şarttır. İkişer rekat selamla kılınması efdaldir.',
    virtues: 'Resûlullah (s.a.v.) buyurdu: "İnsanoğlunun vücudunda 360 eklem vardır. Her gün her bir eklem için bir sadaka vermek gerekir. Kuşluk vaktinde kılınacak 2 rekat namaz ise bütün bunların yerine geçer." (Müslim)\n'
        'Rızkın bereketlenmesine, günün manevi zırhla korunmasına vesile olur.',
    rewards: [
      '360 Eklemin Günlük Şükür Sadakası: Peygamberimiz (s.a.v.): "Her birinizin her bir eklemi için her gün bir sadaka gerekir. Kuşluk vaktinde kılınan iki rekat namaz ise bütün bunların yerine geçer." (Müslim, Müsâfirîn 84).',
      'Günün Bütün İşlerine İlahi Kifâyet: Kutsi Hadiste Cenâb-ı Hak buyurur: "Ey Âdemoğlu! Günün evvelinde benim için dört rekat namaz kıl, ben de günün sonuna kadar sana kâfi geleyim." (Ebû Dâvûd, Tatavvu 12; Tirmizî).',
      'Deniz Köpüğü Kadar Günahların Bağışlanması: "Kim kuşluk namazının iki rekatına devam ederse, günahları deniz köpüğü kadar çok olsa bile bağışlanır." (İbn Mâce, İkâme 187).',
      'Evvâbîn (Tevbekârlar) Arasına Yazılma: "Kuşluk namazına ancak tevbe ile Allah\'a çokça yönelenler (evvâbîn) devam eder. O, evvâbînin namazıdır." (Müslim).',
    ],
    niyyah: 'Niyet ettim Allah rızası için Kuşluk (Duhâ) namazı kılmaya.',
    shortSummary: 'Vücuttaki 360 eklemin şükür sadakası sayılan, rızık ve bereket vesilesi gündüz sünneti.',
    isFeatured: true,
    recommendedSurahs: [
      '1. Rekat: Şems Sûresi veya Kâfirûn Sûresi',
      '2. Rekat: Duhâ Sûresi veya İhlâs Sûresi',
    ],
    steps: [
      NafilaStep(
        title: '1. Rekat',
        description: 'Niyet edilir, tekbir alınır. Sübhaneke, Eûzü-Besmele, Fâtiha ve zamm-ı sûre (tercihen Şems veya Kâfirûn) okunup rükû ve secdeler yapılır.',
      ),
      NafilaStep(
        title: '2. Rekat ve Selam',
        description: 'Ayağa kalkılır, Besmele, Fâtiha ve zamm-ı sûre (tercihen Duhâ veya İhlâs) okunur. Rükû ve secdelerden sonra ka\'dede Ettehiyyâtü, Salli-Bârik, Rabbenâ okunarak selâm verilir.',
      ),
    ],
  );

  // ════════════════════════════════════════════════════════════════════════════
  // 4. EVVÂBÎN NAMAZI
  // ════════════════════════════════════════════════════════════════════════════
  static const _evvabinPrayer = NafilaPrayer(
    id: 'evvabin',
    title: 'Evvâbîn Namazı',
    arabicTitle: 'صَلَاةُ الْأَوَّابِينَ (التَّوَّابِينَ)',
    category: NafilaCategory.dailySunnah,
    rakats: '2, 4 veya 6 Rekat (İkişer rekat selamla kılınması müstehaptır)',
    timing: 'Akşam namazının farzı ve iki rekat sünneti kılındıktan hemen sonra, yatsı namazı vaktine kadar kılınır.',
    conditions: 'Akşam namazından sonra dünyevi laflarla meşgul olmadan hemen nafileye niyet etmek edeplerdendir.',
    virtues: '"Evvâbîn", günahlarından tövbe edip daima Allah\'a yönelenler demektir. '
        'Hadis-i şerifte: "Kim akşam namazından sonra araya kötü bir söz sokmadan altı rekat namaz kılarsa, bu namaz onun için on iki senelik nafile ibadete denk tutulur." (Tirmizî) buyrulmuştur.',
    rewards: [
      '12 Yıllık Nafile İbadet Sevabı: Resûlullah (s.a.v.): "Kim akşam namazından sonra dünya kelamı konuşmaksızın altı rekat kılarsa, bu onun için on iki senelik nafile ibadete denk tutulur." (Tirmizî, Salât 321; İbn Mâce).',
      'Allah\'a Yönelenler Kütüğüne Kaydolma: Kur\'an-ı Kerim\'deki "Şüphesiz O, evvâb olanları (kendisine çokça yönelenleri) çok bağışlayıcıdır" (İsrâ, 25) ilahi iltifatına nail olma.',
      'Gaflet Saatini İhyâ: İnsanların akşam telaşı ve yemekle meşgul olduğu vakti seccade başında geçirip meleklerin gıpta ettiği kullardan olma bereketi.',
    ],
    niyyah: 'Niyet ettim Allah rızası için Evvâbîn namazı kılmaya.',
    shortSummary: 'Akşam namazından sonra kılınan, günahları bağışlatan ve tevbe edenlerin nişanı olan 6 rekatlık sünnet.',
    steps: [
      NafilaStep(
        title: 'Kılınış Düzeni',
        description: 'Akşam namazının sünnetinden sonra ikişer rekatlık niyetlerle toplam 6 rekata kadar kılınır. '
            'Sabah namazının sünneti gibi 2 rekat kılınıp selam verilir; ardından tekrar niyet edilip diğer rekatlar tamamlanır.',
      ),
    ],
  );

  // ════════════════════════════════════════════════════════════════════════════
  // 5. İSTİHÂRE NAMAZI
  // ════════════════════════════════════════════════════════════════════════════
  static const _istiharePrayer = NafilaPrayer(
    id: 'istihare',
    title: 'İstihâre Namazı',
    arabicTitle: 'صَلَاةُ الِاسْتِخَارَةِ لِطَلَبِ الْخَيْرِ',
    category: NafilaCategory.hacetGuidance,
    rakats: '2 Rekat',
    timing: 'Kerahet vakitleri dışında herhangi bir zaman kılınabilir. En faziletlisi, gece yatmadan hemen önce abdestli olarak kılınmasıdır.',
    conditions: '1. Meşru, helal ve hayırlı bir konuda iki alternatif arasında kararsız kalmış olmak (Haram veya farz olan şeylerde istihare yapılmaz).\n'
        '2. Namazdan sonra istihare duasını okumak ve lüzumsuz dünya kelamı konuşmadan sağ yana kıbleye dönük yatmak.\n'
        '3. Rüyada beyaz veya yeşil renk görmek hayra, siyah veya kırmızı görmek şerre yorulur; ancak asıl olan kalbin meylidir.',
    virtues: 'Cabir b. Abdullah (r.a.) anlatıyor: "Resûlullah (s.a.v.) bize, Kur\'an\'dan bir sûre öğretir gibi her işte istihare yapmayı öğretirdi." (Buhârî)',
    rewards: [
      'Pişmanlık ve Hüsrandan Muhafaza: "İstihâre eden hüsrana uğramaz, istişare eden pişman olmaz, iktisatlı olan da fakir düşmez." (Taberânî).',
      'İlahi İlim ve Hikmete Teslimiyet: Kul, sınırlı aklını Cenâb-ı Hakk\'ın sonsuz ilmine emanet ederek doğru ve hayırlı kapıların açılmasını sağlar.',
      'Gönül Ferahlığı & Şerlerden Korunma: Kararsızlık sıkıntısı son bulur; zahiren cazip görünse dahi sonu musibet getirecek tehlikeler bertaraf edilir.',
    ],
    niyyah: 'Niyet ettim Allah rızası için İstihâre namazı kılmaya.',
    shortSummary: 'Önemli kararlar öncesinde hayırlı olanı Cenâb-ı Hakk\'tan talep etmek için kılınan 2 rekatlık istişare namazı.',
    recommendedSurahs: [
      '1. Rekat: Fâtiha ve Kâfirûn Sûresi',
      '2. Rekat: Fâtiha ve İhlâs Sûresi',
    ],
    steps: [
      NafilaStep(
        title: '1. Rekat',
        description: 'Niyet edilip tekbir alınır. Sübhaneke, Besmele, Fâtiha ve Kâfirûn Sûresi okunur. Rükû ve secdeler yapılır.',
      ),
      NafilaStep(
        title: '2. Rekat',
        description: 'Besmele, Fâtiha ve İhlâs Sûresi okunur. Ka\'dede dualar bitirilip selâm verilir. Selamdan sonra İstihâre Duası huşû ile okunur.',
      ),
    ],
    specialDuas: [
      NafilaSpecialDua(
        title: 'Resûlullah (s.a.v.)\'in Öğrettiği İstihâre Duası (Tam Metin)',
        arabic: 'اللّٰهُمَّ إِنِّي أَسْتَخِيرُكَ بِعِلْمِكَ، وَأَسْتَقْدِرُكَ بِقُدْرَتِكَ، وَأَسْأَلُكَ مِنْ فَضْلِكَ الْعَظِيمِ، فَإِنَّكَ تَقْدِرُ وَلَا أَقْدِرُ، وَتَعْلَمُ وَلَا أَعْلَمُ، وَأَنْتَ عَلَّامُ الْغُيُوبِ. اللّٰهُمَّ إِنْ كُنْتَ تَعْلَمُ أَنَّ هَذَا الْأَمْرَ خَيْرٌ لِي فِي دِينِي وَمَعَاشِي وَعَاقِبَةِ أَمْرِي فَاقْدُرْهُ لِي وَيَسِّرْهُ لِي ثُمَّ بَارِكْ لِي فِيهِ...',
        transliteration: 'Allâhümme innî estehîrüke bi-ılmike ve estakdirüke bi-kudratike ve es\'elüke min fadlike\'l-azîm. Fe-inneke takdiru ve lâ akdiru ve ta\'lemü ve lâ a\'lemü ve ente allâmü\'l-guyûb. Allâhümme in künte ta\'lemü enne hâze\'l-emra hayrun lî fî dînî ve meâşî ve âkıbeti emrî fe\'kdürhü lî ve yessirhü lî sümme bârik lî fîh...',
        meaning: 'Allah\'ım! İlminle Sen\'den hayırlısını dilerim, kudretinle Sen\'den güç isterim. Lütfundan dilerim. Çünkü Sen\'in gücün yeter, benimki yetmez; Sen bilirsin, ben bilmem. Sen gaybları kemâliyle bilensin. Allah\'ım! Bu iş benim dinim, dünyam ve ahiretim için hayırlı ise onu bana takdir eyle, kolaylaştır ve bereketli kıl...',
        note: 'Dua okunurken "hâze\'l-emra" (bu iş) kısmında kalpten niyet edilen niyet/karar geçirilir.',
      ),
    ],
  );

  // ════════════════════════════════════════════════════════════════════════════
  // 6. HÂCET NAMAZI (Dilek ve İhtiyaç)
  // ════════════════════════════════════════════════════════════════════════════
  static const _hacetPrayer = NafilaPrayer(
    id: 'hacet',
    title: 'Hâcet Namazı (Dilek & İhtiyaç)',
    arabicTitle: 'صَلَاةُ الْحَاجَةِ وَكَشْفِ الْكَرْبِ',
    category: NafilaCategory.hacetGuidance,
    rakats: '2 veya 4 Rekat',
    timing: 'Kerahet vakitleri dışında her vakit kılınabilir. Özellikle yatsı namazından sonra veya gecenin sakin vakitlerinde kılınması çok tecrübe edilmiştir.',
    conditions: '1. Meşru ve helal bir ihtiyacın olması.\n'
        '2. Gusül veya güzelce alınmış kamil bir abdest.\n'
        '3. Namaz sonrasında Allah\'a hamd, Peygamberimiz (s.a.v.)\'e bolca salavat getirip Hâcet Duasını okumak.',
    virtues: 'Peygamber Efendimiz (s.a.v.) buyurdu: "Kimin Allah\'tan veya insanlardan bir dileği ve ihtiyacı olursa, güzelce abdest alsın, sonra iki rekat namaz kılsın. Sonra Allah\'a hamd edip Resûlullah\'a salât ü selâm getirsin ve şu duayı okusun..." (Tirmizî, İbn Mâce)',
    rewards: [
      'Meleklerin Âmin Demesi & Darlıkların Açılması: Efendimiz (s.a.v.): "Kimin Allah\'tan veya kullardan bir dileği olursa güzelce abdest alıp iki rekat namaz kılsın, hamd ü senâ ve salavatla dua etsin... Muhakkak Allah ona bir çıkış yolu ihsan eder." (Tirmizî, Salât 348).',
      'Sebeplerin Sahibi Olan Allah\'a İlticâ: Kula minnet etmeden, bizzat Hâcetlerin Mercii olan Kadîr-i Zülcelâl\'e boyun büküp istemenin vakar ve mükafatı.',
      'Sabır, Teselli ve Manevi Sekînet: Çaresizlik girdabından kurtulup dertlerin yükünü sonsuz rahmet sahibine tevdi etmenin huzuru.',
    ],
    niyyah: 'Niyet ettim Allah rızası için Hâcet namazı kılmaya.',
    shortSummary: 'Dünyevi ve uhrevi meşru bir dilek, şifa veya sıkıntının feraha kavuşması için kılınan dua namazı.',
    steps: [
      NafilaStep(
        title: 'Kılınış',
        description: '2 rekat olarak kılınır. 1. rekatta Fâtiha ve Âyetü\'l-Kürsî (veya Kâfirûn), 2. rekatta Fâtiha ve İhlâs okunması efdaldir. '
            'Selamdan sonra eller semaya açılıp hacet duası ve samimi münacat yapılır.',
      ),
    ],
    specialDuas: [
      NafilaSpecialDua(
        title: 'Hâcet Duası (Tirmizî Rivayeti)',
        arabic: 'لَا إِلٰهَ إِلَّا اللّٰهُ الْحَلِيمُ الْكَرِيمُ، سُبْحَانَ اللّٰهِ رَبِّ الْعَرْشِ الْعَظِيمِ، الْحَمْدُ لِلّٰهِ رَبِّ الْعَالَمِينَ. أَسْأَلُكَ مُوجِبَاتِ رَحْمَتِكَ، وَعَزَائِمَ مَغْفِرَتِكَ، وَالْغَنِيمَةَ مِنْ كُلِّ بِرٍّ، وَالسَّلَامَةَ مِنْ كُلِّ إِثْمٍ، لَا تَدَعْ لِي ذَنْبًا إِلَّا غَفَرْتَهُ، وَلَا هَمًّا إِلَّا فَرَّجْتَهُ، وَلَا حَاجَةً هِيَ لَكَ رِضًا إِلَّا قَضَيْتَهَا يَا أَرْحَمَ الرَّاحِمِينَ.',
        transliteration: 'Lâ ilâhe illallâhü\'l-Halîmü\'l-Kerîm. Sübhânallâhi Rabbi\'l-arşi\'l-azîm. El-hamdü lillâhi Rabbi\'l-âlemîn. Es\'elüke mûcibâti rahmetike ve azâime mağfiratike ve\'l-ganîmete min külli birrin ves-selâmete min külli ismin. Lâ teda\' lî zenben illâ gaferteh, ve lâ hemmen illâ ferrecteh, ve lâ hâceten hiye leke rıdan illâ kadaytehâ yâ erhame\'r-râhimîn.',
        meaning: 'Hilim ve kerem sahibi Allah\'tan başka ilah yoktur. Yüce Arş\'ın Rabbi olan Allah\'ı noksanlıklardan tenzih ederim. Âlemlerin Rabbi Allah\'a hamdolsun. Allah\'ım! Rahmetini celbeden vesileleri, mağfiretini gerektiren amelleri, her iyilikten nasibi ve her günahtan selameti Senden dilerim. Bağışlamadığın hiçbir günahımı, gidermediğin hiçbir kederimi ve rızana uygun olup da yerine getirmediğin hiçbir meşru ihtiyacımı bırakma, ey merhametlilerin en merhametlisi!',
      ),
    ],
  );

  // ════════════════════════════════════════════════════════════════════════════
  // 7. TESBİH NAMAZI (300 Tesbih)
  // ════════════════════════════════════════════════════════════════════════════
  static const _tesbihPrayer = NafilaPrayer(
    id: 'tesbih',
    title: 'Tesbih Namazı',
    arabicTitle: 'صَلَاةُ التَّسْبِيحِ (ثَلَاثُمِائَةِ تَسْبِيحَةٍ)',
    category: NafilaCategory.specialOccasion,
    rakats: '4 Rekat (Toplam 300 defa mahsus tesbih zikredilir)',
    timing: 'Kerahet vakitleri haricinde gündüz veya gece kılınabilir. Kandil gecelerinde ve Cuma gecelerinde kılınması çok yaygındır.',
    conditions: 'Her rekatta 75 defa olmak üzere 4 rekatta toplam 300 defa şu tesbih okunur:\n'
        '«Sübhânallâhi ve\'l-hamdü lillâhi ve lâ ilâhe illallâhü vallâhü ekber»',
    virtues: 'Peygamberimiz (s.a.v.) amcası Hz. Abbas\'a: "Ey amca! Sana on fazileti olan bir namaz öğreteyim mi? Bunu kıldığın zaman Allah senin günahlarının ilkini, sonunu, eskisini, yenisini, bilerek veya bilmeyerek işlediğini bağışlar. Gücün yeterse her gün, olmazsa her cuma, olmazsa ayda bir, olmazsa yılda bir, o da olmazsa ömründe bir defa kıl." buyurmuştur. (Ebû Dâvûd, Tirmizî)',
    rewards: [
      '10 Çeşit Günahın Toptan Affedilmesi: Peygamberimiz (s.a.v.) amcası Hz. Abbas\'a buyurdu: "Bu namazı kıldığın vakit Allah senin ilk ve son, eski ve yeni, bilerek veya bilmeyerek işlediğin, küçük ve büyük, gizli ve aşikâr on çeşit günahını bağışlar." (Ebû Dâvûd, Tatavvu 14; Tirmizî).',
      '300 Defa En Yüce Tevhid ve Tesbih Ecri: 4 rekatta toplam 300 defa Arş\'ı titreten tesbih okunarak amel terazisinin sağ kefesi en ağır sevaplarla doldurulur.',
      'Kandil ve Cuma Gecelerinin Manevi Tacı: Bütün ömrün günah yükünden arınıp melekler safına yükselme fırsatı sunan müstesna bir ilahi hediyedir.',
    ],
    niyyah: 'Niyet ettim Allah rızası için Tesbih namazı kılmaya.',
    shortSummary: 'Ömürde en az bir kez kılınması tavsiye edilen, 300 tesbihle bütün günahlara kefaret olan muazzam namaz.',
    steps: [
      NafilaStep(
        title: 'Her Rekatta 75 Tesbihin Dağılım Tablosu',
        description: '1. Sübhaneke\'den sonra Fâtiha ve sûre okunmadan önce: 15 defa\n'
            '2. Fâtiha ve bir zamm-ı sûre okunduktan sonra (ayaktayken): 10 defa\n'
            '3. Rükûya varıp rükû tesbihinden sonra: 10 defa\n'
            '4. Rükûdan doğrulunca (ayakta / kavmede): 10 defa\n'
            '5. Birinci secdede secde tesbihinden sonra: 10 defa\n'
            '6. İki secde arasındaki oturuşta (celsede): 10 defa\n'
            '7. İkinci secdede secde tesbihinden sonra: 10 defa\n'
            '➜ Böylece bir rekatta tam 75 tesbih okunmuş olur. 4 rekatta toplam 300 tesbih tamamlanır.',
        recitationArabic: 'سُبْحَانَ اللّٰهِ وَالْحَمْدُ لِلّٰهِ وَلَا إِلٰهَ إِلَّا اللّٰهُ وَاللّٰهُ أَكْبَرُ',
        recitationTranslit: 'Sübhânallâhi vel-hamdü lillâhi ve lâ ilâhe illallâhü vallâhü ekber.',
        recitationMeaning: 'Allah noksan sıfatlardan münezzehtir, hamd Allah\'a mahsustur, Allah\'tan başka ilah yoktur ve Allah en büyüktür.',
      ),
    ],
  );

  // ════════════════════════════════════════════════════════════════════════════
  // 8. TEVBE NAMAZI
  // ════════════════════════════════════════════════════════════════════════════
  static const _tovbePrayer = NafilaPrayer(
    id: 'tovbe',
    title: 'Tevbe Namazı',
    arabicTitle: 'صَلَاةُ التَّوْبَةِ وَالِاسْتِغْفَارِ',
    category: NafilaCategory.repentance,
    rakats: '2 Rekat',
    timing: 'Bir günah işlendiğinde veya kalpte nedamet hissi uyandığında geciktirmeden derhal kılınır.',
    conditions: '1. İşlenen günahtan dolayı kalben derin bir pişmanlık duymak.\n'
        '2. Günahı derhal terk etmek ve bir daha dönmemeye kesin azmetmek.\n'
        '3. Kul hakkı varsa hak sahibine hakkını iade edip helallik almak.',
    virtues: 'Hz. Ebû Bekir (r.a.) rivayet eder: Resûlullah (s.a.v.) şöyle buyurdu: "Bir kul bir günah işler de ardından güzelce abdest alır, kalkıp iki rekat namaz kılar ve Allah\'tan bağışlanma dilerse, Allah onu mutlaka bağışlar." (Ebû Dâvûd, Tirmizî)',
    rewards: [
      'Günahsız Doğmuş Gibi Arınma: Fahr-i Kâinat Efendimiz (s.a.v.) müjdeler: "Günahtan tam tevbe eden, sanki hiç günah işlememiş gibidir." (İbn Mâce, Zühd 30).',
      'Kötülüklerin Sevaba Dönüşmesi: Kur\'an-ı Kerim: "Ancak tevbe edip iman eden ve salih amel işleyenler müstesna; işte Allah onların kötülüklerini (seyyiatını) iyiliklere (hasenata) çevirir." (Furkân, 70).',
      'Meleklerin Mağfiret Müjdesi: Bir günahın ardından abdest alıp iki rekat namaz kılan ve istiğfar eden kulun mutlaka affedileceği Hadis-i Şerif ile sabittir (Ebû Dâvûd, Vitir 26).',
    ],
    niyyah: 'Niyet ettim Allah rızası için Tevbe namazı kılmaya.',
    shortSummary: 'Hata ve günahların ardından kulun günah kirinden arınıp tertemiz bir sayfa açması için kılınan 2 rekatlık mağfiret namazı.',
    steps: [
      NafilaStep(
        title: 'Kılınış',
        description: 'Huşu içinde 2 rekat namaz kılınır. Selamdan sonra secdede veya eller semaya kaldırılarak Seyyidü\'l-İstiğfar duası okunur ve gözyaşlarıyla af dilenir.',
      ),
    ],
    specialDuas: [
      NafilaSpecialDua(
        title: 'Seyyidü\'l-İstiğfar (İstiğfarların Efendisi)',
        arabic: 'اللّٰهُمَّ أَنْتَ رَبِّي لَا إِلٰهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ.',
        transliteration: 'Allâhümme ente Rabbî lâ ilâhe illâ ente, halaktenî ve ene abdüke, ve ene alâ ahdike ve va\'dike mesteta\'tü, eûzü bike min şerri mâ sana\'tü, ebûü leke bi-ni\'metike aleyye ve ebûü bi-zenbî fağfirlî fe-innehû lâ yağfiru\'z-zünûbe illâ ente.',
        meaning: 'Allah\'ım! Sen benim Rabbimsin. Senden başka hiçbir ilah yoktur. Beni Sen yarattın, ben Senin kulunum. Gücüm yettiğince Sana verdiğim söz ve ahid üzerindeyim. İşlediğim kötülüklerin şerrinden Sana sığınırım. Üzerimdeki nimetini itiraf eder, günahımı da ikrar ederim. Beni bağışla; çünkü günahları Senden başkası bağışlayamaz.',
        note: 'Peygamberimiz: "Bunu inanarak gündüz okuyan akşama varmadan ölürse cennetliktir, gece okuyan sabaha varmadan ölürse cennetliktir" buyurmuştur.',
      ),
    ],
  );

  // ════════════════════════════════════════════════════════════════════════════
  // 9. TAHİYYETÜ'L-MESCİD (Mescidi Selamlama)
  // ════════════════════════════════════════════════════════════════════════════
  static const _tahiyyetulMescidPrayer = NafilaPrayer(
    id: 'tahiyyetul_mescid',
    title: 'Tahiyyetü\'l-Mescid',
    arabicTitle: 'تَحِيَّةُ الْمَسْجِدِ (إِكْرَامُ بَيْتِ اللّٰهِ)',
    category: NafilaCategory.specialOccasion,
    rakats: '2 Rekat',
    timing: 'Bir camiye veya mescide girildiğinde, henüz oturmadan önce kılınır. Kerahet vakti ise kılınmaz, tesbih ile meşgul olunur.',
    conditions: 'Camiye ibadet veya ziyaret niyetiyle girilmiş olması ve oturmadan önce kılınması sünnettir.',
    virtues: 'Peygamberimiz (s.a.v.) buyurdu: "Biriniz mescide girdiğinde, oturmadan önce iki rekat namaz kılsın." (Buhârî, Müslim)',
    rewards: [
      'Allah\'ın Evine ve Sahibine Tazim: Peygamberimiz (s.a.v.): "Biriniz mescide girdiğinde oturmadan önce iki rekat namaz kılsın." buyurarak Beytullah\'ın şubelerini selamlama sünnetini emretmiştir (Buhârî, Salât 60).',
      'Meleklerin Kesintisiz Duası: Camide bu hürmetle bekleyen kul için melekler "Allah\'ım ona merhamet et, onu bağışla, tövbesini kabul buyur" diye istiğfar eder.',
      'Namazda Geçen Vakit Ecri: Mescide adım attığı andan itibaren kul, namaz kılmış gibi sevap hanesine aralıksız ecir yazılır.',
    ],
    niyyah: 'Niyet ettim Allah rızası için Tahiyyetü\'l-Mescid namazı kılmaya.',
    shortSummary: 'Allah\'ın evi olan camiye girildiğinde hürmet ve selamlama olarak kılınan 2 rekatlık sünnet.',
    steps: [
      NafilaStep(
        title: 'Kılınış',
        description: 'Camiye girince oturmadan kıbleye dönülür, 2 rekat nafile namaz kılınır. Cemaatle farza başlanmışsa veya hutbe okunuyorsa kılınmaz, imama uyulur.',
      ),
    ],
  );

  // ════════════════════════════════════════════════════════════════════════════
  // 10. ŞÜKÜR NAMAZI
  // ════════════════════════════════════════════════════════════════════════════
  static const _sukurPrayer = NafilaPrayer(
    id: 'sukur',
    title: 'Şükür Namazı',
    arabicTitle: 'صَلَاةُ الشُّكْرِ وَسَجْدَةُ الشُّكْرِ',
    category: NafilaCategory.repentance,
    rakats: '2 Rekat',
    timing: 'Sevindirici bir haber alındığında, bir nimet ihsan edildiğinde veya büyük bir kaza, bela ve musibetten kurtulunduğunda kılınır.',
    conditions: 'Kerahet vakti dışında abdestli olarak kılınır. Vakit müsait değilse hemen secde-i şükür yapılır.',
    virtues: 'Peygamber Efendimiz (s.a.v.), kendisini sevindiren bir haber veya hayırlı bir durumla karşılaştığında Allah\'a şükretmek için namaz kılar veya secdeye kapanırdı. (Ebû Dâvûd)',
    rewards: [
      'Nimetlerin Kat Kat Artması Vaadi: Kur\'an-ı Kerim\'in ilahi fermanı: "Eğer şükrederseniz, elbette size (nimetimi) artırırım." (İbrâhîm, 7).',
      'Peygamber Ahlakıyla Süslenme: Efendimiz (s.a.v.) sevinçli bir haber veya zafer kazandığında derhal secdeye varır veya iki rekat şükür namazı kılardı (Ebû Dâvûd, Cihâd 162).',
      'Nimetin Elden Çıkmasından (Zevalinden) Korunma: Şükrü kılınan nimet zeval bulmaz, nankörlük afetinden korunur ve ilahi muhafazaya alınır.',
    ],
    niyyah: 'Niyet ettim Allah rızası için Şükür namazı kılmaya.',
    shortSummary: 'İhsan edilen nimetlere, şifaya veya atlatılan belalara karşı kulun teşekkür nişanesi olan 2 rekat namaz.',
    steps: [
      NafilaStep(
        title: 'Kılınış',
        description: '2 rekat kılınır. Fâtiha\'dan sonra şükür ve hamd âyetleri okunması güzeldir. Selamdan sonra secdeye varılarak uzun uzun şükredilir.',
      ),
    ],
  );

  // ════════════════════════════════════════════════════════════════════════════
  // 11. YOLCULUK (SEFER) NAMAZI
  // ════════════════════════════════════════════════════════════════════════════
  static const _seferPrayer = NafilaPrayer(
    id: 'sefer',
    title: 'Yolculuk (Sefer) Namazı',
    arabicTitle: 'صَلَاةُ السَّفَرِ وَالْقُدُومِ',
    category: NafilaCategory.specialOccasion,
    rakats: '2 Rekat',
    timing: 'Yolculuğa çıkmadan önce evden ayrılırken 2 rekat; yolculuktan dönüldüğünde ise mahalleye/şehre girince mescitte 2 rekat kılınır.',
    conditions: 'Yolun hayırlı, kazasız ve bereketli geçmesi niyetiyle kılınır.',
    virtues: 'Resûlullah (s.a.v.) buyurdu: "Kişinin evinden ayrılırken geride bıraktığı en hayırlı şey, kılacağı iki rekat sefer namazıdır." (Taberânî)',
    rewards: [
      'Ev Halkına Bırakılan En Faziletli Emanet: Peygamberimiz (s.a.v.): "Kişinin sefere çıkarken geride bıraktığı en hayırlı vekil, evinde kıldığı iki rekat namazdır." (Taberânî).',
      'Yolculuk Boyunca İlahi Muhafaza: Yolun kazalarından, belalarından, meşakkat ve kötü sürprizlerinden Cenâb-ı Hakk\'ın koruma kalkanına sığınma.',
      'Salimen ve Afiyetle Dönüş Şükrü: Sefer dönüşü mescitte kılınan 2 rekat, yol yorgunluğunu manevi huzura dönüştürür ve aileyi selamete erdirir.',
    ],
    niyyah: 'Niyet ettim Allah rızası için Sefer (Yolculuk) namazı kılmaya.',
    shortSummary: 'Yola çıkarken selamet ve bereket, dönüşte ise afiyet şükrü için kılınan 2 rekatlık sünnet.',
    steps: [
      NafilaStep(
        title: 'Kılınış',
        description: '1. rekatta Kâfirûn, 2. rekatta İhlâs okunması tavsiye edilir. Namazdan sonra Ayetü\'l-Kürsi okunup selamet duaları edilir.',
      ),
    ],
  );

  // ════════════════════════════════════════════════════════════════════════════
  // 12. CUMA NAMAZI
  // ════════════════════════════════════════════════════════════════════════════
  static const _cumaPrayer = NafilaPrayer(
    id: 'cuma',
    title: 'Cuma Namazı',
    arabicTitle: 'صَلَاةُ الْجُمُعَةِ (سَيِّدُ الْأَيَّامِ)',
    category: NafilaCategory.specialOccasion,
    rakats: 'Toplam 16 veya 10 Rekat (2 Rekat Farz)',
    timing: 'Cuma günü öğle namazı vaktinde cemaatle ve camide kılınır. Cuma namazı kılınan yerde ayrıca o günün öğle farzı kılınmaz.',
    conditions: '1. Cemaatle kılınması farzdır (münferit kılınamaz).\n'
        '2. Farzdan önce hutbe okunması şarttır.\n'
        '3. Hür, mukim, sıhhati yerinde ve erkek Müslümanlara farz-ı ayındır.',
    virtues: 'Cuma günü müminlerin haftalık bayramıdır. "Üzerine güneşin doğduğu en hayırlı gün Cuma günüdür." (Müslim)',
    rewards: [
      'Haftalık Günahlara Kefaret: Peygamberimiz (s.a.v.): "Büyük günahlardan kaçınıldığı müddetçe, beş vakit namaz ve iki Cuma, aralarında işlenen küçük günahlara kefarettir." (Müslim, Tahâret 16).',
      'Her Adımına 1 Yıllık Oruç ve Namaz Sevabı: "Kim Cuma günü erkenden camiye yürüyerek gider ve hutbeyi dinlerse; attığı her adım için bir yıllık nafile oruç ve gece namazı sevabı verilir." (Tirmizî, Cuma 356).',
      'İcabet Saatiyle Duaların Kabulü: Cuma gününde gizli olan icabet vaktinde yapılan dualar semadan geri çevrilmez (Buhârî, Cuma 37).',
    ],
    niyyah: 'Niyet ettim Allah rızası için Cuma namazının farzına / sünnetine uydum hazır olan imama.',
    shortSummary: 'Haftalık bayramımız olan Cuma gününde hutbe ile cemaat halinde eda edilen mübarek farz namaz.',
    steps: [
      NafilaStep(
        title: 'Rekat Dağılımı ve Kılınış Sırası',
        description: '1. Cuma\'nın 4 rekat İlk Sünneti (Öğlenin ilk sünneti gibi kılınır).\n'
            '2. Cami içinde iç ezan okunur ve İmam minberde Cuma Hutbesi irad eder.\n'
            '3. Kamet getirilir ve İmamla birlikte 2 rekat Cuma Farzı kılınır.\n'
            '4. Farzın ardından 4 rekat Cuma\'nın Son Sünneti kılınır.\n'
            '5. İhtiyaten 4 rekat Zühr-i Âhir (Son Öğle) ve 2 rekat Vaktin Sünneti kılınarak tamamlanır.',
      ),
    ],
  );

  // ════════════════════════════════════════════════════════════════════════════
  // 13. BAYRAM NAMAZI (Ramazan ve Kurban)
  // ════════════════════════════════════════════════════════════════════════════
  static const _bayramPrayer = NafilaPrayer(
    id: 'bayram',
    title: 'Bayram Namazı (Fıtır & Kurban)',
    arabicTitle: 'صَلَاةُ الْعِيدَيْنِ (الْفِطْرِ وَالْأَضْحَى)',
    category: NafilaCategory.specialOccasion,
    rakats: '2 Rekat (Toplam 6 Zevâid Tekbiri ile)',
    timing: 'Bayramın 1. günü, güneş doğup kerahet vakti çıktıktan (yaklaşık 45-50 dakika sonra) istiva vaktine kadar kılınır.',
    conditions: 'Cuma namazının farz olduğu kimselere bayram namazı kılmak vaciptir. Cemaatle kılınır, ezanı ve kameti yoktur.',
    virtues: 'Bütün müminlerin neşe ve kardeşlikle camileri doldurduğu, birlik ve af bayramıdır.',
    rewards: [
      'Yevmü\'l-Câize (Mükafat ve Af Günü): Bayram sabahı Allah Teâlâ meleklere: "İşini bitiren işçinin karşılığı nedir?" diye sorar. Melekler: "Ücretini tam almaktır" der. Allah Teâlâ: "Şahit olun ki onları toptan affettim!" buyurur (Beyhakî).',
      'Müminlerin Kardeşlik & Birlik Nişanı: Tekbirlerle gök kubbeyi inleten cemaat, günahlarından arınarak bayrama masum bir neşeyle başlar.',
      'İbadetlerin Kabul Mührü: Ramazan orucunun veya Kurban fedakarlığının Cenâb-ı Hak katında kabul mührü hükmündedir.',
    ],
    niyyah: 'Niyet ettim Allah rızası için Ramazan/Kurban Bayramı namazını kılmaya, uydum hazır olan imama.',
    shortSummary: 'Yılda iki kez Ramazan ve Kurban sabahlarında 6 ilave tekbirle cemaatle kılınan sevinç namazı.',
    steps: [
      NafilaStep(
        title: '1. Rekat (3 İlave Tekbir Başta)',
        description: 'Niyet edilir, İftitah tekbiriyle başlanır. Sübhaneke okunur. Ardından imamla beraber eller kulaklara kaldırılarak 3 defa tekbir alınır:\n'
            '1. ve 2. tekbirde eller yana salınır, 3. tekbirde eller göbek altında bağlanır. İmam Fâtiha ve sûre okur, rükû ve secdeler yapılır.',
      ),
      NafilaStep(
        title: '2. Rekat (3 İlave Tekbir Rükûdan Önce)',
        description: 'İkinci rekatta imam önce Fâtiha ve zamm-ı sûreyi okur. Rükûya gitmeden önce eller kulaklara kaldırılarak 3 defa tekbir alınır ve her birinde eller yana salınır. '
            '4. tekbirde eller kaldırılmadan doğrudan rükûya varılır. Secdeler ve ka\'de tamamlanıp selam verilir. Ardından Bayram Hutbesi dinlenir.',
      ),
    ],
  );

  // ════════════════════════════════════════════════════════════════════════════
  // 14. TERAVİH NAMAZI
  // ════════════════════════════════════════════════════════════════════════════
  static const _teravihPrayer = NafilaPrayer(
    id: 'teravih',
    title: 'Teravih Namazı',
    arabicTitle: 'صَلَاةُ التَّرَاوِيحِ فِي شَهْرِ رَمَضَانَ',
    category: NafilaCategory.specialOccasion,
    rakats: '20 Rekat (İkişer veya dörder rekatta bir selamla)',
    timing: 'Ramazan ayına mahsustur. Yatsı namazının son sünnetinden sonra, Vitir namazından önce kılınır.',
    conditions: 'Kadın ve erkek her Müslümana sünnet-i müekkededir. Camide cemaatle kılınması sünnet-i kifayedir, evde tek başına da kılınabilir.',
    virtues: 'Peygamberimiz (s.a.v.): "Kim inanarak ve sevabını Allah\'tan umarak Ramazan gecelerini ihya ederse (teravih kılarsa), geçmiş günahları bağışlanır." (Buhârî, Müslim)',
    rewards: [
      'Geçmiş Günahların Bağışlanması: Resûl-i Ekrem (s.a.v.): "Kim inanarak ve sevabını Allah\'tan umarak Ramazan gecelerini (teravih ile) ihya ederse, geçmiş günahları bağışlanır." (Buhârî, Salâtü\'t-Terâvîh 1).',
      'Bütün Geceyi İbadetle Geçirmiş Sayılma: "Kim imamla birlikte namazı tamamlayıncaya kadar kılarsa, ona bütün geceyi kıyamla (ibadetle) geçirmiş sevabı yazılır." (Ebû Dâvûd, Ramazân 1; Tirmizî).',
      'Cemaat Bereketi ve Kur\'an Hatmi: Kur\'an ayetlerinin huşû ile tilaveti kalpleri diriltir ve cemaatle kılınan her rekatın ecri katlanır.',
    ],
    niyyah: 'Niyet ettim Allah rızası için Teravih namazı kılmaya (varsa: uydum imama).',
    shortSummary: 'Ramazan gecelerinin neşesi, yatsı ile vitir arasında kılınan 20 rekatlık müekked sünnet.',
    steps: [
      NafilaStep(
        title: 'Kılınış Tertibi',
        description: 'Genellikle 4\'er rekat olarak kılınır (5 defa 4 rekat = 20 rekat). Dörder kılınırken ikindi namazının sünneti gibi kılınır; '
            'yani 1. oturuşta Salli-Barik okunur, 3. rekata kalkınca Sübhaneke ile başlanır. Her 4 rekat selamından sonra Salavat-ı Şerifeler ve Teravih İlahileri okunur. Sonunda Vitir namazı eda edilir.',
      ),
    ],
  );

  // ════════════════════════════════════════════════════════════════════════════
  // 15. KÜSÛF VE HUSÛF NAMAZI (Güneş ve Ay Tutulması)
  // ════════════════════════════════════════════════════════════════════════════
  static const _kusufPrayer = NafilaPrayer(
    id: 'kusuf_husuf',
    title: 'Küsûf & Husûf Namazı',
    arabicTitle: 'صَلَاةُ الْكُسُوفِ وَالْخُسُوفِ',
    category: NafilaCategory.specialOccasion,
    rakats: '2 Rekat (Uzun kıraat ve rükûlarla)',
    timing: 'Güneş tutulması (Küsûf) veya Ay tutulması (Husûf) başladığında kılınır; tutulma bitene kadar dua ve istiğfar edilir.',
    conditions: 'Güneş veya ay tutulduğunda ezansız ve kametsiz olarak cemaatle veya münferit olarak kılınır.',
    virtues: 'Peygamberimiz (s.a.v.) oğlu İbrahim vefat ettiğinde güneş tutulunca buyurdu: "Şüphesiz güneş ve ay Allah\'ın âyetlerindendir; birinin ölümü veya doğumu için tutulmazlar. Bunu gördüğünüzde Allah\'ı zikredin, tekbir getirin, namaz kılın ve sadaka verin." (Buhârî, Müslim)',
    rewards: [
      'İlahi İhtişam Karşısında Secde Edebi: Peygamberimiz (s.a.v.): "Güneş ve ay Allah\'ın ayetlerindendir... Bunu gördüğünüzde Allah\'ı zikredin, tekbir getirin, namaz kılın ve sadaka verin." (Buhârî, Küsûf 2).',
      'Kıyamet Dehşetini Hatırlayıp Uyanış: Kozmik düzenin sahibine sığınarak kalbi gafletten uyandırır ve haşyet makamına erdirir.',
      'Belaların Def\'i ve Rahmetin Celbi: Tutulma esnasında yapılan toplu dua ve namazlar, ilahi gazabı teskin eder ve semavi rahmeti celbeder.',
    ],
    niyyah: 'Niyet ettim Allah rızası için Küsûf/Husûf namazı kılmaya.',
    shortSummary: 'Güneş veya Ay tutulduğunda ilahi azamet karşısında ürperip kılınan sünnet namaz.',
    steps: [
      NafilaStep(
        title: 'Kılınış',
        description: '2 rekat kılınır. Kıraati, rükûsu ve secdeleri normal namazlara göre oldukça uzun tutulur. Namazdan sonra tutulma açılana dek kıbleye karşı istiğfar ve dua edilir.',
      ),
    ],
  );
}

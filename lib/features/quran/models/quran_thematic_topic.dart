import 'package:flutter/material.dart';

/// Tematik bir konudaki ayet kaydı
class ThematicVerseEntry {
  final int surahId;
  final String surahNameTr;
  final String surahNameAr;
  final int verseNumber;
  final String arabicText;
  final String turkishMeaning;
  final String? englishMeaning;
  final String insight;

  const ThematicVerseEntry({
    required this.surahId,
    required this.surahNameTr,
    required this.surahNameAr,
    required this.verseNumber,
    required this.arabicText,
    required this.turkishMeaning,
    this.englishMeaning,
    required this.insight,
  });

  String get reference => '$surahNameTr • $verseNumber. Âyet';
}

/// Tematik Kur'an Fihristi ve Kavram Atlası Kategori Modeli
class QuranThematicTopic {
  final String id;
  final String titleTr;
  final String titleEn;
  final String subtitleTr;
  final IconData icon;
  final int primaryColorHex;
  final String category; // 'zorluk_sifa', 'ibadet_ahiret', 'ahlak_aile', 'ilim_tefekkur'
  final String contemplationNote;
  final List<String> searchKeywords;
  final List<ThematicVerseEntry> verses;

  const QuranThematicTopic({
    required this.id,
    required this.titleTr,
    required this.titleEn,
    required this.subtitleTr,
    required this.icon,
    required this.primaryColorHex,
    required this.category,
    required this.contemplationNote,
    required this.searchKeywords,
    required this.verses,
  });

  bool matchesQuery(String query) {
    if (query.trim().isEmpty) return false;
    final q = normalize(query);
    if (normalize(titleTr).contains(q) || normalize(titleEn).contains(q)) return true;
    if (normalize(subtitleTr).contains(q) || normalize(contemplationNote).contains(q)) return true;
    for (final kw in searchKeywords) {
      final nKw = normalize(kw);
      if (nKw == q) return true;
      if (nKw.length >= 3 && q.length >= 3 && (nKw.contains(q) || q.contains(nKw))) return true;
    }
    for (final v in verses) {
      if (normalize(v.turkishMeaning).contains(q) || normalize(v.surahNameTr).contains(q) || normalize(v.insight).contains(q)) {
        return true;
      }
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

/// 14 Temel Hayati Konu ve Doğrulanmış Kur'an Ayetleri Veri Tabanı
final List<QuranThematicTopic> quranThematicTopicsList = [
  // 1. Sabır ve Tevekkül
  const QuranThematicTopic(
    id: 'sabir_ve_tevekkul',
    titleTr: 'Sabır ve Tevekkül',
    titleEn: 'Patience & Trust in Allah',
    subtitleTr: 'Zorluklar karşısında metanet, ilahi yardımın müjdesi ve gönül sükuneti',
    icon: Icons.hourglass_empty_rounded,
    primaryColorHex: 0xFF10B981,
    category: 'zorluk_sifa',
    contemplationNote: 'Kur\'an-ı Kerim\'de sabır sadece katlanmak değil; Hakk\'a güvenerek aktif bir sebat göstermektir. Allah sabredenlerle beraberdir.',
    searchKeywords: ['sabir', 'tevekkul', 'metanet', 'sikinti', 'dayanma', 'guven', 'patience', 'trust'],
    verses: [
      ThematicVerseEntry(
        surahId: 2,
        surahNameTr: 'Bakara',
        surahNameAr: 'البقرة',
        verseNumber: 153,
        arabicText: 'يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ ۚ إِنَّ اللَّهَ مَعَ الصَّابِرِينَ',
        turkishMeaning: 'Ey iman edenler! Sabır ve namazla Allah\'tan yardım isteyin. Şüphesiz Allah sabredenlerle beraberdir.',
        englishMeaning: 'O you who have believed, seek help through patience and prayer. Indeed, Allah is with the patient.',
        insight: 'İki büyük manevi sığınak: Sabır iç dünyayı dengeler, namaz ise Yüce Yaratıcı ile kesintisiz bağ kurar.',
      ),
      ThematicVerseEntry(
        surahId: 2,
        surahNameTr: 'Bakara',
        surahNameAr: 'البقرة',
        verseNumber: 155,
        arabicText: 'وَلَنَبْلُوَنَّكُم بِشَيْءٍ مِّنَ الْخَوْفِ وَالْجُوعِ وَنَقْصٍ مِّنَ الْأَمْوَالِ وَالْأَنفُسِ وَالثَّمَرَاتِ ۗ وَبَشِّرِ الصَّابِرِينَ',
        turkishMeaning: 'Andolsun ki sizi biraz korku ve açlıkla; mallardan, canlardan ve ürünlerden eksiltmekle sınayacağız. Sabredenleri müjdele!',
        englishMeaning: 'And We will surely test you with something of fear and hunger and a loss of wealth and lives and fruits, but give good tidings to the patient.',
        insight: 'Dünya imtihan yurdudur; kayıplar karşısında isyan etmek yerine sabretmek ilahi mükafatı celbeder.',
      ),
      ThematicVerseEntry(
        surahId: 65,
        surahNameTr: 'Talâk',
        surahNameAr: 'الطلاق',
        verseNumber: 3,
        arabicText: 'وَيَرْزُقْهُ مِنْ حَيْثُ لَا يَحْتَسِبُ ۚ وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ ۚ إِنَّ اللَّهَ بَالِغُ أَمْرِهِ',
        turkishMeaning: 'Ve onu ummadığı yerden rızıklandırır. Kim Allah\'a tevekkül ederse, O kendisine yeter. Şüphesiz Allah emrini yerine getirendir.',
        englishMeaning: 'And will provide for him from where he does not expect. And whoever relies upon Allah - then He is sufficient for him.',
        insight: 'Gerçek tevekkül, sebeplere sarıldıktan sonra neticeyi Allah\'ın sonsuz hikmetine teslim etmektir.',
      ),
      ThematicVerseEntry(
        surahId: 3,
        surahNameTr: 'Âl-i İmrân',
        surahNameAr: 'آل عمران',
        verseNumber: 200,
        arabicText: 'يَا أَيُّهَا الَّذِينَ آمَنُوا اصْبِرُوا وَصَابِرُوا وَرَابِطُوا وَاتَّقُوا اللَّهَ لَعَلَّكُمْ تُفْلِحُونَ',
        turkishMeaning: 'Ey iman edenler! Sabredin, sebat gösterin, (cihad için) hazırlıklı ve uyanık bulunun ve Allah\'tan korkun ki kurtuluşa eresiniz.',
        englishMeaning: 'O you who have believed, persevere and endure and remain stationed and fear Allah that you may be successful.',
        insight: 'Kurtuluş ve zafer, sabırda direnmek ve manevi nöbeti asla terk etmemekle gelir.',
      ),
    ],
  ),

  // 2. Rızık, Bereket ve Şükür
  const QuranThematicTopic(
    id: 'rizik_ve_bereket',
    titleTr: 'Rızık, Bereket ve Helal Kazanç',
    titleEn: 'Sustenance & Gratitude',
    subtitleTr: 'Tüm canlıların rızık kefili, şükürle artan nimetler ve helal lokma',
    icon: Icons.grain_rounded,
    primaryColorHex: 0xFFD97706,
    category: 'zorluk_sifa',
    contemplationNote: 'Rızık sadece para veya mal değildir; sıhhat, hidayet, huzurlu bir kalp ve helal nafaka en büyük rızıktır. Şükür nimeti çoğaltan anahtardır.',
    searchKeywords: ['rizik', 'bereket', 'helal', 'kazanc', 'nimet', 'sukur', 'wealth', 'provision'],
    verses: [
      ThematicVerseEntry(
        surahId: 11,
        surahNameTr: 'Hûd',
        surahNameAr: 'هود',
        verseNumber: 6,
        arabicText: 'وَمَا مِن دَابَّةٍ فِي الْأَرْضِ إِلَّا عَلَى اللَّهِ رِزْقُهَا وَيَعْلَمُ مُسْتَقَرَّهَا وَمُسْتَوْدَعَهَا',
        turkishMeaning: 'Yeryüzünde hiçbir canlı yoktur ki, rızkı Allah\'a ait olmasın. O, onun durduğu yeri de emanet bırakıldığı yeri de bilir.',
        englishMeaning: 'And there is no creature on earth but that upon Allah is its provision, and He knows its place of dwelling and place of storage.',
        insight: 'Hiçbir canlı sahipsiz değildir; geleceğe dair rızık endişesi iman ile giderilir.',
      ),
      ThematicVerseEntry(
        surahId: 14,
        surahNameTr: 'İbrâhîm',
        surahNameAr: 'إبراهيم',
        verseNumber: 7,
        arabicText: 'وَإِذْ تَأَذَّنَ رَبُّكُمْ لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ ۖ وَلَئِن كَفَرْتُمْ إِنَّ عَذَابِي لَشَدِيدٌ',
        turkishMeaning: 'Hani Rabbiniz şöyle duyurmuştu: "Andolsun, eğer şükrederseniz elbette size (nimetimi) artırırım. Eğer nankörlük ederseniz, şüphesiz azabım çok çetindir."',
        englishMeaning: 'And when your Lord proclaimed, \'If you are grateful, I will surely increase you [in favor]; but if you deny, indeed, My punishment is severe.\'',
        insight: 'Şükür sadece dille değil, nimeti verenin rızasına uygun kullanarak yapılan kalbi bir duruştur.',
      ),
      ThematicVerseEntry(
        surahId: 51,
        surahNameTr: 'Zâriyât',
        surahNameAr: 'الذاريات',
        verseNumber: 58,
        arabicText: 'إِنَّ اللَّهَ هُوَ الرَّزَّاقُ ذُو الْقُوَّةِ الْمَتِينُ',
        turkishMeaning: 'Şüphesiz rızık veren, mutlak güç ve sarsılmaz kuvvet sahibi olan ancak Allah\'tır.',
        englishMeaning: 'Indeed, it is Allah who is the Continual Provider, the firm possessor of strength.',
        insight: 'Kullara boyun eğmeden, yalnızca Rezzâk olan Rabbimizden talep etmek izzet kazandırır.',
      ),
    ],
  ),

  // 3. Şifa, Huzur ve Korunma Âyetleri
  const QuranThematicTopic(
    id: 'sifa_ve_huzur',
    titleTr: 'Şifa, Huzur ve Korunma Âyetleri',
    titleEn: 'Healing & Divine Peace',
    subtitleTr: 'Gönüllere ferahlık veren, vesveseyi dağıtan ve dertlere şifa olan ilahi nefesler',
    icon: Icons.spa_rounded,
    primaryColorHex: 0xFF0284C7,
    category: 'zorluk_sifa',
    contemplationNote: 'Kur\'an-ı Kerim hem kalbi hem de ruhi yaralar için bir şifa kaynağıdır. Kalpler ancak O\'nu zikretmekle sükuna erer.',
    searchKeywords: ['sifa', 'huzur', 'korunma', 'vesvese', 'kalp', 'sukunet', 'healing', 'peace'],
    verses: [
      ThematicVerseEntry(
        surahId: 17,
        surahNameTr: 'İsrâ',
        surahNameAr: 'الإسراء',
        verseNumber: 82,
        arabicText: 'وَنُنَزِّلُ مِنَ الْقُرْآنِ مَا هُوَ شِفَاءٌ وَرَحْمَةٌ لِّلْمُؤْمِنِينَ ۙ وَلَا يَزِيدُ الظَّالِمِينَ إِلَّا خَسَارًا',
        turkishMeaning: 'Biz Kur\'an\'dan öyle şeyler indiriyoruz ki, müminler için şifa ve rahmettir; zalimlerin ise ancak ziyanını artırır.',
        englishMeaning: 'And We send down of the Qur\'an that which is healing and mercy for the believers.',
        insight: 'Kur\'an okumak ve dinlemek, daralan göğüslere ilahi bir inşirah ve sekinet indirir.',
      ),
      ThematicVerseEntry(
        surahId: 13,
        surahNameTr: 'Ra\'d',
        surahNameAr: 'الرعد',
        verseNumber: 28,
        arabicText: 'الَّذِينَ آمَنُوا وَتَطْمَئِنُّ قُلُوبُهُم بِذِكْرِ اللَّهِ ۗ أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
        turkishMeaning: 'Onlar, iman etmiş ve kalpleri Allah\'ın zikriyle huzura kavuşmuş kimselerdir. Bilesiniz ki, kalpler ancak Allah\'ı anmakla huzur bulur.',
        englishMeaning: 'Those who have believed and whose hearts are assured by the remembrance of Allah. Unquestionably, by the remembrance of Allah hearts are assured.',
        insight: 'İnsanın iç dünyasındaki derin boşluğu dünya nimetleri değil, yalnızca Yaratıcısını anmak doldurabilir.',
      ),
      ThematicVerseEntry(
        surahId: 26,
        surahNameTr: 'Şuarâ',
        surahNameAr: 'الشعراء',
        verseNumber: 80,
        arabicText: 'وَإِذَا مَرِضْتُ فَهُوَ يَشْفِينِ',
        turkishMeaning: 'Hastalandığım zaman bana şifa veren O\'dur.',
        englishMeaning: 'And when I am ill, it is He who cures me.',
        insight: 'Hz. İbrahim\'in tevhid dili: Sebeplere ve tıbba başvururuz, fakat mutlak şifayı Şâfî olan Allah\'tan biliriz.',
      ),
    ],
  ),

  // 4. Tevbe, Mağfiret ve İlahi Rahmet
  const QuranThematicTopic(
    id: 'tevbe_ve_magfiret',
    titleTr: 'Tevbe, Mağfiret ve İlahi Rahmet',
    titleEn: 'Repentance & Divine Mercy',
    subtitleTr: 'Günahları örten, ümitsizliği yıkan ve günahkarları bağışlayan sonsuz merhamet',
    icon: Icons.water_drop_rounded,
    primaryColorHex: 0xFF8B5CF6,
    category: 'zorluk_sifa',
    contemplationNote: 'Allah\'ın rahmeti gazabını geçmiştir. Ne kadar hata yapılırsa yapılsın, samimi bir tevbe kapısı son nefese kadar ardına kadar açıktır.',
    searchKeywords: ['tevbe', 'bagislanma', 'affet', 'rahmet', 'magfiret', 'gunah', 'mercy', 'forgiveness'],
    verses: [
      ThematicVerseEntry(
        surahId: 39,
        surahNameTr: 'Zümer',
        surahNameAr: 'الزمر',
        verseNumber: 53,
        arabicText: 'قُلْ يَا عِبَادِيَ الَّذِينَ أَسْرَفُوا عَلَىٰ أَنفُسِهِمْ لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ ۚ إِنَّ اللَّهَ يَغْفِرُ الذُّنُوبَ جَمِيعًا ۚ إِنَّهُ هُوَ الْغَفُورُ الرَّحِيمُ',
        turkishMeaning: 'De ki: "Ey nefisleri aleyhine haddi aşmış olan kullarım! Allah\'ın rahmetinden ümidinizi kesmeyin. Şüphesiz Allah bütün günahları bağışlar. Çünkü O, çok bağışlayandır, çok merhamet edendir."',
        englishMeaning: 'Say, \'O My servants who have transgressed against themselves, do not despair of the mercy of Allah. Indeed, Allah forgives all sins. Indeed, it is He who is the Forgiving, the Merciful.\'',
        insight: 'Kur\'an\'ın en umut verici âyeti; hiçbir günah Allah\'ın sonsuz merhamet ve affından daha büyük olamaz.',
      ),
      ThematicVerseEntry(
        surahId: 4,
        surahNameTr: 'Nisâ',
        surahNameAr: 'النساء',
        verseNumber: 110,
        arabicText: 'وَمَن يَعْمَلْ سُوءًا أَوْ يَظْلِمْ نَفْسَهُ ثُمَّ يَسْتَغْفِرِ اللَّهَ يَجِدِ اللَّهَ غَفُورًا رَّحِيمًا',
        turkishMeaning: 'Kim bir kötülük yapar yahut nefsine zulmeder de sonra Allah\'tan bağışlanma dilerse, Allah\'ı çok bağışlayıcı ve çok merhamet edici bulur.',
        englishMeaning: 'And whoever does a wrong or wrongs himself but then seeks forgiveness of Allah will find Allah Forgiving and Merciful.',
        insight: 'İstiğfar, geçmişin ağırlığını omuzlardan kaldıran ve ruhu tazeleyen bir manevi arınmadır.',
      ),
      ThematicVerseEntry(
        surahId: 42,
        surahNameTr: 'Şûrâ',
        surahNameAr: 'الشورى',
        verseNumber: 25,
        arabicText: 'وَهُوَ الَّذِي يَقْبَلُ التَّوْبَةَ عَنْ عِبَادِهِ وَيَعْفُو عَنِ السَّيِّئَاتِ وَيَعْلَمُ مَا تَفْعَلُونَ',
        turkishMeaning: 'O, kullarından tevbeyi kabul eden, kötülükleri bağışlayan ve yaptıklarınızı bilendir.',
        englishMeaning: 'And it is He who accepts repentance from His servants and pardons misdeeds, and He knows what you do.',
        insight: 'Hataların ardından dönüp boyun eğmek ve tevbe etmek müminin en değerli meziyetidir.',
      ),
    ],
  ),

  // 5. Zor Zamanlar ve İnşirah (Ferahlama)
  const QuranThematicTopic(
    id: 'zor_zamanlar_ve_insirah',
    titleTr: 'Zor Zamanlar ve İnşirah (Ferahlama)',
    titleEn: 'Hardship & Relief',
    subtitleTr: 'Her gecenin bir sabahı, her zorluğun ardından gelen iki kat kolaylık müjdesi',
    icon: Icons.wb_sunny_rounded,
    primaryColorHex: 0xFFEC4899,
    category: 'zorluk_sifa',
    contemplationNote: 'Hayat iniş ve çıkışlarla doludur; darlık anında sabredenlere genişlik, keder anında sığınanlara ferahlık vadedilmiştir.',
    searchKeywords: ['zorluk', 'insirah', 'ferahlik', 'kolaylik', 'keder', 'huzun', 'hardship', 'relief'],
    verses: [
      ThematicVerseEntry(
        surahId: 94,
        surahNameTr: 'İnşirâh',
        surahNameAr: 'الشرح',
        verseNumber: 5,
        arabicText: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا • إِنَّ مَعَ الْعُسْرِ يُسْرًا',
        turkishMeaning: 'Şüphesiz zorlukla beraber bir kolaylık vardır. Gerçekten zorlukla beraber bir kolaylık vardır.',
        englishMeaning: 'For indeed, with hardship [will be] ease. Indeed, with hardship [will be] ease.',
        insight: 'Arapça gramer inceliği: Zorluk (el-usr) bir tanedir, kolaylık (yusr) ise iki kez tekrarlanarak zorluğu kuşatmıştır.',
      ),
      ThematicVerseEntry(
        surahId: 2,
        surahNameTr: 'Bakara',
        surahNameAr: 'البقرة',
        verseNumber: 286,
        arabicText: 'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا ۚ لَهَا مَا كَسَبَتْ وَعَلَيْهَا مَا اكْتَسَبَتْ',
        turkishMeaning: 'Allah hiçbir kimseyi güç yetiremeyeceği bir şeyle yükümlü kılmaz. Kazandığı iyilik kendi lehine, işlediği kötülük de kendi aleyhinedir.',
        englishMeaning: 'Allah does not charge a soul except [with that within] its capacity. It will have [the consequence of] what [good] it has gained, and it will bear [the consequence of] what [evil] it has earned.',
        insight: 'Başınıza gelen hiçbir yük omuzlarınızın taşıyamayacağı büyüklükte değildir; Allah güç ve sabır verir.',
      ),
      ThematicVerseEntry(
        surahId: 21,
        surahNameTr: 'Enbiyâ',
        surahNameAr: 'الأنبياء',
        verseNumber: 87,
        arabicText: 'لَّا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ',
        turkishMeaning: '"Senden başka hiçbir ilah yoktur. Seni her türlü eksiklikten tenzih ederim. Gerçekten ben haksızlık edenlerden oldum."',
        englishMeaning: 'There is no deity except You; exalted are You. Indeed, I have been of the wrongdoers.',
        insight: 'Hz. Yunus\'un balığın karnındaki duası: Karanlıklardan, sıkıntılardan ve bunalımlardan çıkaran en azametli münacat.',
      ),
    ],
  ),

  // 6. Anne-Baba ve Aile Hakkı
  const QuranThematicTopic(
    id: 'anne_baba_ve_aile',
    titleTr: 'Anne-Baba ve Aile Hakkı',
    titleEn: 'Parents & Family Rights',
    subtitleTr: 'Tevhitten hemen sonra emredilen anne-babaya hürmet ve ailedeki sevgi bağı',
    icon: Icons.family_restroom_rounded,
    primaryColorHex: 0xFFF97316,
    category: 'ahlak_aile',
    contemplationNote: 'Kur\'an, Allah\'a kulluktan hemen sonra anne-babaya iyiliği emreder. Onlara kol kanat germek cennet kapılarını aralar.',
    searchKeywords: ['anne', 'baba', 'aile', 'evlat', 'esler', 'merhamet', 'parents', 'family'],
    verses: [
      ThematicVerseEntry(
        surahId: 17,
        surahNameTr: 'İsrâ',
        surahNameAr: 'الإسراء',
        verseNumber: 23,
        arabicText: 'وَقَضَىٰ رَبُّكَ أَلَّا تَعْبُدُوا إِلَّا إِيَّاهُ وَبِالْوَالِدَيْنِ إِحْسَانًا ۚ إِمَّا يَبْلُغَنَّ عِندَكَ الْكِبَرَ أَحَدُهُمَا أَوْ كِلَاهُمَا فَلَا تَقُل لَّهُمَا أُفٍّ وَلَا تَنْهَرْهُمَا وَقُل لَّهُمَا قَوْلًا كَرِيمًا',
        turkishMeaning: 'Rabbin, kendisinden başkasına asla ibadet etmemenizi ve ana-babaya iyi davranmanızı kesin olarak emretti. Eğer onlardan biri veya her ikisi senin yanında yaşlanırsa, kendilerine "öf!" bile deme; onları azarlama; ikisine de güzel ve tatlı söz söyle.',
        englishMeaning: 'And your Lord has decreed that you not worship except Him, and to parents, good treatment. Whether one or both of them reach old age [while] with you, say not to them [so much as], \'uff,\' and do not repel them but speak to them a noble word.',
        insight: 'Yaşlandıklarında anne-babaya gösterilen sabır ve hürmet, evladın vefa ve iman derecesini gösterir.',
      ),
      ThematicVerseEntry(
        surahId: 30,
        surahNameTr: 'Rûm',
        surahNameAr: 'الروم',
        verseNumber: 21,
        arabicText: 'وَمِنْ آيَاتِهِ أَنْ خَلَقَ لَكُم مِّنْ أَنفُسِكُمْ أَزْوَاجًا لِّتَسْكُنُوا إِلَيْهَا وَجَعَلَ بَيْنَكُم مَّوَدَّةً وَرَحْمَةً',
        turkishMeaning: 'Kendileri ile huzur bulasınız diye sizin için kendi türünüzden eşler yaratması ve aranızda bir sevgi ve merhamet kılması da O\'nun delillerindendir.',
        englishMeaning: 'And of His signs is that He created for you from yourselves mates that you may find tranquility in them; and He placed between you affection and mercy.',
        insight: 'Evlilik ve aile kurumunun temeli karşılıklı sevgi (meveddet) ve kusurları örten merhamettir.',
      ),
      ThematicVerseEntry(
        surahId: 25,
        surahNameTr: 'Furkân',
        surahNameAr: 'الفرقان',
        verseNumber: 74,
        arabicText: 'رَبَّنَا هَبْ لَنَا مِنْ أَزْوَاجِنَا وَذُرِّيَّاتِنَا قُرَّةَ أَعْيُنٍ وَاجْعَلْنَا لِلْمُتَّقِينَ إِمَامًا',
        turkishMeaning: '"Ey Rabbimiz! Bize eşlerimizden ve çocuklarımızdan göz aydınlığı olacak kimseler bağışla ve bizi takva sahiplerine önder kıl."',
        englishMeaning: 'Our Lord, grant us from among our wives and offspring comfort to our eyes and make us a leader for the righteous.',
        insight: 'Göz aydınlığı bir nesil, takva üzere kurulmuş bir aileden neşet eder.',
      ),
    ],
  ),

  // 7. Adalet, İhsan ve Doğruluk
  const QuranThematicTopic(
    id: 'adalet_ve_ihsan',
    titleTr: 'Adalet, İhsan ve Doğruluk',
    titleEn: 'Justice, Excellence & Honesty',
    subtitleTr: 'Kişi aleyhine dahi olsa hakkı ayakta tutmak, iyilikle kötülüğü savmak',
    icon: Icons.balance_rounded,
    primaryColorHex: 0xFF6366F1,
    category: 'ahlak_aile',
    contemplationNote: 'İslam ahlakı adaleti mülkün temeli, ihsanı (Allah\'ı görür gibi yaşamayı ve iyilik yapmayı) ise insanın kemali sayar.',
    searchKeywords: ['adalet', 'ihsan', 'dogruluk', 'durustluk', 'hak', 'hukuk', 'justice', 'honesty'],
    verses: [
      ThematicVerseEntry(
        surahId: 16,
        surahNameTr: 'Nahl',
        surahNameAr: 'النحل',
        verseNumber: 90,
        arabicText: 'إِنَّ اللَّهَ يَأْمُرُ بِالْعَدْلِ وَالْإِحْسَانِ وَإِيتَاءِ ذِي الْقُرْبَىٰ وَيَنْهَىٰ عَنِ الْفَحْشَاءِ وَالْمُنكَرِ وَالْبَغْيِ ۚ يَعِظُكُمْ لَعَلَّكُمْ تَذَكَّرُونَ',
        turkishMeaning: 'Şüphesiz Allah adaleti, iyilik yapmayı (ihsanı) ve yakınlara vermeyi emreder; hayasızlıktan, fenalıktan ve azgınlıktan yasaklar. İyice düşünesiniz diye size öğüt verir.',
        englishMeaning: 'Indeed, Allah orders justice and good conduct and giving to relatives and forbids immorality and bad conduct and oppression. He admonishes you that perhaps you will be reminded.',
        insight: 'Cuma hutbelerinde okunan bu âyet-i kerime, tüm sosyal ve ahlaki nizâmın özeti ve temel taşıdır.',
      ),
      ThematicVerseEntry(
        surahId: 5,
        surahNameTr: 'Mâide',
        surahNameAr: 'المائدة',
        verseNumber: 8,
        arabicText: 'يَا أَيُّهَا الَّذِينَ آمَنُوا كُونُوا قَوَّامِينَ لِلَّهِ شُهَدَاءَ بِالْقِسْطِ ۖ وَلَا يَجْرِمَنَّكُمْ شَنَآنُ قَوْمٍ عَلَىٰ أَلَّا تَعْدِلُوا ۚ اعْدِلُوا هُوَ أَقْرَبُ لِلتَّقْوَىٰ',
        turkishMeaning: 'Ey iman edenler! Allah için hakkı ayakta tutan, adaletle şahitlik eden kimseler olun. Bir topluluğa olan öfkeniz sizi adaletsizliğe sürüklemesin. Âdil olun; bu, takvaya daha uygundur.',
        englishMeaning: 'O you who have believed, be persistently standing firm for Allah, witnesses in justice, and do not let the hatred of a people prevent you from being just. Be just; that is nearer to righteousness.',
        insight: 'Düşmana karşı bile adaletten zerre kadar ayrılmamak Kur\'an\'ın insanlığa sunduğu en yüce adalet ölçüsüdür.',
      ),
      ThematicVerseEntry(
        surahId: 41,
        surahNameTr: 'Fussilet',
        surahNameAr: 'فصلت',
        verseNumber: 34,
        arabicText: 'وَلَا تَسْتَوِي الْحَسَنَةُ وَلَا السَّيِّئَةُ ۚ ادْفَعْ بِالَّتِي هِيَ أَحْسَنُ فَإِذَا الَّذِي بَيْنَكَ وَبَيْنَهُ عَدَاوَةٌ كَأَنَّهُ وَلِيٌّ حَمِيمٌ',
        turkishMeaning: 'İyilikle kötülük bir olmaz. Sen (kötülüğü) en güzel olanla sav; o zaman göreceksin ki, seninle arasında düşmanlık bulunan kimse sımsıcak bir dost oluvermiştir.',
        englishMeaning: 'And not equal are the good deed and the bad. Repel [evil] by that [deed] which is better; and thereupon the one whom between you and him is enmity [will become] as though he was a devoted friend.',
        insight: 'Kötülüğe iyilikle mukabele etmek kalpleri fetheden en tesirli peygamberi ahlaktır.',
      ),
    ],
  ),

  // 8. Cennet Müjdeleri ve Ahiret
  const QuranThematicTopic(
    id: 'cennet_ve_ahiret',
    titleTr: 'Cennet Müjdeleri ve Ahiret Yurdu',
    titleEn: 'Paradise & Eternity',
    subtitleTr: 'Gözlerin görmediği, kulakların işitmediği ebedi nimetler ve esenlik diyarı',
    icon: Icons.park_rounded,
    primaryColorHex: 0xFF14B8A6,
    category: 'ibadet_ahiret',
    contemplationNote: 'Dünya fani, ahiret ise bakidir. Salih ameller işleyen, sabreden ve kalbini kötülüklerden arındıranlara cennet müjdelenmiştir.',
    searchKeywords: ['cennet', 'ahiret', 'ebedi', 'mujde', 'firdevs', 'nimet', 'paradise', 'hereafter'],
    verses: [
      ThematicVerseEntry(
        surahId: 18,
        surahNameTr: 'Kehf',
        surahNameAr: 'الكهف',
        verseNumber: 107,
        arabicText: 'إِنَّ الَّذِينَ آمَنُوا وَعَمِلُوا الصَّالِحَاتِ كَانَتْ لَهُمْ جَنَّاتُ الْفِرْدَوْسِ نُزُلًا • خَالِدِينَ فِيهَا لَا يَبْغُونَ عَنْهَا حِوَلًا',
        turkishMeaning: 'İman edip salih ameller işleyenlere gelince, onlar için konak olarak Firdevs cennetleri vardır. Orada ebedi kalacaklar, oradan ayrılmak istemeyeceklerdir.',
        englishMeaning: 'Indeed, those who have believed and done righteous deeds - they will have the Gardens of Paradise as a lodging, wherein they abide eternally. They will not desire from it any transfer.',
        insight: 'Cennet bıkkınlık değil, her an yenilenen ilahi lezzet ve daimî saadet yurdudur.',
      ),
      ThematicVerseEntry(
        surahId: 89,
        surahNameTr: 'Fecr',
        surahNameAr: 'الفجر',
        verseNumber: 27,
        arabicText: 'يَا أَيَّتُهَا النَّفْسُ الْمُطْمَئِنَّةُ • ارْجِعِي إِلَىٰ رَبِّكِ رَاضِيَةً مَّرْضِيَّةً • فَادْخُلِي فِي عِبَادِي • وَادْخُلِي جَنَّتِي',
        turkishMeaning: 'Ey huzura kavuşmuş nefis! Sen O\'ndan razı, O da senden razı olarak Rabbine dön! Gir kullarımın arasına ve gir cennetime!',
        englishMeaning: 'O reassured soul, return to your Lord, well-pleased and pleasing [to Him], and enter among My [righteous] servants, and enter My Paradise.',
        insight: 'En büyük cennet nimeti, kulun Rabbinden razı olması ve Yüce Allah\'ın da o kuldan hoşnut olmasıdır.',
      ),
    ],
  ),

  // 9. Dua, Yakarma ve Münacat
  const QuranThematicTopic(
    id: 'dua_ve_munacat',
    titleTr: 'Dua, Yakarma ve Münacat',
    titleEn: 'Supplication & Closeness to Allah',
    subtitleTr: 'Kulun Yaratıcısına en yakın olduğu an, peygamberlerin kabul olmuş duaları',
    icon: Icons.volunteer_activism_rounded,
    primaryColorHex: 0xFFF43F5E,
    category: 'ibadet_ahiret',
    contemplationNote: 'Dua müminin miracı ve manevi kalkanıdır. Allah kulunun duasına icabet etmeyi vadetmiştir.',
    searchKeywords: ['dua', 'munacat', 'yakarma', 'istek', 'niyaz', 'dua et', 'supplication', 'prayer'],
    verses: [
      ThematicVerseEntry(
        surahId: 2,
        surahNameTr: 'Bakara',
        surahNameAr: 'البقرة',
        verseNumber: 186,
        arabicText: 'وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ ۖ أُجِيبُ دَعْوَةَ الدَّاعِ إِذَا دَعَانِ ۖ فَلْيَسْتَجِيبُوا لِي وَلْيُؤْمِنُوا بِي لَعَلَّهُمْ يَرْشُدُونَ',
        turkishMeaning: 'Kullarım sana Beni sorduklarında bilsinler ki Ben onlara çok yakınım. Bana dua ettiği zaman dua edenin dileğine karşılık veririm.',
        englishMeaning: 'And when My servants ask you concerning Me - indeed I am near. I respond to the invocation of the supplicant when he calls upon Me.',
        insight: 'Allah ile kul arasında aracı yoktur; içten samimi bir fısıltı Arş-ı Âlâ\'da yankılanır.',
      ),
      ThematicVerseEntry(
        surahId: 40,
        surahNameTr: 'Mü\'min',
        surahNameAr: 'غافر',
        verseNumber: 60,
        arabicText: 'وَقَالَ رَبُّكُمُ ادْعُونِي أَسْتَجِبْ لَكُمْ',
        turkishMeaning: 'Rabbiniz buyurdu ki: "Bana dua edin, size cevap vereyim."',
        englishMeaning: 'And your Lord says, \'Call upon Me; I will respond to you.\'',
        insight: 'Dua etmek ibadetin özüdür; istemeyi veren, vereceği için istemeyi lütfetmiştir.',
      ),
      ThematicVerseEntry(
        surahId: 20,
        surahNameTr: 'Tâhâ',
        surahNameAr: 'طه',
        verseNumber: 25,
        arabicText: 'قَالَ رَبِّ اشْرَحْ لِي صَدْرِي • وَيَسِّرْ لِي أَمْرِي • وَاحْلُلْ عُقْدَةً مِّن لِّسَانِي • يَفْقَهُوا قَوْلِي',
        turkishMeaning: '(Musa) dedi ki: "Rabbim! Gönlüme ferahlık ver, işimi bana kolaylaştır, dilimdeki bağı çöz ki sözümü anlasınlar."',
        englishMeaning: '[Moses] said, \'My Lord, expand for me my breast [with assurance] and ease for me my task and untie the knot from my tongue that they may understand my speech.\'',
        insight: 'Zor bir vazifeye veya konuşmaya başlarken okunacak en tesirli peygamber duası.',
      ),
    ],
  ),

  // 10. İlim, Tefekkür ve Kâinat Delilleri
  const QuranThematicTopic(
    id: 'ilim_ve_tefekkur',
    titleTr: 'İlim, Tefekkür ve Kâinat Delilleri',
    titleEn: 'Knowledge, Reason & Universe',
    subtitleTr: 'Göklerin ve yerin nizamı, aklı kullanmanın fazileti ve ilim talipleri',
    icon: Icons.lightbulb_rounded,
    primaryColorHex: 0xFFEAB308,
    category: 'ilim_tefekkur',
    contemplationNote: 'Kur\'an insanı araştırmaya, tefekküre ve evrendeki harika düzeni keşfetmeye davet eder. İlim insanı marifetullaha ulaştırır.',
    searchKeywords: ['ilim', 'tefekkur', 'kainat', 'akil', 'dusunce', 'bilgi', 'knowledge', 'reason'],
    verses: [
      ThematicVerseEntry(
        surahId: 3,
        surahNameTr: 'Âl-i İmrân',
        surahNameAr: 'آل عمران',
        verseNumber: 190,
        arabicText: 'إِنَّ فِي خَلْقِ السَّمَاوَاتِ وَالْأَرْضِ وَاخْتِلَافِ اللَّيْلِ وَالنَّهَارِ لَآيَاتٍ لِّأُولِي الْأَلْبَابِ',
        turkishMeaning: 'Göklerin ve yerin yaratılışında, gece ile gündüzün birbiri ardınca gelişinde aklıselim sahipleri için gerçekten açık deliller vardır.',
        englishMeaning: 'Indeed, in the creation of the heavens and the earth and the alternation of the night and the day are signs for those of understanding.',
        insight: 'Gözlem ve tefekkür ibadetin bir parçasıdır; kâinat Allah\'ın okunmayı bekleyen açık kitabıdır.',
      ),
      ThematicVerseEntry(
        surahId: 39,
        surahNameTr: 'Zümer',
        surahNameAr: 'الزمر',
        verseNumber: 9,
        arabicText: 'قُلْ هَلْ يَسْتَوِي الَّذِينَ يَعْلَمُونَ وَالَّذِينَ لَا يَعْلَمُونَ ۗ إِنَّمَا يَتَذَكَّرُ أُولُو الْأَلْبَابِ',
        turkishMeaning: 'De ki: "Hiç bilenlerle bilmeyenler bir olur mu?" Ancak akıl sahipleri öğüt alır.',
        englishMeaning: 'Say, \'Are those who know equal to those who do not know?\' Only they will remember who are people of understanding.',
        insight: 'İlim insanı cehaletin karanlığından çıkarır, bilginin nihai hedefi ise hakikate ulaşmaktır.',
      ),
      ThematicVerseEntry(
        surahId: 20,
        surahNameTr: 'Tâhâ',
        surahNameAr: 'طه',
        verseNumber: 114,
        arabicText: 'وَقُل رَّبِّ زِدْنِي عِلْمًا',
        turkishMeaning: 'Ve de ki: "Rabbim, benim ilmimi artır!"',
        englishMeaning: 'And say, \'My Lord, increase me in knowledge.\'',
        insight: 'İlimde doymak yoktur; peygamberlerin bile artmasını istediği tek nimet ilimdir.',
      ),
    ],
  ),

  // 11. Namaz, Zikir ve Huşu
  const QuranThematicTopic(
    id: 'namaz_ve_zikir',
    titleTr: 'Namaz, Zikir ve Huşu',
    titleEn: 'Prayer & Spiritual Mindfulness',
    subtitleTr: 'Dinin direği, kötülüklerden alıkoyan kalkan ve Allah ile buluşma vakti',
    icon: Icons.mosque_rounded,
    primaryColorHex: 0xFF059669,
    category: 'ibadet_ahiret',
    contemplationNote: 'Namaz, günün koşuşturmacası içinde ruhun arındığı ve Hakk\'ın huzurunda durduğu en mukaddes andır.',
    searchKeywords: ['namaz', 'zikir', 'husu', 'secde', 'ruku', 'ibadet', 'prayer', 'salah'],
    verses: [
      ThematicVerseEntry(
        surahId: 29,
        surahNameTr: 'Ankebût',
        surahNameAr: 'العنكبوت',
        verseNumber: 45,
        arabicText: 'اتْلُ مَا أُوحِيَ إِلَيْكَ مِنَ الْكِتَابِ وَأَقِمِ الصَّلَاةَ ۖ إِنَّ الصَّلَاةَ تَنْهَىٰ عَنِ الْفَحْشَاءِ وَالْمُنكَرِ ۗ وَلَذِكْرُ اللَّهِ أَكْبَرُ',
        turkishMeaning: 'Sana vahyedilen Kitabı oku ve namazı kıl. Şüphesiz namaz, hayasızlıktan ve kötülükten alıkoyar. Allah\'ı anmak (zikretmek) elbette en büyüktür.',
        englishMeaning: 'Recite what has been revealed to you of the Book and establish prayer. Indeed, prayer prohibits immorality and wrongdoing, and the remembrance of Allah is greater.',
        insight: 'Hakkıyla kılınan bir namaz, sahibini günün geri kalanında kötülüklere karşı korur.',
      ),
      ThematicVerseEntry(
        surahId: 23,
        surahNameTr: 'Mü\'minûn',
        surahNameAr: 'المؤمنون',
        verseNumber: 1,
        arabicText: 'قَدْ أَفْلَحَ الْمُؤْمِنُونَ • الَّذِينَ هُمْ فِي صَلَاتِهِمْ خَاشِعُونَ',
        turkishMeaning: 'Müminler kesinlikle kurtuluşa ermiştir; onlar ki namazlarında derin bir saygı ve huşu içindedirler.',
        englishMeaning: 'Certainly will the believers have succeeded: They who are during their prayer humbly submissive.',
        insight: 'Huşu, bedenin sükunetiyle birlikte kalbin de Yüce Allah\'ın huzurunda titremesidir.',
      ),
    ],
  ),

  // 12. Gıybet, Zan ve Dilin Muhafazası
  const QuranThematicTopic(
    id: 'giybet_ve_dilin_muhafazasi',
    titleTr: 'Gıybet, Zan ve Dilin Muhafazası',
    titleEn: 'Social Ethics & Pure Tongue',
    subtitleTr: 'Kardeşlik hukukunu korumak, kötü zandan ve kalp kırıcı sözlerden sakınmak',
    icon: Icons.record_voice_over_rounded,
    primaryColorHex: 0xFF7C3AED,
    category: 'ahlak_aile',
    contemplationNote: 'Dil küçüktür fakat cürmü büyüktür. Kur\'an müminlerin birbirlerinin onur ve haysiyetini korumasını emreder.',
    searchKeywords: ['giybet', 'zan', 'dil', 'iftira', 'yalan', 'dedikodu', 'ethics', 'tongue'],
    verses: [
      ThematicVerseEntry(
        surahId: 49,
        surahNameTr: 'Hucurât',
        surahNameAr: 'الحجرات',
        verseNumber: 12,
        arabicText: 'يَا أَيُّهَا الَّذِينَ آمَنُوا اجْتَنِبُوا كَثِيرًا مِّنَ الظَّنِّ إِنَّ بَعْضَ الظَّنِّ إِثْمٌ ۖ وَلَا تَجَسَّسُوا وَلَا يَغْتَب بَّعْضُكُم بَعْضًا',
        turkishMeaning: 'Ey iman edenler! Zannın çoğundan sakının; çünkü zannın bir kısmı günahtır. Birbirinizin kusurlarını araştırmayın; biriniz diğerini arkasından çekiştirmesin (gıybet etmesin).',
        englishMeaning: 'O you who have believed, avoid much [negative] assumption. Indeed, some assumption is sin. And do not spy or backbite each other.',
        insight: 'Sosyal barışın temeli: Kötü zandan kaçınmak, kusur avcılığı yapmamak ve kardeşinin arkasında konuşmamak.',
      ),
      ThematicVerseEntry(
        surahId: 17,
        surahNameTr: 'İsrâ',
        surahNameAr: 'الإسراء',
        verseNumber: 53,
        arabicText: 'وَقُل لِّعِبَادِي يَقُولُوا الَّتِي هِيَ أَحْسَنُ ۚ إِنَّ الشَّيْطَانَ يَنزَغُ بَيْنَهُمْ',
        turkishMeaning: 'Kullarıma söyle: Sözün en güzelini söylesinler! Çünkü şeytan aralarını bozmak ister.',
        englishMeaning: 'And tell My servants to say that which is best. Indeed, Satan induces [dissension] among them.',
        insight: 'Güzel söz sadakadır; incitici kelimeler ise fitne tohumları eker.',
      ),
    ],
  ),
];

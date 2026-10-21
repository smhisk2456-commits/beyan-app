import 'package:flutter/foundation.dart';

@immutable
class QuizQuestion {
  final String questionText;
  final String? audioTarget;
  final String arabicPrompt;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;
  final bool autoPlayAudio;

  const QuizQuestion({
    required this.questionText,
    this.audioTarget,
    required this.arabicPrompt,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
    this.autoPlayAudio = false,
  });
}

@immutable
class ElifBaLesson {
  final String id;
  final int levelNumber;
  final String title;
  final String subtitle;
  final String iconName;
  final bool isPremiumOnly;
  final int xpReward;
  final List<QuizQuestion> questions;

  const ElifBaLesson({
    required this.id,
    required this.levelNumber,
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.isPremiumOnly,
    required this.xpReward,
    required this.questions,
  });
}

final List<ElifBaLesson> elifBaLessonsList = [
  // ── SEVİYE 1: Temel Harfleri Tanıma (ÜCRETSİZ) ──────────────
  const ElifBaLesson(
    id: 'lesson_1_letters_basic',
    levelNumber: 1,
    title: '1. Adım: Harfleri Tanıyalım',
    subtitle: 'Elif, Be, Te, Se, Cim ve temel 28 harfin mahreci',
    iconName: 'menu_book',
    isPremiumOnly: false,
    xpReward: 60,
    questions: [
      QuizQuestion(
        questionText: 'Ekranda görünen, altında tek noktası bulunan bu harfin adı nedir?',
        arabicPrompt: 'ب',
        audioTarget: '2',
        options: ['Elif (ا)', 'Be (ب)', 'Te (ت)', 'Cim (ج)'],
        correctOptionIndex: 1,
        explanation: '"Be" (ب) harfi altında tek bir nokta bulunan tekneli harftir ve "B" sesiyle okunur.',
      ),
      QuizQuestion(
        questionText: 'Üzerinde yan yana iki nokta bulunan bu harfin adı hangisidir?',
        arabicPrompt: 'ت',
        audioTarget: '3',
        options: ['Be (ب)', 'Te (ت)', 'Se (ث)', 'Nun (ن)'],
        correctOptionIndex: 1,
        explanation: '"Te" (ت) harfinin üzerinde iki nokta vardır ve ince bir "T" sesiyle okunur.',
      ),
      QuizQuestion(
        questionText: 'Kur\'an-ı Kerim alfabesinin ilk harfi olan bu dik harf hangisidir?',
        arabicPrompt: 'ا',
        audioTarget: '1',
        options: ['Elif (ا)', 'Lam (ل)', 'Dal (د)', 'Vav (و)'],
        correctOptionIndex: 0,
        explanation: '"Elif" (ا) alfabenin ilk harfidir; dik durur ve harekelerle ses kazanır.',
      ),
      QuizQuestion(
        questionText: 'Üzerinde üç nokta bulunan ve dil ucu ön dişlerden hafifçe çıkarılarak okunan peltek harf hangisidir?',
        arabicPrompt: 'ث',
        audioTarget: '4',
        options: ['Te (ت)', 'Şın (ش)', 'Se (ث)', 'Cim (ج)'],
        correctOptionIndex: 2,
        explanation: '"Se" (ث) harfinin üstünde 3 nokta bulunur; dil ucu ön dişlerden hafifçe çıkarılarak yumuşakça telaffuz edilir.',
      ),
      QuizQuestion(
        questionText: 'Karnının ortasında tek bir nokta bulunan bu harfin adı nedir?',
        arabicPrompt: 'ج',
        audioTarget: '5',
        options: ['Ha (ح)', 'Hı (خ)', 'Cim (ج)', 'Ayn (ع)'],
        correctOptionIndex: 2,
        explanation: '"Cim" (ج) harfinin karnında bir nokta vardır ve Türkçe\'deki "C" sesi gibi çıkar.',
      ),
      QuizQuestion(
        questionText: 'Hiç noktası olmayan ve boğazın ortasından nefes akıtılarak temiz çıkarılan harf hangisidir?',
        arabicPrompt: 'ح',
        audioTarget: '6',
        options: ['Ha (ح)', 'Cim (ج)', 'Hı (خ)', 'He (ه)'],
        correctOptionIndex: 0,
        explanation: '"Ha" (ح) noktasızdır; hırıltı olmadan boğazın ortasından tatlı bir nefes akımıyla çıkar.',
      ),
      QuizQuestion(
        questionText: 'Tepesinde tek bir nokta olan ve boğazın üst kısmından hırıltılı çıkan kalın harf hangisidir?',
        arabicPrompt: 'خ',
        audioTarget: '7',
        options: ['Ha (ح)', 'Hı (خ)', 'Cim (ج)', 'Gayn (غ)'],
        correctOptionIndex: 1,
        explanation: '"Hı" (خ) harfinin tepesinde tek nokta vardır; hırıltılı ve kalın bir sestir.',
      ),
      QuizQuestion(
        questionText: 'Noktasız, hafif bükük duran ve ince okunan bu harf hangisidir?',
        arabicPrompt: 'د',
        audioTarget: '8',
        options: ['Dal (د)', 'Zel (ذ)', 'Ra (ر)', 'Vav (و)'],
        correctOptionIndex: 0,
        explanation: '"Dal" (د) ince ve tok bir "D" sesidir; kendisinden sonraki harfe birleşmez.',
      ),
      QuizQuestion(
        questionText: 'Dal harfine benzeyen ancak üstünde tek nokta olan peltek harf hangisidir?',
        arabicPrompt: 'ذ',
        audioTarget: '9',
        options: ['Dal (د)', 'Zel (ذ)', 'Ze (ز)', 'Zı (ظ)'],
        correctOptionIndex: 1,
        explanation: '"Zel" (ذ) harfinin üzerinde bir nokta bulunur ve dil ucu dişlerin arasından peltek çıkarılır.',
      ),
      QuizQuestion(
        questionText: 'Aşağıya doğru kavisli kuyruğu olan ve noktasız olan bu harf hangisidir?',
        arabicPrompt: 'ر',
        audioTarget: '10',
        options: ['Ra (ر)', 'Ze (ز)', 'Dal (د)', 'Vav (و)'],
        correctOptionIndex: 0,
        explanation: '"Ra" (ر) harfi noktasızdır; dil ucunun titreşimiyle çıkar ve üstün/ötre ile kalın, esre ile ince okunur.',
      ),
      QuizQuestion(
        questionText: 'Üç dişli, noktasız ve keskin ıslık sesi veren bu harfin adı nedir?',
        arabicPrompt: 'س',
        audioTarget: '12',
        options: ['Sin (س)', 'Şın (ش)', 'Sad (ص)', 'Dad (ض)'],
        correctOptionIndex: 0,
        explanation: '"Sin" (س) üç dişlidir, noktasızdır ve ince bir "S" sesi verir.',
      ),
      QuizQuestion(
        questionText: 'Üç dişinin üzerinde üç nokta bulunan harf hangisidir?',
        arabicPrompt: 'ش',
        audioTarget: '13',
        options: ['Sin (س)', 'Şın (ش)', 'Se (ث)', 'Sad (ص)'],
        correctOptionIndex: 1,
        explanation: '"Şın" (ش) harfinin üzerinde 3 nokta vardır ve ağız dolusu nefes yayılarak "Ş" sesi verir.',
      ),
      QuizQuestion(
        questionText: 'Kur\'an alfabesinde kendisinden sonraki harfe BİRLEŞMEYEN 6 harften biri hangisidir?',
        arabicPrompt: 'و',
        audioTarget: '26',
        options: ['Be (ب)', 'Vav (و)', 'Sin (س)', 'Mim (م)'],
        correctOptionIndex: 1,
        explanation: 'Elif (ا), Dal (د), Zel (ذ), Ra (ر), Ze (ز) ve Vav (و) harfleri kendilerinden sonra gelen harfe bitişmezler.',
      ),
    ],
  ),

  // ── SEVİYE 2: Harekeler (Üstün, Esre, Ötre) (ÜCRETSİZ) ────────
  const ElifBaLesson(
    id: 'lesson_2_harekeler',
    levelNumber: 2,
    title: '2. Adım: Harekeler',
    subtitle: 'Üstün (e/a), Esre (i/ı), Ötre (u/ü) ve kelime okunuşları',
    iconName: 'music_note',
    isPremiumOnly: false,
    xpReward: 80,
    questions: [
      QuizQuestion(
        questionText: 'Harfin üzerindeki eğik çizgiye "Üstün" (Fetha) denir. "بَ" nasıl okunur?',
        arabicPrompt: 'بَ',
        audioTarget: '2',
        options: ['Be', 'Bi', 'Bü', 'Eb'],
        correctOptionIndex: 0,
        explanation: 'Üstün (Fetha) harfin üstüne konur; ince harfleri "e", kalın harfleri "a" sesiyle okutur. "بَ" = "Be".',
      ),
      QuizQuestion(
        questionText: 'Harfin altındaki eğik çizgiye "Esre" (Kesra) denir. "دِ" nasıl okunur?',
        arabicPrompt: 'دِ',
        audioTarget: '8',
        options: ['De', 'Di', 'Dü', 'Ed'],
        correctOptionIndex: 1,
        explanation: 'Esre harfin altına konur ve harfe "i" (kalın harflerde "ı/i") sesi verir: "دِ" = "Di".',
      ),
      QuizQuestion(
        questionText: 'Harfin üzerindeki küçük vav benzeri işarete "Ötre" (Damma) denir. "رُ" nasıl okunur?',
        arabicPrompt: 'رُ',
        audioTarget: '10',
        options: ['Re', 'Rı', 'Ru', 'Er'],
        correctOptionIndex: 2,
        explanation: 'Ötre harfin üstüne konur ve harfe "u / ü" sesi verir. Ra kalın harf olduğu için "Ru" şeklinde okunur.',
      ),
      QuizQuestion(
        questionText: 'Kalın harflerden olan "Sad" (ص) harfi üstün aldığında nasıl seslendirilir?',
        arabicPrompt: 'صَ',
        audioTarget: '14',
        options: ['Se', 'Sa', 'Sı', 'Su'],
        correctOptionIndex: 1,
        explanation: 'Sad (ص) kalın bir harftir. Üstün ile "e" değil, tok ve dolgun bir "Sa" sesiyle telaffuz edilir.',
      ),
      QuizQuestion(
        questionText: 'Kalın harflerden olan "Tı" (ط) harfi esre aldığında nasıl okunur?',
        arabicPrompt: 'طِ',
        audioTarget: '16',
        options: ['Ti', 'Tı', 'Te', 'Tu'],
        correctOptionIndex: 1,
        explanation: 'Tı (ط) harfi en kuvvetli kalın harftir; esre ile ince "Ti" değil, kalın "Tı" sesiyle okunur.',
      ),
      QuizQuestion(
        questionText: 'Üzerinde ötre bulunan ince "Sin" (س) harfinin doğru okunuşu hangisidir?',
        arabicPrompt: 'سُ',
        audioTarget: '12',
        options: ['Se', 'Si', 'Sü', 'Es'],
        correctOptionIndex: 2,
        explanation: 'Sin ince bir harftir; ötre aldığında "Sü" sesiyle okunur.',
      ),
      QuizQuestion(
        questionText: 'Üç harfi de üstünlü olan bu Kur\'an kelimesi nasıl okunur?',
        arabicPrompt: 'كَتَبَ',
        audioTarget: 'كَتَبَ',
        options: ['Kütibe', 'Ketebe', 'Kitâb', 'Ketebü'],
        correctOptionIndex: 1,
        explanation: 'ك (Ke) + ت (Te) + ب (Be) harfleri üstünlerle birleştiğinde akıcı olarak "Ketebe" (Yazdı) şeklinde okunur.',
      ),
      QuizQuestion(
        questionText: 'Birinci harfi üstün, ikincisi esre, üçüncüsü üstün olan bu kelime nasıl okunur?',
        arabicPrompt: 'سَمِعَ',
        audioTarget: 'سَمِعَ',
        options: ['Semia', 'Semee', 'Sümia', 'Samia'],
        correctOptionIndex: 0,
        explanation: 'س (Se) + م (Mi) + ع (\'A) birleştiğinde "Semia" (İşitti) şeklinde telaffuz edilir.',
      ),
      QuizQuestion(
        questionText: 'Birinci harfi ötre, ikincisi esre, üçüncüsü üstün olan bu kelime nasıl okunur?',
        arabicPrompt: 'رُزِقَ',
        audioTarget: 'رُزِقَ',
        options: ['Rezeka', 'Ruzika', 'Rüzika', 'Rızk'],
        correctOptionIndex: 1,
        explanation: 'ر (Ru) + ز (Zi) + ق (Ka) -> "Ruzika" (Rızıklandırıldı) şeklinde okunur.',
      ),
      QuizQuestion(
        questionText: 'Her üç harfi de üstünlü olan bu fiil nasıl okunur?',
        arabicPrompt: 'دَرَسَ',
        audioTarget: 'دَرَسَ',
        options: ['Ders', 'Derese', 'Dürise', 'Derisü'],
        correctOptionIndex: 1,
        explanation: 'د (De) + ر (Ra) + س (Se) -> "Derese" (Ders çalıştı) şeklinde okunur.',
      ),
      QuizQuestion(
        questionText: 'İnce harfler üstün (Fetha) aldığında hangi sesle okunur?',
        arabicPrompt: 'فَ',
        audioTarget: '20',
        options: ['"a" sesiyle', '"e" sesiyle', '"ı" sesiyle', '"o" sesiyle'],
        correctOptionIndex: 1,
        explanation: 'Üstün (Fetha) ince harfleri "e" sesiyle (Fe, Be, Te, Se), kalın harfleri "a" sesiyle okutur.',
      ),
      QuizQuestion(
        questionText: 'Aşağıdaki seçeneklerden hangisinde "Nu - Ni - Ne" sırası doğru verilmiştir?',
        arabicPrompt: 'نُ نِ نَ',
        audioTarget: '25',
        options: [
          'Ötre - Esre - Üstün',
          'Üstün - Esre - Ötre',
          'Esre - Ötre - Üstün',
          'Cezm - Şedde - Tenvin'
        ],
        correctOptionIndex: 0,
        explanation: 'نُ (Ötre - Nu/Nü), نِ (Esre - Ni), نَ (Üstün - Ne) sırasıyla yer alır.',
      ),
      QuizQuestion(
        questionText: '"Hamide" (Övdü) kelimesinin Arapça yazılışı nasıldır?',
        arabicPrompt: 'حَمِدَ',
        audioTarget: 'حَمِدَ',
        options: ['حَمِدَ', 'حَمَدَ', 'حُمِدَ', 'حَمْد'],
        correctOptionIndex: 0,
        explanation: 'Ha üstün (Ha), Mim esre (Mi), Dal üstün (De): "Hamide".',
      ),
    ],
  ),

  // ── SEVİYE 3: Cezm, Şedde ve Tenvin ─────────────────
  const ElifBaLesson(
    id: 'lesson_3_cezm_sedde',
    levelNumber: 3,
    title: '3. Adım: Cezm & Şedde',
    subtitle: 'Harfleri tutturma, çift okuma, tenvin ve uzatma kuralları',
    iconName: 'auto_stories_rounded',
    isPremiumOnly: false,
    xpReward: 120,
    questions: [
      QuizQuestion(
        questionText: 'Harfin üzerindeki küçük yuvarlak daireye "Cezm" (Sükun) denir. "قُلْ" kelimesi nasıl okunur?',
        arabicPrompt: 'قُلْ',
        audioTarget: 'قُلْ',
        options: ['Kule', 'Kuli', 'Kul', 'Kulu'],
        correctOptionIndex: 2,
        explanation: 'Cezm (Sükun) harfi durdurur ve önceki harfe bağlar: Kaf ötreli "Ku", Lam cezimli "l" = "Kul" (De ki).',
      ),
      QuizQuestion(
        questionText: 'Harfin üzerindeki "W" benzeri Şedde işareti harfe ne yaptırır?',
        arabicPrompt: 'رَبِّ',
        audioTarget: 'رَبِّ',
        options: [
          'Harfi tek seferde hızlı okutur',
          'Harfi iki defa (kuvvetlice) okutur',
          'Harfi uzatır',
          'Harfi atlayıp okutmaz'
        ],
        correctOptionIndex: 1,
        explanation: 'Şedde harfi iki kere okutur: Birincisi cezimli, ikincisi harekeli olur: "رَبِّ" = "Rab-bi".',
      ),
      QuizQuestion(
        questionText: 'Nun harfindeki şedde ile bu kelime nasıl okunur?',
        arabicPrompt: 'إِنَّ',
        audioTarget: 'إِنَّ',
        options: ['İne', 'İn-ne', 'İn', 'Enne'],
        correctOptionIndex: 1,
        explanation: 'Elif esreli "İ", ardından şeddeli Nun tutularak okunur: "İn-ne" (Şüphesiz).',
      ),
      QuizQuestion(
        questionText: 'Mim harfindeki cezm ile bu kelime nasıl okunur?',
        arabicPrompt: 'لَمْ',
        audioTarget: 'لَمْ',
        options: ['Leme', 'Lemi', 'Lem', 'Lümü'],
        correctOptionIndex: 2,
        explanation: 'Lam üstünlü "Le", Mim cezimli "m" ile birleşerek "Lem" şeklinde durulur.',
      ),
      QuizQuestion(
        questionText: 'Kelime sonundaki çift üstün (Tenvin ً) kelimeye hangi sesi katar?',
        arabicPrompt: 'كِتَابًا',
        audioTarget: 'كِتَابًا',
        options: ['-en / -an sesi', '-im sesi', '-et sesi', '-er sesi'],
        correctOptionIndex: 0,
        explanation: 'Çift üstün tenvin kelimenin sonuna gizli bir nun sesi katar: "Kitâben".',
      ),
      QuizQuestion(
        questionText: 'İhlas Suresinin sonundaki "أَحَدٌ" kelimesi çift ötre ile nasıl okunur?',
        arabicPrompt: 'أَحَدٌ',
        audioTarget: 'أَحَدٌ',
        options: ['Ehadü', 'Ehaden', 'Ehadün', 'Ehadi'],
        correctOptionIndex: 2,
        explanation: 'Çift ötre tenvin kelimenin sonuna "-ün" sesi katar: "E-ha-dün".',
      ),
      QuizQuestion(
        questionText: 'Çift esre tenvin (ٍ) kelimenin sonuna hangi sesi verir?',
        arabicPrompt: 'خَيْرٍ',
        audioTarget: 'خَيْرٍ',
        options: ['-in / -ın sesi', '-en sesi', '-un sesi', '-i sesi'],
        correctOptionIndex: 0,
        explanation: 'Çift esre tenvin kelimenin sonuna "-in" veya "-ın" sesi katar: "Hayrin".',
      ),
      QuizQuestion(
        questionText: '"Sen" anlamına gelen ve nun harfi cezimli olan bu kelime nasıl okunur?',
        arabicPrompt: 'أَنْتَ',
        audioTarget: 'أَنْتَ',
        options: ['Ente', 'Ante', 'İnte', 'Enit'],
        correctOptionIndex: 0,
        explanation: 'Elif üstün "E", Nun cezim "n", Te üstün "Te" -> "Ente" (Sen).',
      ),
      QuizQuestion(
        questionText: '"Sonra" anlamına gelen şeddeli bu kelime nasıl okunur?',
        arabicPrompt: 'ثُمَّ',
        audioTarget: 'ثُمَّ',
        options: ['Sümme', 'Süme', 'Samme', 'Semme'],
        correctOptionIndex: 0,
        explanation: 'Peltek Se ötreli "Sü", Mim şeddeli "m-me" -> "Sümme" (Sonra).',
      ),
      QuizQuestion(
        questionText: '"Hak ve Gerçek" anlamına gelen bu şeddeli kelime nasıl okunur?',
        arabicPrompt: 'حَقّ',
        audioTarget: 'حَقّ',
        options: ['Hakk', 'Hake', 'Haki', 'Huk'],
        correctOptionIndex: 0,
        explanation: 'Ha harfi üstün, Kaf harfi şeddeli olarak tutulur: "Hakk".',
      ),
      QuizQuestion(
        questionText: 'Uzatma (Med) harfleri kaç tanedir ve hangileridir?',
        arabicPrompt: 'ا و ي',
        audioTarget: '1',
        options: [
          '3 tanedir: Elif (ا), Vav (و), Ye (ي)',
          '2 tanedir: Be ve Te',
          '4 tanedir: Cezm, Şedde, Üstün, Esre',
          '1 tanedir: Sadece Elif'
        ],
        correctOptionIndex: 0,
        explanation: 'Hareketsiz Elif, Vav ve Ye harfleri önceki harfi bir elif miktarı uzatan Med harfleridir.',
      ),
      QuizQuestion(
        questionText: '"Dedi" anlamına gelen ve Elif ile uzatılan bu kelime nasıl okunur?',
        arabicPrompt: 'قَالَ',
        audioTarget: 'قَالَ',
        options: ['Kâle', 'Kale', 'Kule', 'Kîle'],
        correctOptionIndex: 0,
        explanation: 'Kaf harfinin üstününden sonra gelen Elif harfi sesi uzatır: "Kâle" (Dedi).',
      ),
      QuizQuestion(
        questionText: '"Işık / Nur" anlamına gelen ve Vav ile uzatılan bu kelime nasıl okunur?',
        arabicPrompt: 'نُور',
        audioTarget: 'نُور',
        options: ['Nûr', 'Nur', 'Nir', 'Ner'],
        correctOptionIndex: 0,
        explanation: 'Nun harfinin ötrelisinden sonra gelen hareketsiz Vav harfi "û" sesini uzatır: "Nûr".',
      ),
    ],
  ),

  // ── SEVİYE 4: Çocuklar İçin Namaz Duaları & Sureler (PREMIUM) ─
  const ElifBaLesson(
    id: 'lesson_4_namaz_duaları',
    levelNumber: 4,
    title: '4. Adım: Namaz Duaları',
    subtitle: 'Sübhaneke, Fatiha, İhlas, namaz tesbihleri ve kısa sureler',
    iconName: 'star_rounded',
    isPremiumOnly: false,
    xpReward: 160,
    questions: [
      QuizQuestion(
        questionText: 'Namazın ilk rekatında tekbirden sonra okunan "Sübhaneke..." duasının anlamı nedir?',
        arabicPrompt: 'سُبْحَانَكَ اللَّهُمَّ',
        audioTarget: 'سُبْحَانَكَ اللَّهُمَّ',
        options: [
          'Yalnız sana kulluk eder, yalnız senden yardım dileriz',
          'Allah\'ım! Sen her türlü eksiklikten uzaksın, seni överek tesbih ederim',
          'Bizi doğru yola, nimet verdiklerinin yoluna ilet',
          'De ki: O Allah tektir'
        ],
        correctOptionIndex: 1,
        explanation: 'Sübhaneke duası namazın başında Allah Teâlâ\'yı her noksanlıktan tenzih edip yücelttiğimiz açılış duasıdır.',
      ),
      QuizQuestion(
        questionText: 'Namazın her rekatında okunan Kur\'an-ı Kerim\'in ilk suresi hangisidir?',
        arabicPrompt: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
        audioTarget: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
        options: ['Fatiha Suresi', 'İhlas Suresi', 'Kevser Suresi', 'Felak Suresi'],
        correctOptionIndex: 0,
        explanation: 'Fatiha Suresi Kur\'an\'ın başlangıcıdır ve namazların her rekatında okunması vaciptir.',
      ),
      QuizQuestion(
        questionText: 'Fatiha suresinde geçen "İyyâke na\'büdü ve iyyâke neste\'în" ayetinin anlamı nedir?',
        arabicPrompt: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
        audioTarget: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
        options: [
          'Yalnız sana kulluk eder ve yalnız senden yardım dileriz',
          'Din gününün sahibidir',
          'Bizi doğru yola ilet',
          'Âlemlerin Rabbi olan Allah\'a hamdolsun'
        ],
        correctOptionIndex: 0,
        explanation: '"İyyâke na\'büdü ve iyyâke neste\'în", kulun yalnızca Allah\'a ibadet ettiğini ve yalnızca O\'ndan yardım dilediğini beyan eder.',
      ),
      QuizQuestion(
        questionText: 'Tevhid inancını bildiren "De ki: O Allah tektir" ayetiyle başlayan sure hangisidir?',
        arabicPrompt: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
        audioTarget: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
        options: ['Nas Suresi', 'Felak Suresi', 'İhlas Suresi', 'Asr Suresi'],
        correctOptionIndex: 2,
        explanation: 'İhlas Suresi Allah\'ın bir ve tek (Ehad) ve hiçbir şeye muhtaç olmadığını (Samed) açıklar.',
      ),
      QuizQuestion(
        questionText: 'İhlas Suresinde geçen "Allâhu\'s-Samed" ifadesi ne anlama gelir?',
        arabicPrompt: 'اللَّهُ الصَّمَدُ',
        audioTarget: 'اللَّهُ الصَّمَدُ',
        options: [
          'Allah her şeyden haberdardır',
          'Allah hiçbir şeye muhtaç değildir, her şey O\'na muhtaçtır',
          'Allah bağışlayandır',
          'Allah her şeyi yaratandır'
        ],
        correctOptionIndex: 1,
        explanation: '"Es-Samed", hiçbir şeye muhtaç olmayan, aksine her varlığın varlığını sürdürmek için O\'na muhtaç olduğu Yüce Yaratıcı demektir.',
      ),
      QuizQuestion(
        questionText: '"Şüphesiz biz sana Kevser\'i verdik" diye başlayan Kur\'an\'ın en kısa suresi hangisidir?',
        arabicPrompt: 'إِنَّا أَعْطَيْنَاكَ الْكَوْثَرَ',
        audioTarget: 'إِنَّا أَعْطَيْنَاكَ الْكَوْثَرَ',
        options: ['Kevser Suresi', 'Kadir Suresi', 'Kureyş Suresi', 'Nasr Suresi'],
        correctOptionIndex: 0,
        explanation: 'Kevser Suresi 3 ayettir ve Kur\'an-ı Kerim\'in en kısa suresidir.',
      ),
      QuizQuestion(
        questionText: 'Namazda rükûya eğildiğimizde 3 defa ne söyleriz?',
        arabicPrompt: 'سُبْحَانَ رَبِّيَ الْعَظِيمِ',
        audioTarget: 'سُبْحَانَ رَبِّيَ الْعَظِيمِ',
        options: [
          'Sübhâne Rabbiye\'l-A\'lâ',
          'Sübhâne Rabbiye\'l-Azîm',
          'Semi\'allâhu limen hamideh',
          'Rabbenâ leke\'l-hamd'
        ],
        correctOptionIndex: 1,
        explanation: 'Rükûda "Sübhâne Rabbiye\'l-Azîm" (Büyük olan Rabbim her türlü noksanlıktan münezzehtir) denir.',
      ),
      QuizQuestion(
        questionText: 'Rükûdan doğrulurken imam ve tek başına kılan kişi ne söyler?',
        arabicPrompt: 'سَمِعَ اللَّهُ لِمَنْ حَمِدَهُ',
        audioTarget: 'سَمِعَ اللَّهُ لِمَنْ حَمِدَهُ',
        options: [
          'Semi\'allâhu limen hamideh (Allah hamdedeni işitti)',
          'Allâhu Ekber',
          'Sübhâne Rabbiye\'l-Azîm',
          'Ettehiyyâtü lillâhi'
        ],
        correctOptionIndex: 0,
        explanation: 'Rükûdan kalkarken "Semi\'allâhu limen hamideh", doğrulunca "Rabbenâ leke\'l-hamd" denir.',
      ),
      QuizQuestion(
        questionText: 'Namazda secdeye vardığımızda 3 defa ne söyleriz?',
        arabicPrompt: 'سُبْحَانَ رَبِّيَ الْأَعْلَى',
        audioTarget: 'سُبْحَانَ رَبِّيَ الْأَعْلَى',
        options: [
          'Sübhâne Rabbiye\'l-A\'lâ',
          'Sübhâne Rabbiye\'l-Azîm',
          'Allâhu Ekber',
          'Ettehiyyâtü lillâhi'
        ],
        correctOptionIndex: 0,
        explanation: 'Secdede "Sübhâne Rabbiye\'l-A\'lâ" (En yüce olan Rabbimi her türlü noksanlıktan tenzih ederim) denir.',
      ),
      QuizQuestion(
        questionText: 'Namazların oturuşlarında (ka\'de) okunan ve Peygamberimizin Miraç selamlaşmasını içeren ilk dua hangisidir?',
        arabicPrompt: 'التَّحِيَّاتُ لِلَّهِ',
        audioTarget: 'التَّحِيَّاتُ لِلَّهِ',
        options: ['Ettehiyyâtü Duası', 'Sübhaneke Duası', 'Kunut Duası', 'Âyetel Kürsi'],
        correctOptionIndex: 0,
        explanation: 'İlk ve son oturuşlarda "Ettehiyyâtü lillâhi ve\'s-salavâtü ve\'t-tayyibât..." duası okunur.',
      ),
      QuizQuestion(
        questionText: '"Sabahın aydınlığına sığınırım" anlamına gelen ve kötülüklerden Allah\'a sığınmayı öğreten sure hangisidir?',
        arabicPrompt: 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ',
        audioTarget: 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ',
        options: ['Felak Suresi', 'Nas Suresi', 'Kevser Suresi', 'Fil Suresi'],
        correctOptionIndex: 0,
        explanation: 'Felak Suresi "Kul e\'ûzü bi-Rabbi\'l-felak" ayetiyle başlar; gecenin ve yaratılanların şerrinden Allah\'a sığınmayı bildirir.',
      ),
      QuizQuestion(
        questionText: '"İnsanların Rabbine, insanların Melikine (hükümranına) sığınırım" diye başlayan sure hangisidir?',
        arabicPrompt: 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
        audioTarget: 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
        options: ['Nas Suresi', 'Felak Suresi', 'İhlas Suresi', 'Kâfirûn Suresi'],
        correctOptionIndex: 0,
        explanation: 'Nas Suresi Kur\'an-ı Kerim\'in son (114.) suresidir; vesveselerden ve görünür-görünmez şerlerden Allah\'a sığınmayı öğretir.',
      ),
      QuizQuestion(
        questionText: '"Zamana andolsun ki insan gerçekten ziyandadır" ayetiyle başlayan sure hangisidir?',
        arabicPrompt: 'وَالْعَصْرِ',
        audioTarget: 'وَالْعَصْرِ',
        options: ['Asr Suresi', 'Kadir Suresi', 'Fecr Suresi', 'Duha Suresi'],
        correctOptionIndex: 0,
        explanation: 'Asr Suresi 3 ayettir; zamanın kıymetini, iman, salih amel, hakkı ve sabrı tavsiye etmeyi anlatır.',
      ),
      QuizQuestion(
        questionText: 'Namazın sonunda sağa ve sola selam verirken ne söyleriz?',
        arabicPrompt: 'السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ',
        audioTarget: 'السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ',
        options: [
          'Es-selâmü aleyküm ve rahmetullâh',
          'Allâhu Ekber',
          'Elhamdülillâh',
          'Sübhânallâh'
        ],
        correctOptionIndex: 0,
        explanation: 'Namazdan çıkarken önce sağa sonra sola "Es-selâmü aleyküm ve rahmetullâh" diyerek selam verilir.',
      ),
    ],
  ),
];

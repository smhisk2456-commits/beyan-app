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
    subtitle: 'Elif, Be, Te, Se, Cim ve temel harfler',
    iconName: 'menu_book',
    isPremiumOnly: false,
    xpReward: 50,
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
        questionText: 'Üzerinde iki nokta bulunan bu harfin doğru adı hangisidir?',
        arabicPrompt: 'ت',
        audioTarget: '3',
        options: ['Be (ب)', 'Te (ت)', 'Se (ث)', 'Nun (ن)'],
        correctOptionIndex: 1,
        explanation: '"Te" (ت) harfinin üzerinde yan yana iki nokta vardır ve ince bir "T" sesiyle okunur.',
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
        questionText: 'Üzerinde üç nokta bulunan ve dil ucu dişlerin arasından peltek çıkarılan harf hangisidir?',
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
        questionText: 'Hiç noktası olmayan ve boğazın ortasından nefes akıtılarak çıkarılan harf hangisidir?',
        arabicPrompt: 'ح',
        audioTarget: '6',
        options: ['Ha (ح)', 'Cim (ج)', 'Hı (خ)', 'He (ه)'],
        correctOptionIndex: 0,
        explanation: '"Ha" (ح) noktasızdır; hırıltı olmadan boğazın ortasından berrak bir nefesle çıkar.',
      ),
      QuizQuestion(
        questionText: 'Noktasız, hafif bükük duran ve ince okunan bu harf hangisidir?',
        arabicPrompt: 'د',
        audioTarget: '8',
        options: ['Dal (د)', 'Zel (ذ)', 'Ra (ر)', 'Vav (و)'],
        correctOptionIndex: 0,
        explanation: '"Dal" (د) ince ve tok bir "D" sesidir; kendisinden sonraki harfe birleşmez.',
      ),
    ],
  ),

  // ── SEVİYE 2: Harekeler (Üstün, Esre, Ötre) (ÜCRETSİZ) ────────
  const ElifBaLesson(
    id: 'lesson_2_harekeler',
    levelNumber: 2,
    title: '2. Adım: Harekeler',
    subtitle: 'Üstün (e/a), Esre (i/ı) ve Ötre (u/ü) sesleri',
    iconName: 'music_note',
    isPremiumOnly: false,
    xpReward: 70,
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
        questionText: 'Üç harfi de üstünlü olan bu Kur\'an kelimesi nasıl okunur?',
        arabicPrompt: 'كَتَبَ',
        audioTarget: 'كَتَبَ',
        options: ['Kütibe', 'Ketebe', 'Kitâb', 'Ketebü'],
        correctOptionIndex: 1,
        explanation: 'ك (Ke) + ت (Te) + ب (Be) harfleri üstünlerle birleştiğinde akıcı olarak "Ketebe" (Yazdı) şeklinde okunur.',
      ),
      QuizQuestion(
        questionText: 'Üzerinde ötre bulunan ince "Sin" (س) harfinin doğru okunuşu hangisidir?',
        arabicPrompt: 'سُ',
        audioTarget: '12',
        options: ['Se', 'Si', 'Sü', 'Es'],
        correctOptionIndex: 2,
        explanation: 'Sin ince bir harftir; ötre aldığında "Sü" sesiyle okunur.',
      ),
    ],
  ),

  // ── SEVİYE 3: Cezm, Şedde ve Tenvin (PREMIUM) ─────────────────
  const ElifBaLesson(
    id: 'lesson_3_cezm_sedde',
    levelNumber: 3,
    title: '3. Adım: Cezm & Şedde',
    subtitle: 'Harfleri tutturma, çift okuma ve tenvin kuralları',
    iconName: 'workspace_premium',
    isPremiumOnly: true,
    xpReward: 100,
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
    ],
  ),

  // ── SEVİYE 4: Çocuklar İçin Namaz Duaları & Sureler (PREMIUM) ─
  const ElifBaLesson(
    id: 'lesson_4_namaz_duaları',
    levelNumber: 4,
    title: '4. Adım: Namaz Duaları',
    subtitle: 'Sübhaneke, Fatiha, İhlas suresi ve rükû/secde tesbihleri',
    iconName: 'star_rounded',
    isPremiumOnly: true,
    xpReward: 150,
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
        explanation: 'Sübhaneke duası namazın başında Allah Teâlâ\'yı her noksanlıktan tenzih edip yücelttiğimiz duadır.',
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
        questionText: 'Tevhid inancını bildiren "De ki: O Allah tektir" ayetiyle başlayan sure hangisidir?',
        arabicPrompt: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
        audioTarget: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
        options: ['Nas Suresi', 'Felak Suresi', 'İhlas Suresi', 'Asr Suresi'],
        correctOptionIndex: 2,
        explanation: 'İhlas Suresi Allah\'ın bir ve tek (Ehad) ve hiçbir şeye muhtaç olmadığını (Samed) açıklar.',
      ),
      QuizQuestion(
        questionText: '"Şüphesiz biz sana Kevser\'i verdik" diye başlayan en kısa sure hangisidir?',
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
        questionText: 'Namazda secdeye kapandığımızda 3 defa ne söyleriz?',
        arabicPrompt: 'سُبْحَانَ رَبِّيَ الْأَعْلَى',
        audioTarget: 'سُبْحَانَ رَبِّيَ الْأَعْلَى',
        options: [
          'Sübhâne Rabbiye\'l-A\'lâ',
          'Sübhâne Rabbiye\'l-Azîm',
          'Allâhu Ekber',
          'Ettehiyyâtü lillâhi'
        ],
        correctOptionIndex: 0,
        explanation: 'Secdede "Sübhâne Rabbiye\'l-A\'lâ" (En yüce olan Rabbimi tenzih ederim) denir.',
      ),
    ],
  ),
];

import 'package:flutter/foundation.dart';

@immutable
class QuizQuestion {
  final String questionText;
  final String? audioTarget;
  final String arabicPrompt;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;

  const QuizQuestion({
    required this.questionText,
    this.audioTarget,
    required this.arabicPrompt,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
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
  // ── SEVİYE 1: Temel Harfler (ÜCRETSİZ) ──────────────────────
  const ElifBaLesson(
    id: 'lesson_1_letters_basic',
    levelNumber: 1,
    title: '1. Adım: İlk Harfler',
    subtitle: 'Elif, Be, Te, Se, Cim harflerini tanıyalım',
    iconName: 'menu_book',
    isPremiumOnly: false,
    xpReward: 50,
    questions: [
      QuizQuestion(
        questionText: 'Aşağıdaki harflerden hangisi "Be" (ب) harfidir?',
        arabicPrompt: 'ب',
        options: ['ت', 'ب', 'ث', 'ج'],
        correctOptionIndex: 1,
        explanation: '"Be" (ب) harfi altında tek bir nokta bulunan tekneli harftir.',
      ),
      QuizQuestion(
        questionText: 'Üzerinde iki nokta bulunan bu harfin adı nedir?',
        arabicPrompt: 'ت',
        options: ['Elif', 'Be', 'Te', 'Cim'],
        correctOptionIndex: 2,
        explanation: '"Te" (ت) harfinin üstünde iki nokta bulunur ve ince okunur.',
      ),
      QuizQuestion(
        questionText: 'Kur\'an alfabesinin ilk harfi hangisidir?',
        arabicPrompt: 'ا',
        options: ['ب', 'ا', 'ح', 'د'],
        correctOptionIndex: 1,
        explanation: '"Elif" (ا) Kur\'an alfabesinin ilk harfidir, dik ve asil bir duruşa sahiptir.',
      ),
      QuizQuestion(
        questionText: 'Karnında tek bir nokta olan bu harf hangisidir?',
        arabicPrompt: 'ج',
        options: ['ح', 'خ', 'ج', 'د'],
        correctOptionIndex: 2,
        explanation: '"Cim" (ج) harfinin karnında bir nokta bulunur ve "C" sesi verir.',
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
        questionText: 'Harfin üstündeki çizgiye ne denir ve nasıl ses verir?',
        arabicPrompt: 'بَ',
        options: [
          'Üstün (Fetha) - "e" veya "a" sesi verir',
          'Esre - "i" sesi verir',
          'Ötre - "u" sesi verir',
          'Cezm - harfi durdurur'
        ],
        correctOptionIndex: 0,
        explanation: 'Üstün (Fetha) harfin üstüne konur; ince harfleri "e", kalın harfleri "a" sesiyle okutur. "بَ" = "Be".',
      ),
      QuizQuestion(
        questionText: 'Harfin altındaki bu işaret (دِ) harfi nasıl okutur?',
        arabicPrompt: 'دِ',
        options: ['De', 'Di', 'Dü', 'Da'],
        correctOptionIndex: 1,
        explanation: 'Esre harfin altına konur ve ince harfleri "i" sesiyle okutur. "دِ" = "Di".',
      ),
      QuizQuestion(
        questionText: 'Üzerinde küçük vav işareti olan (رُ) nasıl okunur?',
        arabicPrompt: 'رُ',
        options: ['Re', 'Rı', 'Ru', 'Er'],
        correctOptionIndex: 2,
        explanation: 'Ötre (Damma) harfin üstüne konur ve harfe "u/ü" sesi verir. "رُ" = "Ru".',
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
        questionText: 'Harfin üstündeki yuvarlak daire (Cezm) ne işe yarar?',
        arabicPrompt: 'قُلْ',
        options: [
          'Harfi iki kere okutur',
          'Önceki harfi bu harfe tutturarak durdurur ("Kul")',
          'Harfi uzatır',
          'Harfi sessiz kılar'
        ],
        correctOptionIndex: 1,
        explanation: 'Cezm (Sükun) harfin harekesiz olduğunu ve önceki harfle tutturularak okunduğunu belirtir: "قُلْ" = "Kul".',
      ),
      QuizQuestion(
        questionText: 'Şedde (W şeklinde işaret) harfe ne yaptırır?',
        arabicPrompt: 'رَبِّ',
        options: [
          'Harfi tek seferde hızlı okutur',
          'Harfi iki defa (birincisi cezimli, ikincisi harekeli) kuvvetlice okutur',
          'Harfi fısıltıyla okutur',
          'Harfi atlatır'
        ],
        correctOptionIndex: 1,
        explanation: 'Şedde harfi iki kere okutur: "رَبِّ" = "Rab-bi".',
      ),
      QuizQuestion(
        questionText: 'Çift hareke olan Tenvin (ً ٍ ٌ) hangi sesi ekler?',
        arabicPrompt: 'كِتَابًا',
        options: ['-m sesi', '-n sesi (en, in, un)', '-r sesi', '-t sesi'],
        correctOptionIndex: 1,
        explanation: 'Tenvin kelimenin sonuna gizli bir nun sesi katar: Kitâben, Kitâbin, Kitâbün.',
      ),
    ],
  ),

  // ── SEVİYE 4: Çocuklar İçin Namaz Duaları & Fatiha (PREMIUM) ─
  const ElifBaLesson(
    id: 'lesson_4_namaz_duaları',
    levelNumber: 4,
    title: '4. Adım: Namaz Duaları',
    subtitle: 'Sübhaneke, Fatiha ve İhlas suresi talimi',
    iconName: 'star_rounded',
    isPremiumOnly: true,
    xpReward: 150,
    questions: [
      QuizQuestion(
        questionText: 'Namazın başında iftitah tekbirinden sonra okunan ilk dua hangisidir?',
        arabicPrompt: 'سُبْحَانَكَ اللَّهُمَّ',
        options: ['Fatiha Suresi', 'Sübhaneke Duası', 'Ettehiyyatü', 'Ayetel Kürsi'],
        correctOptionIndex: 1,
        explanation: 'Namazın ilk rekatında tekbirden sonra Sübhaneke okunur.',
      ),
      QuizQuestion(
        questionText: '"Elhamdülillâhi Rabbi\'l-âlemîn" hangi surenin ilk ayetidir?',
        arabicPrompt: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
        options: ['İhlas Suresi', 'Fatiha Suresi', 'Kevser Suresi', 'Nas Suresi'],
        correctOptionIndex: 1,
        explanation: 'Fatiha Suresi Kur\'an\'ın başlangıcı ve namazın her rekatında okunan ana suredir.',
      ),
      QuizQuestion(
        questionText: 'Tevhid inancını bildiren "Kul hüvallâhü ehad" suresi hangisidir?',
        arabicPrompt: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
        options: ['Felak Suresi', 'Nas Suresi', 'İhlas Suresi', 'Asr Suresi'],
        correctOptionIndex: 2,
        explanation: 'İhlas Suresi Allah\'ın bir ve tek (Ehad) olduğunu ve hiçbir şeye muhtaç olmadığını (Samed) beyan eder.',
      ),
    ],
  ),
];

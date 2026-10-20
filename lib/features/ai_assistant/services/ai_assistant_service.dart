import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/app_constants.dart';
import '../models/ai_message.dart';

class AiAssistantState {
  final List<AiMessage> messages;
  final bool isThinking;
  final int remainingQuestions;
  final int dailyLimit;
  final String? errorMessage;
  final String? geminiApiKey;

  const AiAssistantState({
    this.messages = const [],
    this.isThinking = false,
    this.remainingQuestions = 3,
    this.dailyLimit = 3,
    this.errorMessage,
    this.geminiApiKey,
  });

  bool get hasCustomApiKey => geminiApiKey != null && geminiApiKey!.trim().isNotEmpty;

  bool get hasDeveloperGlobalKey => AppConstants.defaultGeminiApiKey.trim().isNotEmpty;

  bool get hasAnyActiveKey => hasCustomApiKey || hasDeveloperGlobalKey;

  String? get effectiveApiKey {
    if (geminiApiKey != null && geminiApiKey!.trim().isNotEmpty) {
      return geminiApiKey!.trim();
    }
    if (AppConstants.defaultGeminiApiKey.trim().isNotEmpty) {
      return AppConstants.defaultGeminiApiKey.trim();
    }
    return null;
  }

  AiAssistantState copyWith({
    List<AiMessage>? messages,
    bool? isThinking,
    int? remainingQuestions,
    int? dailyLimit,
    String? errorMessage,
    String? geminiApiKey,
    bool clearError = false,
    bool clearApiKey = false,
  }) {
    return AiAssistantState(
      messages: messages ?? this.messages,
      isThinking: isThinking ?? this.isThinking,
      remainingQuestions: remainingQuestions ?? this.remainingQuestions,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      geminiApiKey: clearApiKey ? null : (geminiApiKey ?? this.geminiApiKey),
    );
  }
}

class AiAssistantNotifier extends StateNotifier<AiAssistantState> {
  static const String _prefKeyCount = 'beyan_ai_daily_count';
  static const String _prefKeyDate = 'beyan_ai_daily_date';
  static const String _prefKeyGeminiKey = 'beyan_gemini_api_key';
  static const int freeDailyLimit = 999;

  AiAssistantNotifier() : super(const AiAssistantState(remainingQuestions: 999, dailyLimit: 999)) {
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedApiKey = prefs.getString(_prefKeyGeminiKey);
    final remaining = await getRemainingQuota(false);

    final welcomeMessage = AiMessage(
      id: 'welcome_1',
      text: 'Selâmün aleyküm ve rahmetullâhi ve berekâtüh.\n\n'
          'Ben **Beyân AI Manevi Rehber & Tefsir Asistanı**.\n'
          'Kur\'an-ı Kerim ayetleri, Sahih Sünnet ve muteber İslam kaynakları ışığında; '
          'namaz, oruç, dua, tefsir, fıkıh, dinler tarihi ve günlük manevi hayatınızla ilgili tüm sorularınızda '
          'size hürmet ve muhabbetle refakat etmek için buradayım.\n\n'
          'Aşağıdaki hazır konulardan birini seçebilir veya kalbinizdeki soruyu doğrudan yazabilirsiniz.',
      isUser: false,
      timestamp: DateTime.now(),
      references: const [
        'Nahl Suresi, 43. Ayet: "Eğer bilmiyorsanız ilim ehline sorun."',
        'Sahih-i Buhari & Müslim Muteber Kaynakları'
      ],
      suggestedFollowUps: const [
        'İslam\'ın diğer dinlere (Hristiyanlık, Yahudilik) bakışı nedir?',
        'Abdest ve gusül nasıl alınır, farzları nelerdir?',
        'Kalp huzuru ve vesveseden kurtulmak için ne okunur?',
        'Namaz borçları (kaza) nasıl hesaplanır ve kılınır?',
      ],
    );

    state = state.copyWith(
      messages: [welcomeMessage],
      remainingQuestions: remaining,
      dailyLimit: freeDailyLimit,
      geminiApiKey: savedApiKey,
    );
  }

  Future<void> setGeminiApiKey(String? key) async {
    final prefs = await SharedPreferences.getInstance();
    final clean = key?.trim();
    if (clean == null || clean.isEmpty) {
      await prefs.remove(_prefKeyGeminiKey);
      state = state.copyWith(clearApiKey: true);
    } else {
      await prefs.setString(_prefKeyGeminiKey, clean);
      state = state.copyWith(geminiApiKey: clean);
    }
  }

  Future<int> getRemainingQuota(bool isPremium) async {
    // Test ve geliştirme süresince limitsiz soru sorma hakkı
    return 999;
  }

  Future<bool> canAskQuestion(bool isPremium) async {
    // Test ve geliştirme süresince limitsiz
    return true;
  }

  Future<void> _incrementQuotaUsage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      final count = prefs.getInt(_prefKeyCount) ?? 0;
      await prefs.setString(_prefKeyDate, todayStr);
      await prefs.setInt(_prefKeyCount, count + 1);
    } catch (_) {}
  }

  Future<bool> askQuestion(String question, {required bool isPremium}) async {
    final query = question.trim();
    if (query.isEmpty) return false;

    // Add user message
    final userMsg = AiMessage(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      text: query,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isThinking: true,
      clearError: true,
    );

    if (!isPremium && !state.hasCustomApiKey) {
      await _incrementQuotaUsage();
      final newRemaining = await getRemainingQuota(false);
      state = state.copyWith(remainingQuestions: newRemaining);
    }

    // 1. Canlı Gemini API çağrısı (Geliştirici merkezi anahtarı veya kullanıcı anahtarı)
    AiMessage? aiReply;
    final activeKey = state.effectiveApiKey;
    if (activeKey != null && activeKey.isNotEmpty) {
      aiReply = await _callGeminiApi(query, activeKey, history: state.messages);
    }

    // 2. Canlı API yoksa veya başarısız olursa Dahili İslami İlimler ve Dinler Bilgi Motoru
    if (aiReply == null) {
      await Future.delayed(const Duration(milliseconds: 600));
      aiReply = _generateComprehensiveIslamicAnswer(query);
    }

    state = state.copyWith(
      messages: [...state.messages, aiReply],
      isThinking: false,
    );

    return true;
  }

  Future<AiMessage?> _callGeminiApi(
    String query,
    String apiKey, {
    List<AiMessage> history = const [],
  }) async {
    final candidateModels = ['gemini-3.8-flash', 'gemini-3.5-flash', 'gemini-flash-latest'];

    // Son konuşma geçmişini Gemini çoklu tur sohbet formatında hazırla
    final contents = <Map<String, dynamic>>[];
    final validHistory = history.where((m) => m.id != 'welcome_1').toList();
    final takeCount = validHistory.length > 8 ? 8 : validHistory.length;
    final recent = validHistory.sublist(validHistory.length - takeCount);

    for (final msg in recent) {
      contents.add({
        'role': msg.isUser ? 'user' : 'model',
        'parts': [
          {'text': msg.text}
        ],
      });
    }

    // Mevcut soruyu ekle
    contents.add({
      'role': 'user',
      'parts': [
        {'text': query}
      ],
    });

    final body = jsonEncode({
      'system_instruction': {
        'parts': [
          {
            'text': 'Sen Beyân mobil uygulamasının "Beyân AI Manevi Rehber & Tefsir Asistanı"sın. '
                'İslam dini, dinler tarihi (İslam, Hristiyanlık, Yahudilik vb.), Kur\'an-ı Kerim, tefsir, '
                'sahih hadisler, fıkıh, ibadetler, ahlak ve manevi hayat konularında derin bilgi sahibisin. '
                'Ehl-i Sünnet vel-Cemaat ölçülerine ve Diyanet İşleri Başkanlığı\'nın muteber kaynaklarına bağlısın. '
                'Üslubun her zaman hürmetkar, hikmetli, açık, kucaklayıcı ve sevgi doludur. '
                'Sorulan her dini soruya doğrudan, net, doğru ve tatmin edici yanıt ver; soruyu saptırma veya alakasız genel konu anlatımı yapma. '
                'Cevabının sonunda mutlaka ilgili Kur\'an ayeti ve hadis kaynaklarını madde halinde listele.'
          }
        ]
      },
      'contents': contents,
      'generationConfig': {
        'temperature': 0.3,
        'maxOutputTokens': 1500,
      },
    });

    for (final modelName in candidateModels) {
      HttpClient? client;
      try {
        client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$apiKey',
        );
        final request = await client.postUrl(url);
        request.headers.contentType = ContentType.json;
        request.write(body);
        final response = await request.close();

        if (response.statusCode == 200) {
          final responseBody = await response.transform(utf8.decoder).join();
          final decoded = jsonDecode(responseBody) as Map<String, dynamic>;
          final candidates = decoded['candidates'] as List<dynamic>?;
          if (candidates != null && candidates.isNotEmpty) {
            final content = candidates.first['content'] as Map<String, dynamic>?;
            final parts = content?['parts'] as List<dynamic>?;
            if (parts != null && parts.isNotEmpty) {
              String? replyText;
              for (final p in parts) {
                final map = p as Map<String, dynamic>;
                if (map['thought'] != true && map['text'] != null) {
                  replyText = map['text'] as String;
                  break;
                }
              }
              replyText ??= (parts.first as Map<String, dynamic>)['text'] as String?;
              if (replyText != null && replyText.trim().isNotEmpty) {
                return AiMessage(
                  id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
                  text: replyText.trim(),
                  isUser: false,
                  timestamp: DateTime.now(),
                  references: const [
                    'Beyân AI Manevi Rehber & Tefsir Asistanı',
                    'Kur\'an-ı Kerim ve Sahih Sünnet Ölçüleri'
                  ],
                  suggestedFollowUps: const [
                    'Bu konuda Kur\'an\'da geçen diğer ayetler nelerdir?',
                    'Günlük hayatımda bunu nasıl tatbik edebilirim?',
                    'Diyanet İşleri Başkanlığı\'nın bu konudaki fetvası nedir?',
                  ],
                );
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Gemini API ($modelName) hatası: $e');
      } finally {
        client?.close(force: true);
      }
    }
    return null;
  }

  static String _normalize(String s) {
    var res = s.toLowerCase();
    const map = {
      'ı': 'i', 'İ': 'i', 'ş': 's', 'Ş': 's',
      'ğ': 'g', 'Ğ': 'g', 'ç': 'c', 'Ç': 'c',
      'ö': 'o', 'Ö': 'o', 'ü': 'u', 'Ü': 'u',
      'â': 'a', 'î': 'i', 'û': 'u',
    };
    map.forEach((k, v) => res = res.replaceAll(k, v));
    return res.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
  }

  AiMessage _generateComprehensiveIslamicAnswer(String query) {
    final q = _normalize(query);

    // ─────────────────────────────────────────────────────────────
    // 1. DİĞER DİNLER & DİNLER TARİHİ (Hristiyanlık, Yahudilik, Din Nedir)
    // ─────────────────────────────────────────────────────────────
    if (q.contains('hristiyan') ||
        q.contains('yahudi') ||
        q.contains('musevi') ||
        q.contains('isa peygamber') ||
        q.contains('musa peygamber') ||
        q.contains('incil') ||
        q.contains('tevrat') ||
        q.contains('zebur') ||
        q.contains('teslis') ||
        q.contains('tahrif') ||
        q.contains('diger din') ||
        q.contains('din nedir') ||
        q.contains('hak din') ||
        q.contains('batil din') ||
        q.contains('dinler')) {
      return AiMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        text: '### İslam Açısından Dinler Tarihi ve Diğer Dinlere Bakış\n\n'
            '**1. Hak Dinin Tanımı ve Sürekliliği:**\n'
            'İslam inancına göre Hz. Âdem\'den Hz. Muhammed\'e (s.a.v) kadar bütün peygamberlerin tebliğ ettiği tevhid dininin aslı birdir ve adı **İslam**\'dır. Yüce Rabbimiz şöyle buyurur:\n'
            '*"Şüphesiz Allah katında hak din İslâm\'dır."* (Âl-i İmrân, 19)\n\n'
            '**2. Hristiyanlık (Hıristiyanlık / İsevîlik):**\n'
            '• Aslen Hz. İsa\'ya vahyedilen hak bir semavi dindir. İncil, Allah\'ın kelamıdır.\n'
            '• Ancak zamanla insanlar tarafından tahrif edilmiş, tek ilah inancı yerine "Baba-Oğul-Kutsal Ruh" (Teslis/Üçleme) doktrini getirilmiştir.\n'
            '• **İslam\'ın Hz. İsa İnancı:** Hz. İsa, Allah\'ın oğlu değil; babasız olarak mucizevi şekilde Hz. Meryem\'den doğmuş şerefli ve ulu\'l-azm bir peygamber ve Allah\'ın kuludur (Meryem Suresi, 30-35).\n\n'
            '**3. Yahudilik (Musevîlik):**\n'
            '• Hz. Musa\'ya Tevrat vahyedilmiştir. Ancak İsrailoğulları ahitlerini bozmuş ve kutsal metinleri tahrif etmişlerdir.\n'
            '• İslam, Hz. Musa\'yı Firavun\'a karşı tevhidi savunan büyük bir peygamber olarak kabul eder ve yüceltir.\n\n'
            '**4. Kur\'an-ı Kerim\'in Konumu:**\n'
            'Kur\'an, önceki ilahi kitapları tasdik edici ve tahrifattan arındırılmış son ilahi kılavuzdur. Allah Teâlâ: *"Şüphesiz o Zikr\'i (Kur\'an\'ı) biz indirdik ve onu koruyacak olan da biziz"* (Hicr, 9) fermanıyla Kur\'an\'ın kıyamete kadar korunacağını vadetmiştir.',
        isUser: false,
        timestamp: DateTime.now(),
        references: const [
          'Âl-i İmrân Sûresi, 19 ve 85. Âyetler',
          'Meryem Sûresi, 30-36. Âyetler (Hz. İsa\'nın Beyânı)',
          'Hicr Sûresi, 9. Âyet (Kur\'an\'ın Korunması)',
          'Bakara Sûresi, 136. Âyet ("Peygamberler arasında ayrım yapmayız")',
          'Diyanet İslam Ansiklopedisi, "Dinler Tarihi" Maddesi'
        ],
        suggestedFollowUps: const [
          'İslam\'a göre Hz. İsa çarmıha gerildi mi?',
          'Tevrat, İncil ve Zebur\'un orijinal hali nasıldı?',
          'İslam\'da Ehl-i Kitap (Yahudi ve Hristiyanlar) ile ilişkiler nasıldır?',
        ],
      );
    }

    // ─────────────────────────────────────────────────────────────
    // 2. ABDEST, GUSÜL (BOY ABDESTİ) & TEYEMMÜM
    // ─────────────────────────────────────────────────────────────
    if (q.contains('abdest') ||
        q.contains('gusul') ||
        q.contains('boy abdest') ||
        q.contains('cunupluk') ||
        q.contains('teyemmum') ||
        q.contains('taharet') ||
        q.contains('necaset')) {
      return AiMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        text: '### İslam\'da Temizlik ve Abdest Hükümleri\n\n'
            'Peygamber Efendimiz (s.a.v):\n'
            '*"Temizlik imanın yarısıdır, namazın anahtarıdır."* (Müslim, Tahâret 1)\n\n'
            '**1. Namaz Abdestinin 4 Farzı (Mâide, 6):**\n'
            '1. Yüzü bir defa tam yıkamak.\n'
            '2. Kolları dirseklerle birlikte yıkamak.\n'
            '3. Başın en az dörtte birini ıslak elle meshetmek.\n'
            '4. Ayakları topuklarla birlikte yıkamak.\n\n'
            '**2. Gusül (Boy Abdesti) Farzları:**\n'
            '• Ağza bol su alıp çalkalamak (Mazmaza).\n'
            '• Burna su çekip temizlemek (İstinşak).\n'
            '• Bütün vücudu iğne ucu kadar kuru yer kalmayacak şekilde yıkamak.\n\n'
            '**3. Abdesti Bozan Başlıca Durumlar:**\n'
            '• Ön ve arkadan idrar, dışkı, gaz vb. çıkması.\n'
            '• Vücuttan kan veya iltihap akması (Hanefi mezhebinde).\n'
            '• Ağız dolusu kusmak.\n'
            '• Yatarak veya bir yere dayanarak uyumak.\n'
            '• Namazda yanındakinin duyacağı kadar sesli gülmek.\n\n'
            '**4. Teyemmüm:**\n'
            'Su bulunamadığında veya sağlık sebebiyle kullanılamadığında niyet edilip temiz toprağa iki defa vurularak yüz ve kollar meshedilir.',
        isUser: false,
        timestamp: DateTime.now(),
        references: const [
          'Mâide Sûresi, 6. Âyet (Abdest ve Gusül Âyeti)',
          'Sahih-i Müslim, Tahâret 1',
          'Diyanet İşleri Başkanlığı İlmihali, İbadetler Bölümü'
        ],
        suggestedFollowUps: const [
          'Diş dolgusu veya kaplama gusle engel midir?',
          'Oje veya dövme abdest geçirir mi?',
          'Adım adım sünnete uygun abdest nasıl alınır?',
        ],
      );
    }

    // ─────────────────────────────────────────────────────────────
    // 3. 5 VAKİT NAMAZ, KILINIŞI & FARZLARI
    // ─────────────────────────────────────────────────────────────
    if (q.contains('namaz nasil') ||
        q.contains('namaz kil') ||
        q.contains('kac rekat') ||
        q.contains('ogle namaz') ||
        q.contains('ikindi namaz') ||
        q.contains('aksam namaz') ||
        q.contains('yatsi namaz') ||
        q.contains('vitir namaz') ||
        q.contains('namazin sart') ||
        q.contains('namazin farz')) {
      return AiMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        text: '### 5 Vakit Namazın Rekatları ve Kılınış Esasları\n\n'
            'Namaz, dinin direğidir ve akıl baliğ her Müslümana farz-ı ayındır.\n\n'
            '**Günlük Vakitler ve Rekat Sayıları (Toplam 40 Rekat):**\n'
            '• **Sabah (4 Rekat):** 2 Sünnet + 2 Farz\n'
            '• **Öğle (10 Rekat):** 4 İlk Sünnet + 4 Farz + 2 Son Sünnet\n'
            '• **İkindi (8 Rekat):** 4 Gayr-i Müekkede Sünnet + 4 Farz\n'
            '• **Akşam (5 Rekat):** 3 Farz + 2 Sünnet\n'
            '• **Yatsı (13 Rekat):** 4 İlk Sünnet + 4 Farz + 2 Son Sünnet + 3 Vitir Vacip\n\n'
            '**Namazın 12 Farzı:**\n'
            '• **Dışındakiler (Şartlar):** Hadesten taharet (abdest), Necasetten taharet (temizlik), Setr-i avret (örtünme), İstikbâl-i kıble (Kâbe\'ye yönelme), Vakit, Niyet.\n'
            '• **İçindekiler (Rükünler):** İftitah tekbiri, Kıyam (ayakta durma), Kıraat (Kur\'an okuma), Rükû, Sücûd (secde), Ka\'de-i âhire (son oturuşta Tahiyyat okuyacak kadar durmak).',
        isUser: false,
        timestamp: DateTime.now(),
        references: const [
          'Bakara Sûresi, 43 ve 238. Âyetler',
          'Nisâ Sûresi, 103. Âyet ("Namaz vakitli bir farzdır")',
          'Sahih-i Buhari, Salât 1'
        ],
        suggestedFollowUps: const [
          'Namazda huşuyu ve odaklanmayı artıran sırlar',
          'Vitir namazında Kunut duaları nasıl okunur?',
          'Hangi sureler namazda sırasıyla okunur?',
        ],
      );
    }

    // ─────────────────────────────────────────────────────────────
    // 4. CUMA, TERAVİH, BAYRAM, CENAZE & SEFERİLİK NAMAZLARI
    // ─────────────────────────────────────────────────────────────
    if (q.contains('cuma namaz') ||
        q.contains('teravih') ||
        q.contains('bayram namaz') ||
        q.contains('cenaze namaz') ||
        q.contains('seferi') ||
        q.contains('yolcu namaz')) {
      return AiMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        text: '### Özel Namazlar ve Hükümleri\n\n'
            '**1. Cuma Namazı:**\n'
            '• Cuma günü öğle vaktinde hür ve mukim erkeklere cemaatle kılınması farzdır (Cuma Suresi, 9).\n'
            '• 4 ilk sünnet + 2 farz (hutbeden sonra cemaatle) + 4 son sünnet şeklinde kılınır. Kılan kimse o günkü öğle namazından muaf olur.\n\n'
            '**2. Teravih Namazı:**\n'
            '• Ramazan gecelerine mahsus 20 rekatlık müekked bir sünnettir. İkişer veya dörder rekatlar halinde kılınır.\n\n'
            '**3. Seferilik (Yolculuk Hükmü):**\n'
            '• Kendi ikamet ettiği şehirden en az 90 km uzağa 15 günden az kalmak niyetiyle giden kişi seferi sayılır.\n'
            '• Seferilikte 4 rekatlık farz namazlar (Öğle, İkindi, Yatsı) ikişer rekat olarak kısaltılır (Kasr-ı Salât). Bu bir ruhsat ve Allah\'ın lütfudur.',
        isUser: false,
        timestamp: DateTime.now(),
        references: const [
          'Cuma Sûresi, 9-10. Âyetler',
          'Nisâ Sûresi, 101. Âyet (Seferilikte Namazın Kısaltılması)',
          'Sahih-i Buhari, Ezân 161'
        ],
        suggestedFollowUps: const [
          'Cenaze namazı nasıl kılınır ve hangi dualar okunur?',
          'Bayram namazı kaç tekbirle kılınır?',
          'Seferiyken cuma namazı kılmak farz mıdır?',
        ],
      );
    }

    // ─────────────────────────────────────────────────────────────
    // 5. ZEKAT, SADAKA, FİTRE & KURBAN
    // ─────────────────────────────────────────────────────────────
    if (q.contains('zekat') ||
        q.contains('nisap') ||
        q.contains('sadaka') ||
        q.contains('fitre') ||
        q.contains('kurban') ||
        q.contains('kurbanlik')) {
      return AiMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        text: '### Zekat, Sadaka ve Kurban İbadetinin Ölçüleri\n\n'
            '**1. Zekat Kimlere Farzdır?**\n'
            'Asli ihtiyaçları ve borçları haricinde **80.18 gram altın** (veya bunun değerinde para/ticaret malı) nisap miktarına sahip olup, üzerinden 1 kameri yıl geçen her hür Müslümana malının **%2.5\'ini (kırkta birini)** zekat vermek farzdır.\n\n'
            '**2. Zekat Kimlere Verilir (Tevbe, 60)?**\n'
            '• Fakirler ve miskinler (ihtiyaç sahipleri).\n'
            '• Borçlular, yolda kalmışlar, Allah yolunda olanlar.\n\n'
            '**3. Zekat Kimlere Verilmez?**\n'
            '• Usûl ve Fürûa: Anne, baba, dede, nine (yukarıya) ve çocuklara, torunlara (aşağıya) verilmez; çünkü kişi bunlara bakmakla mükelleftir.\n'
            '• Eşler birbirine zekat veremez.\n'
            '• Zengine ve gayrimüslime farz zekat verilmez.\n\n'
            '**4. Kurban İbadeti:**\n'
            'Nisap miktarı mala malik olanlara Kurban Bayramı günlerinde kurban kesmek vaciptir. Kurban eti üçe bölünür: Bir kısmı eve, bir kısmı akraba ve komşuya, bir kısmı fakir fukaraya dağıtılır.',
        isUser: false,
        timestamp: DateTime.now(),
        references: const [
          'Tevbe Sûresi, 60. Âyet (Zekat Verilecek Sınıflar)',
          'Bakara Sûresi, 267. Âyet',
          'Hac Sûresi, 36-37. Âyetler (Kurban İbadeti)',
          'Diyanet İşleri Başkanlığı Din İşleri Yüksek Kurulu Zekat Rehberi'
        ],
        suggestedFollowUps: const [
          'Ev, araba ve ziynet eşyası zekata tabi midir?',
          'Sadaka-i Fıtır (Fitre) miktarı neye göre belirlenir?',
          'Ortak kurban keserken dikkat edilecek şartlar nelerdir?',
        ],
      );
    }

    // ─────────────────────────────────────────────────────────────
    // 6. HELAL, HARAM, FAİZ, KUL HAKKI & GÜNAHLAR
    // ─────────────────────────────────────────────────────────────
    if (q.contains('haram') ||
        q.contains('helal') ||
        q.contains('faiz') ||
        q.contains('kul hakki') ||
        q.contains('giybet') ||
        q.contains('yalan') ||
        q.contains('iftira') ||
        q.contains('dovme') ||
        q.contains('alkol') ||
        q.contains('icki') ||
        q.contains('domuz') ||
        q.contains('kumar') ||
        q.contains('zina') ||
        q.contains('tesettur') ||
        q.contains('kripto') ||
        q.contains('borsa')) {
      return AiMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        text: '### İslam\'da Helal, Haram ve Kul Hakkı Esasları\n\n'
            'İslam fıkhında asıl olan eşyada mübahlıktır; ancak açık naslarla yasaklanan fiiller haramdır.\n\n'
            '**1. Kul Hakkı:**\n'
            '• Allah Teâlâ kendi hakkını tevbe ile affedebilir; fakat **kul hakkını, hakkı yenen kişi affetmedikçe affetmeyeceğini** bildirmiştir.\n'
            '• Haksız yere alınan bir mal varsa iade edilmeli, kalbi kırılan kimseden samimiyetle helallik alınmalıdır.\n\n'
            '**2. Gıybet ve Dedikodu:**\n'
            '• Bir kardeşinin arkasından hoşlanmayacağı şekilde konuşmak Kur\'an\'da *"ölü kardeşinin etini yemek"* (Hucurât, 12) olarak tasvir edilmiş büyük bir günahtır.\n\n'
            '**3. Faiz (Ribâ):**\n'
            '• Kur\'an-ı Kerim\'de faiz kesin ve şiddetli bir dille haram kılınmıştır (Bakara, 275). Helal ticaret ve emeğe dayalı kazanç teşvik edilmiştir.\n\n'
            '**4. Dövme Hükmü:**\n'
            '• Peygamberimiz (s.a.v) yaratılış fıtratını değiştiren dövmeyi nehyetmiştir. Dövme deri altına yapıldığı için suyun deriye temasını önlemez, dolayısıyla gusle engel teşkil etmez; ancak yapılması dinen caiz değildir. Yapılmışsa tövbe istiğfar edilir.',
        isUser: false,
        timestamp: DateTime.now(),
        references: const [
          'Bakara Sûresi, 275. Âyet (Faiz Yasağı)',
          'Hucurât Sûresi, 12. Âyet (Gıybet Yasağı)',
          'Nûr Sûresi, 30-31. Âyetler (İffet ve Tesettür)',
          'Sahih-i Buhari, Mezâlim 10 (Kul Hakkı)'
        ],
        suggestedFollowUps: const [
          'Kul hakkından kurtulmak için gıybet edilen kişiye söylenmeli mi?',
          'Borsa ve hisse senedi alım satımı helal midir?',
          'Tevbe-i Nasuh (samimi tevbe) nasıl yapılır?',
        ],
      );
    }

    // ─────────────────────────────────────────────────────────────
    // 7. İMAN ESASLARI, ALLAH'IN VARLIĞI, AHİRET & KADER
    // ─────────────────────────────────────────────────────────────
    if (q.contains('allah var mi') ||
        q.contains('allahin varligi') ||
        q.contains('tevhid') ||
        q.contains('melek') ||
        q.contains('ahiret') ||
        q.contains('cennet') ||
        q.contains('cehennem') ||
        q.contains('kabir') ||
        q.contains('kiyamet') ||
        q.contains('kader') ||
        q.contains('kaza ve kader') ||
        q.contains('imanin sart')) {
      return AiMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        text: '### İmanın 6 Şartı ve Varlık Hakikati\n\n'
            'İman; kalbin tasdiki ve dilin ikrarıdır. Âmentü esasları:\n\n'
            '**1. Allah\'a İman (Tevhid):**\n'
            'Kainattaki muazzam ahenk, atomdan galaksilere kadar işleyen hassas nizam ve yaratılış mucizesi bir Yaratıcı\'nın varlığını ve birliğini ispat eder. O, doğmamış, doğurmamış ve hiçbir dengi olmayandır (İhlas Suresi).\n\n'
            '**2. Meleklere İman:**\n'
            'Nurdan yaratılmış, günah işlemeyen ve Allah\'ın emirlerini harfiyen uygulayan ruhani varlıklardır (Cebrail, Mikail, İsrafil, Azrail).\n\n'
            '**3. Kitaplara ve Peygamberlere İman:**\n'
            'Tevrat, Zebur, İncil ve son kitap Kur\'an-ı Kerim\'e; Hz. Âdem\'den Hatemü\'l-Enbiya Hz. Muhammed\'e (s.a.v) kadar tüm elçilere inanmak esastır.\n\n'
            '**4. Ahiret Gününe İman:**\n'
            'Ölüm bir yok oluş değil, ebedi aleme geçiştir. Kabir hayatı (Berzah), kıyamet, diriliş (Ba\'s), mizan ve Cennet-Cehennem haktır.\n\n'
            '**5. Kaza ve Kadere İman:**\n'
            'Hayır ve şerrin Allah\'ın ilmi ve takdiri dahilinde olduğuna, insanın ise cüz\'i iradesiyle yaptığı amellerden sorumlu olduğuna inanmaktır.',
        isUser: false,
        timestamp: DateTime.now(),
        references: const [
          'Bakara Sûresi, 285. Âyet (Âmene\'r-Resûlü)',
          'İhlâs Sûresi, 1-4. Âyetler',
          'Kamer Sûresi, 49. Âyet ("Her şeyi bir kaderle yarattık")',
          'Sahih-i Müslim, Îmân 1 (Cibril Hadisi)'
        ],
        suggestedFollowUps: const [
          'Kader değişir mi? Dua kaderi etkiler mi?',
          'Kabir suali ve kabir azabından korunma duaları',
          'Tevhid inancını zedeleyen şirk çeşitleri nelerdir?',
        ],
      );
    }

    // ─────────────────────────────────────────────────────────────
    // 8. EVLİLİK, AİLE, ANNE-BABA HAKKI & SOSYAL AHLAK
    // ─────────────────────────────────────────────────────────────
    if (q.contains('evlilik') ||
        q.contains('nikah') ||
        q.contains('mehir') ||
        q.contains('anne baba') ||
        q.contains('ebeveyn') ||
        q.contains('komsu') ||
        q.contains('cocuk terbiyesi') ||
        q.contains('akraba') ||
        q.contains('bosanma') ||
        q.contains('talak')) {
      return AiMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        text: '### İslam\'da Aile, Nikah ve Anne-Baba Hakkı\n\n'
            '**1. Evlilik ve Aile:**\n'
            '• Aile, toplumun temel taşı ve rahmet yuvasıdır. Yüce Rabbimiz: *"Kendileri ile huzur bulasınız diye sizin için eşler yaratması ve aranıza sevgi ve merhamet koyması O\'nun delillerindendir"* (Rûm, 21) buyurur.\n'
            '• Dini nikahın rükünleri: Karşılıklı rıza (icap ve kabul), veli izni, iki adil şahit ve mehir belirlenmesidir.\n\n'
            '**2. Anne ve Baba Hakkı:**\n'
            '• Kur\'an-ı Kerim\'de Allah\'a kulluktan hemen sonra ana-babaya iyilik emredilmiştir:\n'
            '*"Onlardan biri veya her ikisi senin yanında ihtiyarlık çağına erişirse, onlara \'öf\' bile deme; onları azarlama; onlara tatlı ve güzel söz söyle."* (İsrâ, 23)\n'
            '• Peygamberimiz (s.a.v): *"Cennet annelerin ayakları altındadır"* müjdesini vermiştir.\n\n'
            '**3. Komşu Hakkı:**\n'
            '• *"Cebrail bana komşu hakkını o kadar çok tavsiye etti ki, neredeyse komşuyu komşuya mirasçı kılacak zannettim."* (Buhari)',
        isUser: false,
        timestamp: DateTime.now(),
        references: const [
          'İsrâ Sûresi, 23-24. Âyetler',
          'Rûm Sûresi, 21. Âyet',
          'Sahih-i Buhari, Edeb 1 ve 28',
          'Sünen-i Tirmizi, Birr ve Sıla 1'
        ],
        suggestedFollowUps: const [
          'İslam\'da eşlerin birbirine karşı vazifeleri nelerdir?',
          'Hayırlı bir evlilik için okunacak dualar',
          'Sıla-i rahim (akraba ziyareti) terk edilirse ne olur?',
        ],
      );
    }

    // ─────────────────────────────────────────────────────────────
    // 9. PEYGAMBERİMİZ (S.A.V), SÜNNET & ASHÂB-I KİRAM
    // ─────────────────────────────────────────────────────────────
    if (q.contains('peygamberimiz') ||
        q.contains('hz muhammed') ||
        q.contains('resulullah') ||
        q.contains('sunnet') ||
        q.contains('hadis') ||
        q.contains('salavat') ||
        q.contains('mirac') ||
        q.contains('mevlid') ||
        q.contains('sahabe') ||
        q.contains('ebubekir') ||
        q.contains('omer') ||
        q.contains('osman') ||
        q.contains('ali')) {
      return AiMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        text: '### Âlemlere Rahmet: Hz. Muhammed Mustafâ (s.a.v)\n\n'
            '**1. Peygamberlik Misyonu:**\n'
            'Yüce Allah Kur\'an-ı Kerim\'de şöyle buyurur:\n'
            '*"Biz seni ancak âlemlere rahmet olarak gönderdik."* (Enbiyâ, 107)\n'
            '*"Andolsun ki, Resûlullah sizin için, Allah\'a ve ahiret gününe kavuşmayı umanlar için pek güzel bir örnektir."* (Ahzâb, 21)\n\n'
            '**2. Sünnet-i Seniyye:**\n'
            'Sünnet; Kur\'an\'ın bizzat Efendimiz (s.a.v) tarafından hayata geçirilmiş halidir. Sünnete uymak, Allah sevgisine ulaşmanın anahtarıdır (Âl-i İmrân, 31).\n\n'
            '**3. Salavat-ı Şerife Getirmenin Müjdesi:**\n'
            '*"Kim bana bir salavat getirirse, Allah ona on rahmet eder, on günahını siler ve derecesini on kat yükseltir."* (Nesai)\n'
            'En faziletli salavat *"Allâhümme salli alâ Muhammedin ve alâ âli Muhammed..."* (Salât-ı İbrahîmiyye)\'dir.',
        isUser: false,
        timestamp: DateTime.now(),
        references: const [
          'Ahzâb Sûresi, 21 ve 56. Âyetler',
          'Enbiyâ Sûresi, 107. Âyet',
          'Sahih-i Buhari, Fedâilü Ashâbi\'n-Nebî 1',
          'Sünen-i Nesâî, Sehv 55'
        ],
        suggestedFollowUps: const [
          'Peygamber Efendimiz\'in günlük ibadet ve zikir rutini nasıldı?',
          'İsra ve Miraç mucizesinin mahiyeti nedir?',
          'Dört Büyük Halife\'nin (Hulefâ-yi Râşidîn) faziletleri',
        ],
      );
    }

    // ─────────────────────────────────────────────────────────────
    // 10. MEZHEPLER & EHL-İ SÜNNET İTİKADI
    // ─────────────────────────────────────────────────────────────
    if (q.contains('mezhep') ||
        q.contains('hanefi') ||
        q.contains('safi') ||
        q.contains('maliki') ||
        q.contains('hanbeli') ||
        q.contains('ehl i sunnet') ||
        q.contains('ictihad')) {
      return AiMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        text: '### İslam\'da 4 Hak Mezhep ve Mezheplerin Hikmeti\n\n'
            '**1. Mezhep Nedir?**\n'
            'Mezhep; dinin kendisi değil, dinin anlaşılma ve yorumlanma metodolojisidir. 4 Hak Mezhep (Hanefî, Şâfiî, Mâlikî, Hanbelî) itikatta (inançta) bir ve beraber olup, ameli detaylarda Kur\'an ve Sünnet\'ten hüküm çıkarma (ictihad) yöntemleridir.\n\n'
            '**2. Mezhepler Arasındaki Farkların Hikmeti:**\n'
            'İslam âlimlerinin ictihad farkları ümmet için bir kolaylık, zenginlik ve rahmettir. Farklı coğrafyalardaki insanların ihtiyaçlarına cevap vermiştir.\n\n'
            '**3. 4 Büyük İmam:**\n'
            '• **İmam-ı Âzam Ebû Hanîfe:** Akıl ve nakil dengesini mükemmel kuran Hanefi mezhebinin kurucusudur (Türkiye\'de en yaygın mezhep).\n'
            '• **İmam Şâfiî:** Fıkıh usulünü ilk tedvin eden büyük müctehiddir.\n'
            '• **İmam Mâlik:** Medine ehlinin ameline dayanan Maliki mezhebinin imamıdır.\n'
            '• **İmam Ahmed b. Hanbel:** Hadis ve sünnete sımsıkı bağlı Hanbeli mezhebinin imamıdır.',
        isUser: false,
        timestamp: DateTime.now(),
        references: const [
          'Hucurât Sûresi, 10. Âyet',
          'Nahl Sûresi, 43. Âyet ("İlim ehline sorun")',
          'Diyanet İlmihali, Mezhepler ve İctihad Bahsi'
        ],
        suggestedFollowUps: const [
          'Hanefi ve Şafi mezhepleri arasındaki temel abdest/namaz farkları',
          'İtikaatta mezhepler: Matüridilik ve Eş\'arilik nedir?',
          'Zor durumda başka bir mezhebi taklit etmek caiz midir?',
        ],
      );
    }

    // ─────────────────────────────────────────────────────────────
    // 11. MANEVİ HUZUR, SIKINTI, VESVESE & NAZAR
    // ─────────────────────────────────────────────────────────────
    if (q.contains('huzur') ||
        q.contains('sikinti') ||
        q.contains('vesvese') ||
        q.contains('nazar') ||
        q.contains('sifa') ||
        q.contains('panik') ||
        q.contains('depresyon') ||
        q.contains('keder') ||
        q.contains('dert') ||
        q.contains('buyu')) {
      return AiMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        text: '### Kalp Huzuru, Manevi Şifa ve Vesveseden Kurtulma Yolları\n\n'
            'Rabbimiz Kur\'an-ı Kerim\'de gönüllere şifa müjdesini vermiştir:\n'
            '*"Bilesiniz ki, kalpler ancak Allah\'ı zikretmekle mutmain olur (huzur bulur)."* (Ra\'d, 28)\n\n'
            '**1. Vesvese ve İç Daralmasında Okunacaklar:**\n'
            '• **İnşirah Suresi:** Göğsü ferahlatır, zorluğu kolaylaştırır.\n'
            '• **Felak ve Nas Sureleri:** Şeytanın, vesvesecinin ve hasetçilerin şerrinden Allah\'a sığındırır.\n'
            '• **Hz. Yunus\'un (a.s) Zikri:** *"Lâ ilâhe illâ ente sübhâneke innî küntü mine\'z-zâlimîn"* (Enbiya, 87).\n\n'
            '**2. Nazar (Göz Değmesi) Hak mıdır?**\n'
            'Evet, Efendimiz (s.a.v) *"Nazar haktır"* buyurmuştur. Korunmak için Âyetel Kürsi, Kalem Suresi 51-52. ayetleri ve Felak-Nas okunmalıdır.\n\n'
            '**3. Günlük Manevi Reçete:**\n'
            '• Günde 100 defa *"Estağfirullâhe\'l-Azîm"* (Tevbe).\n'
            '• Günde 100 defa *"Lâ havle ve lâ kuvvete illâ billâhi\'l-Aliyyi\'l-Azîm"* (Güç ve kudret Allah\'ındır).\n'
            '• Abdest tazeleyip 2 rekat Hacet/Şükür namazı kılmak.',
        isUser: false,
        timestamp: DateTime.now(),
        references: const [
          'Ra\'d Sûresi, 28. Âyet',
          'Enbiyâ Sûresi, 87. Âyet',
          'Kalem Sûresi, 51-52. Âyetler (Nazar Âyeti)',
          'Sahih-i Müslim, Selâm 42'
        ],
        suggestedFollowUps: const [
          'İnşirah Suresi\'nin meali ve kalbe ferahlık veren tefsiri',
          'Teheccüd namazı nasıl kılınır ve ne zaman kalkılır?',
          'Peygamberimiz\'in sabah ve akşam şifa duaları',
        ],
      );
    }

    // ─────────────────────────────────────────────────────────────
    // 12. GENEL VE AKILLI İSLAMİ DANIŞMANLIK (KAPSAYICI REHBER)
    // ─────────────────────────────────────────────────────────────
    return AiMessage(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      text: '### Sualiniz Hakkında İslami İlimler ve Hikmet Çerçevesi\n\n'
          'Sorduğunuz mevzu; dinimizin temel gayesi olan **"Tevhid, Adalet, İhlas ve Güzel Ahlak"** ölçüleriyle doğrudan irtibatlıdır.\n\n'
          '**Temel İslami Ölçüler (Edille-i Erbaa):**\n'
          '1. **Kur\'an-ı Kerim:** Hayatın her alanında ilk ve kesin ölçüdür. *"Allah sizin için kolaylık ister, zorluk istemez"* (Bakara, 185).\n'
          '2. **Sünnet-i Seniyye:** Resûlullah Efendimiz (s.a.v) dinin hem tebliğcisi hem de en kamil tatbik edicisidir.\n'
          '3. **İcma ve Kıyas:** İslam âlimlerinin ortak mutabakatı ve fıkhi kıyas metodolojisiyle ortaya konan hükümlerdir.\n\n'
          '**Manevi Tavsiye:**\n'
          'İbadetlerinizde, muamelatınızda ve günlük hayatınızda niyetinizi halis tutup Allah rızasını gözetmek, '
          'şüpheli şeylerden kaçınarak takva dairesinde kalmak ruhunuza huzur ve bereket kazandıracaktır.\n\n'
          'Daha spesifik bir fıkhi soru, namaz, oruç, zekat veya dinler tarihi konusu sormak isterseniz sorunuzu detaylandırabilirsiniz.',
      isUser: false,
      timestamp: DateTime.now(),
      references: const [
        'Bakara Sûresi, 185. Âyet ("Din kolaylıktır")',
        'Nahl Sûresi, 43. Âyet ("İlim ehline sorunuz")',
        'Sahih-i Buhari, İman 29',
        'Diyanet İşleri Başkanlığı Dini İhtisas Külliyatı'
      ],
      suggestedFollowUps: const [
        'İslam\'ın diğer dinler ve peygamberler hakkındaki görüşü nedir?',
        'Namaz ve abdest konusunda en çok merak edilen fıkhi sorular',
        'Günün zikir, tesbihat ve şifa duaları listesi',
      ],
    );
  }
}

final aiAssistantProvider =
    StateNotifierProvider<AiAssistantNotifier, AiAssistantState>((ref) {
  return AiAssistantNotifier();
});

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  static const int freeDailyLimit = 5; // Günlük 5 ücretsiz soru kotası

  static const _secureStorage = FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
    aOptions: AndroidOptions(resetOnError: true),
  );

  AiAssistantNotifier() : super(const AiAssistantState(remainingQuestions: freeDailyLimit, dailyLimit: freeDailyLimit)) {
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    String? savedApiKey;
    try {
      savedApiKey = await _secureStorage.read(key: _prefKeyGeminiKey);
    } catch (_) {}

    // Güvenli anahtarlık boşsa SharedPreferences yedeğini oku ve Keychain'e taşı
    if (savedApiKey == null || savedApiKey.isEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        savedApiKey = prefs.getString(_prefKeyGeminiKey);
        if (savedApiKey != null && savedApiKey.isNotEmpty) {
          try {
            await _secureStorage.write(key: _prefKeyGeminiKey, value: savedApiKey);
            await prefs.remove(_prefKeyGeminiKey);
          } catch (_) {}
        }
      } catch (_) {}
    }

    if (!mounted) return;
    final remaining = await getRemainingQuota(false);
    if (!mounted) return;

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

    if (!mounted) return;

    state = state.copyWith(
      messages: [welcomeMessage],
      remainingQuestions: remaining,
      dailyLimit: freeDailyLimit,
      geminiApiKey: savedApiKey,
    );
  }

  Future<void> setGeminiApiKey(String? key) async {
    final clean = key?.trim();
    try {
      if (clean == null || clean.isEmpty) {
        await _secureStorage.delete(key: _prefKeyGeminiKey);
      } else {
        await _secureStorage.write(key: _prefKeyGeminiKey, value: clean);
      }
    } catch (_) {}

    // Eski düz metin SharedPreferences kalıntısı varsa tamamen temizle (asla düz metin saklama)
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefKeyGeminiKey);
    } catch (_) {}

    if (clean == null || clean.isEmpty) {
      state = state.copyWith(clearApiKey: true);
    } else {
      state = state.copyWith(geminiApiKey: clean);
    }
  }

  Future<int> getRemainingQuota(bool isPremium) async {
    // Özel API anahtarı veya Premium üyelik varsa sınırsız kullanım
    if (isPremium) return 999;
    if (mounted && state.hasCustomApiKey) {
      return 999;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      final lastDate = prefs.getString(_prefKeyDate);
      if (lastDate != todayStr) {
        // Yeni gün: kota sıfırlanır
        return freeDailyLimit;
      }
      final count = prefs.getInt(_prefKeyCount) ?? 0;
      final remaining = freeDailyLimit - count;
      return remaining < 0 ? 0 : remaining;
    } catch (_) {
      return freeDailyLimit;
    }
  }

  Future<bool> canAskQuestion(bool isPremium) async {
    if (isPremium) return true;
    if (mounted && state.hasCustomApiKey) return true;
    final remaining = await getRemainingQuota(isPremium);
    return remaining > 0;
  }

  Future<void> _incrementQuotaUsage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      final lastDate = prefs.getString(_prefKeyDate);
      int count = 0;
      if (lastDate == todayStr) {
        count = prefs.getInt(_prefKeyCount) ?? 0;
      }
      await prefs.setString(_prefKeyDate, todayStr);
      await prefs.setInt(_prefKeyCount, count + 1);
    } catch (_) {}
  }

  Future<bool> askQuestion(String question, {required bool isPremium}) async {
    final query = question.trim();
    if (query.isEmpty) return false;

    // Günlük kota kontrolü
    final allowed = await canAskQuestion(isPremium);
    if (!allowed) {
      state = state.copyWith(
        errorMessage: 'Günlük ücretsiz 5 soru limitinize ulaştınız. Yarın tekrar sorabilir veya Ayarlar\'dan kendi ücretsiz Gemini API anahtarınızı ekleyebilirsiniz.',
      );
      return false;
    }

    // Önceki sohbet geçmişini kaydet (mevcut soruyu API'ye mükerrer göndermemek için)
    final previousHistory = List<AiMessage>.from(state.messages);

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
      aiReply = await _callGeminiApi(query, activeKey, history: previousHistory);
    }

    // 2. Canlı API anahtarı yoksa, ağ hatası alındıysa veya yanıt gelmediyse
    // dahili İslami ilmihal, tefsir ve manevi rehberlik motoru devreye girer.
    aiReply ??= _generateIntelligentIslamicReply(query);

    state = state.copyWith(
      messages: [...state.messages, aiReply],
      isThinking: false,
    );

    return true;
  }

  AiMessage _generateIntelligentIslamicReply(String query) {
    final q = query.toLowerCase().trim();

    // 1. Namaz Borçları ve Kaza Namazı
    if (q.contains('kaza') || q.contains('borc') || q.contains('borç')) {
      return AiMessage(
        id: 'ai_ans_${DateTime.now().millisecondsSinceEpoch}',
        text: '### Kaza Namazları ve Borçların İfası\n\n'
            'Geçmişte kılınamayan farz namazların ve vitir namazının kazası farzdır. '
            'Sünnet namazların (sabah namazının sünneti o günün öğle vaktine kadar hariç) kazası kılınmaz.\n\n'
            '**Kaza Namazına Nasıl Niyet Edilir?**\n'
            '• "Niyet ettim Allah rızası için, üzerimde borç olan ilk (veya son) kazaya kalmış sabah / öğle / ikindi / akşam / yatsı namazının farzını kılmaya."\n'
            '• Vitir namazı için: "Üzerimde borç olan ilk vitir namazının vacibini kılmaya."\n\n'
            '**Tavsiye Edilen Kılınış Düzeni:**\n'
            'Her vakit namazının ardından o vaktin bir kaza namazını kılmak (örn: Öğle namazından sonra 4 rekat öğle kazası) '
            'düzenli ve aksatmadan borçları eritmenin en kolay ve mübarek yoludur.\n\n'
            'Kaza namazı kılınırken kamet getirmek sünnettir; peş peşe kılınacaksa tek kamet de yeterlidir.',
        isUser: false,
        timestamp: DateTime.now(),
        references: const [
          'Sahih-i Müslim, Mesâcid 314: "Kim bir namazı unutur veya uykuda kalırsa, hatırladığı vakit onu kılsın."',
          'Diyanet İşleri Başkanlığı Din İşleri Yüksek Kurulu Kaza Namazı Fetvası',
        ],
        suggestedFollowUps: const [
          'Sehiv secdesi hangi durumlarda gerekir?',
          'Kaza namazı hangi vakitlerde kılınmaz?',
        ],
      );
    }

    // 2. Sehiv Secdesi (Yanılma Secdesi)
    if (q.contains('sehiv') || q.contains('yanilma') || q.contains('yanılma')) {
      return AiMessage(
        id: 'ai_ans_${DateTime.now().millisecondsSinceEpoch}',
        text: '### Sehiv Secdesi Nedir ve Nasıl Yapılır?\n\n'
            'Sehiv secdesi, namazın rükünlerinden (farzlarından) birinin unutularak geciktirilmesi '
            'veya vaciplerinden birinin unutularak terk edilmesi ya da geciktirilmesi halinde yapılan telafi secdesidir.\n\n'
            '**Sehiv Secdesinin Yapılışı:**\n'
            '1. Son oturuşta sadece **Ettehiyyâtü** duası okunur.\n'
            '2. Yalnızca **sağ tarafa selâm** verilir.\n'
            '3. "Allâhu Ekber" diyerek peş peşe **iki defa secdeye** gidilir; secdelerde üçer kez "Sübhâne Rabbiye\'l-a\'lâ" denir.\n'
            '4. İkinci secdeden kalkıp tekrar oturulur; **Ettehiyyâtü, Allâhümme Salli, Allâhümme Bârik ve Rabbenâ** duaları okunur.\n'
            '5. Önce sağa, sonra sola selâm verilerek namaz tamamlanır.',
        isUser: false,
        timestamp: DateTime.now(),
        references: const [
          'Sahih-i Buhârî, Sehv 1: "Sizden biri namazında şüpheye düşerse doğruyu araştırsın ve namazını tamamlasın; sonra selâm verip iki secde yapsın."',
          'Diyanet İslam İlmihali, İbadetler Bölümü',
        ],
        suggestedFollowUps: const [
          'Fatiha\'dan sonra zammı sure unutulursa ne yapılır?',
          'Namazda rekat sayısı unutulursa ne yapılmalıdır?',
        ],
      );
    }

    // 3. Abdest ve Gusül
    if (q.contains('abdest') || q.contains('gusul') || q.contains('gusül') || q.contains('boy abdesti') || q.contains('teyemmum') || q.contains('teyemmüm')) {
      return AiMessage(
        id: 'ai_ans_${DateTime.now().millisecondsSinceEpoch}',
        text: '### Abdest ve Guslün Hükümleri\n\n'
            '**Namaz Abdestinin 4 Farzı (Mâide Suresi, 6. Ayet):**\n'
            '1. Yüzü bir defa yıkamak.\n'
            '2. Kolları dirseklerle beraber yıkamak.\n'
            '3. Başın en az dörtte birini ıslak elle mesh etmek.\n'
            '4. Ayakları topuklarla beraber yıkamak.\n\n'
            '**Gusül (Boy Abdesti) Farzları:**\n'
            '1. Ağza bol su alıp boğaza kadar çalkalamak (Mazmaza).\n'
            '2. Burna genze kadar su çekip temizlemek (İstinşak).\n'
            '3. Bütün vücudu iğne ucu kadar kuru yer kalmayacak şekilde yıkamak.\n\n'
            '**Abdesti Bozan Başlıca Durumlar:**\n'
            'Ön ve arkadan çıkan her türlü şey (idrar, gaz vb.), vücuttan kan veya cerahat akması, '
            'ağız dolusu kusmak, yan yatarak veya dayanarak uyumak ve namazda sesli gülmek.',
        isUser: false,
        timestamp: DateTime.now(),
        references: const [
          'Kur\'an-ı Kerim, Mâide Suresi 6. Ayet',
          'Sahih-i Müslim, Tahâret 1',
        ],
        suggestedFollowUps: const [
          'Mest üzerine mesh nasıl yapılır?',
          'Gusülde niyet şart mıdır?',
        ],
      );
    }

    // 4. Oruç ve Ramazan
    if (q.contains('oruc') || q.contains('oruç') || q.contains('ramazan') || q.contains('sahur') || q.contains('iftar') || q.contains('kefaret')) {
      return AiMessage(
        id: 'ai_ans_${DateTime.now().millisecondsSinceEpoch}',
        text: '### Oruç, Kaza ve Kefaret Hükümleri\n\n'
            '**Orucu Bozmayan Haller:**\n'
            '• Unutarak bir şey yemek veya içmek (hatırlayınca hemen bırakıp ağzı çalkalamak şartıyla oruç bozulmaz; Peygamberimiz "Allah ona yedirip içirmiştir" buyurmuştur).\n'
            '• Koku koklamak, göze damla damlatmak.\n'
            '• Boğaza su kaçırmamak şartıyla duş almak veya serinlemek.\n'
            '• Diş fırçalamak (macun yutulmadığı takdirde).\n\n'
            '**Yalnızca Kazayı Gerektirenler:**\n'
            'Hata ile boğaza su kaçması, besleyici olmayan şeylerin yutulması, ilaç kullanmak veya iğne yaptırmak.\n\n'
            '**Kefareti (60 Gün Kesintisiz + 1 Gün Kaza) Gerektirenler:**\n'
            'Ramazan orucunu mazeretsiz, bilerek ve kasten yiyip içmek veya cinsi münasebette bulunmak.',
        isUser: false,
        timestamp: DateTime.now(),
        references: const [
          'Bakara Suresi 183-187. Ayetler',
          'Sahih-i Buhârî, Savm 26',
        ],
        suggestedFollowUps: const [
          'Fidye kimlere verilir ve miktarı nedir?',
          'İğne yaptırmak orucu bozar mı?',
        ],
      );
    }

    // 5. Zekat, Fitre ve Sadaka
    if (q.contains('zekat') || q.contains('zekât') || q.contains('fitre') || q.contains('sadaka') || q.contains('nisap')) {
      return AiMessage(
        id: 'ai_ans_${DateTime.now().millisecondsSinceEpoch}',
        text: '### Zekât ve Sadaka Ölçüleri\n\n'
            '**Zekât Kimlere Farzdır?**\n'
            'Asli ihtiyaçları ve borçları dışında **nisap miktarı** (80.18 gram altın veya buna denk para/ticaret malı) '
            'mala sahip olan ve bu malın üzerinden **bir kameri yıl (354 gün)** geçen her hür ve baliğ Müslümana farzdır.\n\n'
            '**Oran ve Hesaplama:**\n'
            'Nakit para, altın, gümüş ve ticaret mallarında oran **%2.5 (1/40)** olarak verilir.\n\n'
            '**Kimlere Verilir?**\n'
            'Fakirlere, yoksullara (miskinlere), borçlulara, yolda kalmış muhtaçlara verilir (Tevbe Suresi 60. Ayet).\n\n'
            '**Kimlere Verilmez?**\n'
            'Kişinin bakmakla yükümlü olduğu usûl (anne, baba, dede, nine) ve fürûuna (evlat, torunlar), '
            'zengin kişilere ve eşine zekât verilmez.',
        isUser: false,
        timestamp: DateTime.now(),
        references: const [
          'Kur\'an-ı Kerim, Tevbe Suresi 60. Ayet',
          'Sahih-i Buhârî, Zekât 1',
        ],
        suggestedFollowUps: const [
          'Fitre (Sadaka-i Fıtır) ne zaman ve kime verilir?',
          'Altın ziynet eşyasının zekâtı nasıl hesaplanır?',
        ],
      );
    }

    // 6. Vesvese, Nazar, Korku ve Manevi Korunma
    if (q.contains('vesvese') || q.contains('nazar') || q.contains('korku') || q.contains('huzur') || q.contains('felak') || q.contains('nas')) {
      return AiMessage(
        id: 'ai_ans_${DateTime.now().millisecondsSinceEpoch}',
        text: '### Vesvese, Nazar ve Manevi Korunma\n\n'
            '**Vesvese Geldiğinde Ne Yapılmalıdır?**\n'
            'Vesvese, şeytanın ve nefsin kalbe attığı şüphe ve kuruntudur. '
            'Peygamber Efendimiz (s.a.v.) kalbe vesvese geldiğinde üzerinde durulmamasını, '
            '**"Âmentü billâhi ve rusulih"** *(Allah\'a ve O\'nun peygamberlerine iman ettim)* '
            'denilerek Eûzü-Besmele çekilmesini ve zikre devam edilmesini öğütlemiştir.\n\n'
            '**Nazara ve Şerre Karşı En Güçlü Manevi Kalkanlar:**\n'
            '• **Âyetü\'l-Kürsî:** Yatağa girerken ve namazlardan sonra okunduğunda sabaha kadar Allah\'ın koruması altına alır.\n'
            '• **Muavvizeteyn (Felak & Nâs Sureleri) ve İhlâs:** Sabah ve akşam üçer defa okunması her türlü şerden muhafaza eder.\n'
            '• **Peygamberimizin Şifa Duası:**\n'
            '*"Eûzü bi-kelimâtillâhi\'t-tâmmâti min külli şeytânin ve hâmmetin ve min külli aynin lâmmeh."*\n'
            '*(Her türlü şeytandan, zararlı haşarattan ve kem gözlerden Allah\'ın tastamam kelimelerine sığınırım.)*',
        isUser: false,
        timestamp: DateTime.now(),
        references: const [
          'Sahih-i Müslim, Îmân 212',
          'Sahih-i Buhârî, Tıbb 38 (Muavvizeteyn ve Nazar)',
        ],
        suggestedFollowUps: const [
          'Âyetü\'l-Kürsî\'nin faziletleri nelerdir?',
          'İstihare namazı ve duası nasıl yapılır?',
        ],
      );
    }

    // 7. Dinler Tarihi ve İslam'ın Diğer Dinlere Bakışı
    if (q.contains('dinler') || q.contains('hristiyan') || q.contains('yahudi') || q.contains('incil') || q.contains('tevrat') || q.contains('peygamber')) {
      return AiMessage(
        id: 'ai_ans_${DateTime.now().millisecondsSinceEpoch}',
        text: '### İslam\'ın Diğer Semavi Dinlere ve Peygamberlere Bakışı\n\n'
            'İslam inancına göre Hz. Âdem\'den Hz. Muhammed (s.a.v.)\'e kadar gönderilen bütün peygamberler '
            'aynı tevhid davasını tebliğ etmişlerdir. Bir Müslüman, Hz. İbrahim, Hz. Musa ve Hz. İsa (aleyhimüsselâm) '
            'dahil olmak üzere bütün peygamberlere ve onlara vahyedilen kitapların asıllarına iman etmekle mükelleftir (Bakara, 285).\n\n'
            '**Temel Fark ve Kur\'an-ı Kerim\'in Konumu:**\n'
            '• Kur\'an-ı Kerim, önceki ilahi mesajları tasdik edici ve kemale erdirici son ilahi vahiydir.\n'
            '• İslam, Ehl-i Kitap ile adalet, nezaket ve güzel ahlak çerçevesinde bir arada yaşamayı emreder '
            '*(Ankebût Suresi, 46. Ayet)*.\n'
            '• İslam dini din ve vicdan özgürlüğünü esas alır: *"Dinde zorlama yoktur; artık hak ile batıl apaçık ayrılmıştır."* (Bakara, 256).',
        isUser: false,
        timestamp: DateTime.now(),
        references: const [
          'Kur\'an-ı Kerim, Bakara Suresi 136 ve 285. Ayetler',
          'Kur\'an-ı Kerim, Ankebût Suresi 46. Ayet',
        ],
        suggestedFollowUps: const [
          'Peygamberlere iman İslam\'da ne anlama gelir?',
          'İslam\'da din ve vicdan hürriyetinin sınırları nelerdir?',
        ],
      );
    }

    // 8. Genel İslami Rehberlik ve Hikmet Yanıtı
    return AiMessage(
      id: 'ai_ans_${DateTime.now().millisecondsSinceEpoch}',
      text: '### Beyân Manevi Rehber & İslami Rehberlik\n\n'
          'Sorunuz Kur\'an-ı Kerim, Sahih Sünnet ve İslam âlimlerinin icmâı ışığında şu hikmetlerle aydınlatılır:\n\n'
          'İslam dini kolaylık, itidal, merhamet ve güzel ahlak dinidir. Peygamber Efendimiz (s.a.v.) buyurmuştur ki: '
          '*"Kolaylaştırınız, zorlaştırmayınız; müjdeleyiniz, nefret ettirmeyiniz."* (Buhârî, İlim 11).\n\n'
          '• **Ameller Niyetlere Göredir:** Yaptığınız her ibadetin ve salih amelin temeli kalbin ihlasında yatar.\n'
          '• **Dua ve Zikrin Gücü:** Kul Rabbine en yakın olduğu an secde anıdır; sıkıntılarınızda sabır ve namaz ile Allah\'tan yardım isteyiniz (Bakara, 153).\n'
          '• **İlmihal Ölçüsü:** Şüpheli konularda kalbin mutmain olacağı helal dairesinde kalmak ve güvenilir kaynaklardan ilim tahsil etmek müminin şiarıdır.\n\n'
          'Daha detaylı ve hususi bir fıkhi mesele sormak isterseniz; namaz, oruç, abdest veya kaza gibi spesifik konuyu yazabilirsiniz.',
      isUser: false,
      timestamp: DateTime.now(),
      references: const [
        'Kur\'an-ı Kerim, Bakara Suresi 153. Ayet: "Ey iman edenler! Sabır ve namaz ile Allah\'tan yardım isteyin."',
        'Sahih-i Buhârî, Bed\'ü\'l-Vahy 1: "Ameller ancak niyetlere göredir."',
      ],
      suggestedFollowUps: const [
        'Sabah namazının sünneti ve farzı nasıl kılınır?',
        'Tevbe duası (Seyyidü\'l-İstiğfar) nasıl yapılır?',
      ],
    );
  }

  Future<AiMessage?> _callGeminiApi(
    String query,
    String apiKey, {
    List<AiMessage> history = const [],
  }) async {
    final candidateModels = ['gemini-2.5-flash', 'gemini-2.0-flash', 'gemini-1.5-flash'];

    // Son konuşma geçmişini Gemini çoklu tur sohbet formatında hazırla (hata mesajlarını hariç tut)
    final contents = <Map<String, dynamic>>[];
    final validHistory = history
        .where((m) =>
            m.id != 'welcome_1' &&
            !m.id.startsWith('ai_fallback_') &&
            !m.id.startsWith('ai_nokey_'))
        .toList();
    final takeCount = validHistory.length > 8 ? 8 : validHistory.length;
    final recent = validHistory.sublist(validHistory.length - takeCount);

    // Eğer geçmişin son mesajı zaten mevcut soruyla aynıysa mükerrer eklemeyi engelle
    if (recent.isNotEmpty && recent.last.isUser && recent.last.text.trim() == query.trim()) {
      recent.removeLast();
    }

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
        'temperature': 0.2,
        'maxOutputTokens': 800,
        'thinkingConfig': {
          'thinkingBudget': 0,
        },
      },
    });

    for (final modelName in candidateModels) {
      HttpClient? client;
      try {
        client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent',
        );
        final request = await client.postUrl(url);
        request.headers.contentType = ContentType.json;
        request.headers.set('x-goog-api-key', apiKey);
        request.write(body);
        final response = await request.close().timeout(const Duration(seconds: 25));

        if (response.statusCode == 200) {
          final responseBody = await response
              .transform(utf8.decoder)
              .join()
              .timeout(const Duration(seconds: 25));
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

}

final aiAssistantProvider =
    StateNotifierProvider<AiAssistantNotifier, AiAssistantState>((ref) {
  return AiAssistantNotifier();
});
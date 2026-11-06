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
  static const int freeDailyLimit = 3;

  static const _secureStorage = FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
    aOptions: AndroidOptions(resetOnError: true),
  );

  AiAssistantNotifier()
      : super(const AiAssistantState(
            remainingQuestions: freeDailyLimit, dailyLimit: freeDailyLimit)) {
    _loadInitialState();
  }

  Future<void> refreshQuota(bool isPremium) async {
    final remaining = await getRemainingQuota(isPremium);
    state = state.copyWith(
      remainingQuestions: remaining,
      dailyLimit: isPremium ? 999 : freeDailyLimit,
    );
  }

  Future<void> _loadInitialState() async {
    String? savedApiKey;
    try {
      savedApiKey = await _secureStorage.read(key: _prefKeyGeminiKey);
    } catch (_) {}

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

    if (!mounted) return;

    state = state.copyWith(
      messages: const [],
      remainingQuestions: remaining,
      dailyLimit: freeDailyLimit,
      geminiApiKey: savedApiKey,
    );
  }

  void resetChat() {
    state = state.copyWith(messages: const []);
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
    if (isPremium) return 999;
    if (mounted && state.hasCustomApiKey) {
      return 999;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      final lastDate = prefs.getString(_prefKeyDate);
      if (lastDate != todayStr) {
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

  /// Ödüllü video izleme karşılığı bonus soru hakkı tanımlar
  Future<void> grantBonusQuestions(int bonusCount) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      final lastDate = prefs.getString(_prefKeyDate);
      int count = 0;
      if (lastDate == todayStr) {
        count = prefs.getInt(_prefKeyCount) ?? 0;
      }
      final newCount = (count - bonusCount).clamp(0, 999);
      await prefs.setString(_prefKeyDate, todayStr);
      await prefs.setInt(_prefKeyCount, newCount);

      final newRemaining = freeDailyLimit - newCount;
      state = state.copyWith(
        remainingQuestions: newRemaining > 0 ? newRemaining : 0,
        clearError: true,
      );
    } catch (_) {}
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

    final allowed = await canAskQuestion(isPremium);
    if (!allowed) {
      state = state.copyWith(
        errorMessage: 'Günlük 3 ücretsiz soru hakkınız tamamlandı. Soru sınırını tamamen kaldırmak için Beyân Pro\'ya geçebilirsiniz.',
      );
      return false;
    }

    final previousHistory = List<AiMessage>.from(state.messages);

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

    AiMessage? aiReply;
    final activeKey = state.effectiveApiKey;
    if (activeKey != null && activeKey.isNotEmpty) {
      aiReply = await _callGeminiApi(query, activeKey, history: previousHistory);
    }

    aiReply ??= _generateIntelligentIslamicReply(query);

    state = state.copyWith(
      messages: [...state.messages, aiReply],
      isThinking: false,
    );

    return true;
  }

  static String _cleanRawMarkdown(String text) {
    var s = text;
    s = s.replaceAll(RegExp(r'^#{1,6}\s*', multiLine: true), '');
    s = s.replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1');
    s = s.replaceAll(RegExp(r'\*([^*]+)\*'), r'$1');
    return s.trim();
  }

  static String _normalizeQuery(String text) {
    var s = text.toLowerCase().trim();
    s = s.replaceAll('ı', 'i')
         .replaceAll('ğ', 'g')
         .replaceAll('ü', 'u')
         .replaceAll('ş', 's')
         .replaceAll('ö', 'o')
         .replaceAll('ç', 'c')
         .replaceAll('â', 'a')
         .replaceAll('î', 'i')
         .replaceAll('û', 'u');
    return s;
  }

  AiMessage _generateIntelligentIslamicReply(String query) {
    final raw = query.trim();
    final q = _normalizeQuery(raw);

    // ── 1. Hz. Âdem (a.s.) Vefatı, Yaşı ve Hayatı ─────────────────────
    if (q.contains('adem')) {
      if (q.contains('olum') || q.contains('oldu') || q.contains('vefat') ||
          q.contains('yil') || q.contains('yas') || q.contains('tarih')) {
        return AiMessage(
          id: 'ai_ans_${DateTime.now().millisecondsSinceEpoch}',
          text: 'Hz. Âdem\'in (a.s.) Vefatı ve Yaşı Hakkında İslami Kaynaklar:\n\n'
              'Hz. Âdem (a.s.) için miladi veya hicri kesin bir takvim yılı (tarih) zikretmek mümkün değildir; '
              'zira o devirde insanlık tarafından kullanılan yazılı bir takvim ve milat sistemi bulunmamaktaydı.\n\n'
              'Ancak Sahih Sünnet, muteber tefsirler ve İslam tarihi kaynaklarında (İbn Kesir el-Bidâye ve\'n-Nihâye, Taberî) '
              'Hz. Âdem\'in vefatı hakkında şu sahih bilgiler nakledilir:\n\n'
              '• Ömrü ve Yaşı: Muteber rivayetlerde Hz. Âdem\'in yaklaşık 930 ile 1000 yıl arasında yaşadığı belirtilmektedir. '
              'Tirmizî\'de geçen sahih bir hadis rivayetine göre Hz. Âdem\'e 1000 yıl ömür takdir edilmiş, bunun bir kısmını zürriyetinden Hz. Davud\'a bağışlamıştır.\n\n'
              '• Vefat Ettiği Gün: Peygamber Efendimiz (s.a.v.) buyurmuştur ki: "Üzerine güneşin doğduğu en hayırlı gün cuma günüdür; Âdem o gün yaratılmış, o gün yeryüzüne indirilmiş, tövbesi o gün kabul edilmiş ve o gün vefat etmiştir." (Müslim, Cuma 18).\n\n'
              '• Cenazesi ve Defni: Hz. Âdem vefat ettiğinde melekler cennetten getirdikleri kefen ve kokularla cenazesini yıkamış, kefenlemiş, '
              'cenaze namazını oğlu Hz. Şit (a.s.) kıldırmış ve kabre konulmuştur. Melekler insanlığa: "Ey Âdemoğulları! İşte ölülerinizin techiz ve tekfin sünneti böyledir" buyurmuşlardır.',
          isUser: false,
          timestamp: DateTime.now(),
          references: const [
            'Sahih-i Müslim, Cuma 18 (Hadis no: 854)',
            'Tirmizî, Tefsîru\'l-Kur\'ân 7 (Hadis no: 3076)',
            'İbn Kesir, el-Bidâye ve\'n-Nihâye, Cilt 1, Hz. Âdem\'in Vefatı',
            'Taberî Tarihi, Cilt 1',
          ],
          suggestedFollowUps: const [
            'Hz. Âdem cennetten nasıl ve niçin indirilmiştir?',
            'Hz. Âdem\'in tevbesi Kur\'an\'da nasıl anlatılır?',
            'İlk insan ve peygamber olarak Hz. Âdem\'in fazileti nedir?',
          ],
        );
      }

      return AiMessage(
        id: 'ai_ans_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Hz. Âdem (a.s.) İlk İnsan ve İlk Peygamberdir:\n\n'
            'Kur\'an-ı Kerim\'e göre Allah Teâlâ Hz. Âdem\'i topraktan (salsâl ve tîn-i lâzib) yaratmış, '
            'kendi ruhundan üflemiş ve ona bütün varlıkların isimlerini (esmâyı) öğretmiştir (Bakara Suresi, 31).\n\n'
            '• İmtihan ve Tövbe: Cennette yasaklanan ağaçtan yedikten sonra şeytanın aldatmasıyla yeryüzüne indirilmiş, '
            'ancak Rabbinden vahiy ve kelimeler alarak tövbe etmiş ve tövbesi kabul buyrulmuştur: "Rabbimiz! Biz kendimize zulmettik. Eğer bizi bağışlamaz ve bize merhamet etmezsen elbette hüsrana uğrayanlardan oluruz." (A\'râf Suresi, 23).\n\n'
            '• Peygamberliği: Hz. Âdem hem insanlığın atası hem de yeryüzündeki ilk peygamber ve ilk tevhîd tebliğcisidir.',
        isUser: false,
        timestamp: DateTime.now(),
        references: const [
          'Kur\'an-ı Kerim, Bakara Suresi 30-38. Ayetler',
          'Kur\'an-ı Kerim, A\'râf Suresi 19-25. Ayetler',
        ],
        suggestedFollowUps: const [
          'Hz. Âdem kaç yıl yaşamış ve ne zaman vefat etmiştir?',
          'Hz. Şit ve Hz. İdris peygamberlerin hayatı nasıldır?',
        ],
      );
    }

    // ── 2. Peygamber Efendimiz Hz. Muhammed (s.a.v.) ─────────────────
    if (q.contains('muhammed') || q.contains('peygamber efendimiz') || q.contains('resulullah') ||
        (q.contains('peygamber') && (q.contains('dogum') || q.contains('vefat') || q.contains('hayat') || q.contains('kac yas')))) {
      return AiMessage(
        id: 'ai_ans_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Peygamber Efendimiz Hz. Muhammed Mustafa (s.a.v.):\n\n'
            '• Doğumu: 20 Nisan 571 (12 Rebiülevvel) Pazartesi sabahı Mekke-i Mükerreme\'de dünyaya teşrif etmiştir.\n'
            '• Risalet (Peygamberlik): 40 yaşında (610 Miladi) Ramazan ayında Hira Mağarası\'nda Cebrail (a.s.) vasıtasıyla Alak Suresi\'nin ilk 5 ayeti vahyedilerek peygamberlikle müjdelenmiştir.\n'
            '• Hicret: 622 yılında Mekke\'den Medine\'ye hicret etmiş, İslam Devleti ve Medine Sözleşmesi tesis edilmiştir.\n'
            '• Vefatı: 8 Haziran 632 (12 Rebiülevvel 11 Hicri) Pazartesi günü 63 yaşında Medine-i Münevvere\'de refik-i a\'lâya irtihal eylemiştir. Kabr-i şerifleri Mescid-i Nebevi\'de Hücre-i Saadet\'tedir.',
        isUser: false,
        timestamp: DateTime.now(),
        references: const [
          'Kur\'an-ı Kerim, Ahzâb Suresi 40. Ayet: "Muhammed Allah\'ın Resûlü ve peygamberlerin sonuncusudur."',
          'Sahih-i Buhârî ve Sahih-i Müslim Siyer Kaynakları',
        ],
        suggestedFollowUps: const [
          'Veda Hutbesi\'nin ana mesajları nelerdir?',
          'Peygamber Efendimiz\'in sünnetlerine uymanın fazileti nedir?',
        ],
      );
    }

    // ── 3. Diğer Ulû\'l-Azm Peygamberler ──────────────────────────────
    if (q.contains('nuh') || q.contains('tufan') || q.contains('ibrahim') || q.contains('musa') ||
        q.contains('isa') || q.contains('yusuf') || q.contains('yunus') || q.contains('eyyub')) {
      return AiMessage(
        id: 'ai_ans_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Kur\'an-ı Kerim\'de Bildirilen Mübarek Peygamberler:\n\n'
            'İslam akidesine göre bütün peygamberler Allah tarafından insanlığa tevhid inancını tebliğ etmek üzere gönderilmiş hak elçilerdir (Bakara, 285):\n\n'
            '• Hz. Nuh (a.s.): 950 sene kavmini tevhide davet etmiş (Ankebût, 14), tufan ile inananlar gemide necat bulmuştur.\n'
            '• Hz. İbrahim (a.s.): Halîlullah\'tır; Nemrud\'un ateşi ona gül bahçesi olmuş, Kâbe-i Muazzama\'yı oğlu Hz. İsmail ile inşa etmiştir.\n'
            '• Hz. Musa (a.s.): Kelîmullah\'tır; Firavun zulmüne karşı Kızıldeniz mucizesiyle kavmini kurtarmış ve Tevrat kendisine indirilmiştir.\n'
            '• Hz. İsa (a.s.): Rûhullah\'tır; Hz. Meryem\'den babasız olarak mucizevi biçimde dünyaya gelmiş, semaya yükseltilmiştir (Nisa, 157-158).\n'
            '• Hz. Yusuf (a.s.): Ahsenü\'l-Kasas (kıssaların en güzeli) sahibi, sabır, iffet ve tevekkül timsalidir.',
        isUser: false,
        timestamp: DateTime.now(),
        references: const [
          'Kur\'an-ı Kerim, Bakara Suresi 285. Ayet',
          'Kur\'an-ı Kerim, Enbiyâ Suresi',
          'Kur\'an-ı Kerim, Yûsuf Suresi',
        ],
        suggestedFollowUps: const [
          'Hz. Yunus\'un balığın karnındaki duası nedir?',
          'Hz. Eyyub\'un şifa ve sabır duası nasıldır?',
        ],
      );
    }

    // ── 4. Kabir, Ölüm, Ahiret ve Cennet-Cehennem ───────────────────
    if (q.contains('olum') || q.contains('kabir') || q.contains('ahiret') ||
        q.contains('cennet') || q.contains('cehennem') || q.contains('kiyamet') ||
        q.contains('munker') || q.contains('sual') || q.contains('azap')) {
      return AiMessage(
        id: 'ai_ans_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Ölüm, Kabir Hayatı (Berzah) ve Ahiret İnancı:\n\n'
            'Ölüm bir yok oluş değil, fani dünyadan ebedi ahiret yurduna geçiş köprüsüdür. '
            'Kur\'an-ı Kerim\'de: "Her nefis ölümü tadacaktır; sonra bize döndürüleceksiniz." (Ankebût, 57) buyrulur.\n\n'
            '• Kabir ve Münker-Nekir Sualleri: Vefat eden kimseye kabirde Münker ve Nekir melekleri: "Rabbin kim? Dinin ne? Peygamberin kim?" suallerini tevcih ederler. İman ve salih amel sahibi kimse bu suallere sükunetle cevap verir ve kabri cennet bahçelerinden bir bahçe olur.\n\n'
            '• Kıyamet ve Diriliş (Ba\'s): İsrafil\'in (a.s.) Sûr\'a üflemesiyle bütün mahlukat diriltilip Mahşer meydanında toplanır.\n\n'
            '• Mizan ve Sırat: İyilikler ve kötülükler hassas adalet mizanında tartılır; Sırat köprüsünden geçilerek cennet veya cehennem menziline varılır.',
        isUser: false,
        timestamp: DateTime.now(),
        references: const [
          'Kur\'an-ı Kerim, Âl-i İmrân Suresi 185. Ayet',
          'Kur\'an-ı Kerim, Ankebût Suresi 57. Ayet',
          'Tirmizî, Cenâiz 70 (Kabir suali ve berzah hadisi)',
        ],
        suggestedFollowUps: const [
          'Kabir azabından korunmak için hangi sure okunur (Mülk Suresi)?',
          'Vefat eden yakınlarımız için ne yapabiliriz?',
        ],
      );
    }

    // ── 5. Kaza Namazları ve Borçlar ─────────────────────────────────
    if (q.contains('kaza') || q.contains('borc')) {
      return AiMessage(
        id: 'ai_ans_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Kaza Namazları ve Borçların İfası:\n\n'
            'Geçmişte kılınamayan farz namazların ve vitir namazının kazası farzdır. '
            'Sünnet namazların (sabah namazının sünneti o günün öğle vaktine kadar hariç) kazası kılınmaz.\n\n'
            'Kaza Namazına Nasıl Niyet Edilir?\n'
            '• "Niyet ettim Allah rızası için, üzerimde borç olan ilk (veya son) kazaya kalmış sabah / öğle / ikindi / akşam / yatsı namazının farzını kılmaya."\n'
            '• Vitir namazı için: "Üzerimde borç olan ilk vitir namazının vacibini kılmaya."\n\n'
            'Tavsiye Edilen Kılınış Düzeni:\n'
            'Her vakit namazının ardından o vaktin bir kaza namazını kılmak (örneğin öğle namazından sonra 4 rekat öğle kazası) '
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
          'Kaza namazı hangi vakitlerde (kerahat) kılınmaz?',
        ],
      );
    }

    // ── 6. Sehiv Secdesi (Yanılma Secdesi) ───────────────────────────
    if (q.contains('sehiv') || q.contains('yanilma')) {
      return AiMessage(
        id: 'ai_ans_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Sehiv Secdesi Nedir ve Nasıl Yapılır?\n\n'
            'Sehiv secdesi, namazın rükünlerinden (farzlarından) birinin unutularak geciktirilmesi '
            'veya vaciplerinden birinin unutularak terk edilmesi ya da geciktirilmesi halinde yapılan telafi secdesidir.\n\n'
            'Sehiv Secdesinin Yapılışı:\n'
            '1. Son oturuşta sadece Ettehiyyâtü duası okunur.\n'
            '2. Yalnızca sağ tarafa selâm verilir.\n'
            '3. "Allâhu Ekber" diyerek peş peşe iki defa secdeye gidilir; secdelerde üçer kez "Sübhâne Rabbiye\'l-a\'lâ" denir.\n'
            '4. İkinci secdeden kalkıp tekrar oturulur; Ettehiyyâtü, Allâhümme Salli, Allâhümme Bârik ve Rabbenâ duaları okunur.\n'
            '5. Önce sağa, sonra sola selâm verilerek namaz tamamlanır.',
        isUser: false,
        timestamp: DateTime.now(),
        references: const [
          'Sahih-i Buhârî, Sehv 1',
          'Diyanet İslam İlmihali, İbadetler Bölümü',
        ],
        suggestedFollowUps: const [
          'Fatiha\'dan sonra zammı sure unutulursa ne yapılır?',
          'Namazda rekat sayısı unutulursa ne yapılmalıdır?',
        ],
      );
    }

    // ── 7. Abdest ve Gusül (Boy Abdesti) ──────────────────────────────
    if (q.contains('abdest') || q.contains('gusul') || q.contains('boy abdesti') ||
        q.contains('teyemmum') || q.contains('hayiz') || q.contains('cunupluk')) {
      return AiMessage(
        id: 'ai_ans_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Abdest ve Guslün Hükümleri:\n\n'
            'Namaz Abdestinin 4 Farzı (Mâide Suresi, 6. Ayet):\n'
            '1. Yüzü bir defa yıkamak.\n'
            '2. Kolları dirseklerle beraber yıkamak.\n'
            '3. Başın en az dörtte birini ıslak elle mesh etmek.\n'
            '4. Ayakları topuklarla beraber yıkamak.\n\n'
            'Gusül (Boy Abdesti) Farzları:\n'
            '1. Ağza bol su alıp boğaza kadar çalkalamak (Mazmaza).\n'
            '2. Burna genze kadar su çekip temizlemek (İstinşak).\n'
            '3. Bütün vücudu iğne ucu kadar kuru yer kalmayacak şekilde yıkamak.\n\n'
            'Abdesti Bozan Başlıca Haller:\n'
            'Ön ve arkadan çıkan her türlü necaset, vücuttan kan veya cerahat akması, ağız dolusu kusmak, yan yatarak veya dayanarak uyumak ve namazda sesli gülmek.',
        isUser: false,
        timestamp: DateTime.now(),
        references: const [
          'Kur\'an-ı Kerim, Mâide Suresi 6. Ayet',
          'Sahih-i Müslim, Tahâret 1',
        ],
        suggestedFollowUps: const [
          'Mest üzerine mesh nasıl yapılır?',
          'Teyemmüm hangi şartlarda ve nasıl alınır?',
        ],
      );
    }

    // ── 8. Oruç, Ramazan, Sahur ve İftar ─────────────────────────────
    if (q.contains('oruc') || q.contains('ramazan') || q.contains('sahur') ||
        q.contains('iftar') || q.contains('kefaret') || q.contains('fidye')) {
      return AiMessage(
        id: 'ai_ans_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Oruç, Kaza ve Kefaret Hükümleri:\n\n'
            'Orucu Bozmayan Haller:\n'
            '• Unutarak bir şey yemek veya içmek (hatırlanınca hemen bırakıp ağzı çalkalamak şartıyla oruç bozulmaz; Efendimiz "Allah ona yedirip içirmiştir" buyurmuştur).\n'
            '• Koku koklamak, göze damla damlatmak.\n'
            '• Boğaza su kaçırmamak şartıyla duş almak veya serinlemek.\n'
            '• Diş fırçalamak (macun boğaza yutulmadığı takdirde).\n\n'
            'Yalnızca Kazayı Gerektirenler:\n'
            'Hata ile boğaza su kaçması, besleyici olmayan şeylerin yutulması, ilaç almak veya iğne yaptırmak.\n\n'
            'Kefareti (60 Gün Kesintisiz + 1 Gün Kaza) Gerektirenler:\n'
            'Ramazan orucunu mazeretsiz, bilerek ve kasten yiyip içmek veya cinsi münasebette bulunmak.',
        isUser: false,
        timestamp: DateTime.now(),
        references: const [
          'Kur\'an-ı Kerim, Bakara Suresi 183-187. Ayetler',
          'Sahih-i Buhârî, Savm 26',
        ],
        suggestedFollowUps: const [
          'Fidye kimlere verilir ve miktarı nedir?',
          'İğne yaptırmak orucu bozar mı?',
        ],
      );
    }

    // ── 9. Zekat, Fitre, Sadaka ve Kurban ────────────────────────────
    if (q.contains('zekat') || q.contains('fitre') || q.contains('sadaka') ||
        q.contains('nisap') || q.contains('kurban')) {
      return AiMessage(
        id: 'ai_ans_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Zekât, Sadaka ve Mali İbadetler:\n\n'
            'Zekât Kimlere Farzdır?\n'
            'Asli ihtiyaçları ve borçları dışında nisap miktarı (80.18 gram altın veya buna denk nakit para/ticaret malı) '
            'mala sahip olan ve bu malın üzerinden bir kameri yıl (354 gün) geçen her hür ve baliğ Müslümana farzdır.\n\n'
            'Oran ve Hesaplama:\n'
            'Nakit para, altın, gümüş ve ticaret mallarında oran %2.5 (1/40) olarak verilir.\n\n'
            'Kimlere Verilir?\n'
            'Fakirlere, yoksullara (miskinlere), borçlulara, yolda kalmış muhtaçlara verilir (Tevbe Suresi 60. Ayet).\n\n'
            'Kimlere Verilmez?\n'
            'Kişinin bakmakla yükümlü olduğu usûl (anne, baba, dede, nine) ve fürûuna (evlat, torunlar), eşine ve zengin kişilere zekât verilmez.',
        isUser: false,
        timestamp: DateTime.now(),
        references: const [
          'Kur\'an-ı Kerim, Tevbe Suresi 60. Ayet',
          'Sahih-i Buhârî, Zekât 1',
        ],
        suggestedFollowUps: const [
          'Fitre (Sadaka-i Fıtır) ne zaman ve kime verilir?',
          'Kurban kesmenin fıkhi hükümleri nelerdir?',
        ],
      );
    }

    // ── 10. Vesvese, Nazar, Manevi Korunma ve Şifa ───────────────────
    if (q.contains('vesvese') || q.contains('nazar') || q.contains('korku') ||
        q.contains('huzur') || q.contains('felak') || q.contains('nas') || q.contains('ayetel kursi')) {
      return AiMessage(
        id: 'ai_ans_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Vesvese, Nazar ve Manevi Korunma Yolları:\n\n'
            'Vesvese Geldiğinde Ne Yapılmalıdır?\n'
            'Vesvese şeytanın kalbe attığı kuruntudur. Peygamber Efendimiz (s.a.v.) kalbe vesvese geldiğinde üzerinde durulmamasını, '
            '"Âmentü billâhi ve rusulih" (Allah\'a ve peygamberlerine iman ettim) denilerek Eûzü-Besmele çekilmesini öğütlemiştir.\n\n'
            'Nazara ve Şerre Karşı En Güçlü Manevi Kalkanlar:\n'
            '• Âyetü\'l-Kürsî: Namazlardan sonra ve yatarken okunduğunda sabaha dek Allah\'ın hıfz ve himayesi altına alır.\n'
            '• Muavvizeteyn (Felak ve Nâs Sureleri) ve İhlâs: Sabah ve akşam üçer defa okunması her türlü şerden muhafaza eder.\n'
            '• Efendimiz\'in Şifa Duası: "Eûzü bi-kelimâtillâhi\'t-tâmmâti min külli şeytânin ve hâmmetin ve min külli aynin lâmmeh." (Her türlü şeytandan, zararlı mahluktan ve kem gözlerden Allah\'ın tastamam kelimelerine sığınırım).',
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

    // ── 11. Dinler Tarihi ve İslam\'ın Bakışı ──────────────────────────
    if (q.contains('dinler') || q.contains('hristiyan') || q.contains('yahudi') ||
        q.contains('incil') || q.contains('tevrat')) {
      return AiMessage(
        id: 'ai_ans_${DateTime.now().millisecondsSinceEpoch}',
        text: 'İslam\'ın Diğer Semavi Dinlere ve Peygamberlere Bakışı:\n\n'
            'İslam inancına göre Hz. Âdem\'den Hz. Muhammed (s.a.v.)\'e kadar gönderilen bütün peygamberler '
            'aynı tevhid davasını tebliğ etmişlerdir. Bir Müslüman; Hz. İbrahim, Hz. Musa ve Hz. İsa (aleyhimüsselâm) '
            'dahil olmak üzere bütün peygamberlere ve onlara vahyedilen kitapların asıllarına iman etmekle mükelleftir (Bakara, 285).\n\n'
            'Kur\'an-ı Kerim\'in Konumu:\n'
            '• Kur\'an-ı Kerim, önceki ilahi mesajları tasdik edici ve kemale erdirici son ilahi vahiydir.\n'
            '• İslam, Ehl-i Kitap ile adalet, nezaket ve güzel ahlak çerçevesinde bir arada yaşamayı emreder (Ankebût Suresi, 46. Ayet).\n'
            '• Din ve vicdan özgürlüğü esastır: "Dinde zorlama yoktur; artık hak ile batıl apaçık ayrılmıştır." (Bakara, 256).',
        isUser: false,
        timestamp: DateTime.now(),
        references: const [
          'Kur\'an-ı Kerim, Bakara Suresi 136 ve 285. Ayetler',
          'Kur\'an-ı Kerim, Ankebût Suresi 46. Ayet',
        ],
        suggestedFollowUps: const [
          'Peygamberlere iman İslam\'da ne anlama gelir?',
          'İslam\'da din ve vicdan hürriyeti nasıldır?',
        ],
      );
    }

    // ── 12. Kul Hakkı, Anne-Baba ve Ahlak ─────────────────────────────
    if (q.contains('kul hakki') || q.contains('anne') || q.contains('baba') ||
        q.contains('giybet') || q.contains('yalan') || q.contains('tovbe') || q.contains('tevbe')) {
      return AiMessage(
        id: 'ai_ans_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Kul Hakkı, Anne-Baba Rızası ve Tövbe Hükümleri:\n\n'
            '• Kul Hakkının Ağırlığı: Allah Teâlâ kendi hakkı olan günahları tövbe ile affedebilir; ancak kul hakkını, hak sahibi kul hakkından vazgeçmedikçe veya helalleşmedikçe bağışlamaz. Kul hakkına giren kimsenin dünyada helalleşmesi farzdır.\n\n'
            '• Anne-Baba Hakkı: Kur\'an-ı Kerim\'de Allah\'a ibadetten hemen sonra anne-babaya iyilik emredilmiştir: "Onlara \'öf\' bile deme, onları azarlama; ikisine de güzel ve tatlı söz söyle." (İsrâ Suresi, 23).\n\n'
            '• Samimi Tövbe (Tevbe-i Nasûh): Günahı hemen terk etmek, işlediğine pişman olmak, bir daha dönmemeye azmetmek ve varsa kul hakkını ödeyip helalleşmekle tamam olur.',
        isUser: false,
        timestamp: DateTime.now(),
        references: const [
          'Kur\'an-ı Kerim, İsrâ Suresi 23-24. Ayetler',
          'Sahih-i Buhârî, Mezâlim 10 (Kul hakkı ve helalleşme)',
          'Tirmizî, Daavât 88 (Seyyidü\'l-İstiğfar)',
        ],
        suggestedFollowUps: const [
          'Seyyidü\'l-İstiğfar (büyük tevbe) duası nasıldır?',
          'Gıybetten kurtulmak için ne yapılmalıdır?',
        ],
      );
    }

    // ── 13. Genel İslami Rehberlik ve Hikmet Yanıtı ───────────────────
    return AiMessage(
      id: 'ai_ans_${DateTime.now().millisecondsSinceEpoch}',
      text: 'Beyân Manevi Rehber & İslami Rehberlik:\n\n'
          'Sualiniz Kur\'an-ı Kerim, Sahih Sünnet ve muteber İslam âlimlerinin icmâı ışığında şu hikmetlerle aydınlatılır:\n\n'
          'İslam dini kolaylık, itidal, merhamet ve güzel ahlak dinidir. Peygamber Efendimiz (s.a.v.) buyurmuştur ki: '
          '"Kolaylaştırınız, zorlaştırmayınız; müjdeleyiniz, nefret ettirmeyiniz." (Buhârî, İlim 11).\n\n'
          '• Ameller Niyetlere Göredir: Yaptığınız her ibadetin ve salih amelin temeli kalbin ihlasında yatar.\n'
          '• Dua ve Zikrin Gücü: Kul Rabbine en yakın olduğu an secde anıdır; sıkıntılarınızda sabır ve namaz ile Allah\'tan yardım isteyiniz (Bakara, 153).\n'
          '• İlmihal Ölçüsü: Şüpheli konularda kalbin mutmain olacağı helal dairesinde kalmak ve güvenilir kaynaklardan ilim tahsil etmek müminin şiarıdır.\n\n'
          'Dilerseniz sorunuzu namaz, oruç, kaza, abdest, peygamberler tarihi veya günlük dualar şeklinde detaylandırarak da sorabilirsiniz.',
      isUser: false,
      timestamp: DateTime.now(),
      references: const [
        'Kur\'an-ı Kerim, Bakara Suresi 153. Ayet: "Sabır ve namaz ile Allah\'tan yardım isteyin."',
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
    final candidateModels = [
      'gemini-3.5-flash',
      'gemini-3.5-flash-lite',
      'gemini-3.7-flash',
      'gemini-3.8-flash',
      'gemini-flash-latest',
    ];

    final contents = <Map<String, dynamic>>[];
    final validHistory = history
        .where((m) =>
            m.id != 'welcome_1' &&
            !m.id.startsWith('ai_fallback_') &&
            !m.id.startsWith('ai_nokey_'))
        .toList();
    final takeCount = validHistory.length > 8 ? 8 : validHistory.length;
    final recent = validHistory.sublist(validHistory.length - takeCount);

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
                'İslam dini, dinler tarihi, Kur\'an-ı Kerim tefsiri, sahih hadisler, fıkıh, ibadetler ve peygamberler tarihinde derin ilim sahibisin. '
                'Ehl-i Sünnet vel-Cemaat ölçülerine ve Diyanet İşleri Başkanlığı\'nın muteber kaynaklarına bağlısın. '
                'Üslubun hürmetkar, hikmetli, açık ve sevgi doludur. '
                'Sorulan soruya doğrudan, net, doğru ve tatmin edici yanıt ver; soruyu saptırma. '
                'ÖNEMLİ BİÇİMLENDİRME KURALI: Yanıtlarında kesinlikle hiçbir markdown başlık işareti (###, ##, #) ve yıldız işareti (**) kullanma. '
                'Metinleri sade paragraflar ve okunaklı madde imleri (•) ile biçimlendir.'
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
          'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$apiKey',
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
                final cleanedText = _cleanRawMarkdown(replyText);
                return AiMessage(
                  id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
                  text: cleanedText,
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

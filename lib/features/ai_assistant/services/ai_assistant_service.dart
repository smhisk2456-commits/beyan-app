import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ai_message.dart';

class AiAssistantState {
  final List<AiMessage> messages;
  final bool isThinking;
  final int remainingQuestions;
  final int dailyLimit;
  final String? errorMessage;

  const AiAssistantState({
    this.messages = const [],
    this.isThinking = false,
    this.remainingQuestions = 3,
    this.dailyLimit = 3,
    this.errorMessage,
  });

  AiAssistantState copyWith({
    List<AiMessage>? messages,
    bool? isThinking,
    int? remainingQuestions,
    int? dailyLimit,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AiAssistantState(
      messages: messages ?? this.messages,
      isThinking: isThinking ?? this.isThinking,
      remainingQuestions: remainingQuestions ?? this.remainingQuestions,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AiAssistantNotifier extends StateNotifier<AiAssistantState> {
  static const String _prefKeyCount = 'beyan_ai_daily_count';
  static const String _prefKeyDate = 'beyan_ai_daily_date';
  static const int freeDailyLimit = 3;

  AiAssistantNotifier() : super(const AiAssistantState()) {
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final remaining = await getRemainingQuota(false);
    final welcomeMessage = AiMessage(
      id: 'welcome_1',
      text: 'Selâmün aleyküm ve rahmetullâhi ve berekâtüh.\n\n'
          'Ben **Beyân AI Manevi Rehber & Tefsir Asistanı**.\n'
          'Kur\'an-ı Kerim ayetleri, Sahih Sünnet ve muteber İslam kaynakları ışığında; '
          'namaz, oruç, dua, tefsir, fıkıh ve günlük manevi hayatınızla ilgili tüm sorularınızda '
          'size hürmet ve muhabbetle refakat etmek için buradayım.\n\n'
          'Aşağıdaki hazır konulardan birini seçebilir veya kalbinizdeki soruyu doğrudan yazabilirsiniz.',
      isUser: false,
      timestamp: DateTime.now(),
      references: const [
        'Nahl Suresi, 43. Ayet: "Eğer bilmiyorsanız ilim ehline sorun."',
        'Sahih-i Buhari & Müslim Muteber Kaynakları'
      ],
      suggestedFollowUps: const [
        'Kalp huzuru için hangi ayet ve dualar okunur?',
        'Sabah namazına nasıl daha dinç kalkabilirim?',
        'Kaza namazı borcu nasıl hesaplanır ve kılınır?',
        'Ayetel Kürsi\'nin fazileti ve tefsiri nedir?',
      ],
    );

    state = state.copyWith(
      messages: [welcomeMessage],
      remainingQuestions: remaining,
      dailyLimit: freeDailyLimit,
    );
  }

  Future<int> getRemainingQuota(bool isPremium) async {
    if (isPremium) return 999;
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      final lastDate = prefs.getString(_prefKeyDate);

      if (lastDate != todayStr) {
        await prefs.setString(_prefKeyDate, todayStr);
        await prefs.setInt(_prefKeyCount, 0);
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
    final remaining = await getRemainingQuota(false);
    return remaining > 0;
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

    if (!isPremium) {
      final remaining = await getRemainingQuota(false);
      if (remaining <= 0) {
        state = state.copyWith(
          errorMessage: 'Bugünkü 3 ücretsiz soru hakkınız doldu. Sınırsız Beyân AI danışmanlığı için Premium üyeliğe geçebilirsiniz.',
        );
        return false;
      }
    }

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

    if (!isPremium) {
      await _incrementQuotaUsage();
      final newRemaining = await getRemainingQuota(false);
      state = state.copyWith(remainingQuestions: newRemaining);
    }

    // Simulate thoughtful synthesis
    await Future.delayed(const Duration(milliseconds: 700));

    final aiReply = _generateIslamicAnswer(query);

    state = state.copyWith(
      messages: [...state.messages, aiReply],
      isThinking: false,
    );

    return true;
  }

  AiMessage _generateIslamicAnswer(String query) {
    final q = query.toLowerCase();

    // 1. Kalp Huzuru / Sıkıntı / Vesvese
    if (q.contains('huzur') || q.contains('sıkıntı') || q.contains('vesvese') || q.contains('ferah') || q.contains('dert')) {
      return AiMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        text: 'İç huzursuzluğu ve daralma anlarında Kur\'an-ı Kerim en büyük şifa ve sığınaktır.\n\n'
            '### 1. Şifa Ayeti (Rad Suresi, 28)\n'
            '*"Onlar, iman eden ve kalpleri Allah\'ı anmakla huzura kavuşan kimselerdir. Bilesiniz ki, kalpler ancak Allah\'ı zikretmekle mutmain olur (huzur bulur)."*\n\n'
            '### 2. Peygamber Efendimiz\'in (s.a.v) Sıkıntı Duası\n'
            '*"Lâ ilâhe illâ ente sübhâneke innî küntü mine\'z-zâlimîn."*\n'
            '*(Senden başka hiçbir ilah yoktur. Seni tenzih ederim. Gerçekten ben haksızlık edenlerden oldum. - Enbiya, 87)*\n\n'
            '### Manevi Tavsiyeler:\n'
            '• Günde en az 100 defa *"Estağfirullâhe\'l-Azîm"* çekmek kalpteki ağırlığı dağıtır.\n'
            '• İnşirah Suresi\'ni ("Elem neşrah leke sadrak") gün içinde 7 defa okumak göğüs darlığını ferahlatır.\n'
            '• Abdest tazeleyip iki rekat Hacet/Şükür namazı kılmak ruhu sükunete erdirir.',
        isUser: false,
        timestamp: DateTime.now(),
        references: const [
          'Rad Sûresi, 28. Âyet',
          'Enbiya Sûresi, 87. Âyet (Hz. Yunus\'un Duası)',
          'İnşirah Sûresi (1-8)',
          'Sahih-i Buhari, Deavat 27'
        ],
        suggestedFollowUps: const [
          'İnşirah Suresi\'nin meali ve fazileti nedir?',
          'Vesveseden korunmak için hangi sureler okunmalı?',
          'Teheccüd namazı ile hacet dilemek',
        ],
      );
    }

    // 2. Sabah Namazı / Uyanma
    if (q.contains('sabah namaz') || q.contains('uyan') || q.contains('kalkam') || q.contains('uyku')) {
      return AiMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Sabah namazı, müminin sadakat ve diriliş vaktidir. Peygamberimiz (s.a.v):\n\n'
            '*"Sabah namazının iki rekat sünneti, dünyadan ve dünyadaki her şeyden daha hayırlıdır."* (Müslim, Müsâfirîn 96)\n\n'
            '### Sabah Namazına Kolay Kalkmanın 4 Altın Kuralı:\n'
            '1. **Akşamdan Niyet ve Zikir:** Yatağa abdestli girmek, Âyetel Kürsi ve İhlas-Felak-Nas surelerini okuyup Allah\'a samimiyetle "Ya Rabbi beni huzuruna uyandır" diye niyaz etmek.\n'
            '2. **Geç Saatte Yemek Yememek:** Gece geç saatte sindirimi zor gıdalar uykuyu derinleştirir ve ağırlık yapar.\n'
            '3. **Alarmı Yatak Dışına Koymak:** Yataktan kalkmadan kapatamayacağınız bir mesafeye koyun.\n'
            '4. **Şeytanın Düğümlerini Çözmek:** Efendimiz (s.a.v) buyurur ki; uyanınca Allah zikredilirse birinci, abdest alınca ikinci, namaz kılınınca üçüncü düğüm çözülür ve kişi dinç ve huzurlu bir gün geçirir.',
        isUser: false,
        timestamp: DateTime.now(),
        references: const [
          'Sahih-i Müslim, Salâtü\'l-Müsâfirîn, 96',
          'Sahih-i Buhari, Teheccüd, 12',
          'İsra Sûresi, 78. Âyet ("Sabah Kur\'an\'ı şahitlidir")'
        ],
        suggestedFollowUps: const [
          'Sabah namazı kaç rekat ve nasıl kılınır?',
          'Sabah namazı kazası ne zamana kadar kılınabilir?',
          'Günün bereketi için sabah duaları',
        ],
      );
    }

    // 3. Kaza Namazları
    if (q.contains('kaza') || q.contains('borç namaz') || q.contains('kaza namazı')) {
      return AiMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Kaza namazı, vaktinde eda edilemeyen farz namazların sonradan yerine getirilmesidir.\n\n'
            '### Kaza Borcu Nasıl Hesaplanır?\n'
            '• Ergenlik çağından (ortalama 12-15 yaş) itibaren kılınmayan farz namazların tahmini süresi belirlenir.\n'
            '• Bir günlük kaza; 5 vakit farz namaz + Vitir namazıdır (toplam 20 rekat).\n\n'
            '### Kılma Tertibi ve Niyet:\n'
            '• *"Niyet ettim Allah rızası için üzerimde kalan en son (veya ilk) kazaya kalmış Sabah namazının farzını kılmaya."*\n'
            '• Kerahet vakitleri haricinde (güneş doğarken, tam tepedeyken ve batarken) günün her anında kaza namazı kılınabilir.\n'
            '• Her gün düzenli olarak bir günlük kaza kılmak bile yılda 365 günlük borcu eritir.',
        isUser: false,
        timestamp: DateTime.now(),
        references: const [
          'Diyanet İlmihali, Namaz Bölümü, Kaza Namazları',
          'Sahih-i Buhari, Mevâkîtü\'s-Salât, 37',
          'Sahih-i Müslim, Mesâcid, 314'
        ],
        suggestedFollowUps: const [
          'Kerahet vakitleri tam olarak ne zamandır?',
          'Sünnetlerin yerine kaza namazı kılınır mı?',
          'Vitir namazı kaza edilir mi?',
        ],
      );
    }

    // 4. Ayetel Kürsi Tefsir / Fazilet
    if (q.contains('ayetel kürsi') || q.contains('âyetel kürsî') || q.contains('kürsi')) {
      return AiMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Âyetel Kürsî (Bakara Suresi 255. Ayet), Kur\'an-ı Kerim\'in en faziletli ve tevhid hakikatini en veciz beyan eden ayetidir.\n\n'
            '### Ayetin Temel Hikmetleri:\n'
            '• **Hayy ve Kayyûm:** Allah diridir ve bütün kainatı her an ayakta tutandır.\n'
            '• **Uyumaz ve Uykulamaz:** O\'nun ilmi ve koruması kesintisizdir.\n'
            '• **Kürsî:** O\'nun sonsuz kudreti, hükümranlığı ve ilminin bütün gökleri ve yeri kuşattığını temsil eder.\n\n'
            '### Hadis-i Şerif Müjdesi:\n'
            '*"Her farz namazın ardından Âyetel Kürsî okuyan kimsenin cennete girmesine ancak ölüm engel olur."* (Nesai, es-Sünenü\'l-Kübrâ)',
        isUser: false,
        timestamp: DateTime.now(),
        references: const [
          'Bakara Sûresi, 255. Âyet (Âyetel Kürsî)',
          'Sünen-i Nesâî, es-Sünenü\'l-Kübrâ 9848',
          'Taberî Tefsiri, Cilt 3, s. 6-12'
        ],
        suggestedFollowUps: const [
          'Namaz tesbihatında neden Âyetel Kürsi okunur?',
          'Evde bereket ve huzur için okunacak ayetler',
          'Arapça okunuşu ve tecvid incelikleri',
        ],
      );
    }

    // 5. Oruç / Ramazan
    if (q.contains('oruç') || q.contains('ramazan') || q.contains('imsak') || q.contains('iftar') || q.contains('bozar')) {
      return AiMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Oruç, nefsi terbiye eden ve takvaya ulaştıran mukaddes bir ibadettir.\n\n'
            '### En Sık Sorulan Hükümler:\n'
            '• **Unutarak Yemek/İçmek:** Orucu bozmaz. Hatırlandığı an hemen ağız yıkanıp oruca devam edilir. Efendimiz (s.a.v): *"Onu Allah yedirmiş ve içirmiştir"* buyurmuştur.\n'
            '• **Diş Fırçalamak / Ağız Çalkalamak:** Boğaza su veya macun kaçırılmadığı müddetçe orucu bozmaz, ancak şüpheden kaçınmak için iftar sonrasına bırakılması veya dikkatli fırçalanması tavsiye edilir.\n'
            '• **Sahur Bereketi:** İmsak vaktine kadar sahur yapmak sünnettir ve gün boyu bedene güç verir.',
        isUser: false,
        timestamp: DateTime.now(),
        references: const [
          'Bakara Sûresi, 183-185. Âyetler',
          'Sahih-i Buhari, Savm 26',
          'Diyanet İşleri Başkanlığı Din İşleri Yüksek Kurulu Fetvaları'
        ],
        suggestedFollowUps: const [
          'Kaza ve kefaret orucu arasındaki fark nedir?',
          'İftar duası ve sünnet iftar adabı',
          'Kadir Gecesi fazileti ve duaları',
        ],
      );
    }

    // 6. Sehiv Secdesi
    if (q.contains('sehiv') || q.contains('yanıl') || q.contains('şüphe') || q.contains('kaçıncı rekat')) {
      return AiMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Sehiv secdesi; namazın vaciplerinden birinin sehven (yanılarak) terk edilmesi veya geciktirilmesi ya da bir farzın ertelenmesi durumunda namazın sonundaki telafi secdesidir.\n\n'
            '### Nasıl Yapılır?\n'
            '1. Son oturuşta (Kade-i Âhire) Tahiyyat duası okunur.\n'
            '2. Yalnızca **sağa** selam verilir.\n'
            '3. "Allahu Ekber" diyerek peş peşe 2 secde yapılır (her secdede 3 kere "Sübhâne Rabbiye\'l-A\'lâ" denir).\n'
            '4. Tekrar oturulup Tahiyyat, Salli-Barik ve Rabbena duaları okunarak her iki tarafa selam verilip namaz tamamlanır.',
        isUser: false,
        timestamp: DateTime.now(),
        references: const [
          'Diyanet İlmihali, Sehiv Secdesi Bahsi',
          'Sahih-i Buhari, Sehv 1-5',
          'Sahih-i Müslim, Mesâcid 88-102'
        ],
        suggestedFollowUps: const [
          'Hangi durumlarda sehiv secdesi gerekmez?',
          'Namazda kaçıncı rekatta olduğunu unutan ne yapar?',
          'Fatiha\'yı unutan sehiv secdesi yapar mı?',
        ],
      );
    }

    // Genel İslami Yanıt
    return AiMessage(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      text: 'Sorunuzu dikkatle inceledim:\n\n'
          'İslam dini, kolaylık ve güzellik dinidir. Yüce Rabbimiz Bakara Suresi 185. ayette:\n'
          '*"Allah sizin için kolaylık ister, zorluk istemez"* buyurmaktadır.\n\n'
          'Sorduğunuz mevzu ile ilgili temel ilke; samimiyet (ihlas), sünnete uygunluk ve kalbi kötülüklerden muhafaza etmektir. '
          'İbadetlerinizde veya günlük hayatınızda karşılaştığınız bu durumda öncelikle niyetinizi tazeleyip, '
          'Resûlullah Efendimiz\'in (s.a.v) tavsiyelerine ve muteber fıkhi ölçülere riayet etmek ruhunuza esenlik kazandıracaktır.\n\n'
          'Konu hakkında daha detaylı fıkhi veya tefsir izahı isterseniz lütfen sorunuzu biraz daha açarak sorabilirsiniz.',
      isUser: false,
      timestamp: DateTime.now(),
      references: const [
        'Bakara Sûresi, 185. Âyet',
        'Sahih-i Buhari, İman 29 ("Din kolaylıktır")',
        'Diyanet İşleri Başkanlığı Dini Bilgiler Külliyatı'
      ],
      suggestedFollowUps: const [
        'Kalp huzuru için hangi ayet ve dualar okunur?',
        'Namazda huşuyu artırmanın yolları',
        'Kaza namazı borcu nasıl hesaplanır?',
        'Günün zikir ve tesbihat listesi',
      ],
    );
  }
}

final aiAssistantProvider =
    StateNotifierProvider<AiAssistantNotifier, AiAssistantState>((ref) {
  return AiAssistantNotifier();
});

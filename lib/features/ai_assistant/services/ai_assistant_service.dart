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

    // 2. Canlı API bağlantısı kurulamazsa veya geçici kesinti olursa net bilgilendirme mesajı
    aiReply ??= AiMessage(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      text: 'Şu anda yapay zeka sunucusuna bağlanırken geçici bir yoğunluk veya kesinti yaşandı. '
          'Lütfen internet bağlantınızı kontrol edip sorunuzu birkaç saniye sonra tekrar iletiniz.',
      isUser: false,
      timestamp: DateTime.now(),
      references: const [
        'Beyân AI Manevi Rehber & Tefsir Asistanı',
      ],
      suggestedFollowUps: const [
        'Soruyu tekrar ilet',
      ],
    );

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
    // gemini-3.5-flash ve gemini-3.6-flash, düşünme yükü olmadan ultra hızlı (1-3 saniye) yanıt üretir.
    // gemini-3.8-flash gibi ağır akıl yürütme modelleri dakikalarca beklettiği için kaldırıldı.
    final candidateModels = ['gemini-3.5-flash', 'gemini-3.6-flash'];

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
        client = HttpClient()..connectionTimeout = const Duration(seconds: 4);
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$apiKey',
        );
        final request = await client.postUrl(url);
        request.headers.contentType = ContentType.json;
        request.write(body);
        final response = await request.close().timeout(const Duration(seconds: 7));

        if (response.statusCode == 200) {
          final responseBody = await response
              .transform(utf8.decoder)
              .join()
              .timeout(const Duration(seconds: 7));
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
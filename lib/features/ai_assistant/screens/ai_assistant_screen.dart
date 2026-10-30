import 'package:islamic_app/core/theme/beyan_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../monetization/providers/premium_provider.dart';
import '../../monetization/screens/premium_paywall_sheet.dart';
import '../models/ai_message.dart';
import '../services/ai_assistant_service.dart';

class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isPremium = ref.read(premiumProvider).isPremium;
      ref.read(aiAssistantProvider.notifier).refreshQuota(isPremium);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutQuad,
        );
      }
    });
  }

  Future<void> _handleSend([String? presetText]) async {
    final text = presetText ?? _controller.text;
    if (text.trim().isEmpty) return;

    // Apple İnceleme Kılavuzu 5.1.2: Kullanıcı verisi üçüncü taraf yapay zekaya (Google Gemini) gitmeden önce açık onay al
    final prefs = await SharedPreferences.getInstance();
    final hasAccepted = prefs.getBool('beyan_ai_consent_accepted') ?? false;
    if (!hasAccepted) {
      if (!mounted) return;
      final accepted = await _showAiConsentDialog();
      if (!accepted) return;
      await prefs.setBool('beyan_ai_consent_accepted', true);
    }

    final isPremium = ref.read(premiumProvider).isPremium;
    final canAsk = await ref.read(aiAssistantProvider.notifier).canAskQuestion(isPremium);

    if (!canAsk && !isPremium) {
      HapticFeedback.heavyImpact();
      if (mounted) {
        _showQuotaExceededDialog();
      }
      return;
    }

    if (presetText == null) {
      _controller.clear();
    }
    _focusNode.unfocus();
    HapticFeedback.lightImpact();

    final success = await ref
        .read(aiAssistantProvider.notifier)
        .askQuestion(text, isPremium: isPremium);

    if (success) {
      _scrollToBottom();
    } else {
      final error = ref.read(aiAssistantProvider).errorMessage;
      if (error != null && mounted) {
        _showQuotaExceededDialog();
      }
    }
  }

  Future<bool> _showAiConsentDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: BeyanColors.tone(0xFF022B24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: BeyanColors.tone(0xFFFFDF7A), width: 1.2),
            ),
            title: Row(
              children: [
                Icon(Icons.security_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Beyân AI & Gizlilik Bildirimi',
                    style: TextStyle(
                      color: BeyanColors.tone(0xFFFFDF7A),
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Beyân AI Manevi Rehber & Tefsir Asistanı, sorularınızı yanıtlamak amacıyla Google Gemini yapay zeka altyapısını kullanır.',
                  style: TextStyle(color: Colors.white, fontSize: 13.5, height: 1.5),
                ),
                const SizedBox(height: 12),
                Text(
                  '• Sorduğunuz dini ve fıkhi sorular cevap üretimi amacıyla üçüncü taraf yapay zeka modeline (Google Gemini) iletilir.\n'
                  '• Lütfen kişisel, gizli veya kimliğinizi ele verebilecek hassas verileri paylaşmayınız.\n'
                  '• Üretilen yanıtlar ilmi ve manevi rehberlik amaçlıdır; kesin fetva ve nihai hüküm yerine geçmez.\n'
                  '• Ayrıntılı bilgi için Gizlilik Politikamızı inceleyebilir, onay tercihinizi dilediğiniz an Ayarlar üzerinden güncelleyebilirsiniz.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12.5, height: 1.45),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Vazgeç', style: TextStyle(color: Colors.white60)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: BeyanColors.tone(0xFFFFDF7A),
                  foregroundColor: const Color(0xFF012E2B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Anladım ve Kabul Ediyorum', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showApiKeyDialog(BuildContext context) {
    final currentKey = ref.read(aiAssistantProvider).geminiApiKey ?? '';
    final keyController = TextEditingController(text: currentKey);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: BeyanColors.tone(0xFF022B24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: BeyanColors.tone(0xFFFFDF7A), width: 1.2),
        ),
        title: Row(
          children: [
            Icon(Icons.key_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 24),
            const SizedBox(width: 8),
            Text(
              'Gemini API Anahtarı',
              style: TextStyle(color: BeyanColors.tone(0xFFFFDF7A), fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Google AI Studio\'dan (aistudio.google.com) 30 saniyede tamamen ücretsiz alabileceğiniz resmi Gemini API anahtarınızı girerek Beyân AI\'yı Google Gemini 1.5 Flash ile canlı olarak bağlayabilirsiniz.',
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.45),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: BeyanColors.tone(0xFF032D26),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nasıl Alınır? (Ücretsiz):',
                    style: TextStyle(color: BeyanColors.tone(0xFFFFDF7A), fontSize: 11.5, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '1. aistudio.google.com adresini açın\n'
                    '2. "Get API key" butonuna dokunup anahtar oluşturun\n'
                    '3. Kopyalayıp aşağıdaki alana yapıştırın',
                    style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: keyController,
              style: const TextStyle(color: Colors.white, fontSize: 13.5),
              decoration: InputDecoration(
                hintText: 'AIzaSy...',
                hintStyle: const TextStyle(color: Colors.white30),
                filled: true,
                fillColor: BeyanColors.tone(0xFF04382F),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: BeyanColors.tone(0xFFD4AF37), width: 1),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.paste_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 20),
                  tooltip: 'Panodan Yapıştır',
                  onPressed: () async {
                    final data = await Clipboard.getData(Clipboard.kTextPlain);
                    if (data?.text != null) {
                      keyController.text = data!.text!.trim();
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '• API anahtarı eklemeden de dahili ilimler motorumuz tüm dini suallerinize eksiksiz cevap verir.',
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
        actions: [
          if (currentKey.isNotEmpty)
            TextButton(
              onPressed: () async {
                await ref.read(aiAssistantProvider.notifier).setGeminiApiKey(null);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Kaldır', style: TextStyle(color: Colors.redAccent)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: BeyanColors.tone(0xFFD4AF37),
              foregroundColor: BeyanColors.tone(0xFF01201B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final newKey = keyController.text.trim();
              await ref.read(aiAssistantProvider.notifier).setGeminiApiKey(newKey.isEmpty ? null : newKey);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Kaydet', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ).then((_) {
      keyController.dispose();
    });
  }

  void _showQuotaExceededDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: BeyanColors.tone(0xFF022B24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: BeyanColors.tone(0xFFFFDF7A), width: 1.2),
        ),
        title: Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 28),
            const SizedBox(width: 8),
            Text(
              'Yapay Zekâ Asistanı',
              style: TextStyle(color: BeyanColors.tone(0xFFFFDF7A), fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Günlük 3 ücretsiz soru hakkınız tamamlandı. Soru sınırını tamamen kaldırmak için Beyân Pro\'ya geçebilir veya kendi ücretsiz Gemini API anahtarınızı tanımlayabilirsiniz.',
              style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: BeyanColors.tone(0xFF0F5A47).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.workspace_premium_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Beyân Pro ile sınırsız soru-cevap ve reklamsız deneyim.',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Kapat', style: TextStyle(color: Colors.white60)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showApiKeyDialog(context);
            },
            child: Text(
              'API Anahtarı 🔑',
              style: TextStyle(color: BeyanColors.tone(0xFFFFDF7A), fontSize: 12),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: BeyanColors.tone(0xFFFFDF7A),
              foregroundColor: BeyanColors.tone(0xFF01201B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              PremiumPaywallSheet.show(context);
            },
            child: const Text(
              'Pro\'ya Geç 👑',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(premiumProvider.select((s) => s.isPremium), (prev, isPrem) {
      ref.read(aiAssistantProvider.notifier).refreshQuota(isPrem);
    });

    final aiState = ref.watch(aiAssistantProvider);
    final premiumState = ref.watch(premiumProvider);
    final isPremium = premiumState.isPremium;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? BeyanColors.tone(0xFF021B16) : BeyanColors.tone(0xFFF4F8F6),
      appBar: AppBar(
        backgroundColor: isDark ? BeyanColors.tone(0xFF012720) : AppColors.teal,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [BeyanColors.tone(0xFFFFDF7A), BeyanColors.tone(0xFFB8860B)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Center(
                child: Icon(Icons.auto_awesome_rounded, color: BeyanColors.tone(0xFF01201B), size: 20),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Beyân AI',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: BeyanColors.tone(0xFFFFDF7A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'İslami Rehber',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: BeyanColors.tone(0xFF012E2B),
                        ),
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Tefsir & Fıkıh & Maneviyat',
                  style: TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline_rounded, color: BeyanColors.tone(0xFFFFDF7A)),
            tooltip: 'Muteber Kaynaklar',
            onPressed: () => _showSourcesDialog(context),
          ),
        ],
      ),
      body: Column(
              children: [
                // ── Quota & Status Banner ────────────────────────
                _buildQuotaBanner(
                  isPremium,
                  aiState.remainingQuestions,
                  aiState.hasCustomApiKey,
                  aiState.hasDeveloperGlobalKey,
                ),

                // ── Mesaj Akışı ──────────────────────────────────
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                    itemCount: aiState.messages.length + (aiState.isThinking ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < aiState.messages.length) {
                        final msg = aiState.messages[index];
                        return _buildMessageBubble(msg, isDark);
                      } else {
                        return _buildThinkingBubble(isDark);
                      }
                    },
                  ),
                ),

                // ── Giriş Alanı ──────────────────────────────────
                _buildInputBar(isDark),
              ],
            ),
    );
  }

  Widget _buildQuotaBanner(
    bool isPremium,
    int remaining,
    bool hasCustomApiKey,
    bool hasDeveloperGlobalKey,
  ) {
    if (isPremium) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: BeyanColors.tone(0xFF0F5A47).withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Icon(Icons.workspace_premium_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Beyân Pro: Sınırsız Soru & Tefsir Asistanı',
                style: TextStyle(
                  color: BeyanColors.tone(0xFFFFDF7A),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Kalan Ücretsiz Soru: $remaining / 3',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          InkWell(
            onTap: () => PremiumPaywallSheet.show(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [BeyanColors.tone(0xFFFFDF7A), BeyanColors.tone(0xFFD4AF37)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.workspace_premium_rounded, size: 12, color: BeyanColors.tone(0xFF071F1B)),
                  const SizedBox(width: 3),
                  Text(
                    'Sınırsız Yap 👑',
                    style: TextStyle(
                      color: BeyanColors.tone(0xFF071F1B),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSourcesDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      backgroundColor: BeyanColors.tone(0xFF022B24),
      barrierColor: Colors.black.withValues(alpha: 0.65),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragUpdate: (details) {
                  if (details.primaryDelta != null && details.primaryDelta! > 6) {
                    Navigator.pop(ctx);
                  }
                },
                onTap: () => Navigator.pop(ctx),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white38,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.verified_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 24),
                  const SizedBox(width: 10),
                  Text(
                    'Muteber İslami Kaynaklarımız',
                    style: TextStyle(color: BeyanColors.tone(0xFFFFDF7A), fontSize: 16.5, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Beyân AI, tüm sorularınıza Ehl-i Sünnet vel-Cemaat istikametinde ve şu muteber kaynaklar referans alınarak cevap verir:',
                style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.45),
              ),
              const SizedBox(height: 14),
              _buildSourceTile('📖 Kur\'an-ı Kerim ve Sahih Tefsirler', 'Diyanet İşleri Başkanlığı ve Elmalılı Hamdi Yazır Tefsiri'),
              _buildSourceTile('📜 Sahih Hadis Külliyatı', 'Sahih-i Buhari, Sahih-i Müslim ve Kütüb-i Sitte'),
              _buildSourceTile('⚖️ 4 Hak Mezhep Fıkhı & Fetvalar', 'Diyanet Din İşleri Yüksek Kurulu ve Ehl-i Sünnet İlmihalleri'),
              _buildSourceTile('🌍 Dinler Tarihi & Karşılaştırmalı İlahiyat', 'İslam\'ın semavi dinlere (Hristiyanlık, Yahudilik) bakışı'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BeyanColors.tone(0xFFD4AF37),
                    foregroundColor: BeyanColors.tone(0xFF01201B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Anladım', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildSourceTile(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600)),
                Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(AiMessage msg, bool isDark) {
    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14, left: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: BeyanColors.tone(0xFF0A4D40),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(4),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
            border: Border.all(color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.5)),
          ),
          child: Text(
            msg.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20, right: 28),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? BeyanColors.tone(0xFF082C25) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          border: Border.all(
            color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Header with Emblem
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: BeyanColors.tone(0xFFFFDF7A),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(Icons.mosque_rounded, size: 14, color: BeyanColors.tone(0xFF01201B)),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Beyân AI',
                  style: TextStyle(
                    color: BeyanColors.tone(0xFFFFDF7A),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 16, color: Colors.white60),
                  tooltip: 'Yanıtı Kopyala',
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Clipboard.setData(ClipboardData(text: msg.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Yanıt panoya kopyalandı'),
                        duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Message text
            Text(
              msg.text,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 14.5,
                height: 1.55,
              ),
            ),

            // References
            if (msg.references.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? BeyanColors.tone(0xFF031E18)
                      : BeyanColors.tone(0xFFF1F8F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.menu_book_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 15),
                        const SizedBox(width: 6),
                        Text(
                          'Muteber Kaynaklar',
                          style: TextStyle(
                            color: BeyanColors.tone(0xFFFFDF7A),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ...msg.references.map(
                      (ref) => Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          '• $ref',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Suggested Follow-up chips
            if (msg.suggestedFollowUps.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: msg.suggestedFollowUps.map((prompt) {
                  return ActionChip(
                    backgroundColor: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.12),
                    side: BorderSide(color: BeyanColors.tone(0xFFD4AF37), width: 0.8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    label: Text(
                      prompt,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: BeyanColors.tone(0xFFFFDF7A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: () => _handleSend(prompt),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildThinkingBubble(bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? BeyanColors.tone(0xFF082C25) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(BeyanColors.tone(0xFFFFDF7A)),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Ayet ve hadis kaynakları taranıyor...',
              style: TextStyle(color: BeyanColors.tone(0xFFFFDF7A), fontSize: 13, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(bool isDark) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        decoration: BoxDecoration(
          color: isDark ? BeyanColors.tone(0xFF011F1A) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? BeyanColors.tone(0xFF0D3830) : BeyanColors.tone(0xFFE2EBE8),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark ? BeyanColors.tone(0xFF072922) : BeyanColors.tone(0xFFF1F8F5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.3),
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: 3,
                  minLines: 1,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14.5,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Bir ayet, dua veya dini soru sorun...',
                    hintStyle: TextStyle(color: Colors.white38, fontSize: 13.5),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [BeyanColors.tone(0xFFFFDF7A), BeyanColors.tone(0xFFD4AF37)],
                ),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.send_rounded, color: BeyanColors.tone(0xFF01201B), size: 20),
                onPressed: () => _handleSend(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

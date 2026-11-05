import 'package:islamic_app/core/utils/navigator_guard.dart';
import 'package:islamic_app/core/theme/beyan_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
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
                onPressed: () => BeyanNavigatorGuard.safePop(ctx, false),
                child: const Text('Vazgeç', style: TextStyle(color: Colors.white60)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: BeyanColors.tone(0xFFFFDF7A),
                  foregroundColor: const Color(0xFF012E2B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => BeyanNavigatorGuard.safePop(ctx, true),
                child: const Text('Anladım ve Kabul Ediyorum', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ) ??
        false;
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
              'Günlük 3 ücretsiz soru hakkınız tamamlandı. Soru sınırını tamamen kaldırmak ve sınırsız soru sormak için Beyân Pro\'ya geçebilirsiniz.',
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
            onPressed: () => BeyanNavigatorGuard.safePop(ctx),
            child: const Text('Kapat', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: BeyanColors.tone(0xFFFFDF7A),
              foregroundColor: BeyanColors.tone(0xFF01201B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () {
              BeyanNavigatorGuard.safePop(ctx);
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
    final effectivePalette = ref.watch(effectivePaletteProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF07080A) : effectivePalette.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0A0C10) : effectivePalette.lightBackground,
        foregroundColor: isDark ? Colors.white : AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: isDark ? Colors.white : AppColors.textPrimary,
            size: 22,
          ),
          onPressed: () => BeyanNavigatorGuard.safePop(context),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Beyân AI',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0D399),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    'İslami Rehber',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF07080A),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 1),
            Text(
              'Tefsir & Fıkıh & Maneviyat',
              style: TextStyle(
                fontSize: 10.5,
                color: isDark ? const Color(0xFF8E929B) : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_rounded,
              size: 24,
            ),
            tooltip: 'Yeni Sohbet',
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(aiAssistantProvider.notifier).resetChat();
            },
          ),
          IconButton(
            icon: Icon(
              Icons.info_outline_rounded,
              size: 20,
              color: isDark ? const Color(0xFFF0D399) : const Color(0xFF8A6B1A),
            ),
            tooltip: 'Muteber Kaynaklar',
            onPressed: () => _showSourcesDialog(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // ── Quota & Status Banner ────────────────────────
          _buildQuotaBanner(
            isPremium,
            aiState.remainingQuestions,
          ),

          // ── İçerik: Boş Durum Karşılama Ekranı VEYA Mesaj Akışı ─
          Expanded(
            child: (aiState.messages.isEmpty && !aiState.isThinking)
                ? _buildWelcomeHeroView(isDark)
                : ListView.builder(
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

  Widget _buildWelcomeHeroView(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Merkezi Işıltı Aurası ve Beyân Logo Markası ──
            Stack(
              alignment: Alignment.center,
              children: [
                // Arka plan atmosferik mor/safir ve şampanya aurası
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF4C2A85).withValues(alpha: isDark ? 0.45 : 0.20),
                        const Color(0xFF1E1738).withValues(alpha: isDark ? 0.30 : 0.10),
                        const Color(0xFFF0D399).withValues(alpha: isDark ? 0.08 : 0.04),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.45, 0.75, 1.0],
                    ),
                  ),
                ),
                // Ortadaki şık tipografik marka & Arapça monogram
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF141722),
                        border: Border.all(
                          color: const Color(0xFFF0D399).withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF0D399).withValues(alpha: 0.25),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          width: 68,
                          height: 68,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFFFFFFFF),
                          Color(0xFFF5E4BE),
                          Color(0xFFF0D399),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ).createShader(bounds),
                      child: const Text(
                        'beyân',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.5,
                          color: Colors.white,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Büyük Karşılama Başlığı ──
            Text(
              'Esselâmü Aleyküm!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.textPrimary,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 8),

            // ── Açıklayıcı İslami Asistan Alt Başlığı ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Ben Beyân İslami Yapay Zekâ rehberinizim. Kur\'an, Sünnet ve muteber ilmi kaynaklar ışığında manevi sorularınızı yanıtlayabilirim.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.45,
                  color: isDark ? const Color(0xFF8E929B) : AppColors.textSecondary,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Referans Görseldeki Gibi Yüzen Cam Kapsül Önerileri ──
            Column(
              children: [
                _buildSuggestionCapsule(
                  '📖  İnşirah Suresi ve manasını açıkla',
                  isDark: isDark,
                  onTap: () => _handleSend('İnşirah Suresi bana ne anlatıyor ve Türkçe anlamı nedir?'),
                ),
                const SizedBox(height: 10),
                _buildSuggestionCapsule(
                  '⏰  Sabah namazına nasıl rahat kalkarım?',
                  isDark: isDark,
                  onTap: () => _handleSend('Sabah namazına vaktinde kalkmak için manevi ve pratik tavsiyeler nelerdir?'),
                ),
                const SizedBox(height: 10),
                _buildSuggestionCapsule(
                  '🤲  Günün manevi duası ve meali nedir?',
                  isDark: isDark,
                  onTap: () => _handleSend('Bugün için Peygamber Efendimiz\'den (s.a.v.) sahih ve faziletli bir dua ve anlamı nedir?'),
                ),
                const SizedBox(height: 10),
                _buildSuggestionCapsule(
                  '🕋  Kaza namazı borçları nasıl hesaplanır?',
                  isDark: isDark,
                  onTap: () => _handleSend('Geçmiş namaz borçları (kaza namazı) nasıl hesaplanır ve en pratik nasıl kılınır?'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionCapsule(
    String label, {
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141720).withValues(alpha: 0.9) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark ? const Color(0xFFF0D399).withValues(alpha: 0.22) : const Color(0xFFD4AF37).withValues(alpha: 0.3),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: isDark ? const Color(0xFFF0D399) : const Color(0xFF8A6B1A),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuotaBanner(
    bool isPremium,
    int remaining,
  ) {
    if (isPremium) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF141720),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF0D399).withValues(alpha: 0.35)),
        ),
        child: const Row(
          children: [
            Icon(Icons.workspace_premium_rounded, color: Color(0xFFF0D399), size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Beyân Pro: Sınırsız Soru & Tefsir Asistanı',
                style: TextStyle(
                  color: Color(0xFFF0D399),
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
        color: const Color(0xFF12141C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: Color(0xFFF0D399), size: 16),
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
                gradient: const LinearGradient(
                  colors: [Color(0xFFF0D399), Color(0xFFD4AF37)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.workspace_premium_rounded, size: 12, color: Color(0xFF07080A)),
                  SizedBox(width: 3),
                  Text(
                    'Sınırsız Yap 👑',
                    style: TextStyle(
                      color: Color(0xFF07080A),
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
                        BeyanNavigatorGuard.safePopOnDrag(ctx);
                      }
                    },
                    onTap: () => BeyanNavigatorGuard.safePop(ctx),
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
                  onPressed: () => BeyanNavigatorGuard.safePop(ctx),
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
            color: isDark ? const Color(0xFF1B1E28) : const Color(0xFF0A4D40),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(4),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
            border: Border.all(
              color: isDark
                  ? const Color(0xFFF0D399).withValues(alpha: 0.4)
                  : BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.5),
            ),
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
          color: isDark ? const Color(0xFF101218) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          border: Border.all(
            color: isDark
                ? const Color(0xFFF0D399).withValues(alpha: 0.25)
                : BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.35),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
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
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0D399),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.auto_awesome_rounded, size: 14, color: Color(0xFF07080A)),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Beyân AI',
                  style: TextStyle(
                    color: isDark ? const Color(0xFFF0D399) : BeyanColors.tone(0xFFFFDF7A),
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
                    Clipboard.setData(ClipboardData(text: _cleanForClipboard(msg.text)));
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

            // Message text (Biçimlendirilmiş, markdown işaretleri temizlenmiş)
            _buildFormattedMessageText(msg.text, isDark),

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
          color: isDark ? const Color(0xFF101218) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFF0D399).withValues(alpha: 0.35),
            width: 1.1,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF0D399)),
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Ayet ve hadis kaynakları taranıyor...',
              style: TextStyle(
                color: Color(0xFFF0D399),
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
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
          color: isDark ? const Color(0xFF090A0D) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF1C1E26) : const Color(0xFFE2EBE8),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF13151D) : const Color(0xFFF1F8F5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFFF0D399).withValues(alpha: 0.25)
                        : BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.3),
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
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF0D399), Color(0xFFD4AF37)],
                ),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Color(0xFF07080A), size: 20),
                onPressed: () => _handleSend(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _cleanForClipboard(String text) {
    var s = text;
    s = s.replaceAll(RegExp(r'^#{1,6}\s*', multiLine: true), '');
    s = s.replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1');
    s = s.replaceAll(RegExp(r'\*([^*]+)\*'), r'$1');
    return s.trim();
  }

  Widget _buildFormattedMessageText(String text, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final lines = text.split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      var line = lines[i];

      final isHeader = line.startsWith('#');
      if (isHeader) {
        line = line.replaceAll(RegExp(r'^#{1,6}\s*'), '');
      }

      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      if (isHeader) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 4),
            child: Text(
              line.replaceAll('**', ''),
              style: TextStyle(
                color: BeyanColors.tone(0xFFFFDF7A),
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
          ),
        );
        continue;
      }

      // Paragraf içinde **kalın** metinleri ayrıştırma
      final spans = <TextSpan>[];
      final regex = RegExp(r'\*\*([^*]+)\*\*');
      int lastIndex = 0;

      for (final match in regex.allMatches(line)) {
        if (match.start > lastIndex) {
          spans.add(
            TextSpan(
              text: line.substring(lastIndex, match.start),
              style: TextStyle(color: textColor, fontSize: 14.5, height: 1.55),
            ),
          );
        }
        spans.add(
          TextSpan(
            text: match.group(1),
            style: TextStyle(
              color: isDark ? BeyanColors.tone(0xFFFFDF7A) : Colors.black,
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              height: 1.55,
            ),
          ),
        );
        lastIndex = match.end;
      }

      if (lastIndex < line.length) {
        spans.add(
          TextSpan(
            text: line.substring(lastIndex),
            style: TextStyle(color: textColor, fontSize: 14.5, height: 1.55),
          ),
        );
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: RichText(
            text: TextSpan(children: spans),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}

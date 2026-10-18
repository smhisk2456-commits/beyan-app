import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  void _showQuotaExceededDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF022B24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFFFFDF7A), width: 1.2),
        ),
        title: const Row(
          children: [
            Icon(Icons.stars_rounded, color: Color(0xFFFFDF7A), size: 28),
            SizedBox(width: 8),
            Text(
              'Günlük Soru Limiti',
              style: TextStyle(color: Color(0xFFFFDF7A), fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Bugünkü 3 ücretsiz soru hakkınız doldu.\n\n'
          'Beyân AI Manevi Rehber & Tefsir Asistanı\'na 7/24 sınırsız soru sormak, '
          'reklamsız deneyim ve tüm lüks özellikler için Beyân Premium\'a geçebilirsiniz.',
          style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Daha Sonra', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: const Color(0xFF01201B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              PremiumPaywallSheet.show(context);
            },
            child: const Text(
              'Premium\'a Geç ✨',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiAssistantProvider);
    final premiumState = ref.watch(premiumProvider);
    final isPremium = premiumState.isPremium;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF021B16) : const Color(0xFFF4F8F6),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF012720) : AppColors.teal,
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
                gradient: const RadialGradient(
                  colors: [Color(0xFFFFDF7A), Color(0xFFB8860B)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFDF7A).withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.auto_awesome_rounded, color: Color(0xFF01201B), size: 20),
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
                        color: const Color(0xFFFFDF7A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'İslami Rehber',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF012E2B),
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
            icon: const Icon(Icons.stars_rounded, color: Color(0xFFFFDF7A)),
            tooltip: 'Beyân Premium',
            onPressed: () => PremiumPaywallSheet.show(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Quota & Status Banner ────────────────────────
          _buildQuotaBanner(isPremium, aiState.remainingQuestions),

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

  Widget _buildQuotaBanner(bool isPremium, int remaining) {
    if (isPremium) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: const Color(0xFF0F3A30),
        child: const Row(
          children: [
            Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFDF7A), size: 18),
            SizedBox(width: 8),
            Text(
              'Beyân Premium: Sınırsız Manevi Danışmanlık Aktif',
              style: TextStyle(
                color: Color(0xFFFFDF7A),
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF032D26),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Colors.white70, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Kalan Ücretsiz Soru: $remaining / 3',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          InkWell(
            onTap: () => PremiumPaywallSheet.show(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFDF7A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt_rounded, size: 12, color: Color(0xFF012E2B)),
                  SizedBox(width: 2),
                  Text(
                    'Sınırsız Yap',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF012E2B),
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

  Widget _buildMessageBubble(AiMessage msg, bool isDark) {
    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14, left: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0A4D40),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(4),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
            border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.5)),
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
          color: isDark ? const Color(0xFF082C25) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          border: Border.all(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
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
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFDF7A),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.mosque_rounded, size: 14, color: Color(0xFF01201B)),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Beyân AI',
                  style: TextStyle(
                    color: Color(0xFFFFDF7A),
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
                      ? const Color(0xFF031E18)
                      : const Color(0xFFF1F8F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.menu_book_rounded, color: Color(0xFFFFDF7A), size: 15),
                        SizedBox(width: 6),
                        Text(
                          'Muteber Kaynaklar',
                          style: TextStyle(
                            color: Color(0xFFFFDF7A),
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
                    backgroundColor: const Color(0xFFD4AF37).withValues(alpha: 0.12),
                    side: const BorderSide(color: Color(0xFFD4AF37), width: 0.8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    label: Text(
                      prompt,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFFFFDF7A),
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
          color: isDark ? const Color(0xFF082C25) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.4)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFDF7A)),
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Ayet ve hadis kaynakları taranıyor...',
              style: TextStyle(color: Color(0xFFFFDF7A), fontSize: 13, fontStyle: FontStyle.italic),
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
          color: isDark ? const Color(0xFF011F1A) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF0D3830) : const Color(0xFFE2EBE8),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF072922) : const Color(0xFFF1F8F5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
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
                  colors: [Color(0xFFFFDF7A), Color(0xFFD4AF37)],
                ),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Color(0xFF01201B), size: 20),
                onPressed: () => _handleSend(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../models/adhan_makam.dart';
import '../services/adhan_audio_player_service.dart';
import '../services/notification_service.dart';
import '../../monetization/providers/premium_provider.dart';
import '../../monetization/screens/premium_paywall_sheet.dart';

/// Ezan Makamları Seçim ve Önizleme Dinleme Ekranı
class AdhanMakamSelectorSheet extends ConsumerStatefulWidget {
  const AdhanMakamSelectorSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AdhanMakamSelectorSheet(),
    );
  }

  @override
  ConsumerState<AdhanMakamSelectorSheet> createState() =>
      _AdhanMakamSelectorSheetState();
}

class _AdhanMakamSelectorSheetState
    extends ConsumerState<AdhanMakamSelectorSheet> {
  final _audioService = AdhanAudioPlayerService.instance;
  AdhanMakam _selectedMakam = AdhanMakam.istanbul;
  AdhanMakam? _playingMakam;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSelectedMakam();
    _audioService.currentlyPlayingStream.listen((makam) {
      if (mounted) {
        setState(() => _playingMakam = makam);
      }
    });
  }

  Future<void> _loadSelectedMakam() async {
    final makam = await NotificationService.instance.getSelectedMakam();
    final isPremium = ref.read(premiumProvider).isPremium;
    if (makam.isPro && !isPremium) {
      await NotificationService.instance.setSelectedMakam(AdhanMakam.istanbul);
      if (mounted) {
        setState(() {
          _selectedMakam = AdhanMakam.istanbul;
          _isLoading = false;
        });
      }
      return;
    }
    if (mounted) {
      setState(() {
        _selectedMakam = makam;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _audioService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final strings = ref.watch(appStringsProvider);
    final isPremium = ref.watch(premiumProvider).isPremium;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = themeState.palette.accentGold;
    final bg = isDark ? themeState.palette.darkSurface : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Çekme çubuğu
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Başlık
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.music_note_rounded, color: gold, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.adhanMakamsAndAudio,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      strings.adhanMakamsDesc,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.workspace_premium_rounded,
                  color: gold,
                  size: 26,
                ),
                tooltip: 'Beyân Premium',
                onPressed: () => PremiumPaywallSheet.show(context),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // PRO Bilgilendirme Bannerı (Eğer Premium değilse)
          if (!isPremium) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: gold.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.stars_rounded, color: gold, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      strings.makamProBannerHint,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? Colors.white70 : AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          else
            Flexible(
              child: ListView(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                children: AdhanMakam.values.map((makam) {
                  final isSelected = _selectedMakam == makam;
                  final isPlaying = _playingMakam == makam;

                  return _buildMakamCard(
                    makam: makam,
                    isSelected: isSelected,
                    isPlaying: isPlaying,
                    isPremium: isPremium,
                    gold: gold,
                    isDark: isDark,
                    strings: strings,
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMakamCard({
    required AdhanMakam makam,
    required bool isSelected,
    required bool isPlaying,
    required bool isPremium,
    required Color gold,
    required bool isDark,
    required AppStrings strings,
  }) {
    final isLocked = makam.isPro && !isPremium;
    final borderColor = isSelected
        ? gold
        : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08));

    final cardBg = isDark
        ? (isSelected ? gold.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.03))
        : (isSelected ? gold.withValues(alpha: 0.10) : Colors.white);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () async {
          if (isLocked) {
            HapticFeedback.lightImpact();
            PremiumPaywallSheet.show(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFDF7A), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${makam.localizedTitle(strings.language.code)} ${strings.proMakamExclusiveNotice}',
                        style: const TextStyle(fontSize: 12.5),
                      ),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF033E35),
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }
          HapticFeedback.selectionClick();
          setState(() => _selectedMakam = makam);
          await NotificationService.instance.setSelectedMakam(makam);
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: isSelected ? 1.8 : 1),
          ),
          child: Row(
            children: [
              // Sol İkon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? gold.withValues(alpha: 0.2)
                      : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  makam.icon,
                  color: isSelected ? gold : (isDark ? Colors.white70 : Colors.black54),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),

              // Bilgi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          makam.localizedTitle(strings.language.code),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        if (makam.isPro) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFDF7A), Color(0xFFD4AF37)],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isLocked) ...[
                                  const Icon(Icons.lock_rounded, size: 10, color: Color(0xFF071F1B)),
                                  const SizedBox(width: 3),
                                ],
                                const Text(
                                  'PRO',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF071F1B),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      makam.localizedDescription(strings.language.code),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white60 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Dinle / Önizleme Butonu (Sessiz hariç - PRO dahil herkes dinleyebilir)
              if (makam != AdhanMakam.silent)
                IconButton(
                  tooltip: isPlaying ? strings.stopAudio : strings.listenAudio,
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isPlaying ? Icons.stop_circle_rounded : Icons.play_circle_outline_rounded,
                      key: ValueKey(isPlaying),
                      color: isPlaying ? Colors.amber : gold,
                      size: 28,
                    ),
                  ),
                  onPressed: () => _audioService.togglePlayPreview(makam),
                ),

              // Seçili Onayı
              if (isSelected)
                Container(
                  margin: const EdgeInsets.only(left: 4),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: gold,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.black,
                    size: 14,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

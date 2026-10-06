import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../models/premium_product.dart';
import '../providers/premium_provider.dart';
import 'onboarding_trial_paywall_screen.dart';

/// Lüks Beyân Premium Üyelik ve Abonelik Tanıtım Ekranı
class PremiumPaywallSheet extends ConsumerStatefulWidget {
  const PremiumPaywallSheet({super.key});

  static Future<void> show(BuildContext context) {
    return OnboardingTrialPaywallScreen.show(context);
  }

  @override
  ConsumerState<PremiumPaywallSheet> createState() =>
      _PremiumPaywallSheetState();
}

class _PremiumPaywallSheetState extends ConsumerState<PremiumPaywallSheet> {
  PremiumTier _selectedTier = PremiumTier.yearly;

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final premiumState = ref.watch(premiumProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = themeState.palette.accentGold;
    final bg = isDark ? themeState.palette.darkSurface : Colors.white;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: gold.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sürükleme Çubuğu
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Taç İkonu (Geliştirici testi için çift tıklamayla mock açıp kapama)
            Center(
              child: GestureDetector(
                onDoubleTap: () async {
                  HapticFeedback.heavyImpact();
                  await ref.read(premiumProvider.notifier).toggleDevPremium();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ref.read(premiumProvider).isPremium
                              ? 'Geliştirici Modu: Premium AKTİF edildi!'
                              : 'Geliştirici Modu: Premium KAPATILDI.',
                        ),
                        backgroundColor: const Color(0xFF033E35),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFDF7A), Color(0xFFD4AF37), Color(0xFF997A15)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: gold.withValues(alpha: 0.45),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: Color(0xFF071F1B),
                    size: 42,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Başlık & Açıklama
            Text(
              premiumState.isPremium ? 'Beyân Premium Üyesisiniz 👑' : 'Beyân Premium',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              premiumState.isPremium
                  ? 'Tüm ayrıcalıklar aktif! Desteğiniz için teşekkür ederiz.'
                  : 'Huzurlu, reklamsız ve ayrıcalıklı bir ibadet deneyimi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Avantajlar Kartları
            _buildFeatureTile(
              icon: Icons.block_rounded,
              title: '%100 Reklamsız İbadet',
              subtitle: 'Uygulama içi tüm reklam afişleri tamamen kaldırılır.',
              gold: gold,
              isDark: isDark,
            ),
            _buildFeatureTile(
              icon: Icons.palette_outlined,
              title: 'Özel Gece & OLED Temaları',
              subtitle: 'Gece Siyahı (OLED), Derin Lacivert ve Kâbe Taş Grisi kilitleri açılır.',
              gold: gold,
              isDark: isDark,
            ),
            _buildFeatureTile(
              icon: Icons.music_note_rounded,
              title: 'Tüm Ezan Makamları',
              subtitle: 'İstanbul, Mekke, Medine ve Tekbir sesleri sınırsız açılır.',
              gold: gold,
              isDark: isDark,
            ),
            _buildFeatureTile(
              icon: Icons.electric_bolt_rounded,
              title: 'Canlı Etkinlikler & Dinamik Ada',
              subtitle: 'Kilit ekranında canlı akan 30 dakikalık geri sayım çubuğu.',
              gold: gold,
              isDark: isDark,
            ),
            _buildFeatureTile(
              icon: Icons.volunteer_activism_rounded,
              title: 'İslami Yazılıma Hâmî Olun',
              subtitle: 'Bağımsız Türk yazılımcılarına ve vakıf ruhuna doğrudan destek verin.',
              gold: gold,
              isDark: isDark,
            ),
            const SizedBox(height: 24),

            // Eğer zaten Premium ise bilgi kartı göster
            if (premiumState.isPremium) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF033E35), Color(0xFF071F1B)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: gold, width: 1.2),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: Color(0xFFFFDF7A), size: 28),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Üyeliğiniz Aktif',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'Reklamlar kaldırıldı ve tüm özelliklerin kilidi açıldı.',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              // Paket Seçim Kartları
              Column(
                children: PremiumTier.values.map((tier) {
                  final isSelected = _selectedTier == tier;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedTier = tier);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? gold.withValues(alpha: 0.14)
                            : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade50),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected ? gold : Colors.grey.withValues(alpha: 0.25),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Seçim Radyo İkonu
                          Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: isSelected ? gold : Colors.grey,
                            size: 22,
                          ),
                          const SizedBox(width: 14),

                          // Paket Başlığı ve Alt Bilgi
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      tier.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: isDark ? Colors.white : AppColors.textPrimary,
                                      ),
                                    ),
                                    if (tier.badgeText.isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: gold,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          tier.badgeText,
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF071F1B),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  tier.subtitle,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? Colors.white60 : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Fiyat
                          Text(
                            tier.defaultPriceText,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isSelected ? gold : (isDark ? Colors.white : AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // Satın Alma Butonu
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: premiumState.isLoading
                      ? null
                      : () async {
                          HapticFeedback.mediumImpact();
                          final success = await ref
                              .read(premiumProvider.notifier)
                              .buyTier(_selectedTier);
                          if (context.mounted) {
                            if (success) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Tebrikler! Beyân Premium üyeliğiniz başlatıldı 👑'),
                                  backgroundColor: Color(0xFF033E35),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Mağaza bağlantısı henüz aktif değil (Geliştirici testi için taç simgesine çift tıklayabilirsiniz).'),
                                  backgroundColor: Color(0xFF3E1203),
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: const Color(0xFF071F1B),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: premiumState.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Color(0xFF071F1B),
                          ),
                        )
                      : Text(
                          '${_selectedTier.title} ile Başla',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Satın Alımları Geri Yükle & Şartlar (Apple Store Zorunluluğu)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () async {
                    HapticFeedback.lightImpact();
                    await ref.read(premiumProvider.notifier).restorePurchases();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Önceki satın alımlar kontrol edildi.'),
                          backgroundColor: Color(0xFF033E35),
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Satın Alımları Geri Yükle',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.black54,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                Text(
                  ' • ',
                  style: TextStyle(color: isDark ? Colors.white38 : Colors.black26),
                ),
                TextButton(
                  onPressed: () {
                    // Gizlilik & Şartlar modal
                  },
                  child: Text(
                    'Gizlilik & Şartlar',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color gold,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: gold, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

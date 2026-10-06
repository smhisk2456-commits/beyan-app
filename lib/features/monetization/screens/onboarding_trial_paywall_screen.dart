import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/premium_product.dart';
import '../providers/premium_provider.dart';

/// 3 Günlük Ücretsiz Deneme & Başlangıç Satın Alma Ekranı
///
/// Kullanıcı uygulamayı açtığında veya Widget kilidini açmak istediğinde
/// lüks, modern ve şeffaf zaman çizelgesiyle (Timeline) 3 günlük denemeyi sunar.
class OnboardingTrialPaywallScreen extends ConsumerStatefulWidget {
  final bool isDismissible;
  final VoidCallback? onDismiss;

  const OnboardingTrialPaywallScreen({
    super.key,
    this.isDismissible = true,
    this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    bool isDismissible = true,
    VoidCallback? onDismiss,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: isDismissible,
      isDismissible: isDismissible,
      builder: (_) => OnboardingTrialPaywallScreen(
        isDismissible: isDismissible,
        onDismiss: onDismiss,
      ),
    );
  }

  @override
  ConsumerState<OnboardingTrialPaywallScreen> createState() =>
      _OnboardingTrialPaywallScreenState();
}

class _OnboardingTrialPaywallScreenState
    extends ConsumerState<OnboardingTrialPaywallScreen> {
  // Seçili paket: 'monthly' veya 'yearly'
  String _selectedPlan = 'monthly';
  bool _isLoading = false;

  void _close() {
    if (widget.onDismiss != null) {
      widget.onDismiss!();
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _startFreeTrial() async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      final tier = _selectedPlan == 'yearly'
          ? PremiumTier.yearly
          : PremiumTier.monthly;

      // 1. Ücretsiz 3 günlük denemeyi aktifleştir
      await ref.read(premiumProvider.notifier).activateFreeTrial();

      // 2. Uygulama içi satın alma akışını başlat (cihaz mağazası aktifse)
      await ref.read(premiumProvider.notifier).buyTier(tier);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Color(0xFFFFDF7A)),
                SizedBox(width: 8),
                Expanded(
                  child: Text('3 Günlük Ücretsiz Denemeniz Başlatıldı! Hoş geldiniz.'),
                ),
              ],
            ),
            backgroundColor: Color(0xFF033E35),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _close();
      }
    } catch (e) {
      debugPrint('Deneme başlatma hatası: $e');
      if (mounted) {
        _close();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _restore() async {
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);
    final success = await ref.read(premiumProvider.notifier).restorePurchases();
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
              ? 'Satın alımlarınız başarıyla geri yüklendi!'
              : 'Aktif bir abonelik bulunamadı.',
          ),
          backgroundColor: const Color(0xFF033E35),
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (success) _close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final billingStartDate = now.add(const Duration(days: 3));
    final billingDateFormatted =
        DateFormat('d MMM yyyy', 'tr_TR').format(billingStartDate);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.94,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF081F1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black87,
            blurRadius: 40,
            offset: Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // ── Üst Kapatma Çubuğu ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const Spacer(),
                  // Kapat (✕) Butonu
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: _close,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Kaydırılabilir Gövde ─────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Ana Başlık
                    const Text(
                      'Devam etmek için 3 günlük\nÜCRETSİZ denemenizi başlatın.',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.25,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Zaman Çizelgesi (Timeline) ───────────────────────────
                    _buildTimelineStep(
                      icon: Icons.lock_open_rounded,
                      title: 'Bugün',
                      subtitle:
                          'Ayetler, alıntılar, temalar, dualar ve daha fazlası gibi tüm uygulama özelliklerini aç.',
                      isLast: false,
                    ),
                    _buildTimelineStep(
                      icon: Icons.notifications_none_rounded,
                      title: '2 Gün İçinde - Hatırlatma',
                      subtitle:
                          'Deneme sürenizin bitmek üzere olduğunu hatırlatacağız.',
                      isLast: false,
                    ),
                    _buildTimelineStep(
                      icon: Icons.workspace_premium_rounded,
                      title: '3 Gün İçinde - Faturalandırma Başlıyor',
                      subtitle:
                          '$billingDateFormatted tarihinde iptal etmediğiniz sürece ücretlendirileceksiniz.',
                      isLast: true,
                    ),

                    const SizedBox(height: 28),

                    // ── Fiyatlandırma Kartları (Aylık & Yıllık) ───────────────
                    Row(
                      children: [
                        // Aylık Kart
                        Expanded(
                          child: _buildPricingCard(
                            id: 'monthly',
                            subBadge: '3 Gün Ücretsiz Deneme',
                            title: 'Aylık',
                            price: '₺49,99 /ay',
                            isSelected: _selectedPlan == 'monthly',
                            onTap: () => setState(() => _selectedPlan = 'monthly'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Yıllık Kart
                        Expanded(
                          child: _buildPricingCard(
                            id: 'yearly',
                            topBadge: '%58 İNDİRİM',
                            title: 'Yıllık',
                            price: '₺20,83 /ay',
                            oldPrice: '₺599,88',
                            totalPrice: '₺249,99',
                            isSelected: _selectedPlan == 'yearly',
                            onTap: () => setState(() => _selectedPlan = 'yearly'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // "✓ Şimdi Ödeme Yok"
                    const Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_rounded,
                            color: Colors.white70,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Şimdi Ödeme Yok',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── Ana Çağrı Butonu (CTA) ────────────────────────────────
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _startFreeTrial,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD6EDE0),
                          foregroundColor: const Color(0xFF022720),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Color(0xFF022720),
                                ),
                              )
                            : const Text(
                                '3 Günlük Ücretsiz Denemeyi Başlat',
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.1,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Alt Açıklama Metni
                    Center(
                      child: Text(
                        _selectedPlan == 'yearly'
                            ? '3 gün ücretsiz, sonra yılda ₺249,99'
                            : '3 gün ücretsiz, sonra ayda ₺49,99',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Yasal Linkler & Geri Yükle ────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildFooterLink('Geri Yükle', _restore),
                        const Text(
                          '  •  ',
                          style: TextStyle(color: Colors.white30),
                        ),
                        _buildFooterLink('Gizlilik Politikası', () {}),
                        const Text(
                          '  •  ',
                          style: TextStyle(color: Colors.white30),
                        ),
                        _buildFooterLink('Kullanım Şartları (EULA)', () {}),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sol İkon ve Bağlantı Çizgisi
          Column(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFBCE3CE),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF052B24),
                  size: 20,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: const Color(0xFFBCE3CE),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),

          // Sağ Metinler
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 12,
                      height: 1.35,
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

  Widget _buildPricingCard({
    required String id,
    String? topBadge,
    String? subBadge,
    required String title,
    required String price,
    String? oldPrice,
    String? totalPrice,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF032620)
                  : const Color(0xFF0A2621),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.15),
                width: isSelected ? 1.6 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subBadge != null) ...[
                  Text(
                    subBadge,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? Colors.white
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? Colors.white
                              : Colors.white38,
                          width: 1.5,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              size: 15,
                              color: Color(0xFF032620),
                            )
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  price,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16.5,
                  ),
                ),
                if (oldPrice != null && totalPrice != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        oldPrice,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        totalPrice,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Üst İndirim Rozeti
          if (topBadge != null)
            Positioned(
              top: -10,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFD6EDE0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  topBadge,
                  style: const TextStyle(
                    color: Color(0xFF032B24),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 11,
        ),
      ),
    );
  }
}

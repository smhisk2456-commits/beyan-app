import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/localization/app_strings.dart';
import '../models/premium_product.dart';
import '../providers/premium_provider.dart';
import '../services/premium_service.dart';

/// Lüks Beyân Premium Satın Alma & Ücretsiz Deneme Ekranı
///
/// Ana Premium Kozları:
/// 1. Kilit Ekranı & Ana Ekran Canlı Widget'ları
/// 2. Tüm Ezan Makamları & Meşhur Müezzinler
/// 3. %100 Reklamsız Huşû Dolu Deneyim
/// 4. Lüks Gece & OLED Temaları
///
/// Öne Çıkan Paketler:
/// - Yıllık Plan (3 Gün Ücretsiz Deneme ile - En Popüler)
/// - Ömür Boyu Sahip Ol (Tek Seferlik Ödeme - En Avantajlı)
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
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (context, animation, secondaryAnimation) =>
            OnboardingTrialPaywallScreen(
          isDismissible: isDismissible,
          onDismiss: onDismiss,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  ConsumerState<OnboardingTrialPaywallScreen> createState() =>
      _OnboardingTrialPaywallScreenState();
}

class _OnboardingTrialPaywallScreenState
    extends ConsumerState<OnboardingTrialPaywallScreen> {
  // Varsayılan olarak Yıllık (3 gün denemeli) seçili
  PremiumTier _selectedTier = PremiumTier.yearly;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Ekran açıldığı an ilk açılış durumunu hemen kaydet.
    // Böylece uygulama her yeniden açıldığında tekrar zorla ekrana gelmez!
    PremiumService.instance.markLaunchPaywallSeen();
  }

  void _close() {
    PremiumService.instance.markLaunchPaywallSeen();
    if (widget.onDismiss != null) {
      widget.onDismiss!();
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _startPurchase() async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      // 1. Eğer yıllık paket seçildiyse 3 günlük ücretsiz denemeyi yerel olarak aktifleştir
      if (_selectedTier == PremiumTier.yearly) {
        await ref.read(premiumProvider.notifier).activateFreeTrial();
      } else {
        await PremiumService.instance.markLaunchPaywallSeen();
      }

      // 2. Uygulama içi satın alma akışını mağazaya gönder
      await ref.read(premiumProvider.notifier).buyTier(_selectedTier);

      if (mounted) {
        final strings = ref.read(appStringsProvider);
        final successMsg = _selectedTier == PremiumTier.yearly
            ? (strings.language == AppLanguage.turkish
                ? '3 Günlük Ücretsiz Denemeniz Başlatıldı!'
                : (strings.language == AppLanguage.english
                    ? 'Your 3-day free trial has started!'
                    : 'بدأت تجربتك المجانية لـ ٣ أيام!'))
            : (_selectedTier == PremiumTier.lifetime
                ? (strings.language == AppLanguage.turkish
                    ? 'Ömür Boyu Üyeliğiniz Başlatılıyor!'
                    : (strings.language == AppLanguage.english
                        ? 'Activating your lifetime membership!'
                        : 'جاري تفعيل عضويتك مدى الحياة!'))
                : (strings.language == AppLanguage.turkish
                    ? 'Aboneliğiniz Başlatılıyor!'
                    : (strings.language == AppLanguage.english
                        ? 'Starting your subscription!'
                        : 'جاري بدء اشتراكك!')));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFFFFDF7A)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(successMsg),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF033E35),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _close();
      }
    } catch (e) {
      debugPrint('Satın alma başlatma hatası: $e');
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
      final strings = ref.read(appStringsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? (strings.language == AppLanguage.turkish
                    ? 'Satın alımlarınız başarıyla geri yüklendi!'
                    : (strings.language == AppLanguage.english
                        ? 'Purchases restored successfully!'
                        : 'تم استعادة مشترياتك بنجاح!'))
                : (strings.language == AppLanguage.turkish
                    ? 'Aktif bir abonelik bulunamadı.'
                    : (strings.language == AppLanguage.english
                        ? 'No active subscription found.'
                        : 'لم يتم العثور على اشتراك نشط.')),
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
    final strings = ref.watch(appStringsProvider);
    final now = DateTime.now();
    final billingStartDate = now.add(const Duration(days: 3));
    final billingDateFormatted =
        DateFormat('d MMM yyyy', strings.language.code).format(billingStartDate);

    return Scaffold(
      backgroundColor: const Color(0xFF021612),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF011410),
              Color(0xFF04261F),
              Color(0xFF011511),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Üst Çubuk (Geri Yükle & Kapat Butonu) ────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    // Geri Yükle Butonu (Apple Kuralı)
                    TextButton(
                      onPressed: _restore,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        strings.restorePurchases,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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
                  padding: const EdgeInsets.fromLTRB(22, 6, 22, 20),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Lüks İkon & Başlık ───────────────────────────────────
                      Center(
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFFDF7A),
                                Color(0xFFD4AF37),
                                Color(0xFF997A15),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.workspace_premium_rounded,
                            color: Color(0xFF071F1B),
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      Text(
                        strings.paywallTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        strings.paywallSubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.72),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 22),

                      // ── Ana Premium Kozları (Widget & Makam Öncelikli) ────────
                      _buildFeatureRow(
                        icon: Icons.widgets_rounded,
                        tag: strings.language == AppLanguage.turkish
                            ? 'ÖNE ÇIKAN'
                            : (strings.language == AppLanguage.english
                                ? 'FEATURED'
                                : 'مميز'),
                        title: strings.paywallFeatWidgets,
                        subtitle: strings.paywallFeatWidgetsDesc,
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureRow(
                        icon: Icons.volume_up_rounded,
                        tag: strings.language == AppLanguage.turkish
                            ? 'LÜKS SES'
                            : (strings.language == AppLanguage.english
                                ? 'PREMIUM AUDIO'
                                : 'صوت فاخر'),
                        title: strings.paywallFeatMakams,
                        subtitle: strings.paywallFeatMakamsDesc,
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureRow(
                        icon: Icons.block_rounded,
                        tag: null,
                        title: strings.paywallFeatAdFree,
                        subtitle: strings.paywallFeatAdFreeDesc,
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureRow(
                        icon: Icons.dark_mode_rounded,
                        tag: null,
                        title: strings.paywallFeatThemes,
                        subtitle: strings.paywallFeatThemesDesc,
                      ),
                      const SizedBox(height: 24),

                      // ── Dinamik Süreç / Güvence Çizelgesi ────────────────────
                      if (_selectedTier == PremiumTier.yearly) ...[
                        _buildTimelineStep(
                          icon: Icons.lock_open_rounded,
                          title: strings.language == AppLanguage.turkish
                              ? 'Bugün: Tüm Kilitler Açılır'
                              : (strings.language == AppLanguage.english
                                  ? 'Today: All Features Unlocked'
                                  : 'اليوم: فتح جميع الميزات'),
                          subtitle: strings.language == AppLanguage.turkish
                              ? 'Widget\'lar, tüm ezan makamları ve lüks temalar anında aktif.'
                              : (strings.language == AppLanguage.english
                                  ? 'Lock screen widgets, adhan makams, and luxury themes active.'
                                  : 'أدوات شاشة القفل، مقامات الأذان، والمظاهر الفاخرة فعالة.'),
                          isLast: false,
                        ),
                        _buildTimelineStep(
                          icon: Icons.notifications_active_outlined,
                          title: strings.language == AppLanguage.turkish
                              ? '2 Gün İçinde: Hatırlatma'
                              : (strings.language == AppLanguage.english
                                  ? 'In 2 Days: Gentle Reminder'
                                  : 'خلال يومين: تذكير لطيف'),
                          subtitle: strings.language == AppLanguage.turkish
                              ? 'Deneme sürenizin bitmek üzere olduğunu size bildireceğiz.'
                              : (strings.language == AppLanguage.english
                                  ? 'We will notify you that your free trial is ending.'
                                  : 'سننبهك بأن فترتك التجريبية أوشكت على الانتهاء.'),
                          isLast: false,
                        ),
                        _buildTimelineStep(
                          icon: Icons.check_circle_outline_rounded,
                          title: strings.language == AppLanguage.turkish
                              ? '3. Gün: Faturalandırma Başlar'
                              : (strings.language == AppLanguage.english
                                  ? 'Day 3: Billing Begins'
                                  : 'اليوم الثالث: بدء الفوترة'),
                          subtitle: strings.language == AppLanguage.turkish
                              ? '$billingDateFormatted tarihine kadar dilediğiniz an tek tıkla iptal edebilirsiniz.'
                              : (strings.language == AppLanguage.english
                                  ? 'Cancel anytime before $billingDateFormatted in App Store settings.'
                                  : 'يمكنك الإلغاء في أي وقت قبل $billingDateFormatted من إعدادات المتجر.'),
                          isLast: true,
                        ),
                      ] else if (_selectedTier == PremiumTier.lifetime) ...[
                        _buildTimelineStep(
                          icon: Icons.all_inclusive_rounded,
                          title: strings.language == AppLanguage.turkish
                              ? 'Ömür Boyu Tek Seferlik Ödeme'
                              : (strings.language == AppLanguage.english
                                  ? 'Lifetime One-Time Purchase'
                                  : 'شراء لمرة واحدة مدى الحياة'),
                          subtitle: strings.language == AppLanguage.turkish
                              ? 'Asla yinelenen abonelik ücreti yok. Bir kez ödeyin, sonsuza dek kullanın.'
                              : (strings.language == AppLanguage.english
                                  ? 'No recurring subscriptions ever. Pay once, enjoy forever.'
                                  : 'لا توجد اشتراكات متكررة أبداً. ادفع مرة واستمتع للأبد.'),
                          isLast: false,
                        ),
                        _buildTimelineStep(
                          icon: Icons.verified_rounded,
                          title: strings.language == AppLanguage.turkish
                              ? 'Gelecek Tüm Güncellemeler Dahil'
                              : (strings.language == AppLanguage.english
                                  ? 'All Future Updates Included'
                                  : 'جميع التحديثات المستقبلية مشمولة'),
                          subtitle: strings.language == AppLanguage.turkish
                              ? 'Gelecekte eklenecek yeni ezan makamları ve widget\'lar ücretsiz.'
                              : (strings.language == AppLanguage.english
                                  ? 'Upcoming adhan makams and widget designs are free.'
                                  : 'المقامات والأدوات الجديدة مستقبلاً مجاناً بالكامل.'),
                          isLast: true,
                        ),
                      ] else ...[
                        _buildTimelineStep(
                          icon: Icons.calendar_month_rounded,
                          title: strings.language == AppLanguage.turkish
                              ? 'Aylık Esnek Kullanım'
                              : (strings.language == AppLanguage.english
                                  ? 'Flexible Monthly Access'
                                  : 'استخدام شهري مرن'),
                          subtitle: strings.language == AppLanguage.turkish
                              ? 'Ayda ₺49,99. İstediğiniz ay durdurup devam ettirebilirsiniz.'
                              : (strings.language == AppLanguage.english
                                  ? '₺49.99 / month. Pause or cancel whenever you wish.'
                                  : 'مرونة كاملة في الإلغاء أو التجديد شهرياً.'),
                          isLast: true,
                        ),
                      ],

                      const SizedBox(height: 24),

                      // ── Ana Paket Seçim Kartları (Yıllık & Ömür Boyu Hero) ────
                      Row(
                        children: [
                          // 1. Yıllık Kart (3 Gün Deneme - En Popüler)
                          Expanded(
                            child: _buildPricingCard(
                              topBadge: strings.badgeMostPopular,
                              subBadge: strings.badgeFreeTrial,
                              title: strings.planYearly,
                              price: '₺20,83 /ay',
                              oldPrice: '₺599,88',
                              totalPrice: '₺249,99 /yıl',
                              isSelected: _selectedTier == PremiumTier.yearly,
                              onTap: () => setState(() => _selectedTier = PremiumTier.yearly),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // 2. Ömür Boyu Kart (Sonsuz Erişim - En Avantajlı)
                          Expanded(
                            child: _buildPricingCard(
                              topBadge: strings.badgeBestValue,
                              subBadge: strings.badgeNoSubscription,
                              title: strings.planLifetime,
                              price: '₺499,99',
                              totalPrice: strings.language == AppLanguage.turkish
                                  ? 'Tek Seferlik'
                                  : (strings.language == AppLanguage.english
                                      ? 'One-Time'
                                      : 'دفعة واحدة'),
                              isSelected: _selectedTier == PremiumTier.lifetime,
                              onTap: () => setState(() => _selectedTier = PremiumTier.lifetime),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // 3. Aylık Plan Alternatif Butonu (Kullanıcı isterse seçebilir)
                      Center(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedTier = PremiumTier.monthly);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Text(
                              _selectedTier == PremiumTier.monthly
                                  ? '✓ ${strings.planMonthly}: ₺49,99 /ay (Seçili)'
                                  : '${strings.planMonthly}: ₺49,99 /ay',
                              style: TextStyle(
                                color: _selectedTier == PremiumTier.monthly
                                    ? const Color(0xFFFFDF7A)
                                    : Colors.white60,
                                fontSize: 12,
                                fontWeight: _selectedTier == PremiumTier.monthly
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                decoration: _selectedTier == PremiumTier.monthly
                                    ? TextDecoration.none
                                    : TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Güvence Bildirimi
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _selectedTier == PremiumTier.lifetime
                                  ? Icons.all_inclusive_rounded
                                  : Icons.check_circle_outline_rounded,
                              color: const Color(0xFFFFDF7A),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _selectedTier == PremiumTier.yearly
                                  ? strings.noPaymentNow
                                  : (_selectedTier == PremiumTier.lifetime
                                      ? strings.oneTimePaymentDesc
                                      : (strings.language == AppLanguage.turkish
                                          ? 'İstediğiniz zaman tek tıkla iptal'
                                          : 'Cancel anytime in App Store')),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Ana Çağrı Butonu (CTA) ────────────────────────────────
                      SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _startPurchase,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedTier == PremiumTier.lifetime
                                ? const Color(0xFFFFDF7A)
                                : const Color(0xFFD6EDE0),
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
                              : Text(
                                  _selectedTier == PremiumTier.yearly
                                      ? strings.btnStartTrial
                                      : (_selectedTier == PremiumTier.lifetime
                                          ? strings.btnBuyLifetime
                                          : strings.btnStartMonthly),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Alt Fiyat Açıklama Metni
                      Center(
                        child: Text(
                          _selectedTier == PremiumTier.yearly
                              ? (strings.language == AppLanguage.turkish
                                  ? '3 gün ücretsiz, sonra yılda ₺249,99 • İstediğin zaman iptal'
                                  : (strings.language == AppLanguage.english
                                      ? '3 days free, then ₺249.99 / year • Cancel anytime'
                                      : '٣ أيام مجاناً ثم ٢٤٩.٩٩ ₺ سنوياً • إلغاء بأي وقت'))
                              : (_selectedTier == PremiumTier.lifetime
                                  ? (strings.language == AppLanguage.turkish
                                      ? '₺499,99 tek seferlik ödeme • Asla tekrar ücretlendirilmez'
                                      : (strings.language == AppLanguage.english
                                          ? '₺499.99 one-time payment • Never billed again'
                                          : '٤٩٩.٩٩ ₺ دفعة واحدة لمرة واحدة'))
                                  : (strings.language == AppLanguage.turkish
                                      ? 'Ayda ₺49,99 • İstediğin zaman iptal'
                                      : '₺49.99 / month • Cancel anytime')),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 12,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ── Yasal Linkler & Geri Yükle (App Store Kuralı) ─────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildFooterLink(strings.restorePurchases, _restore),
                          const Text('  •  ', style: TextStyle(color: Colors.white30)),
                          _buildFooterLink(strings.privacyPolicy, () {}),
                          const Text('  •  ', style: TextStyle(color: Colors.white30)),
                          _buildFooterLink(strings.termsOfUse, () {}),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String? tag,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFFFDF7A).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFFFDF7A),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (tag != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFDF7A),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            color: Color(0xFF032620),
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
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
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFBCE3CE),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF052B24),
                  size: 19,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: const Color(0xFFBCE3CE).withValues(alpha: 0.6),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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
                  ? const Color(0xFF06332B)
                  : const Color(0xFF08221D),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFFFDF7A)
                    : Colors.white.withValues(alpha: 0.15),
                width: isSelected ? 1.8 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFFDF7A).withValues(alpha: 0.18),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subBadge != null) ...[
                  Text(
                    subBadge,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFFFFDF7A) : Colors.white60,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? const Color(0xFFFFDF7A)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFFFDF7A)
                              : Colors.white38,
                          width: 1.5,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              size: 14,
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
                    fontSize: 16,
                  ),
                ),
                if (totalPrice != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (oldPrice != null) ...[
                        Text(
                          oldPrice,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 10.5,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        totalPrice,
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFFFFDF7A)
                              : Colors.white70,
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Üst İndirim / Vurgu Rozeti
          if (topBadge != null)
            Positioned(
              top: -10,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFDF7A), Color(0xFFD4AF37)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  topBadge,
                  style: const TextStyle(
                    color: Color(0xFF032B24),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
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

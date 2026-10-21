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
  }) async {
    // v1.0 sürümünde tüm özellikler ücretsiz sunulur; satın alma paywall'u açılmaz.
    if (onDismiss != null) onDismiss();
    return;
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

  String _t(AppLanguage lang, {required String tr, required String en, required String ar, String? id}) {
    switch (lang) {
      case AppLanguage.turkish:
        return tr;
      case AppLanguage.arabic:
      case AppLanguage.urdu:
        return ar;
      case AppLanguage.indonesian:
        return id ?? en;
      default:
        return en;
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
        final lang = strings.language;
        final successMsg = _selectedTier == PremiumTier.yearly
            ? _t(lang,
                tr: '3 Günlük Ücretsiz Denemeniz Başlatıldı!',
                en: 'Your 3-day free trial has started!',
                ar: 'بدأت تجربتك المجانية لـ ٣ أيام!',
                id: 'Uji coba gratis 3 hari Anda telah dimulai!')
            : (_selectedTier == PremiumTier.lifetime
                ? _t(lang,
                    tr: 'Ömür Boyu Üyeliğiniz Başlatılıyor!',
                    en: 'Activating your lifetime membership!',
                    ar: 'جاري تفعيل عضويتك مدى الحياة!',
                    id: 'Mengaktifkan keanggotaan seumur hidup Anda!')
                : _t(lang,
                    tr: 'Aboneliğiniz Başlatılıyor!',
                    en: 'Starting your subscription!',
                    ar: 'جاري بدء اشتراكك!',
                    id: 'Memulai langganan Anda!'));

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
      final lang = strings.language;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? _t(lang,
                    tr: 'Satın alımlarınız başarıyla geri yüklendi!',
                    en: 'Purchases restored successfully!',
                    ar: 'تم استعادة مشترياتك بنجاح!',
                    id: 'Pembelian Anda berhasil dipulihkan!')
                : _t(lang,
                    tr: 'Aktif bir abonelik bulunamadı.',
                    en: 'No active subscription found.',
                    ar: 'لم يتم العثور على اشتراك نشط.',
                    id: 'Tidak ada langganan aktif yang ditemukan.'),
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
                        tag: _t(strings.language,
                            tr: 'ÖNE ÇIKAN',
                            en: 'FEATURED',
                            ar: 'مميز',
                            id: 'UNGGULAN'),
                        title: strings.paywallFeatWidgets,
                        subtitle: strings.paywallFeatWidgetsDesc,
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureRow(
                        icon: Icons.volume_up_rounded,
                        tag: _t(strings.language,
                            tr: 'LÜKS SES',
                            en: 'PREMIUM AUDIO',
                            ar: 'صوت فاخر',
                            id: 'AUDIO PREMIUM'),
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
                          title: _t(strings.language,
                              tr: 'Bugün: Tüm Kilitler Açılır',
                              en: 'Today: All Features Unlocked',
                              ar: 'اليوم: فتح جميع الميزات',
                              id: 'Hari Ini: Semua Fitur Terbuka'),
                          subtitle: _t(strings.language,
                              tr: 'Widget\'lar, tüm ezan makamları ve lüks temalar anında aktif.',
                              en: 'Lock screen widgets, adhan makams, and luxury themes active.',
                              ar: 'أدوات شاشة القفل، مقامات الأذان، والمظاهر الفاخرة فعالة.',
                              id: 'Widget layar kunci, makam adzan, dan tema mewah langsung aktif.'),
                          isLast: false,
                        ),
                        _buildTimelineStep(
                          icon: Icons.notifications_active_outlined,
                          title: _t(strings.language,
                              tr: '2 Gün İçinde: Hatırlatma',
                              en: 'In 2 Days: Gentle Reminder',
                              ar: 'خلال يومين: تذكير لطيف',
                              id: 'Dalam 2 Hari: Pengingat'),
                          subtitle: _t(strings.language,
                              tr: 'Deneme sürenizin bitmek üzere olduğunu size bildireceğiz.',
                              en: 'We will notify you that your free trial is ending.',
                              ar: 'سننبهك بأن فترتك التجريبية أوشكت على الانتهاء.',
                              id: 'Kami akan mengingatkan bahwa masa uji coba gratis Anda akan berakhir.'),
                          isLast: false,
                        ),
                        _buildTimelineStep(
                          icon: Icons.check_circle_outline_rounded,
                          title: _t(strings.language,
                              tr: '3. Gün: Faturalandırma Başlar',
                              en: 'Day 3: Billing Begins',
                              ar: 'اليوم الثالث: بدء الفوترة',
                              id: 'Hari ke-3: Penagihan Dimulai'),
                          subtitle: _t(strings.language,
                              tr: '$billingDateFormatted tarihine kadar dilediğiniz an tek tıkla iptal edebilirsiniz.',
                              en: 'Cancel anytime before $billingDateFormatted in App Store settings.',
                              ar: 'يمكنك الإلغاء في أي وقت قبل $billingDateFormatted من إعدادات المتجر.',
                              id: 'Batalkan kapan saja sebelum $billingDateFormatted di pengaturan App Store.'),
                          isLast: true,
                        ),
                      ] else if (_selectedTier == PremiumTier.lifetime) ...[
                        _buildTimelineStep(
                          icon: Icons.all_inclusive_rounded,
                          title: _t(strings.language,
                              tr: 'Ömür Boyu Tek Seferlik Ödeme',
                              en: 'Lifetime One-Time Purchase',
                              ar: 'شراء لمرة واحدة مدى الحياة',
                              id: 'Pembelian Sekali Seumur Hidup'),
                          subtitle: _t(strings.language,
                              tr: 'Asla yinelenen abonelik ücreti yok. Bir kez ödeyin, sonsuza dek kullanın.',
                              en: 'No recurring subscriptions ever. Pay once, enjoy forever.',
                              ar: 'لا توجد اشتراكات متكررة أبداً. ادفع مرة واستمتع للأبد.',
                              id: 'Tanpa biaya langganan berulang. Bayar sekali, nikmati selamanya.'),
                          isLast: false,
                        ),
                        _buildTimelineStep(
                          icon: Icons.verified_rounded,
                          title: _t(strings.language,
                              tr: 'Gelecek Tüm Güncellemeler Dahil',
                              en: 'All Future Updates Included',
                              ar: 'جميع التحديثات المستقبلية مشمولة',
                              id: 'Termasuk Semua Pembaruan Mendatang'),
                          subtitle: _t(strings.language,
                              tr: 'Gelecekte eklenecek yeni ezan makamları ve widget\'lar ücretsiz.',
                              en: 'Upcoming adhan makams and widget designs are free.',
                              ar: 'المقامات والأدوات الجديدة مستقبلاً مجاناً بالكامل.',
                              id: 'Makam adzan dan desain widget baru di masa mendatang gratis.'),
                          isLast: true,
                        ),
                      ] else ...[
                        _buildTimelineStep(
                          icon: Icons.calendar_month_rounded,
                          title: _t(strings.language,
                              tr: 'Aylık Esnek Kullanım',
                              en: 'Flexible Monthly Access',
                              ar: 'استخدام شهري مرن',
                              id: 'Akses Bulanan Fleksibel'),
                          subtitle: _t(strings.language,
                              tr: 'Ayda ₺49,99. İstediğiniz ay durdurup devam ettirebilirsiniz.',
                              en: '₺49.99 / month. Pause or cancel whenever you wish.',
                              ar: 'مرونة كاملة في الإلغاء أو التجديد شهرياً.',
                              id: '₺49,99 / bulan. Jeda atau batalkan kapan saja Anda inginkan.'),
                          isLast: true,
                        ),
                      ],

                      const SizedBox(height: 24),

                      // ── Paket Seçim Kartları (Aylık • Yıllık • Ömür Boyu) ────
                      // 1. Aylık Kart
                      _buildPricingCard(
                        subBadge: _t(strings.language,
                            tr: 'İstediğin zaman iptal',
                            en: 'Cancel anytime',
                            ar: 'إلغاء في أي وقت',
                            id: 'Batalkan kapan saja'),
                        title: strings.planMonthly,
                        price: '₺49,99',
                        totalPrice: _t(strings.language,
                            tr: '/ay', en: '/month', ar: '/شهر', id: '/bulan'),
                        isSelected: _selectedTier == PremiumTier.monthly,
                        onTap: () => setState(() => _selectedTier = PremiumTier.monthly),
                      ),
                      const SizedBox(height: 16),

                      // 2. Yıllık Kart (3 Gün Deneme - En Popüler)
                      _buildPricingCard(
                        topBadge: '${strings.badgeMostPopular} • %60',
                        subBadge: strings.badgeFreeTrial,
                        title: strings.planYearly,
                        price: _t(strings.language,
                            tr: '₺19,99 /ay',
                            en: '₺19.99 /mo',
                            ar: '١٩.٩٩ ₺ /شهر',
                            id: '₺19,99 /bln'),
                        oldPrice: '₺599,88',
                        totalPrice: _t(strings.language,
                            tr: '₺299,99 /yıl',
                            en: '₺299.99 /year',
                            ar: '٢٩٩.٩٩ ₺ /سنة',
                            id: '₺299,99 /tahun'),
                        isSelected: _selectedTier == PremiumTier.yearly,
                        onTap: () => setState(() => _selectedTier = PremiumTier.yearly),
                      ),
                      const SizedBox(height: 16),

                      // 3. Ömür Boyu Kart (Sonsuz Erişim - En Avantajlı)
                      _buildPricingCard(
                        topBadge: strings.badgeBestValue,
                        subBadge: strings.badgeNoSubscription,
                        title: strings.planLifetime,
                        price: '₺499,99',
                        totalPrice: _t(strings.language,
                            tr: 'Tek Seferlik',
                            en: 'One-Time',
                            ar: 'دفعة واحدة',
                            id: 'Sekali Bayar'),
                        isSelected: _selectedTier == PremiumTier.lifetime,
                        onTap: () => setState(() => _selectedTier = PremiumTier.lifetime),
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
                                      : _t(strings.language,
                                          tr: 'İstediğiniz zaman tek tıkla iptal',
                                          en: 'Cancel anytime in App Store',
                                          ar: 'إلغاء في أي وقت من المتجر',
                                          id: 'Batalkan kapan saja di App Store')),
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
                              ? _t(strings.language,
                                  tr: '3 gün ücretsiz, sonra yılda ₺299,99 • İstediğin zaman iptal',
                                  en: '3 days free, then ₺299.99 / year • Cancel anytime',
                                  ar: '٣ أيام مجاناً ثم ٢٩٩.٩٩ ₺ سنوياً • إلغاء بأي وقت',
                                  id: '3 hari gratis, lalu ₺299,99 / tahun • Batalkan kapan saja')
                              : (_selectedTier == PremiumTier.lifetime
                                  ? _t(strings.language,
                                      tr: '₺499,99 tek seferlik ödeme • Asla tekrar ücretlendirilmez',
                                      en: '₺499.99 one-time payment • Never billed again',
                                      ar: '٤٩٩.٩٩ ₺ دفعة واحدة لمرة واحدة',
                                      id: '₺499,99 sekali bayar • Tidak pernah ditagih lagi')
                                  : _t(strings.language,
                                      tr: 'Ayda ₺49,99 • İstediğin zaman iptal',
                                      en: '₺49.99 / month • Cancel anytime',
                                      ar: '٤٩.٩٩ ₺ شهرياً • إلغاء بأي وقت',
                                      id: '₺49,99 / bulan • Batalkan kapan saja')),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
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
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
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
                          size: 15,
                          color: Color(0xFF032620),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      if (subBadge != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          subBadge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isSelected ? const Color(0xFFFFDF7A) : Colors.white60,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    if (totalPrice != null) ...[
                      const SizedBox(height: 3),
                      Row(
                        mainAxisSize: MainAxisSize.min,
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

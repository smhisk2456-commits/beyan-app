import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widget_service.dart';
import '../../monetization/providers/premium_provider.dart';
import '../../monetization/screens/onboarding_trial_paywall_screen.dart';
import '../../monetization/widgets/banner_ad_widget.dart';

/// Kilit Ekranı Widget Kategorileri
enum WidgetCategoryType {
  quotes, // İslami Sözler, Dua ve Ayet
  dailyVerse, // Günün Ayeti
  prayerTimes, // Namaz Vakitleri
  countdown, // Namaz Geri Sayımı
  hijri, // Hicri Takvim
  sunTimes, // Güneş & Vakit
}

/// Kilit Ekranı & Widget Yönetim ve Özelleştirme Merkezi
class WidgetCenterScreen extends ConsumerStatefulWidget {
  const WidgetCenterScreen({super.key});

  @override
  ConsumerState<WidgetCenterScreen> createState() => _WidgetCenterScreenState();
}

class _WidgetCenterScreenState extends ConsumerState<WidgetCenterScreen> {
  WidgetCategoryType _selectedCategory = WidgetCategoryType.quotes;

  // Özelleştirme ayarları
  String _selectedQuoteCategory = 'Tümü';
  String _verseViewMode = 'Yalnızca Meal';
  String _refreshInterval = 'Her saat';
  String _textSize = 'Standart';
  String _fontFamily = 'Standart';

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedPreferences();
  }

  Future<void> _loadSavedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedQuoteCategory = prefs.getString('widget_quote_category') ?? 'Tümü';
      _verseViewMode = prefs.getString('widget_verse_view') ?? 'Yalnızca Meal';
      _refreshInterval = prefs.getString('widget_refresh_interval') ?? 'Her saat';
      _textSize = prefs.getString('widget_text_size') ?? 'Standart';
      _fontFamily = prefs.getString('widget_font_family') ?? 'Standart';
      _isLoading = false;
    });
  }

  Future<void> _savePreference(String key, String value, Function(String) updater) async {
    final premiumState = ref.read(premiumProvider);

    // 3 Günlük deneme bitti ve kullanıcı Premium değilse Paywall göster
    if (!premiumState.hasWidgetAccess) {
      OnboardingTrialPaywallScreen.show(context);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    setState(() => updater(value));
    HapticFeedback.lightImpact();

    // Widget verilerini arka planda güncelle
    await WidgetService().updateAllWidgets();
  }

  void _showOptionSheet<T>({
    required String title,
    required List<String> options,
    required String currentValue,
    required Function(String) onSelected,
  }) {
    final premiumState = ref.read(premiumProvider);
    if (!premiumState.hasWidgetAccess) {
      OnboardingTrialPaywallScreen.show(context);
      return;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF07211C) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...options.map((opt) {
                final isSelected = opt == currentValue;
                return ListTile(
                  title: Text(
                    opt,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? const Color(0xFFD4AF37)
                          : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_rounded, color: Color(0xFFD4AF37))
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    onSelected(opt);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final premiumState = ref.watch(premiumProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF051C17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF051C17),
        elevation: 0,
        title: const Text(
          'Kilit Ekranı Widget\'ları',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── 3 Günlük Deneme / Premium Durum Şeridi ────────────────
                  _buildTrialStatusBanner(premiumState),

                  const SizedBox(height: 16),

                  // ── Yatay Kategori İkon Seçici (6 İkon) ───────────────────
                  _buildCategoryIconsBar(),

                  const SizedBox(height: 24),

                  // ── Gerçekçi Kilit Ekranı Canlı Önizlemesi (9:41) ──────────
                  _buildLockScreenPhoneMockup(),

                  const SizedBox(height: 24),

                  // ── Başlık ve Açıklama ───────────────────────────────────
                  _buildWidgetTitleAndDescription(),

                  const SizedBox(height: 20),

                  // ── Özelleştirilebilir Seçenekler Listesi ─────────────────
                  _buildCustomizationOptionsCard(),

                  const SizedBox(height: 24),

                  // ── Özellikler (Yeşil Onay İşaretleri) ────────────────────
                  _buildFeaturesCard(),

                  const SizedBox(height: 24),

                  // ── Nasıl Eklenir Adımları ────────────────────────────────
                  _buildHowToAddGuide(),

                  const SizedBox(height: 20),

                  // Alt banner reklam
                  const BannerAdWidget(),
                ],
              ),
            ),
    );
  }

  // ── 3 Günlük Deneme Durum Şeridi ───────────────────────────────────────────
  Widget _buildTrialStatusBanner(PremiumState premiumState) {
    if (premiumState.isPremium) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
          ),
        ),
        child: const Row(
          children: [
            Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFDF7A), size: 18),
            SizedBox(width: 8),
            Text(
              '★ Beyân Premium: Sınırsız Widget Erişimi',
              style: TextStyle(
                color: Color(0xFFFFDF7A),
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      );
    }

    if (premiumState.isTrialActive) {
      return InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => OnboardingTrialPaywallScreen.show(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF0F3E33),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF2DD4BF).withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.timer_outlined, color: Color(0xFF2DD4BF), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '3 Günlük Ücretsiz Deneme Aktif (${premiumState.trialDaysRemaining} Gün Kaldı)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const Text(
                'Yükselt >',
                style: TextStyle(
                  color: Color(0xFF2DD4BF),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Deneme süresi doldu
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => OnboardingTrialPaywallScreen.show(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.amber.shade900.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.amber.shade600,
          ),
        ),
        child: const Row(
          children: [
            Icon(Icons.lock_clock_rounded, color: Colors.amber, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                '3 Günlük Deneme Süresi Doldu • Widget için Premium\'a Geçin',
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 11.5,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.amber, size: 12),
          ],
        ),
      ),
    );
  }

  // ── 6 İkonlu Yatay Kategori Çubuğu (Screenshots 2-5 üst kısmı) ─────────────
  Widget _buildCategoryIconsBar() {
    final categories = [
      (WidgetCategoryType.quotes, Icons.format_quote_rounded),
      (WidgetCategoryType.dailyVerse, Icons.menu_book_rounded),
      (WidgetCategoryType.prayerTimes, Icons.access_time_rounded),
      (WidgetCategoryType.countdown, Icons.timer_outlined),
      (WidgetCategoryType.hijri, Icons.nightlight_round),
      (WidgetCategoryType.sunTimes, Icons.wb_sunny_outlined),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: categories.map((item) {
          final isSelected = _selectedCategory == item.$1;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedCategory = item.$1);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? const Color(0xFF10B981)
                      : const Color(0xFF0E2C24),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF34D399)
                        : Colors.white.withValues(alpha: 0.1),
                    width: 1.2,
                  ),
                ),
                child: Icon(
                  item.$2,
                  color: isSelected ? Colors.white : Colors.white60,
                  size: 22,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Gerçekçi iPhone Kilit Ekranı Önizlemesi ────────────────────────────────
  Widget _buildLockScreenPhoneMockup() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
      decoration: BoxDecoration(
        color: const Color(0xFF041713),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Kilit Ekranı Tarihi veya Kompakt Satır Widget'ı ───────────────
          if (_selectedCategory == WidgetCategoryType.countdown) ...[
            // Screenshot 5: "Pazartesi, 6 Haziran | ⏱️ İkindi: 2:15:30"
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Pazartesi, 6 Haziran',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  '|',
                  style: TextStyle(color: Colors.white38),
                ),
                SizedBox(width: 6),
                Icon(Icons.timer_outlined, color: Colors.white, size: 14),
                SizedBox(width: 4),
                Text(
                  'İkindi: 2:15:30',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ] else ...[
            const Text(
              'Pazartesi, 6 Haziran',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          const SizedBox(height: 6),

          // ── Büyük Saat: "9:41" ───────────────────────────────────────────
          const Text(
            '9:41',
            style: TextStyle(
              fontSize: 76,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              letterSpacing: -2,
              height: 1.0,
            ),
          ),

          const SizedBox(height: 14),

          // ── Kilit Ekranı Saat Altı Widget Alanı ───────────────────────────
          _buildActiveWidgetPreviewContent(),
        ],
      ),
    );
  }

  // Aktif Kategoriye Göre Widget Önizleme İçeriği
  Widget _buildActiveWidgetPreviewContent() {
    switch (_selectedCategory) {
      case WidgetCategoryType.quotes:
        // Screenshot 2: "Bakara 2:152 / Beni anın ki, ben de sizi anayım."
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            children: [
              const Text(
                'Bakara 2:152',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Beni anın ki,\nben de sizi anayım.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 12,
                  height: 1.25,
                ),
              ),
            ],
          ),
        );

      case WidgetCategoryType.dailyVerse:
        // Screenshot 3: "İnşirah 94:6 / Şüphesiz her güçlükle bir kolaylık vardır."
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            children: [
              const Text(
                'İnşirah 94:6',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Şüphesiz her güçlükle\nbir kolaylık vardır.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 12,
                  height: 1.25,
                ),
              ),
            ],
          ),
        );

      case WidgetCategoryType.prayerTimes:
        // Screenshot 4: "Öğle 12:30 PM • İkindi 3:45 PM / 2:15:30"
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: const Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wb_sunny_rounded, color: Colors.white70, size: 13),
                  SizedBox(width: 4),
                  Text('Öğle 12:30 PM', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  SizedBox(width: 8),
                  Icon(Icons.wb_twilight_rounded, color: Colors.white70, size: 13),
                  SizedBox(width: 4),
                  Text('İkindi 3:45 PM', style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
              SizedBox(height: 4),
              Text(
                '2:15:30',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        );

      case WidgetCategoryType.countdown:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: const Text(
            'İkindi vaktine 2 saat 15 dk kaldı',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        );

      case WidgetCategoryType.hijri:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: const Column(
            children: [
              Text(
                '🌙 18 Ramazan 1447',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              SizedBox(height: 2),
              Text(
                'Kadir Gecesine 9 Gün Kaldı',
                style: TextStyle(color: Colors.white70, fontSize: 11.5),
              ),
            ],
          ),
        );

      case WidgetCategoryType.sunTimes:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wb_sunny_outlined, color: Colors.amber, size: 16),
              SizedBox(width: 6),
              Text(
                'Güneş: 05:42  •  İşrak: 06:27',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
    }
  }

  // ── Başlık & Açıklama Metni ───────────────────────────────────────────────
  Widget _buildWidgetTitleAndDescription() {
    String title;
    String desc;

    switch (_selectedCategory) {
      case WidgetCategoryType.quotes:
        title = 'İslami Sözler, Dua ve Ayet';
        desc =
            'Telefonunuzun kilidini açmadan Kilit Ekranınızda Kur\'an ayetlerini ve İslami alıntıları görüntüleyin.';
        break;
      case WidgetCategoryType.dailyVerse:
        title = 'Günün Ayeti';
        desc = 'Her gün otomatik olarak yeni bir ilham verici Kur\'an ayeti alın.';
        break;
      case WidgetCategoryType.prayerTimes:
        title = 'Namaz Vakitleri';
        desc =
            'Canlı geri sayım sayacıyla mevcut ve yaklaşan namaz vakitlerini görün.';
        break;
      case WidgetCategoryType.countdown:
        title = 'Namaz Geri Sayımı';
        desc =
            'Bir sonraki namazı canlı geri sayımla gösteren kompakt satır içi widget. Kilit Ekranınızda tarihin üzerinde görünür.';
        break;
      case WidgetCategoryType.hijri:
        title = 'Hicri Takvim & Kandiller';
        desc =
            'Hicri tarih, mübarek kandiller ve dini bayramları kilit ekranınızdan anlık takip edin.';
        break;
      case WidgetCategoryType.sunTimes:
        title = 'Güneş & Kerahat Vakti';
        desc =
            'Güneş doğuşunu, kerahat çıkışını ve işrak vaktini kilit ekranınızda izleyin.';
        break;
    }

    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            desc,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.white.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  // ── Özelleştirilebilir Seçenekler Kartı (Screenshots 2-3) ───────────────────
  Widget _buildCustomizationOptionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A241F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          // 1. Görüntülenecek Kategoriler (Yalnızca Quotes için)
          if (_selectedCategory == WidgetCategoryType.quotes) ...[
            _buildOptionTile(
              title: 'Görüntülenecek Kategoriler',
              value: _selectedQuoteCategory,
              onTap: () => _showOptionSheet(
                title: 'Kategori Seçin',
                options: const ['Tümü', 'Sabır ve Şükür', 'Dualar', 'İman ve Tevekkül', 'Ahlak'],
                currentValue: _selectedQuoteCategory,
                onSelected: (val) => _savePreference('widget_quote_category', val, (v) => _selectedQuoteCategory = v),
              ),
            ),
            _buildDivider(),
          ],

          // 2. Ayet Görünümü
          if (_selectedCategory == WidgetCategoryType.quotes ||
              _selectedCategory == WidgetCategoryType.dailyVerse) ...[
            _buildOptionTile(
              title: 'Ayet Görünümü',
              value: _verseViewMode,
              onTap: () => _showOptionSheet(
                title: 'Ayet Görünümü',
                options: const ['Yalnızca Meal', 'Arapça + Meal', 'Yalnızca Arapça'],
                currentValue: _verseViewMode,
                onSelected: (val) => _savePreference('widget_verse_view', val, (v) => _verseViewMode = v),
              ),
            ),
            _buildDivider(),
          ],

          // 3. Alıntı Yenileme Sıklığı
          _buildOptionTile(
            title: 'Alıntı Yenileme Sıklığı',
            value: _refreshInterval,
            onTap: () => _showOptionSheet(
              title: 'Yenileme Sıklığı',
              options: const ['15 Dakika', '30 Dakika', 'Her saat', 'Her gün'],
              currentValue: _refreshInterval,
              onSelected: (val) => _savePreference('widget_refresh_interval', val, (v) => _refreshInterval = v),
            ),
          ),
          _buildDivider(),

          // 4. Metin Boyutu
          _buildOptionTile(
            title: 'Metin Boyutu',
            value: _textSize,
            onTap: () => _showOptionSheet(
              title: 'Metin Boyutu',
              options: const ['Küçük', 'Standart', 'Büyük'],
              currentValue: _textSize,
              onSelected: (val) => _savePreference('widget_text_size', val, (v) => _textSize = v),
            ),
          ),
          _buildDivider(),

          // 5. Yazı Tipi
          _buildOptionTile(
            title: 'Yazı Tipi',
            value: _fontFamily,
            onTap: () => _showOptionSheet(
              title: 'Yazı Tipi',
              options: const ['Standart', 'Zarif (Lato)', 'Klasik (Amiri)'],
              currentValue: _fontFamily,
              onSelected: (val) => _savePreference('widget_font_family', val, (v) => _fontFamily = v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white38,
            size: 13,
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.8,
      color: Colors.white.withValues(alpha: 0.08),
      indent: 16,
      endIndent: 16,
    );
  }

  // ── Özellikler Listesi (Screenshots 3-4) ──────────────────────────────────
  Widget _buildFeaturesCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Özellikler',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0A241F),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            children: [
              _buildFeatureItem('Sonraki namaza canlı geri sayım'),
              const SizedBox(height: 12),
              _buildFeatureItem('Mevcut ve yaklaşan namazları gösterir'),
              const SizedBox(height: 12),
              _buildFeatureItem('Her namaz vaktinde otomatik güncellenir'),
              const SizedBox(height: 12),
              _buildFeatureItem('100% Çevrimdışı ve pil tasarruflu'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF10B981),
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 14,
            color: Color(0xFF032620),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ── Nasıl Eklenir Adımları (Screenshots 4-5) ──────────────────────────────
  Widget _buildHowToAddGuide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nasıl Eklenir',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0A241F),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            children: [
              _buildStepItem(
                number: '1',
                text:
                    'Uygulamadan çıkın ve kilit ekranınıza gidin (telefonunuzu kilitleyin, ardından kilidini açmadan ekranı uyandırın).',
              ),
              const SizedBox(height: 14),
              _buildStepItem(
                number: '2',
                text:
                    'Kilit ekranına basılı tutun ve alttaki \'Özelleştir\' butonuna dokunun.',
              ),
              const SizedBox(height: 14),
              _buildStepItem(
                number: '3',
                text:
                    'Saat alanına veya altına dokunarak \'Beyân\' widget\'ını seçip kilit ekranınıza ekleyin.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepItem({required String number, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF10B981),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Color(0xFF032620),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

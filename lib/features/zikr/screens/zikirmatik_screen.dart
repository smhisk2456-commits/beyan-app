import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/language_selector_sheet.dart';
import '../../widget_service/screens/widget_settings_dialog.dart';
import '../../monetization/providers/premium_provider.dart';
import '../../monetization/screens/premium_paywall_sheet.dart';
import '../../monetization/widgets/banner_ad_widget.dart';

/// Lüks Zikirmatik ve Tesbihat Ekranı.
class ZikirmatikScreen extends ConsumerStatefulWidget {
  const ZikirmatikScreen({super.key});

  @override
  ConsumerState<ZikirmatikScreen> createState() => _ZikirmatikScreenState();
}

class _ZikirmatikScreenState extends ConsumerState<ZikirmatikScreen>
    with SingleTickerProviderStateMixin {
  int _count = 0;
  int _target = 33;
  int _selectedDhikrIndex = 0;
  int _completedLaps = 0;

  final ScrollController _chipScrollController = ScrollController();
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;

  static const _dhikrList = [
    {
      'tr': 'Sübhanallâh',
      'en': 'SubhanAllah',
      'ar': 'سُبْحَانَ اللَّهِ',
      'meaning': 'Allah her türlü eksiklikten uzaktır',
    },
    {
      'tr': 'Elhamdülillâh',
      'en': 'Alhamdulillah',
      'ar': 'الْحَمْدُ لِلَّهِ',
      'meaning': 'Hamd ve övgü yalnızca Allah\'adır',
    },
    {
      'tr': 'Allâhu Ekber',
      'en': 'Allahu Akbar',
      'ar': 'اللَّهُ أَكْبَرُ',
      'meaning': 'Allah en büyüktür',
    },
    {
      'tr': 'Lâ ilâhe illallâh',
      'en': 'La ilaha illallah',
      'ar': 'لَا إِلَهَ إِلَّا اللَّهُ',
      'meaning': 'Allah\'tan başka ilah yoktur',
    },
    {
      'tr': 'Estağfirullâh',
      'en': 'Astaghfirullah',
      'ar': 'أَسْتَغْفِرُ اللَّهَ',
      'meaning': 'Allah\'tan bağışlanma dilerim',
    },
    {
      'tr': 'Salavât-ı Şerîfe',
      'en': 'Salawat',
      'ar': 'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ',
      'meaning': 'Allah\'ım Efendimiz Muhammed\'e salat eyle',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.94,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _chipScrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _increment() {
    HapticFeedback.lightImpact();
    _pulseController.reverse().then((_) => _pulseController.forward());

    setState(() {
      _count++;
      // Kullanıcının isteği: "zikirde ise 33 kere tıkladıktan sonra diğer zikire otomatik aktarsın"
      if (_count >= 33) {
        _completedLaps++;
        HapticFeedback.heavyImpact();

        final prevDhikr = _dhikrList[_selectedDhikrIndex];
        final nextIndex = (_selectedDhikrIndex + 1) % _dhikrList.length;
        final nextDhikr = _dhikrList[nextIndex];

        _count = 0;
        _selectedDhikrIndex = nextIndex;

        // Çip listesini yeni seçilen zikre doğru kaydır
        if (_chipScrollController.hasClients) {
          _chipScrollController.animateTo(
            nextIndex * 105.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }

        // Lüks geçiş bildirimi
        final strings = ref.read(appStringsProvider);
        final lang = strings.language;
        final prevTitle = lang == AppLanguage.english
            ? prevDhikr['en']
            : (lang == AppLanguage.arabic ? prevDhikr['ar'] : prevDhikr['tr']);
        final nextTitle = lang == AppLanguage.english
            ? nextDhikr['en']
            : (lang == AppLanguage.arabic ? nextDhikr['ar'] : nextDhikr['tr']);

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF012E2B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFD4AF37), width: 1.2),
            ),
            duration: const Duration(seconds: 2),
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFFFFDF7A), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    lang == AppLanguage.english
                        ? '$prevTitle completed (33) ➔ Switched to $nextTitle'
                        : (lang == AppLanguage.arabic
                            ? '$prevTitle اكتمل (٣٣) ➔ الانتقال إلى $nextTitle'
                            : '$prevTitle tamamlandı (33) ➔ $nextTitle\'a geçildi'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    });
  }

  void _reset() {
    HapticFeedback.mediumImpact();
    setState(() {
      _count = 0;
      _completedLaps = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    final currentLang = ref.watch(appLanguageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeDhikr = _dhikrList[_selectedDhikrIndex];

    final progress = _target > 0 ? (_count % _target) / _target : 0.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(strings.actionZikr),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => showLanguageSelectorSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(currentLang.flag, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 4),
                    Text(
                      currentLang.shortCode,
                      style: const TextStyle(
                        color: Color(0xFFFFDF7A),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              ref.watch(premiumProvider).isPremium
                  ? Icons.workspace_premium_rounded
                  : Icons.workspace_premium_outlined,
              color: const Color(0xFFFFDF7A),
            ),
            tooltip: ref.watch(premiumProvider).isPremium ? 'Beyân Premium' : 'Premium & Reklamsız',
            onPressed: () => PremiumPaywallSheet.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            tooltip: strings.settings,
            onPressed: () => showWidgetSettings(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Zikir Seçim Çipleri ─────────────────────────────────
              SizedBox(
                height: 38,
                child: ListView.separated(
                  controller: _chipScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _dhikrList.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final item = _dhikrList[index];
                    final isSelected = index == _selectedDhikrIndex;
                    final title = currentLang == AppLanguage.english
                        ? item['en']!
                        : (currentLang == AppLanguage.arabic
                            ? item['ar']!
                            : item['tr']!);

                    return ChoiceChip(
                      label: Text(title),
                      selected: isSelected,
                      onSelected: (_) {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedDhikrIndex = index;
                          _count = 0;
                          _completedLaps = 0;
                        });
                      },
                      selectedColor: const Color(0xFFD4AF37),
                      backgroundColor: isDark
                          ? const Color(0xFF07211C)
                          : Colors.grey.shade100,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? Colors.black
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFFD4AF37)
                              : Colors.transparent,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // ── Zikir Kartı (Arapça & Anlamı) ───────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF012E2B),
                      Color(0xFF023E36),
                      Color(0xFF01201D),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      activeDhikr['ar']!,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 26,
                        height: 1.5,
                        color: Color(0xFFFFDF7A),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currentLang == AppLanguage.english
                          ? activeDhikr['en']!
                          : activeDhikr['tr']!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activeDhikr['meaning']!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.65),
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Hedef & Tur Bilgisi ──────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _targetButton(33),
                  const SizedBox(width: 10),
                  _targetButton(99),
                  const SizedBox(width: 10),
                  _targetButton(0, label: '∞'),
                  const Spacer(),
                  if (_completedLaps > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        '$_completedLaps Tur',
                        style: const TextStyle(
                          color: Color(0xFFFFDF7A),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Dev Sayaç Dokunma Alanı (Interactive Dial) ───────────
              ScaleTransition(
                scale: _scaleAnimation,
                child: GestureDetector(
                  onTap: _increment,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Dış Çember Progress
                      SizedBox(
                        width: 220,
                        height: 220,
                        child: CircularProgressIndicator(
                          value: _target > 0 ? progress : 1.0,
                          strokeWidth: 7,
                          backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                        ),
                      ),
                      // İç Dokunma Butonu
                      Container(
                        width: 196,
                        height: 196,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [
                              Color(0xFF034A40),
                              Color(0xFF012E2B),
                              Color(0xFF011C19),
                            ],
                            stops: [0.0, 0.7, 1.0],
                          ),
                          border: Border.all(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                              blurRadius: 28,
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$_count',
                              style: const TextStyle(
                                fontSize: 52,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                            if (_target > 0)
                              Text(
                                '/ $_target',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFFFDF7A),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            const SizedBox(height: 6),
                            const Text(
                              'DOKUN',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white54,
                                letterSpacing: 2.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Sıfırla & Yardımcı Butonlar ───────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Sıfırla'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFD4AF37),
                      side: BorderSide(color: const Color(0xFFD4AF37).withValues(alpha: 0.4)),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // ── Saygılı Alt Banner Reklam (Premium'da otomatik gizlenir) ──
              const BannerAdWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _targetButton(int val, {String? label}) {
    final isSelected = _target == val;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _target = val;
          _count = 0;
          _completedLaps = 0;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFD4AF37)
              : (Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF07211C)
                  : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFD4AF37) : Colors.white12,
          ),
        ),
        child: Text(
          label ?? '$val',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.black : Colors.white70,
          ),
        ),
      ),
    );
  }
}

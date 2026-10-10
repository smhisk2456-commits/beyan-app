import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/language_selector_sheet.dart';
import '../../widget_service/screens/widget_settings_dialog.dart';
import '../../monetization/providers/premium_provider.dart';
import '../../monetization/screens/premium_paywall_sheet.dart';
import '../../monetization/widgets/banner_ad_widget.dart';
import '../models/worship_tracker_model.dart';

/// Lüks Zikirmatik ve İbadet Takibi Ekranı
class ZikirmatikScreen extends ConsumerStatefulWidget {
  const ZikirmatikScreen({super.key});

  @override
  ConsumerState<ZikirmatikScreen> createState() => _ZikirmatikScreenState();
}

class _ZikirmatikScreenState extends ConsumerState<ZikirmatikScreen>
    with TickerProviderStateMixin {
  int _activeTab = 0; // 0: Zikirmatik, 1: İbadet Takibi
  int _count = 0;
  int _target = 33;
  int _selectedDhikrIndex = 0;
  int _completedLaps = 0;
  int _verseShuffleOffset = 0;
  int _hapticMode = 1; // 0: Off, 1: Light, 2: Medium, 3: Heavy

  final ScrollController _chipScrollController = ScrollController();
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;

  late final AnimationController _plusOneController;
  late final Animation<double> _plusOneOpacity;
  late final Animation<Offset> _plusOneOffset;

  Future<void> _loadSavedDhikrState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCount = prefs.getInt('zikirmatik_count') ?? 0;
      final savedTarget = prefs.getInt('zikirmatik_target') ?? 33;
      final savedDhikrIndex = prefs.getInt('zikirmatik_selected_index') ?? 0;
      final savedLaps = prefs.getInt('zikirmatik_laps') ?? 0;
      final savedHaptic = prefs.getInt('zikirmatik_haptic_mode') ?? 1;

      if (mounted) {
        setState(() {
          _count = savedCount;
          _target = savedTarget;
          _selectedDhikrIndex = savedDhikrIndex.clamp(0, _dhikrList.length - 1);
          _completedLaps = savedLaps;
          _hapticMode = savedHaptic;
        });
        if (_chipScrollController.hasClients && _selectedDhikrIndex > 0) {
          _chipScrollController.animateTo(
            _selectedDhikrIndex * 105.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    } catch (_) {}
  }

  Future<void> _saveDhikrState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('zikirmatik_count', _count);
      await prefs.setInt('zikirmatik_target', _target);
      await prefs.setInt('zikirmatik_selected_index', _selectedDhikrIndex);
      await prefs.setInt('zikirmatik_laps', _completedLaps);
      await prefs.setInt('zikirmatik_haptic_mode', _hapticMode);
    } catch (_) {}
  }

  final List<Map<String, String>> _dhikrList = [
    {
      'tr': 'Sübhanallâh',
      'en': 'SubhanAllah',
      'ar': 'سُبْحَانَ اللَّهِ',
      'meaning': 'Allah her türlü eksiklikten uzaktır',
      'meaning_tr': 'Allah her türlü eksiklikten uzaktır',
      'meaning_en': 'Glory be to Allah, free of all imperfections',
      'meaning_ar': 'تنزيه الله عن كل نقص وعيب',
    },
    {
      'tr': 'Elhamdülillâh',
      'en': 'Alhamdulillah',
      'ar': 'الْحَمْدُ لِلَّهِ',
      'meaning': 'Hamd ve övgü yalnızca Allah\'adır',
      'meaning_tr': 'Hamd ve övgü yalnızca Allah\'adır',
      'meaning_en': 'All praise and gratitude is due to Allah alone',
      'meaning_ar': 'الثناء والشكر لله وحده على كل نعمه',
    },
    {
      'tr': 'Allâhu Ekber',
      'en': 'Allahu Akbar',
      'ar': 'اللَّهُ أَكْبَرُ',
      'meaning': 'Allah en büyüktür',
      'meaning_tr': 'Allah en büyüktür',
      'meaning_en': 'Allah is the Greatest above all things',
      'meaning_ar': 'الله أكبر وأعظم من كل شيء',
    },
    {
      'tr': 'Lâ ilâhe illallâh',
      'en': 'La ilaha illallah',
      'ar': 'لَا إِلَهَ إِلَّا اللَّهُ',
      'meaning': 'Allah\'tan başka ilah yoktur',
      'meaning_tr': 'Allah\'tan başka ilah yoktur',
      'meaning_en': 'There is no deity worthy of worship except Allah',
      'meaning_ar': 'لا معبود بحق إلا الله وحده لا شريك له',
    },
    {
      'tr': 'Estağfirullâh',
      'en': 'Astaghfirullah',
      'ar': 'أَسْتَغْفِرُ اللَّهَ',
      'meaning': 'Allah\'tan bağışlanma dilerim',
      'meaning_tr': 'Allah\'tan bağışlanma dilerim',
      'meaning_en': 'I seek the forgiveness of Allah',
      'meaning_ar': 'أطلب المغفرة والستر من الله تعالى',
    },
    {
      'tr': 'Salavât-ı Şerîfe',
      'en': 'Salawat',
      'ar': 'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ',
      'meaning': 'Allah\'ım Efendimiz Muhammed\'e salat eyle',
      'meaning_tr': 'Allah\'ım Efendimiz Muhammed\'e salat eyle',
      'meaning_en': 'O Allah, bestow blessings upon our Master Muhammad',
      'meaning_ar': 'اللهم صل وسلم وبارك على سيدنا محمد',
    },
  ];

  String _getDhikrMeaning(Map<String, String> dhikr, AppLanguage lang) {
    if (lang == AppLanguage.english) {
      return dhikr['meaning_en'] ?? dhikr['meaning_tr'] ?? dhikr['meaning'] ?? '';
    }
    if (lang == AppLanguage.arabic) {
      return dhikr['meaning_ar'] ?? dhikr['meaning_tr'] ?? dhikr['meaning'] ?? '';
    }
    return dhikr['meaning_tr'] ?? dhikr['meaning'] ?? '';
  }

  @override
  void initState() {
    super.initState();
    _loadSavedDhikrState();
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

    _plusOneController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _plusOneOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _plusOneController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
    _plusOneOffset = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -32),
    ).animate(
      CurvedAnimation(
        parent: _plusOneController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _chipScrollController.dispose();
    _pulseController.dispose();
    _plusOneController.dispose();
    super.dispose();
  }

  void _increment() {
    if (_hapticMode == 1) {
      HapticFeedback.lightImpact();
    } else if (_hapticMode == 2) {
      HapticFeedback.mediumImpact();
    } else if (_hapticMode == 3) {
      HapticFeedback.heavyImpact();
    }
    _pulseController.reverse().then((_) => _pulseController.forward());
    _plusOneController.forward(from: 0.0);

    setState(() {
      _count++;
      if (_target > 0 && _count >= _target) {
        _completedLaps++;
        HapticFeedback.heavyImpact();

        final prevDhikr = _dhikrList[_selectedDhikrIndex];
        final nextIndex = (_selectedDhikrIndex + 1) % _dhikrList.length;
        final nextDhikr = _dhikrList[nextIndex];

        _count = 0;
        _selectedDhikrIndex = nextIndex;

        if (_chipScrollController.hasClients) {
          _chipScrollController.animateTo(
            nextIndex * 105.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }

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
                        ? '$prevTitle completed ($_target) ➔ Switched to $nextTitle'
                        : (lang == AppLanguage.arabic
                            ? '$prevTitle اكتمل ($_target) ➔ الانتقال إلى $nextTitle'
                            : '$prevTitle tamamlandı ($_target) ➔ $nextTitle\'a geçildi'),
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
    _saveDhikrState();
  }

  void _undo() {
    if (_count > 0) {
      HapticFeedback.selectionClick();
      setState(() => _count--);
      _saveDhikrState();
    }
  }

  void _confirmReset() {
    final strings = ref.read(appStringsProvider);
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF032B25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFD4AF37), width: 1),
        ),
        title: Text(strings.resetConfirmTitle, style: const TextStyle(color: Color(0xFFFFDF7A))),
        content: Text(
          strings.resetConfirmDesc,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(strings.cancel, style: const TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              setState(() {
                _count = 0;
                _completedLaps = 0;
              });
              _saveDhikrState();
              Navigator.pop(ctx);
            },
            child: Text(strings.reset),
          ),
        ],
      ),
    );
  }

  void _showAddCustomDhikrDialog() {
    final strings = ref.read(appStringsProvider);
    final titleController = TextEditingController();
    final meaningController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF032B25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFD4AF37), width: 1),
        ),
        title: Text(strings.addCustomDhikr, style: const TextStyle(color: Color(0xFFFFDF7A))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: strings.customDhikrTitleHint,
                labelStyle: const TextStyle(color: Colors.white70),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37))),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: meaningController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: strings.customDhikrMeaningHint,
                labelStyle: const TextStyle(color: Colors.white70),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(strings.cancel, style: const TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.black),
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                setState(() {
                  final customMeaning = meaningController.text.trim().isNotEmpty
                      ? meaningController.text.trim()
                      : (strings.language == AppLanguage.english
                          ? 'Custom Dhikr'
                          : (strings.language == AppLanguage.arabic ? 'ذكر مخصص' : 'Özel zikir'));
                  _dhikrList.add({
                    'tr': title,
                    'en': title,
                    'ar': title,
                    'meaning': customMeaning,
                    'meaning_tr': customMeaning,
                    'meaning_en': customMeaning,
                    'meaning_ar': customMeaning,
                  });
                  _selectedDhikrIndex = _dhikrList.length - 1;
                  _count = 0;
                  _completedLaps = 0;
                });
              }
              Navigator.pop(ctx);
            },
            child: Text(strings.add),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    final currentLang = ref.watch(appLanguageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_activeTab == 0 ? strings.actionZikr : strings.worshipTrackerTab),
        centerTitle: true,
        actions: [
          // Özel zikir ekle butonu
          if (_activeTab == 0)
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFFFFDF7A)),
              tooltip: currentLang == AppLanguage.turkish
                  ? 'Özel Zikir Ekle'
                  : (currentLang == AppLanguage.english ? 'Add Custom Dhikr' : 'إضافة ذكر مخصص'),
              onPressed: _showAddCustomDhikrDialog,
            ),
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
            tooltip: ref.watch(premiumProvider).isPremium
                ? 'Beyân Premium'
                : (currentLang == AppLanguage.turkish
                    ? 'Premium & Reklamsız'
                    : (currentLang == AppLanguage.english ? 'Premium & Ad-Free' : 'نسخة مميزة بدون إعلانات')),
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
        child: Column(
          children: [
            // ── Üst Segment Seçici: Zikirmatik / İbadet Takibi ───────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF04201B) : const Color(0xFFE5EEEB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _activeTab = 0),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _activeTab == 0 ? const Color(0xFFD4AF37) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              strings.actionZikr,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _activeTab == 0 ? Colors.black : (isDark ? Colors.white70 : Colors.black87),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _activeTab = 1),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _activeTab == 1 ? const Color(0xFFD4AF37) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              strings.worshipTrackerTab,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _activeTab == 1 ? Colors.black : (isDark ? Colors.white70 : Colors.black87),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: _activeTab == 0
                  ? _buildZikirmatikView(isDark, currentLang)
                  : _buildWorshipTrackerView(isDark),
            ),

            // Alt banner reklam
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildZikirmatikView(bool isDark, AppLanguage currentLang) {
    final strings = ref.watch(appStringsProvider);
    final activeDhikr = _dhikrList[_selectedDhikrIndex];
    final progress = _target > 0 ? (_count % _target) / _target : 0.0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
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
                    : (currentLang == AppLanguage.arabic ? item['ar']! : item['tr']!);

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
                    _saveDhikrState();
                  },
                  selectedColor: const Color(0xFFD4AF37),
                  backgroundColor: isDark ? const Color(0xFF07211C) : Colors.grey.shade100,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.black : (isDark ? Colors.white70 : Colors.black87),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 14),

          // ── Zikir Kartı (Arapça & Anlamı) ───────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF012E2B), Color(0xFF023E36), Color(0xFF01201D)],
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
                const SizedBox(height: 4),
                Text(
                  currentLang == AppLanguage.english
                      ? (activeDhikr['en'] ?? activeDhikr['tr']!)
                      : (currentLang == AppLanguage.arabic
                          ? (activeDhikr['ar'] ?? activeDhikr['tr']!)
                          : activeDhikr['tr']!),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  _getDhikrMeaning(activeDhikr, currentLang),
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

          const SizedBox(height: 20),

          // ── Hedef Seçimi (33, 99, 100, Serbest) ───────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _targetButton(33),
              const SizedBox(width: 8),
              _targetButton(99),
              const SizedBox(width: 8),
              _targetButton(100),
              const SizedBox(width: 8),
              _targetButton(0, label: '∞'),
              const Spacer(),
              if (_completedLaps > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    strings.lapsText(_completedLaps),
                    style: const TextStyle(color: Color(0xFFFFDF7A), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Lüks Sayaç Dokunma Alanı (Yükselme Animasyonu & Parçacık) ─
          ScaleTransition(
            scale: _scaleAnimation,
            child: GestureDetector(
              onTap: _increment,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Dış Altın Halkalı İlerleme Göstergesi
                  SizedBox(
                    width: 228,
                    height: 228,
                    child: CircularProgressIndicator(
                      value: _target > 0 ? progress : 1.0,
                      strokeWidth: 8,
                      backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                    ),
                  ),

                  // Lüks İç Sayaç Küresi
                  Container(
                    width: 202,
                    height: 202,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFF04584C), Color(0xFF012E2B), Color(0xFF011512)],
                        stops: [0.0, 0.65, 1.0],
                      ),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.7),
                        width: 2.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Yüzen +1 Parçacık Animasyonu
                        SizedBox(
                          height: 22,
                          child: AnimatedBuilder(
                            animation: _plusOneController,
                            builder: (context, _) {
                              if (_plusOneController.value == 0.0 || _plusOneController.value == 1.0) {
                                return const SizedBox.shrink();
                              }
                              return Transform.translate(
                                offset: _plusOneOffset.value,
                                child: Opacity(
                                  opacity: _plusOneOpacity.value,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xFFFFDF7A),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Text(
                                      '+1',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFFFFDF7A),
                                        shadows: [
                                          Shadow(color: Color(0xFFD4AF37), blurRadius: 6),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Sayı Yükselme Animasyonu (Slide + Scale Pop)
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                              scale: Tween<double>(begin: 0.78, end: 1.0).animate(
                                CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                              ),
                              child: FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.0, 0.28),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                                  child: child,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            '$_count',
                            key: ValueKey<int>(_count),
                            style: const TextStyle(
                              fontSize: 54,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                              shadows: [
                                Shadow(color: Color(0xFFD4AF37), blurRadius: 14),
                              ],
                            ),
                          ),
                        ),

                        if (_target > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              '/ $_target',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFFFFDF7A),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                        const SizedBox(height: 6),
                        Text(
                          strings.tapToCount,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white54,
                            letterSpacing: 2.2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 22),

          // ── Geri Al ve Sıfırla Butonları ─────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: _undo,
                icon: const Icon(Icons.undo_rounded, size: 18),
                label: Text(strings.undo),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(width: 14),
              OutlinedButton.icon(
                onPressed: _confirmReset,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(strings.reset),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFD4AF37),
                  side: BorderSide(color: const Color(0xFFD4AF37).withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ── Titreşim / Dokunuş Hissi Seçici ──────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF04201B) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _hapticMode == 0 ? Icons.vibration_outlined : Icons.vibration_rounded,
                  size: 16,
                  color: const Color(0xFFFFDF7A),
                ),
                const SizedBox(width: 8),
                Text(
                  strings.hapticTitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 10),
                _hapticChip(1, strings.hapticLight, isDark),
                const SizedBox(width: 4),
                _hapticChip(2, strings.hapticMedium, isDark),
                const SizedBox(width: 4),
                _hapticChip(3, strings.hapticHeavy, isDark),
                const SizedBox(width: 4),
                _hapticChip(0, strings.hapticOff, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hapticChip(int mode, String label, bool isDark) {
    final isSelected = _hapticMode == mode;
    return InkWell(
      onTap: () {
        setState(() => _hapticMode = mode);
        _saveDhikrState();
        if (mode == 1) HapticFeedback.lightImpact();
        if (mode == 2) HapticFeedback.mediumImpact();
        if (mode == 3) HapticFeedback.heavyImpact();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.black : (isDark ? Colors.white60 : Colors.black54),
          ),
        ),
      ),
    );
  }

  Widget _buildWorshipTrackerView(bool isDark) {
    final strings = ref.watch(appStringsProvider);
    final todayEntry = ref.watch(todayWorshipEntryProvider);
    final streakData = ref.watch(worshipStreakProvider);
    final completedCount = todayEntry.completedCount;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
      children: [
        // ── 1. Günlük Seri & Motivasyon Kartı (🔥 10, 30, 50, 100, 200, 400 Gün) ──
        _buildStreakCard(streakData, isDark),
        const SizedBox(height: 14),

        // ── 2. Günlük İlerleme & 7/7 Tamamlanma Kutlama Kartı ─────────
        if (todayEntry.isFullyCompleted)
          _buildCompletionCelebrationCard(streakData, todayEntry, isDark)
        else
          _buildProgressCard(completedCount, todayEntry, isDark),
        const SizedBox(height: 18),

        // ── 3. 5 Vakit Namaz Kontrol Listesi ─────────────────────────
        _buildHabitItem(strings.habitFajr, 'fajr', todayEntry.fajr, Icons.wb_twilight_rounded, isDark),
        _buildHabitItem(strings.habitDhuhr, 'dhuhr', todayEntry.dhuhr, Icons.wb_sunny_rounded, isDark),
        _buildHabitItem(strings.habitAsr, 'asr', todayEntry.asr, Icons.wb_sunny_outlined, isDark),
        _buildHabitItem(strings.habitMaghrib, 'maghrib', todayEntry.maghrib, Icons.nights_stay_outlined, isDark),
        _buildHabitItem(strings.habitIsha, 'isha', todayEntry.isha, Icons.nightlight_round, isDark),
        const SizedBox(height: 10),

        // ── 4. Kur'an & Zikir Takibi ────────────────────────────────
        _buildHabitItem(strings.habitQuran, 'quran', todayEntry.quran, Icons.menu_book_rounded, isDark),
        _buildHabitItem(strings.habitZikr, 'zikr', todayEntry.zikr, Icons.fingerprint_rounded, isDark),
      ],
    );
  }

  /// Günlük Seri & Motivasyon Kartı
  Widget _buildStreakCard(WorshipStreakData streak, bool isDark) {
    final strings = ref.watch(appStringsProvider);
    final hasStreak = streak.currentStreak > 0;
    final nextMilestone = streak.nextMilestone;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF04241E), const Color(0xFF07382E)]
              : [const Color(0xFF063B32), const Color(0xFF084F43)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst Satır: Seri Başlığı + En İyi Seri Rozeti
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFDF7A).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Text('🔥', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasStreak
                            ? strings.streakDaysTitle(streak.currentStreak)
                            : strings.startStreak,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFDF7A),
                        ),
                      ),
                      Text(
                        streak.isTodayCompleted
                            ? strings.todayAllTasksDone
                            : strings.remainingTasksText(7 - streak.todayCompletedCount),
                        style: TextStyle(
                          fontSize: 12,
                          color: streak.isTodayCompleted
                              ? const Color(0xFF85E3B3)
                              : Colors.white70,
                          fontWeight: streak.isTodayCompleted
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // En İyi Seri
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.emoji_events_rounded,
                        color: Color(0xFFFFDF7A), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      strings.bestStreakLabel(streak.bestStreak),
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // İlerleme ve Bir Sonraki Hedef (10, 30, 50, 100, 200, 400 Gün)
          if (nextMilestone != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(nextMilestone.badgeIcon,
                        style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      strings.targetMilestoneLabel(nextMilestone.localizedBadgeName(strings.language.code)),
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Text(
                  strings.daysRemainingText(streak.daysToNextMilestone),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFDF7A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: streak.milestoneProgress,
                minHeight: 7,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFDF7A)),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Motive Edici Sure & Ödüller Butonu
          InkWell(
            onTap: () => _showMilestonesSheet(context, streak, isDark),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.workspace_premium_rounded,
                      color: Color(0xFFFFDF7A), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '${strings.spiritualRewardsBtn} (10-400 Gün)',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFDF7A),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded,
                      color: Color(0xFFFFDF7A), size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tüm ibadetler (7/7) bittiğinde gösterilen lüks tebrik kartı & her gün farklı Kur'an ayeti
  Widget _buildCompletionCelebrationCard(WorshipStreakData streakData, DailyWorshipEntry todayEntry, bool isDark) {
    final strings = ref.watch(appStringsProvider);
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final verse = DailyCompletionVerse.getByIndex(dayOfYear + _verseShuffleOffset);
    final streakDay = streakData.currentStreak > 0 ? streakData.currentStreak : 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF042F26), const Color(0xFF02231C)]
              : [const Color(0xFF063F34), const Color(0xFF022A23)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFD4AF37),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Üst Satır: 7/7 Başarı Rozeti + "X. Gün Görevi Tamamlandı!" ──
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD4AF37), Color(0xFFFFDF7A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_rounded,
                    color: Color(0xFF012E2B),
                    size: 34,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.dayTasksCompleted(streakDay),
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFDF7A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      strings.allTasksCompletedMessage,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Günün Tebrik Âyeti Kartı (Her gün farklı ayet) ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Başlık & Başka Âyet Butonu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Color(0xFFFFDF7A), size: 15),
                        const SizedBox(width: 6),
                        Text(
                          '${strings.dailyCompletionVerseBadge} • ${verse.verseReference}',
                          style: const TextStyle(
                            color: Color(0xFFFFDF7A),
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _verseShuffleOffset++;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.refresh_rounded, color: Colors.white70, size: 13),
                            const SizedBox(width: 4),
                            Text(
                              strings.anotherVerse,
                              style: const TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Arapça Âyet Metni (Amiri Fontu)
                Text(
                  verse.arabicText,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 18,
                    height: 1.6,
                    color: Color(0xFFFFDF7A),
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),

                const SizedBox(height: 8),

                // Türkçe Meal
                Text(
                  verse.turkishMeaning,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Manevi Not
                Text(
                  '🤲 ${verse.spiritualNote}',
                  style: const TextStyle(
                    color: Color(0xFF85E3B3),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 7/7 tamamlanmadan önce gösterilen standart ilerleme kartı
  Widget _buildProgressCard(int completedCount, DailyWorshipEntry todayEntry, bool isDark) {
    final strings = ref.watch(appStringsProvider);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF012E2B), Color(0xFF034A3E)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: todayEntry.completionRatio,
                  strokeWidth: 6,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                ),
              ),
              Text(
                '$completedCount/7',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.language == AppLanguage.turkish
                      ? 'Bugünkü İbadet İlerlemeniz'
                      : (strings.language == AppLanguage.english
                          ? 'Today\'s Worship Progress'
                          : 'تقدم عباداتك اليوم'),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFFFDF7A)),
                ),
                const SizedBox(height: 4),
                Text(
                  completedCount == 0
                      ? (strings.language == AppLanguage.turkish
                          ? '5 Vakit Namaz, Kur\'an-ı Kerim tilaveti ve günlük zikrinizi buradan takip edin.'
                          : (strings.language == AppLanguage.english
                              ? 'Track your 5 daily prayers, Quran recitation and dhikr here.'
                              : 'تابع صلواتك الخمس، تلاوة القرآن وأذكارك اليومية هنا.'))
                      : strings.remainingTasksText(7 - completedCount),
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Dönüm Noktaları, Sureler ve Ödüller Alt Sayfası
  void _showMilestonesSheet(BuildContext context, WorshipStreakData streak, bool isDark) {
    final strings = ref.read(appStringsProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF031B17) : const Color(0xFF052B24),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
              width: 1.2,
            ),
          ),
          child: Column(
            children: [
              // Üst Sürükleme Çizgisi
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),

              // Başlık
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      strings.language == AppLanguage.turkish
                          ? 'İbadet Serisi Dönüm Noktaları & Beratlar'
                          : (strings.language == AppLanguage.english
                              ? 'Worship Streak Milestones & Certificates'
                              : 'محطات ومعالم سلسلة العبادات'),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFDF7A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      strings.language == AppLanguage.turkish
                          ? '5 Vakit namaz, Kur\'an ve zikir ile serinizi koruyun. Her dönüm noktasında (10, 30, 50, 100, 200, 400. gün) motive edici sure ve beratlar kazanın.'
                          : (strings.language == AppLanguage.english
                              ? 'Maintain your streak with prayers, Quran, and dhikr. Unlock inspiring surahs and certificates at each milestone.'
                              : 'حافظ على سلسلتك مع الصلوات والقرآن والذكر. وافتح سورًا ملهمة وشهادات عند كل محطة.'),
                      style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.white12, height: 1),

              // Dönüm Noktaları Listesi
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                  physics: const BouncingScrollPhysics(),
                  itemCount: WorshipStreakMilestone.allMilestones.length,
                  itemBuilder: (context, index) {
                    final milestone = WorshipStreakMilestone.allMilestones[index];
                    final isUnlocked = streak.currentStreak >= milestone.days ||
                        streak.bestStreak >= milestone.days;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? const Color(0xFF083C32)
                            : Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isUnlocked
                              ? const Color(0xFFD4AF37)
                              : Colors.white12,
                          width: isUnlocked ? 1.4 : 1,
                        ),
                        boxShadow: isUnlocked
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Başlık Satırı
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(milestone.badgeIcon,
                                      style: const TextStyle(fontSize: 22)),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        milestone.title,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: isUnlocked
                                              ? const Color(0xFFFFDF7A)
                                              : Colors.white,
                                        ),
                                      ),
                                      Text(
                                        strings.language == AppLanguage.turkish
                                            ? '${milestone.days}. Gün Hedefi'
                                            : (strings.language == AppLanguage.english
                                                ? 'Day ${milestone.days} Goal'
                                                : 'هدف اليوم ${milestone.days}'),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isUnlocked
                                              ? const Color(0xFF85E3B3)
                                              : Colors.white60,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // Rozet Durumu
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isUnlocked
                                      ? const Color(0xFFD4AF37)
                                      : Colors.white10,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  isUnlocked
                                      ? (strings.language == AppLanguage.turkish
                                        ? '🏆 KAZANILDI'
                                        : (strings.language == AppLanguage.english
                                            ? '🏆 UNLOCKED'
                                            : '🏆 مكتمل'))
                                      : '🔒 ${milestone.days - streak.currentStreak > 0 ? (strings.language == AppLanguage.turkish ? "${milestone.days - streak.currentStreak} Gün" : (strings.language == AppLanguage.english ? "${milestone.days - streak.currentStreak} Days" : "${milestone.days - streak.currentStreak} يوم")) : (strings.language == AppLanguage.turkish ? "Kilitli" : (strings.language == AppLanguage.english ? "Locked" : "مقفل"))}',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: isUnlocked ? Colors.black87 : Colors.white60,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Sure & Ayet Referansı
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.menu_book_rounded,
                                    color: Color(0xFFFFDF7A), size: 14),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Motive Edici Sure: ${milestone.ayahReference}',
                                    style: const TextStyle(
                                      color: Color(0xFFFFDF7A),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Ayet Metni ve Meali (Açılmışsa veya detaylı)
                          if (isUnlocked) ...[
                            Text(
                              milestone.arabicText,
                              style: const TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 16,
                                height: 1.6,
                                color: Color(0xFFFFDF7A),
                              ),
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              milestone.turkishMeaning,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                                fontStyle: FontStyle.italic,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.stars_rounded,
                                    color: Color(0xFF85E3B3), size: 14),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    milestone.spiritualVirtue,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFF85E3B3),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            Text(
                              'Bu beratı ve ${milestone.surahName} müjdesini açmak için ${milestone.days} gün boyunca 5 vakit namaz ve zikrinizi eksiksiz tamamlayın.',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Colors.white54,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Dönüm Noktasına Ulaşıldığında Tebrik Modalı
  void _showCelebrationDialog(BuildContext context, WorshipStreakMilestone milestone) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF012E2B), Color(0xFF034A3E), Color(0xFF011C18)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFD4AF37), width: 1.8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(milestone.badgeIcon, style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 10),
                  const Text(
                    '🎉 MAŞAALLAH! 🎉',
                    style: TextStyle(
                      color: Color(0xFFFFDF7A),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${milestone.days}. GÜN SERİSİNE ULAŞTINIZ!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD4AF37)),
                    ),
                    child: Text(
                      milestone.badgeName,
                      style: const TextStyle(
                        color: Color(0xFFFFDF7A),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Motive Edici Sure: ${milestone.surahName}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          milestone.arabicText,
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 17,
                            height: 1.6,
                            color: Color(0xFFFFDF7A),
                          ),
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          milestone.turkishMeaning,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Colors.white70,
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    milestone.spiritualVirtue,
                    style: const TextStyle(
                      color: Color(0xFF85E3B3),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF012E2B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text(
                      'Manevi Beratı Kabul Et 🤲',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHabitItem(String title, String habitKey, bool isCompleted, IconData icon, bool isDark) {
    Future<void> handleToggle() async {
      HapticFeedback.lightImpact();
      final milestone = await ref.read(worshipTrackerProvider.notifier).toggleHabit(habitKey: habitKey);
      if (milestone != null && mounted) {
        _showCelebrationDialog(context, milestone);
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF06221D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFFD4AF37)
              : (isDark ? const Color(0xFF133B34) : const Color(0xFFE2EBE8)),
          width: isCompleted ? 1.4 : 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isCompleted
                ? const Color(0xFFD4AF37).withValues(alpha: 0.2)
                : (isDark ? Colors.white10 : Colors.grey.shade100),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isCompleted ? const Color(0xFFFFDF7A) : Colors.grey, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: isCompleted ? FontWeight.bold : FontWeight.w500,
            color: isDark ? Colors.white : Colors.black87,
            decoration: isCompleted ? TextDecoration.none : null,
          ),
        ),
        trailing: Checkbox(
          value: isCompleted,
          activeColor: const Color(0xFFD4AF37),
          checkColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          onChanged: (_) => handleToggle(),
        ),
        onTap: handleToggle,
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
        _saveDhikrState();
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

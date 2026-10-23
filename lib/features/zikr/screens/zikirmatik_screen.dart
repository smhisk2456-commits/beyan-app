import 'package:islamic_app/core/theme/beyan_colors.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../settings/screens/settings_screen.dart';
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

  late final AnimationController _shimmerController;
  late final Animation<double> _shimmerAnimation;

  late final AnimationController _countPopController;
  late final Animation<double> _countPopScale;

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
      'id': 'SubhanAllah',
      'ar': 'سُبْحَانَ اللَّهِ',
      'ur': 'سبحان اللہ',
      'meaning': 'Allah her türlü eksiklikten uzaktır',
      'meaning_tr': 'Allah her türlü eksiklikten uzaktır',
      'meaning_en': 'Glory be to Allah, free of all imperfections',
      'meaning_id': 'Maha Suci Allah dari segala kekurangan',
      'meaning_ar': 'تنزيه الله عن كل نقص وعيب',
      'meaning_fr': 'Gloire à Allah, exempt de toute imperfection',
      'meaning_de': 'Gepriesen sei Allah, frei von allen Mängeln',
      'meaning_ru': 'Пречист Аллах от всяких недостатков',
      'meaning_ur': 'اللہ ہر قسم کے نقص سے پاک ہے',
    },
    {
      'tr': 'Elhamdülillâh',
      'en': 'Alhamdulillah',
      'id': 'Alhamdulillah',
      'ar': 'الْحَمْدُ لِلَّهِ',
      'ur': 'الحمد للہ',
      'meaning': 'Hamd ve övgü yalnızca Allah\'adır',
      'meaning_tr': 'Hamd ve övgü yalnızca Allah\'adır',
      'meaning_en': 'All praise and gratitude is due to Allah alone',
      'meaning_id': 'Segala puji dan syukur hanya bagi Allah',
      'meaning_ar': 'الثناء والشكر لله وحده على كل نعمه',
      'meaning_fr': 'Toutes les louanges sont à Allah seul',
      'meaning_de': 'Alles Lob gebührt allein Allah',
      'meaning_ru': 'Вся хвала принадлежит только Аллаху',
      'meaning_ur': 'تمام تعریفیں صرف اللہ ہی کے لیے ہیں',
    },
    {
      'tr': 'Allâhu Ekber',
      'en': 'Allahu Akbar',
      'id': 'Allahu Akbar',
      'ar': 'اللَّهُ أَكْبَرُ',
      'ur': 'اللہ اکبر',
      'meaning': 'Allah en büyüktür',
      'meaning_tr': 'Allah en büyüktür',
      'meaning_en': 'Allah is the Greatest above all things',
      'meaning_id': 'Allah Maha Besar di atas segala sesuatu',
      'meaning_ar': 'الله أكبر وأعظم من كل شيء',
      'meaning_fr': 'Allah est le Plus Grand',
      'meaning_de': 'Allah ist der Größte',
      'meaning_ru': 'Аллах Превелик',
      'meaning_ur': 'اللہ سب سے بڑا ہے',
    },
    {
      'tr': 'Lâ ilâhe illallâh',
      'en': 'La ilaha illallah',
      'id': 'La ilaha illallah',
      'ar': 'لَا إِلَهَ إِلَّا اللَّهُ',
      'ur': 'لا الہ الا اللہ',
      'meaning': 'Allah\'tan başka ilah yoktur',
      'meaning_tr': 'Allah\'tan başka ilah yoktur',
      'meaning_en': 'There is no deity worthy of worship except Allah',
      'meaning_id': 'Tiada Tuhan yang berhak disembah selain Allah',
      'meaning_ar': 'لا معبود بحق إلا الله وحده لا شريك له',
      'meaning_fr': 'Nul divinité digne d\'adoration sauf Allah',
      'meaning_de': 'Es gibt keinen Gott außer Allah',
      'meaning_ru': 'Нет божества, кроме Аллаха',
      'meaning_ur': 'اللہ کے سوا کوئی معبود نہیں',
    },
    {
      'tr': 'Estağfirullâh',
      'en': 'Astaghfirullah',
      'id': 'Astaghfirullah',
      'ar': 'أَسْتَغْفِرُ اللَّهَ',
      'ur': 'استغفر اللہ',
      'meaning': 'Allah\'tan bağışlanma dilerim',
      'meaning_tr': 'Allah\'tan bağışlanma dilerim',
      'meaning_en': 'I seek the forgiveness of Allah',
      'meaning_id': 'Aku memohon ampunan kepada Allah',
      'meaning_ar': 'أطلب المغفرة والستر من الله تعالى',
      'meaning_fr': 'Je demande pardon à Allah',
      'meaning_de': 'Ich bitte Allah um Vergebung',
      'meaning_ru': 'Прошу прощения у Аллаха',
      'meaning_ur': 'میں اللہ سے معافی مانگتا ہوں',
    },
    {
      'tr': 'Salavât-ı Şerîfe',
      'en': 'Salawat',
      'id': 'Shalawat',
      'ar': 'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ',
      'ur': 'درود شریف',
      'meaning': 'Allah\'ım Efendimiz Muhammed\'e salat eyle',
      'meaning_tr': 'Allah\'ım Efendimiz Muhammed\'e salat eyle',
      'meaning_en': 'O Allah, bestow blessings upon our Master Muhammad',
      'meaning_id': 'Ya Allah, limpahkanlah shalawat kepada junjungan kami Nabi Muhammad',
      'meaning_ar': 'اللهم صل وسلم وبارك على سيدنا محمد',
      'meaning_fr': 'Ô Allah, répands Tes bénédictions sur notre Prophète Muhammad',
      'meaning_de': 'O Allah, segne unseren Meister Muhammad',
      'meaning_ru': 'О Аллах, благослови нашего Пророка Мухаммада',
      'meaning_ur': 'اے اللہ! ہمارے آقا حضرت محمد پر رحمتیں نازل فرما',
    },
  ];

  String _getDhikrMeaning(Map<String, String> dhikr, AppLanguage lang) {
    switch (lang) {
      case AppLanguage.indonesian:
        return dhikr['meaning_id'] ?? dhikr['meaning_en'] ?? '';
      case AppLanguage.english:
        return dhikr['meaning_en'] ?? '';
      case AppLanguage.arabic:
        return dhikr['meaning_ar'] ?? '';
      case AppLanguage.french:
        return dhikr['meaning_fr'] ?? dhikr['meaning_en'] ?? '';
      case AppLanguage.german:
        return dhikr['meaning_de'] ?? dhikr['meaning_en'] ?? '';
      case AppLanguage.russian:
        return dhikr['meaning_ru'] ?? dhikr['meaning_en'] ?? '';
      case AppLanguage.urdu:
        return dhikr['meaning_ur'] ?? dhikr['meaning_ar'] ?? '';
      case AppLanguage.turkish:
        return dhikr['meaning_tr'] ?? dhikr['meaning'] ?? '';
    }
  }

  String _getDhikrTitle(Map<String, String> dhikr, AppLanguage lang) {
    switch (lang) {
      case AppLanguage.indonesian:
        return dhikr['id'] ?? dhikr['en'] ?? dhikr['tr']!;
      case AppLanguage.arabic:
        return dhikr['ar']!;
      case AppLanguage.urdu:
        return dhikr['ur'] ?? dhikr['ar']!;
      case AppLanguage.turkish:
        return dhikr['tr']!;
      default:
        return dhikr['en'] ?? dhikr['tr']!;
    }
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

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _shimmerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _countPopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _countPopScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.20).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.20, end: 1.0).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 65,
      ),
    ]).animate(_countPopController);
  }

  @override
  void dispose() {
    _chipScrollController.dispose();
    _pulseController.dispose();
    _plusOneController.dispose();
    _shimmerController.dispose();
    _countPopController.dispose();
    super.dispose();
  }

  void _increment() {
    if (_hapticMode == 1) {
      HapticFeedback.selectionClick();
    } else if (_hapticMode == 2) {
      HapticFeedback.mediumImpact();
    } else if (_hapticMode == 3) {
      HapticFeedback.heavyImpact();
    }
    _pulseController.reverse().then((_) => _pulseController.forward());
    _plusOneController.forward(from: 0.0);
    _shimmerController.forward(from: 0.0);
    _countPopController.forward(from: 0.0);

    setState(() {
      _count++; if (_count % 33 == 0 && _count != _target) { HapticFeedback.mediumImpact(); }
      if (_target > 0 && _count >= _target) {
        _completedLaps++; Future.delayed(const Duration(milliseconds: 100), () => HapticFeedback.mediumImpact());
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
        final prevTitle = _getDhikrTitle(prevDhikr, lang);
        final nextTitle = _getDhikrTitle(nextDhikr, lang);

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: BeyanColors.tone(0xFF012E2B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: BeyanColors.tone(0xFFD4AF37), width: 1.2),
            ),
            duration: const Duration(seconds: 2),
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    lang == AppLanguage.indonesian
                        ? '$prevTitle selesai ($_target) ➔ Beralih ke $nextTitle'
                        : (lang == AppLanguage.english
                            ? '$prevTitle completed ($_target) ➔ Switched to $nextTitle'
                            : (lang == AppLanguage.arabic
                                ? '$prevTitle اكتمل ($_target) ➔ الانتقال إلى $nextTitle'
                                : (lang != AppLanguage.turkish
                                    ? '$prevTitle completed ($_target) ➔ Switched to $nextTitle'
                                    : '$prevTitle tamamlandı ($_target) ➔ $nextTitle\'a geçildi'))),
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
        backgroundColor: BeyanColors.tone(0xFF032B25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: BeyanColors.tone(0xFFD4AF37), width: 1),
        ),
        title: Text(strings.resetConfirmTitle, style: TextStyle(color: BeyanColors.tone(0xFFFFDF7A))),
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
              backgroundColor: BeyanColors.tone(0xFFD4AF37),
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
        backgroundColor: BeyanColors.tone(0xFF032B25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: BeyanColors.tone(0xFFD4AF37), width: 1),
        ),
        title: Text(strings.addCustomDhikr, style: TextStyle(color: BeyanColors.tone(0xFFFFDF7A))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: strings.customDhikrTitleHint,
                labelStyle: const TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: BeyanColors.tone(0xFFD4AF37))),
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
            style: ElevatedButton.styleFrom(backgroundColor: BeyanColors.tone(0xFFD4AF37), foregroundColor: Colors.black),
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                setState(() {
                  final customMeaning = meaningController.text.trim().isNotEmpty
                      ? meaningController.text.trim()
                      : (strings.language == AppLanguage.turkish
                          ? 'Özel zikir'
                          : (strings.language == AppLanguage.arabic
                              ? 'ذكر مخصص'
                              : (strings.language == AppLanguage.indonesian
                                  ? 'Dzikir Khusus'
                                  : 'Custom Dhikr')));
                  _dhikrList.add({
                    'tr': title,
                    'en': title,
                    'ar': title,
                    'id': title,
                    'meaning': customMeaning,
                    'meaning_tr': customMeaning,
                    'meaning_en': customMeaning,
                    'meaning_ar': customMeaning,
                    'meaning_id': customMeaning,
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
    final effectivePalette = ref.watch(effectivePaletteProvider);
    BeyanColors.setPalette(effectivePalette);
    final strings = ref.watch(appStringsProvider);
    final currentLang = ref.watch(appLanguageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? effectivePalette.darkBackground : effectivePalette.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? effectivePalette.darkSurface : effectivePalette.primaryColor,
        title: Text(_activeTab == 0 ? strings.actionZikr : strings.worshipTrackerTab),
        centerTitle: true,
        actions: [
          // Özel zikir ekle butonu (Zikir sekmesinde aktif)
          if (_activeTab == 0)
            IconButton(
              icon: Icon(Icons.add_circle_outline_rounded, color: BeyanColors.tone(0xFFFFDF7A)),
              tooltip: strings.addCustomDhikr,
              onPressed: _showAddCustomDhikrDialog,
            ),
          // Lüks Ayarlar Butonu
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            tooltip: strings.settings,
            onPressed: () => SettingsScreen.show(context),
          ),
          const SizedBox(width: 6),
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
                  color: isDark ? BeyanColors.tone(0xFF04201B) : BeyanColors.tone(0xFFE5EEEB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.3),
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
                            color: _activeTab == 0 ? BeyanColors.tone(0xFFD4AF37) : Colors.transparent,
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
                            color: _activeTab == 1 ? BeyanColors.tone(0xFFD4AF37) : Colors.transparent,
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
                final title = _getDhikrTitle(item, currentLang);

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
                  selectedColor: BeyanColors.tone(0xFFD4AF37),
                  backgroundColor: isDark ? BeyanColors.tone(0xFF07211C) : Colors.grey.shade100,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.black : (isDark ? Colors.white70 : Colors.black87),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? BeyanColors.tone(0xFFD4AF37) : Colors.transparent,
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
              gradient: LinearGradient(
                colors: [BeyanColors.tone(0xFF012E2B), BeyanColors.tone(0xFF023E36), BeyanColors.tone(0xFF01201D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.35),
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
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 26,
                    height: 1.5,
                    color: BeyanColors.tone(0xFFFFDF7A),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 4),
                Text(
                  _getDhikrTitle(activeDhikr, currentLang),
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
                    color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    strings.lapsText(_completedLaps),
                    style: TextStyle(color: BeyanColors.tone(0xFFFFDF7A), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Lüks Sayaç Dokunma Alanı (33'lü 3B Tesbih Dizisi, Altın Şok Dalgası & Cam Yansıması) ─
          ScaleTransition(
            scale: _scaleAnimation,
            child: GestureDetector(
              onTap: _increment,
              child: SizedBox(
                width: 266,
                height: 266,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 1. Dokunuşta Dışa Yayılan 24K Altın Şok Dalgası (Aura Ripple)
                    IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _shimmerAnimation,
                        builder: (context, _) {
                          final v = _shimmerAnimation.value;
                          if (v <= 0.01 || v >= 0.99) return const SizedBox.shrink();
                          final rippleSize = 202.0 + (v * 64.0);
                          final rippleOpacity = ((1.0 - v) * 0.75).clamp(0.0, 1.0);
                          return Container(
                            width: rippleSize,
                            height: rippleSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: rippleOpacity),
                                width: 2.5 * (1.0 - v) + 0.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: rippleOpacity * 0.45),
                                  blurRadius: 18,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // 2. Dış Altın Halkalı İlerleme Göstergesi
                    SizedBox(
                      width: 228,
                      height: 228,
                      child: CircularProgressIndicator(
                        value: _target > 0 ? progress : 1.0,
                        strokeWidth: 5.0,
                        backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(BeyanColors.tone(0xFFD4AF37)),
                      ),
                    ),

                    // 3. Lüks İç Sayaç Küresi
                    Container(
                      width: 210,
                      height: 210,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [BeyanColors.tone(0xFF04584C), BeyanColors.tone(0xFF012E2B), BeyanColors.tone(0xFF011512)],
                          stops: const [0.0, 0.65, 1.0],
                        ),
                        border: Border.all(
                          color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.85),
                          width: 2.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.28),
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
                      child: ClipOval(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Küre İçinden Diyagonal Geçen 24K Altın Işık Yansıması (Her Dokunuşta Görünür)
                            IgnorePointer(
                              child: AnimatedBuilder(
                                animation: _shimmerAnimation,
                                builder: (context, _) {
                                  final v = _shimmerAnimation.value;
                                  if (v <= 0.01 || v >= 0.99) return const SizedBox.shrink();
                                  final pos = -1.4 + (v * 2.8);
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment(pos - 0.45, -1.0),
                                        end: Alignment(pos + 0.45, 1.0),
                                        colors: [
                                          Colors.transparent,
                                          BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.22 * (1.0 - v * 0.4)),
                                          Colors.white.withValues(alpha: 0.36 * (1.0 - v * 0.4)),
                                          BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.22 * (1.0 - v * 0.4)),
                                          Colors.transparent,
                                        ],
                                        stops: const [0.0, 0.38, 0.50, 0.62, 1.0],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            Column(
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
                                              color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.35),
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(
                                                color: BeyanColors.tone(0xFFFFDF7A),
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              '+1',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w900,
                                                color: BeyanColors.tone(0xFFFFDF7A),
                                                shadows: [
                                                  Shadow(color: BeyanColors.tone(0xFFD4AF37), blurRadius: 6),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                // Sayı Yükselme & Yaylanma Animasyonu (Rolling Slide + Scale Bounce)
                                ScaleTransition(
                                  scale: _countPopScale,
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 220),
                                    transitionBuilder: (Widget child, Animation<double> animation) {
                                      final isCurrent = (child.key as ValueKey<int>?)?.value == _count;
                                      return SlideTransition(
                                        position: Tween<Offset>(
                                          begin: isCurrent ? const Offset(0.0, 0.45) : Offset.zero,
                                          end: isCurrent ? Offset.zero : const Offset(0.0, -0.45),
                                        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                                        child: FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: Text(
                                      '$_count',
                                      key: ValueKey<int>(_count),
                                      style: TextStyle(
                                        fontSize: 56,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 1.5,
                                        shadows: [
                                          Shadow(
                                            color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.7),
                                            blurRadius: 18,
                                          ),
                                          Shadow(
                                            color: BeyanColors.tone(0xFFD4AF37),
                                            blurRadius: 12,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                if (_target > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      '/ $_target',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: BeyanColors.tone(0xFFFFDF7A),
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
                          ],
                        ),
                      ),
                    ),

                    // 5. Lüks Cam & Altın Çember Işık Süzülmesi (Rotating Ring Shimmer)
                    SizedBox(
                      width: 202,
                      height: 202,
                      child: IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _shimmerAnimation,
                          builder: (context, _) {
                            final animValue = _shimmerAnimation.value;
                            final isMilestone = (_count > 0 && (_count % 33 == 0 || _count == _target));
                            final sweepIntensity = isMilestone ? 0.75 : 0.42;

                            return Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: SweepGradient(
                                  center: Alignment.center,
                                  transform: GradientRotation(animValue * math.pi * 2),
                                  colors: [
                                    Colors.transparent,
                                    BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.0),
                                    BeyanColors.tone(0xFFFFDF7A).withValues(alpha: sweepIntensity),
                                    Colors.white.withValues(alpha: isMilestone ? 0.85 : 0.55),
                                    BeyanColors.tone(0xFFFFDF7A).withValues(alpha: sweepIntensity),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.40, 0.48, 0.50, 0.52, 0.65],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // 6. Lüks Kavisli Cam Yansıması (Curved Specular Arc)
                    Positioned(
                      top: 38,
                      child: IgnorePointer(
                        child: Container(
                          width: 136,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.elliptical(68, 24)),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: 0.25),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

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
                  foregroundColor: BeyanColors.tone(0xFFD4AF37),
                  side: BorderSide(color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Titreşim / Dokunuş Hissi Seçici ──────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? BeyanColors.tone(0xFF04201B) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _hapticMode == 0 ? Icons.vibration_outlined : Icons.vibration_rounded,
                  size: 16,
                  color: BeyanColors.tone(0xFFFFDF7A),
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
          color: isSelected ? BeyanColors.tone(0xFFD4AF37) : Colors.transparent,
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
              ? [BeyanColors.tone(0xFF04241E), BeyanColors.tone(0xFF07382E)]
              : [BeyanColors.tone(0xFF063B32), BeyanColors.tone(0xFF084F43)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.5),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.15),
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
                      color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.2),
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: BeyanColors.tone(0xFFFFDF7A),
                        ),
                      ),
                      Text(
                        streak.isTodayCompleted
                            ? strings.todayAllTasksDone
                            : strings.remainingTasksText(7 - streak.todayCompletedCount),
                        style: TextStyle(
                          fontSize: 12,
                          color: streak.isTodayCompleted
                              ? BeyanColors.tone(0xFF85E3B3)
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
                    color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.emoji_events_rounded,
                        color: BeyanColors.tone(0xFFFFDF7A), size: 14),
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
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: BeyanColors.tone(0xFFFFDF7A),
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
                valueColor: AlwaysStoppedAnimation<Color>(BeyanColors.tone(0xFFFFDF7A)),
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
                color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.military_tech_rounded,
                      color: BeyanColors.tone(0xFFFFDF7A), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '${strings.spiritualRewardsBtn} (10-400 Gün)',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: BeyanColors.tone(0xFFFFDF7A),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded,
                      color: BeyanColors.tone(0xFFFFDF7A), size: 18),
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
              ? [BeyanColors.tone(0xFF042F26), BeyanColors.tone(0xFF02231C)]
              : [BeyanColors.tone(0xFF063F34), BeyanColors.tone(0xFF022A23)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: BeyanColors.tone(0xFFD4AF37),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.25),
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
                  gradient: LinearGradient(
                    colors: [BeyanColors.tone(0xFFD4AF37), BeyanColors.tone(0xFFFFDF7A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.check_rounded,
                    color: BeyanColors.tone(0xFF012E2B),
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
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: BeyanColors.tone(0xFFFFDF7A),
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
                color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.35),
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
                        Icon(Icons.auto_awesome, color: BeyanColors.tone(0xFFFFDF7A), size: 15),
                        const SizedBox(width: 6),
                        Text(
                          '${strings.dailyCompletionVerseBadge} • ${verse.verseReference}',
                          style: TextStyle(
                            color: BeyanColors.tone(0xFFFFDF7A),
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
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 18,
                    height: 1.6,
                    color: BeyanColors.tone(0xFFFFDF7A),
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),

                const SizedBox(height: 8),

                // Meal
                Text(
                  verse.localizedMeaning(strings.language.code),
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
                  '🤲 ${verse.localizedSpiritualNote(strings.language.code)}',
                  style: TextStyle(
                    color: BeyanColors.tone(0xFF85E3B3),
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
        gradient: LinearGradient(
          colors: [BeyanColors.tone(0xFF012E2B), BeyanColors.tone(0xFF034A3E)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.4)),
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
                  valueColor: AlwaysStoppedAnimation<Color>(BeyanColors.tone(0xFFD4AF37)),
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
                  strings.dailyProgressTitle,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: BeyanColors.tone(0xFFFFDF7A)),
                ),
                const SizedBox(height: 4),
                Text(
                  completedCount == 0
                      ? strings.dailyProgressSubtitle
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
            color: isDark ? BeyanColors.tone(0xFF031B17) : BeyanColors.tone(0xFF052B24),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.4),
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
                      strings.streaksBannerTitle,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: BeyanColors.tone(0xFFFFDF7A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      strings.streaksBannerSubtitle,
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
                            ? BeyanColors.tone(0xFF083C32)
                            : Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isUnlocked
                              ? BeyanColors.tone(0xFFD4AF37)
                              : Colors.white12,
                          width: isUnlocked ? 1.4 : 1,
                        ),
                        boxShadow: isUnlocked
                            ? [
                                BoxShadow(
                                  color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.15),
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
                                        milestone.localizedTitle(strings.language.code),
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: isUnlocked
                                              ? BeyanColors.tone(0xFFFFDF7A)
                                              : Colors.white,
                                        ),
                                      ),
                                      Text(
                                        strings.dayGoalLabel(milestone.days),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isUnlocked
                                              ? BeyanColors.tone(0xFF85E3B3)
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
                                      ? BeyanColors.tone(0xFFD4AF37)
                                      : Colors.white10,
                                ),
                                child: Text(
                                  isUnlocked
                                      ? strings.unlockedBadge
                                      : '🔒 ${milestone.days - streak.currentStreak > 0 ? strings.daysRemainingLock(milestone.days - streak.currentStreak) : strings.lockedBadge}',
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
                                Icon(Icons.menu_book_rounded,
                                    color: BeyanColors.tone(0xFFFFDF7A), size: 14),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${strings.motivatingSurahLabel}: ${milestone.ayahReference}',
                                    style: TextStyle(
                                      color: BeyanColors.tone(0xFFFFDF7A),
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
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 16,
                                height: 1.6,
                                color: BeyanColors.tone(0xFFFFDF7A),
                              ),
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              milestone.localizedMeaning(strings.language.code),
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
                                Icon(Icons.stars_rounded,
                                    color: BeyanColors.tone(0xFF85E3B3), size: 14),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    milestone.localizedSpiritualVirtue(strings.language.code),
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: BeyanColors.tone(0xFF85E3B3),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            Text(
                              strings.milestoneUnlockHint(milestone.localizedSurahName(strings.language.code), milestone.days),
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
    final strings = ref.read(appStringsProvider);
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [BeyanColors.tone(0xFF012E2B), BeyanColors.tone(0xFF034A3E), BeyanColors.tone(0xFF011C18)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: BeyanColors.tone(0xFFD4AF37), width: 1.8),
              boxShadow: [
                BoxShadow(
                  color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.3),
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
                  Text(
                    strings.celebrationTitle,
                    style: TextStyle(
                      color: BeyanColors.tone(0xFFFFDF7A),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    strings.celebrationStreakReached(milestone.days),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: BeyanColors.tone(0xFFD4AF37)),
                    ),
                    child: Text(
                      milestone.localizedBadgeName(strings.language.code),
                      style: TextStyle(
                        color: BeyanColors.tone(0xFFFFDF7A),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${strings.motivatingSurahLabel}: ${milestone.localizedSurahName(strings.language.code)}',
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
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 17,
                            height: 1.6,
                            color: BeyanColors.tone(0xFFFFDF7A),
                          ),
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          milestone.localizedMeaning(strings.language.code),
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
                    milestone.localizedSpiritualVirtue(strings.language.code),
                    style: TextStyle(
                      color: BeyanColors.tone(0xFF85E3B3),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BeyanColors.tone(0xFFD4AF37),
                      foregroundColor: BeyanColors.tone(0xFF012E2B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(
                      strings.acceptSpiritualBadge,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
      HapticFeedback.selectionClick();
      final milestone = await ref.read(worshipTrackerProvider.notifier).toggleHabit(habitKey: habitKey);
      if (milestone != null && mounted) {
        _showCelebrationDialog(context, milestone);
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? BeyanColors.tone(0xFF06221D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? BeyanColors.tone(0xFFD4AF37)
              : (isDark ? BeyanColors.tone(0xFF133B34) : BeyanColors.tone(0xFFE2EBE8)),
          width: isCompleted ? 1.4 : 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isCompleted
                ? BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.2)
                : (isDark ? Colors.white10 : Colors.grey.shade100),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isCompleted ? BeyanColors.tone(0xFFFFDF7A) : Colors.grey, size: 20),
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
          activeColor: BeyanColors.tone(0xFFD4AF37),
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
              ? BeyanColors.tone(0xFFD4AF37)
              : (Theme.of(context).brightness == Brightness.dark
                  ? BeyanColors.tone(0xFF07211C)
                  : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? BeyanColors.tone(0xFFD4AF37) : Colors.white12,
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

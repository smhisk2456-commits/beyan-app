import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    with SingleTickerProviderStateMixin {
  int _activeTab = 0; // 0: Zikirmatik, 1: İbadet Takibi
  int _count = 0;
  int _target = 33;
  int _selectedDhikrIndex = 0;
  int _completedLaps = 0;

  final ScrollController _chipScrollController = ScrollController();
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;

  final List<Map<String, String>> _dhikrList = [
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
  }

  void _undo() {
    if (_count > 0) {
      HapticFeedback.selectionClick();
      setState(() => _count--);
    }
  }

  void _confirmReset() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF032B25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFD4AF37), width: 1),
        ),
        title: const Text('Zikri Sıfırla', style: TextStyle(color: Color(0xFFFFDF7A))),
        content: const Text(
          'Mevcut sayımı ve tur sayısını sıfırlamak istiyor musunuz?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Vazgeç', style: TextStyle(color: Colors.white60)),
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
              Navigator.pop(ctx);
            },
            child: const Text('Sıfırla'),
          ),
        ],
      ),
    );
  }

  void _showAddCustomDhikrDialog() {
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
        title: const Text('Özel Zikir Ekle', style: TextStyle(color: Color(0xFFFFDF7A))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Zikir Başlığı (Örn: Lâ Havle...)',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37))),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: meaningController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Anlamı veya Niyeti',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.black),
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                setState(() {
                  _dhikrList.add({
                    'tr': title,
                    'en': title,
                    'ar': title,
                    'meaning': meaningController.text.trim().isNotEmpty ? meaningController.text.trim() : 'Özel zikir',
                  });
                  _selectedDhikrIndex = _dhikrList.length - 1;
                  _count = 0;
                  _completedLaps = 0;
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('Ekle'),
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
        title: Text(_activeTab == 0 ? strings.actionZikr : 'İbadet Takibi'),
        centerTitle: true,
        actions: [
          // Özel zikir ekle butonu
          if (_activeTab == 0)
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFFFFDF7A)),
              tooltip: 'Özel Zikir Ekle',
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
                              'Zikirmatik',
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
                              'İbadet Takibi',
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
                  currentLang == AppLanguage.english ? activeDhikr['en']! : activeDhikr['tr']!,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
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
                    '$_completedLaps Tur',
                    style: const TextStyle(color: Color(0xFFFFDF7A), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Dev Sayaç Dokunma Alanı ─────────────────────────────
          ScaleTransition(
            scale: _scaleAnimation,
            child: GestureDetector(
              onTap: _increment,
              child: Stack(
                alignment: Alignment.center,
                children: [
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
                  Container(
                    width: 196,
                    height: 196,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFF034A40), Color(0xFF012E2B), Color(0xFF011C19)],
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

          const SizedBox(height: 24),

          // ── Geri Al ve Sıfırla Butonları ─────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: _undo,
                icon: const Icon(Icons.undo_rounded, size: 18),
                label: const Text('Geri Al'),
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
                label: const Text('Sıfırla'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFD4AF37),
                  side: BorderSide(color: const Color(0xFFD4AF37).withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorshipTrackerView(bool isDark) {
    final todayEntry = ref.watch(todayWorshipEntryProvider);
    final completedCount = todayEntry.completedCount;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
      children: [
        // ── Günlük Özet Kartı ─────────────────────────────────────
        Container(
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bugünkü İbadet İlerlemeniz',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFFFDF7A)),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '5 Vakit Namaz, Kur\'an-ı Kerim tilaveti ve günlük zikrinizi buradan takip edebilirsiniz.',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // ── 5 Vakit Namaz Kontrol Listesi ─────────────────────────
        _buildHabitItem('Sabah Namazı', 'fajr', todayEntry.fajr, Icons.wb_twilight_rounded, isDark),
        _buildHabitItem('Öğle Namazı', 'dhuhr', todayEntry.dhuhr, Icons.wb_sunny_rounded, isDark),
        _buildHabitItem('İkindi Namazı', 'asr', todayEntry.asr, Icons.wb_sunny_outlined, isDark),
        _buildHabitItem('Akşam Namazı', 'maghrib', todayEntry.maghrib, Icons.nights_stay_outlined, isDark),
        _buildHabitItem('Yatsı Namazı', 'isha', todayEntry.isha, Icons.nightlight_round, isDark),
        const SizedBox(height: 10),

        // ── Kur'an & Zikir Takibi ────────────────────────────────
        _buildHabitItem('Günlük Kur\'an Tilaveti', 'quran', todayEntry.quran, Icons.menu_book_rounded, isDark),
        _buildHabitItem('Günlük Zikir & Tesbihat', 'zikr', todayEntry.zikr, Icons.fingerprint_rounded, isDark),
      ],
    );
  }

  Widget _buildHabitItem(String title, String habitKey, bool isCompleted, IconData icon, bool isDark) {
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
          onChanged: (_) {
            HapticFeedback.lightImpact();
            ref.read(worshipTrackerProvider.notifier).toggleHabit(habitKey: habitKey);
          },
        ),
        onTap: () {
          HapticFeedback.lightImpact();
          ref.read(worshipTrackerProvider.notifier).toggleHabit(habitKey: habitKey);
        },
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

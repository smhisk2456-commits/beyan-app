import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/beyan_colors.dart';
import '../../../core/utils/navigator_guard.dart';
import '../models/prayer_guide_data.dart';

/// Lüks Görsel & Sesli Namaz Kılınış Rehberi, Duaları ve Abdest Ekranı
class InteractivePrayerGuideScreen extends StatefulWidget {
  final int initialTab; // 0: Kılınış, 1: Dualar, 2: Abdest

  const InteractivePrayerGuideScreen({
    super.key,
    this.initialTab = 0,
  });

  @override
  State<InteractivePrayerGuideScreen> createState() =>
      _InteractivePrayerGuideScreenState();
}

class _InteractivePrayerGuideScreenState
    extends State<InteractivePrayerGuideScreen> {
  late int _activeTab;
  int _selectedVakitIndex = 0;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final gold = BeyanColors.tone(0xFFFFDF7A);
    final goldPrimary = BeyanColors.tone(0xFFD4AF37);
    final bgDark = BeyanColors.tone(0xFF041915);

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => BeyanNavigatorGuard.safePop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: goldPrimary.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.menu_book_rounded, color: gold, size: 18),
            ),
            const SizedBox(width: 8),
            const Text(
              'Namaz & Dua Rehberi',
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── ÜST SEGMENT SEÇİCİ (3 SEKME) ────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: goldPrimary.withValues(alpha: 0.18)),
            ),
            child: Row(
              children: [
                _segmentTab(0, 'Namaz Kılınışı', Icons.accessibility_new_rounded),
                _segmentTab(1, 'Namaz Duaları', Icons.auto_stories_rounded),
                _segmentTab(2, 'Abdest Rehberi', Icons.water_drop_rounded),
              ],
            ),
          ),

          // ── SEKME İÇERİĞİ ───────────────────────────────────────
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _buildTabContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _segmentTab(int index, String label, IconData icon) {
    final isSelected = _activeTab == index;
    final gold = BeyanColors.tone(0xFFFFDF7A);
    final goldPrimary = BeyanColors.tone(0xFFD4AF37);

    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _activeTab = index);
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? goldPrimary.withValues(alpha: 0.22)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? goldPrimary : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? gold : Colors.white60,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? gold : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_activeTab) {
      case 0:
        return _buildPrayerFlowTab();
      case 1:
        return _buildDuasLibraryTab();
      case 2:
        return _buildWuduGuideTab();
      default:
        return const SizedBox.shrink();
    }
  }

  // ════════════════════════════════════════════════════════════════
  // 1. SEKME: 5 VAKİT NAMAZ REHBERİ (ADIM ADIM REKAT AKIŞI)
  // ════════════════════════════════════════════════════════════════
  Widget _buildPrayerFlowTab() {
    final gold = BeyanColors.tone(0xFFFFDF7A);
    final goldPrimary = BeyanColors.tone(0xFFD4AF37);
    final cardBg = BeyanColors.tone(0xFF072620);
    final vakit = PrayerGuideVakit.allPrayers[_selectedVakitIndex];

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 30),
      children: [
        // Vakit Seçici Yatay Liste
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(PrayerGuideVakit.allPrayers.length, (index) {
              final v = PrayerGuideVakit.allPrayers[index];
              final isSelected = _selectedVakitIndex == index;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(v.name),
                  selected: isSelected,
                  selectedColor: goldPrimary.withValues(alpha: 0.25),
                  backgroundColor: cardBg,
                  labelStyle: TextStyle(
                    color: isSelected ? gold : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                  side: BorderSide(
                    color: isSelected ? goldPrimary : Colors.white10,
                  ),
                  onSelected: (val) {
                    if (val) {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedVakitIndex = index);
                    }
                  },
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 14),

        // Vakit Bilgi Kartı
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                cardBg,
                BeyanColors.tone(0xFF041E19),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: goldPrimary.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    vakit.name,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: gold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: goldPrimary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: goldPrimary.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      vakit.totalRakats,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: gold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Rekat Dağılımı: ${vakit.rakatsBreakdown}',
                style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Vakti: ${vakit.timeWindow}',
                style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
              ),
              const Divider(color: Colors.white12, height: 20),
              // Niyet
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.format_quote_rounded, color: gold, size: 20),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      vakit.intentionSample,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 12.5,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Rekat Adımları
        ...vakit.rakats.map((rakat) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: goldPrimary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check_circle_outline_rounded, color: gold, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      rakat.rakatTitle,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: gold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...rakat.steps.asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final stepText = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          margin: const EdgeInsets.only(top: 2, right: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.07),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$idx',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: gold,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            stepText,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════
  // 2. SEKME: NAMAZ DUALARI & SÛRELERİ (SESLİ DİNLEME & ANLAMI)
  // ════════════════════════════════════════════════════════════════
  Widget _buildDuasLibraryTab() {
    final gold = BeyanColors.tone(0xFFFFDF7A);
    final cardBg = BeyanColors.tone(0xFF072620);

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardBg.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: gold, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Namazda okunan tüm temel dualar, sûreler ve zikirler. Arapça hattı, okunuşu ve Diyanet meali ile ezberleyebilirsiniz.',
                  style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.75)),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        ...NamazDuaItem.allDuas.map((item) => _buildDuaCard(item)),
      ],
    );
  }

  Widget _buildDuaCard(NamazDuaItem item) {
    final gold = BeyanColors.tone(0xFFFFDF7A);
    final goldPrimary = BeyanColors.tone(0xFFD4AF37);
    final cardBg = BeyanColors.tone(0xFF072620);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: goldPrimary.withValues(alpha: 0.18)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: item.id == 'subhaneke' || item.id == 'ettehiyyatu',
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          title: Text(
            item.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(
                item.subtitle,
                style: TextStyle(fontSize: 12, color: gold),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.whereRead,
                  style: TextStyle(fontSize: 10.5, color: Colors.white.withValues(alpha: 0.6)),
                ),
              ),
            ],
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            const Divider(color: Colors.white12),

            // Arapça Metin
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                item.arabic,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 21,
                  height: 1.8,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFAFBF9),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Türkçe Okunuşu
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.record_voice_over_rounded, color: gold, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'TÜRKÇE OKUNUŞU',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: gold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.transliteration,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Türkçe Meali
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.translate_rounded, color: gold, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'ANLAMI / MEALİ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: gold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.meaning,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),

            if (item.virtue != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: goldPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.stars_rounded, color: gold, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.virtue!,
                        style: TextStyle(fontSize: 11.5, color: gold),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Kopyalama Butonu
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.copy_rounded, size: 15, color: Colors.white70),
                label: const Text('Metni Kopyala', style: TextStyle(fontSize: 12, color: Colors.white70)),
                onPressed: () {
                  Clipboard.setData(ClipboardData(
                    text: '${item.title}\n\n${item.arabic}\n\nOkunuşu: ${item.transliteration}\n\nMeali: ${item.meaning}',
                  ));
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Dua panoya kopyalandı.'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // 3. SEKME: ABDEST, GUSÜL VE TEYEMMÜM REHBERİ
  // ════════════════════════════════════════════════════════════════
  Widget _buildWuduGuideTab() {
    final gold = BeyanColors.tone(0xFFFFDF7A);
    final goldPrimary = BeyanColors.tone(0xFFD4AF37);
    final cardBg = BeyanColors.tone(0xFF072620);

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
      children: [
        // Abdestin 4 Farzı Kartı
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                cardBg,
                BeyanColors.tone(0xFF041E19),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: goldPrimary.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.verified_rounded, color: gold, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Abdestin 4 Farzı',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: gold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _farzItem('1. Yüzü yıkamak (Alından çene altına, kulak memelerine kadar).'),
              _farzItem('2. Kolları dirseklerle birlikte yıkamak.'),
              _farzItem('3. Başın en az dörtte birini ıslak elle mesh etmek.'),
              _farzItem('4. Ayakları topuklarla birlikte yıkamak.'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'SÜNNETE UYGUN ABDEST ALINIŞI',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: gold,
          ),
        ),
        const SizedBox(height: 10),

        _stepCard(1, 'Niyet & Eûzü Besmele', 'Niyet ettim Allah rızası için abdest almaya denir ve Eûzü Besmele çekilir. Eller bileklere kadar 3 defa yıkanır.'),
        _stepCard(2, 'Ağza Su Verme (Mazmaza)', 'Sağ avuçla ağza 3 defa su alınır ve her defasında ağız çalkalanır (Misvak veya fırça kullanmak sünnettir).'),
        _stepCard(3, 'Buruna Su Verme (İstinşak)', 'Sağ elle buruna 3 defa su çekilir ve sol elle sümkürülerek temizlenir.'),
        _stepCard(4, 'Yüzü Yıkamak', 'Alın saç bitiminden çene altına, sağ kulaktan sol kulağa kadar tüm yüz 3 defa yıkanır.'),
        _stepCard(5, 'Kolları Yıkamak', 'Önce sağ kol, sonra sol kol dirseklerle beraber 3\'er defa yıkanır.'),
        _stepCard(6, 'Başı Mesh Etmek', 'Eller ıslatılır ve başın üst kısmı (en az dörtte biri) mesh edilir.'),
        _stepCard(7, 'Kulak ve Boynu Mesh Etmek', 'Islak işaret parmaklarıyla kulağın içi, baş parmaklarla kulağın arkası ve elin tersiyle boyun mesh edilir.'),
        _stepCard(8, 'Ayakları Yıkamak', 'Önce sağ ayak, sonra sol ayak parmak aralarından başlanarak topuk kemikleriyle birlikte 3 defa yıkanır.'),

        const SizedBox(height: 16),

        // Gusül Abdesti Kartı
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.water_rounded, color: gold, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Gusül (Boy) Abdestinin 3 Farzı',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: gold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _farzItem('1. Ağza bolca su verip boğaza kadar çalkalamak (Mazmaza).'),
              _farzItem('2. Buruna bolca su çekip temizlemek (İstinşak).'),
              _farzItem('3. Bütün vücudu iğne ucu kadar kuru yer kalmayacak şekilde yıkamak.'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _farzItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, height: 1.35, color: Colors.white.withValues(alpha: 0.9)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepCard(int number, String title, String desc) {
    final gold = BeyanColors.tone(0xFFFFDF7A);
    final cardBg = BeyanColors.tone(0xFF072620);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.4)),
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: gold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(fontSize: 12.5, height: 1.35, color: Colors.white.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/theme/beyan_colors.dart';
import '../models/wudu_guide_model.dart';

/// Abdest Rehberi Bottom Sheet (Namaz Abdesti, Gusül, Teyemmüm ve Hükümler)
class WuduGuideSheet extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const WuduGuideSheet({
    super.key,
    this.initialTabIndex = 0,
  });

  static void show(BuildContext context, [int initialTab = 0]) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WuduGuideSheet(initialTabIndex: initialTab),
    );
  }

  @override
  ConsumerState<WuduGuideSheet> createState() => _WuduGuideSheetState();
}

class _WuduGuideSheetState extends ConsumerState<WuduGuideSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        HapticFeedback.selectionClick();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    final lang = strings.language;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final namazSteps = WuduGuideData.getNamazWuduSteps(lang);
    final ghuslSteps = WuduGuideData.getGhuslSteps(lang);
    final tayammumSteps = WuduGuideData.getTayammumSteps(lang);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: BoxDecoration(
        color: isDark ? BeyanColors.tone(0xFF01241E) : BeyanColors.tone(0xFF032F28),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: BeyanColors.tone(0xFFD4AF37), width: 1.8),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Üst Tutma Çubuğu (Drag Handle)
            const SizedBox(height: 12),
            Container(
              width: 48,
              height: 4.5,
              decoration: BoxDecoration(
                color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 14),

            // Başlık Barı
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          BeyanColors.tone(0xFF005A4C),
                          BeyanColors.tone(0xFF002923),
                        ],
                      ),
                      border: Border.all(
                        color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.7),
                        width: 1.2,
                      ),
                    ),
                    child: const Center(
                      child: Text('💧', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Abdest Rehberi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Hükmî ve Manevi Temizlik Ölçüleri',
                          style: TextStyle(
                            color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.85),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ── Sekme Çubuğu (Tabs) ──────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: BeyanColors.tone(0xFFD4AF37),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: BeyanColors.tone(0xFF01201B),
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
                tabs: const [
                  Tab(text: 'Namaz Abdesti'),
                  Tab(text: 'Gusül (Boy)'),
                  Tab(text: 'Teyemmüm'),
                  Tab(text: 'Bozan Haller'),
                ],
              ),
            ),

            const SizedBox(height: 10),
            const Divider(color: Colors.white12, height: 1),

            // ── Sekme İçerikleri ─────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 1. Namaz Abdesti
                  _buildStepListView(namazSteps),

                  // 2. Gusül (Boy Abdesti)
                  _buildStepListView(ghuslSteps),

                  // 3. Teyemmüm
                  _buildStepListView(tayammumSteps),

                  // 4. Abdesti Bozan & Bozmayan Durumlar
                  _buildNullifiersView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepListView(List<WuduStep> steps) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        final step = steps[index];
        return _buildStepCard(step);
      },
    );
  }

  Widget _buildStepCard(WuduStep step) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: step.isFard
              ? BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.5)
              : Colors.white12,
          width: step.isFard ? 1.4 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst Satır: Numara + Başlık + Farz/Sünnet Rozeti
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: step.isFard
                        ? RadialGradient(
                            colors: [
                              BeyanColors.tone(0xFFFFDF7A),
                              BeyanColors.tone(0xFFD4AF37),
                            ],
                          )
                        : RadialGradient(
                            colors: [
                              BeyanColors.tone(0xFF056E5D),
                              BeyanColors.tone(0xFF02362E),
                            ],
                          ),
                    border: Border.all(
                      color: BeyanColors.tone(0xFFFFDF7A),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${step.stepNumber}',
                      style: TextStyle(
                        color: step.isFard ? BeyanColors.tone(0xFF01201B) : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    step.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: step.isFard
                        ? BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: step.isFard
                          ? BeyanColors.tone(0xFFFFDF7A)
                          : Colors.white24,
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    step.isFard ? 'FARZ' : 'SÜNNET',
                    style: TextStyle(
                      color: step.isFard ? BeyanColors.tone(0xFFFFDF7A) : Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Açıklama
            Text(
              step.description,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.88),
                fontSize: 13,
                height: 1.45,
              ),
            ),

            // Varsa Arapça Dua & Meal
            if (step.arabicDua != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: BeyanColors.tone(0xFF011A16),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      step.arabicDua!,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 18,
                        color: BeyanColors.tone(0xFFFFDF7A),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                    if (step.transliteration != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        step.transliteration!,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontStyle: FontStyle.italic,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (step.duaMeaning != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        step.duaMeaning!,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.85),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // Varsa Önemli İpucu (Tip)
            if (step.tip != null) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline_rounded,
                      size: 15, color: BeyanColors.tone(0xFFFFDF7A)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      step.tip!,
                      style: TextStyle(
                        color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.8),
                        fontSize: 11.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNullifiersView() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        // Bozan Haller Kartı
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.cancel_rounded, color: Colors.redAccent.shade100, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Abdesti Bozan Başlıca Durumlar',
                    style: TextStyle(
                      color: Colors.redAccent.shade100,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...WuduGuideData.nullifiers.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ',
                          style: TextStyle(color: Colors.redAccent.shade100, fontSize: 16)),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Bozmayan Yanılgılar Kartı
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.greenAccent.shade100, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Abdesti Bozmayan Yaygın Yanılgılar',
                    style: TextStyle(
                      color: Colors.greenAccent.shade100,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...WuduGuideData.nonNullifiers.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('✓ ',
                          style: TextStyle(color: Colors.greenAccent.shade100, fontSize: 15)),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

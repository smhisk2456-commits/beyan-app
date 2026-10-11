import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/curated_verse_preset.dart';
import '../widgets/verse_wallpaper_painters.dart';

enum CardStudioBackground {
  mistyMosque('Sisli Cami', '🕌'),
  goldenSunset('Gün Batımı', '🌅'),
  starryNight('Gece Seması', '🌌'),
  kaabaHoly('Kâbe-i Muazzama', '🕋'),
  islamicArch('Mihrap & Tezhip', '💠'),
  oledBlack('OLED Siyah', '🖤');

  final String label;
  final String emoji;
  const CardStudioBackground(this.label, this.emoji);
}

/// Gelişmiş Estetik Ayet / Hikaye & Duvar Kağıdı Stüdyosu
class VerseCardStudioScreen extends StatefulWidget {
  final String initialReference;
  final String initialArabic;
  final String initialMeaning;

  const VerseCardStudioScreen({
    super.key,
    this.initialReference = 'İnşirâh 94:6',
    this.initialArabic = 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
    this.initialMeaning = 'Şüphesiz her güçlükle beraber bir kolaylık vardır.',
  });

  @override
  State<VerseCardStudioScreen> createState() => _VerseCardStudioScreenState();
}

class _VerseCardStudioScreenState extends State<VerseCardStudioScreen> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  late String _reference;
  late String _arabic;
  late String _meaning;

  CardStudioBackground _bg = CardStudioBackground.mistyMosque;
  bool _isStoryRatio = true; // true: 9:16 (Story/Wallpaper), false: 1:1 (Square Post)
  bool _showArabic = true;
  bool _showMeaning = true;
  bool _showWatermark = true;
  int _fontStyle = 0; // 0: Zarif Serif, 1: Klasik Nesih, 2: Modern
  double _fontSizeMultiplier = 1.0; // 0.8 to 1.3
  bool _isSaving = false;
  bool _isPreviewMode = false; // Tam ekran duvar kağıdı önizlemesi

  @override
  void initState() {
    super.initState();
    _reference = widget.initialReference;
    _arabic = widget.initialArabic;
    _meaning = widget.initialMeaning;
  }

  void _randomizeVerse() {
    HapticFeedback.lightImpact();
    final presets = List<CuratedVersePreset>.from(CuratedVersePreset.presets);
    presets.shuffle();
    final randomPreset = presets.first;
    setState(() {
      _reference = randomPreset.reference;
      _arabic = randomPreset.arabic;
      _meaning = randomPreset.meaning;
    });
  }

  void _showVerseSelectorSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF032620),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        final categories = <String, List<CuratedVersePreset>>{};
        for (final item in CuratedVersePreset.presets) {
          categories.putIfAbsent(item.category, () => []).add(item);
        }

        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Tutamaç
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_stories_rounded, color: Color(0xFFFFDF7A)),
                      const SizedBox(width: 10),
                      const Text(
                        'Âyet & Dua Kütüphanesi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showCustomTextInputDialog();
                        },
                        icon: const Icon(Icons.edit_note_rounded, size: 18, color: Color(0xFFFFDF7A)),
                        label: const Text('Kendin Yaz', style: TextStyle(color: Color(0xFFFFDF7A))),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(),
                    children: categories.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                color: Color(0xFFFFDF7A),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          ...entry.value.map((preset) {
                            final isSelected = _reference == preset.reference;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFD4AF37).withValues(alpha: 0.18)
                                    : Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFFFDF7A)
                                      : Colors.white.withValues(alpha: 0.1),
                                  width: 1,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                title: Row(
                                  children: [
                                    Text(
                                      preset.reference,
                                      style: TextStyle(
                                        color: isSelected ? const Color(0xFFFFDF7A) : Colors.white,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (isSelected)
                                      const Icon(Icons.check_circle_rounded, color: Color(0xFFFFDF7A), size: 18),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      preset.arabic,
                                      style: const TextStyle(
                                        fontFamily: 'Amiri',
                                        fontSize: 15,
                                        color: Colors.white70,
                                      ),
                                      textDirection: TextDirection.rtl,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      preset.meaning,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withValues(alpha: 0.8),
                                        fontStyle: FontStyle.italic,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    _reference = preset.reference;
                                    _arabic = preset.arabic;
                                    _meaning = preset.meaning;
                                  });
                                  Navigator.pop(ctx);
                                },
                              ),
                            );
                          }),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCustomTextInputDialog() {
    final refCtrl = TextEditingController(text: _reference);
    final arCtrl = TextEditingController(text: _arabic);
    final meanCtrl = TextEditingController(text: _meaning);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF04241F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text(
          'Kendi Âyetini / Metnini Yaz',
          style: TextStyle(color: Color(0xFFFFDF7A), fontSize: 17, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: refCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Kaynak / Sure (Örn: İnşirâh 94:6)',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: arCtrl,
                textDirection: TextDirection.rtl,
                style: const TextStyle(color: Colors.white, fontFamily: 'Amiri'),
                decoration: const InputDecoration(
                  labelText: 'Arapça Metin (İsteğe Bağlı)',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: meanCtrl,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Türkçe Meâl / Anlam',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Vazgeç', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              if (meanCtrl.text.trim().isNotEmpty) {
                setState(() {
                  _reference = refCtrl.text.trim();
                  _arabic = arCtrl.text.trim();
                  _meaning = meanCtrl.text.trim();
                });
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
            ),
            child: const Text('Uygula'),
          ),
        ],
      ),
    );
  }

  Future<void> _captureAndShare() async {
    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);
    try {
      final boundary = _repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/beyan_verse_card_${DateTime.now().millisecondsSinceEpoch}.png').create();
      await file.writeAsBytes(pngBytes);

      if (mounted) {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path)],
            text: '$_reference • Beyân',
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Paylaşım hatası: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF011815),
      appBar: _isPreviewMode
          ? null
          : AppBar(
              title: const Text(
                'Ayet & Duvar Kağıdı Stüdyosu',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              actions: [
                // Rastgele Âyet Düğmesi
                IconButton(
                  icon: const Icon(Icons.casino_rounded, color: Color(0xFFFFDF7A)),
                  tooltip: 'Rastgele Âyet',
                  onPressed: _randomizeVerse,
                ),
                // Paylaş
                IconButton(
                  icon: const Icon(Icons.share_rounded, color: Color(0xFFFFDF7A)),
                  tooltip: 'Paylaş',
                  onPressed: _isSaving ? null : _captureAndShare,
                ),
              ],
            ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Üst Hızlı İşlem Çubuğu (Âyet Seç & Önizle) ───────────
            if (!_isPreviewMode)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _showVerseSelectorSheet,
                        icon: const Icon(Icons.menu_book_rounded, size: 18),
                        label: Text(
                          'Âyet Seç: $_reference',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF03332B),
                          foregroundColor: const Color(0xFFFFDF7A),
                          side: const BorderSide(color: Color(0xFFD4AF37), width: 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        setState(() => _isPreviewMode = true);
                      },
                      icon: const Icon(Icons.fullscreen_rounded, color: Colors.black),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFFFDF7A),
                      ),
                      tooltip: 'Tam Ekran Önizle',
                    ),
                  ],
                ),
              ),

            // ── Kart Önizleme Alanı ─────────────────────────────────
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    if (_isPreviewMode) {
                      setState(() => _isPreviewMode = false);
                    }
                  },
                  child: AspectRatio(
                    aspectRatio: _isStoryRatio ? (9 / 16) : 1.0,
                    child: Padding(
                      padding: EdgeInsets.all(_isPreviewMode ? 0 : 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(_isPreviewMode ? 0 : 22),
                        child: RepaintBoundary(
                          key: _repaintBoundaryKey,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // 1. Gerçek Sanatsal Arka Plan Tablosu
                              _buildArtworkBackground(),

                              // 2. Âyet & Hat İçeriği
                              _buildCardContent(),

                              // Önizlemeden Çıkış Düğmesi
                              if (_isPreviewMode)
                                Positioned(
                                  top: 20,
                                  right: 20,
                                  child: IconButton.filled(
                                    icon: const Icon(Icons.fullscreen_exit_rounded, color: Colors.white),
                                    style: IconButton.styleFrom(backgroundColor: Colors.black54),
                                    onPressed: () => setState(() => _isPreviewMode = false),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Alt Kontrol Paneli ───────────────────────────────────
            if (!_isPreviewMode) _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // Gerçek Sanat Arka Planı (CustomPainter & Artwork)
  // ════════════════════════════════════════════════════════════════
  Widget _buildArtworkBackground() {
    switch (_bg) {
      case CardStudioBackground.mistyMosque:
        return const CustomPaint(
          size: Size.infinite,
          painter: MosqueArtPainter(),
        );
      case CardStudioBackground.goldenSunset:
        return const CustomPaint(
          size: Size.infinite,
          painter: SunsetMosquePainter(),
        );
      case CardStudioBackground.starryNight:
        return const CustomPaint(
          size: Size.infinite,
          painter: StarryNightPainter(),
        );
      case CardStudioBackground.kaabaHoly:
        return const CustomPaint(
          size: Size.infinite,
          painter: KaabaArtPainter(),
        );
      case CardStudioBackground.islamicArch:
        return const CustomPaint(
          size: Size.infinite,
          painter: IslamicArchPainter(),
        );
      case CardStudioBackground.oledBlack:
        return Container(
          color: Colors.black,
        );
    }
  }

  // ════════════════════════════════════════════════════════════════
  // Kart Metin ve Hat İçeriği
  // ════════════════════════════════════════════════════════════════
  Widget _buildCardContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Üst Âyet Rozeti
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFFDF7A).withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Text(
              _reference,
              style: const TextStyle(
                color: Color(0xFFFFDF7A),
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Arapça Metin
          if (_showArabic && _arabic.isNotEmpty) ...[
            Text(
              _arabic,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 22 * _fontSizeMultiplier,
                height: 1.7,
                color: Colors.white,
                shadows: const [
                  Shadow(
                    color: Colors.black,
                    blurRadius: 16,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 50,
              height: 1.5,
              color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
          ],

          // Meâl / Anlam
          if (_showMeaning && _meaning.isNotEmpty)
            Text(
              _meaning,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15 * _fontSizeMultiplier,
                height: 1.55,
                color: Colors.white.withValues(alpha: 0.95),
                fontStyle: _fontStyle == 0 ? FontStyle.italic : FontStyle.normal,
                fontWeight: _fontStyle == 2 ? FontWeight.w500 : FontWeight.w400,
                shadows: const [
                  Shadow(
                    color: Colors.black87,
                    blurRadius: 14,
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),

          // Alt Beyân Logosu
          if (_showWatermark)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.nights_stay_rounded, size: 13, color: Color(0xFFFFDF7A)),
                const SizedBox(width: 5),
                Text(
                  'Beyân',
                  style: TextStyle(
                    color: const Color(0xFFFFDF7A).withValues(alpha: 0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // Alt Kontrol Paneli (Arka Plan Seçimi, Boyut, Font, Paylaş)
  // ════════════════════════════════════════════════════════════════
  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF032621),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Color(0xFFD4AF37), width: 1.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Arka Plan Seçici
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: CardStudioBackground.values.map((bg) {
                final isSelected = _bg == bg;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    avatar: Text(bg.emoji, style: const TextStyle(fontSize: 14)),
                    label: Text(bg.label),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _bg = bg),
                    selectedColor: const Color(0xFFD4AF37),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),

          // 2. Ayar Çipleri (Oran, Font, Metin Boyutu, Arapça, Meâl)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                // Oran (9:16 vs 1:1)
                ChoiceChip(
                  label: Text(_isStoryRatio ? '9:16 Duvar Kağıdı' : '1:1 Kare'),
                  selected: true,
                  onSelected: (_) => setState(() => _isStoryRatio = !_isStoryRatio),
                  selectedColor: const Color(0xFFD4AF37),
                  labelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11.5),
                ),
                const SizedBox(width: 6),

                // Font Stili
                ActionChip(
                  avatar: const Icon(Icons.font_download_rounded, size: 14, color: Color(0xFFFFDF7A)),
                  label: Text(
                    _fontStyle == 0 ? 'Zarif Serif' : (_fontStyle == 1 ? 'Klasik Nesih' : 'Modern'),
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFFFFDF7A)),
                  ),
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  onPressed: () {
                    setState(() => _fontStyle = (_fontStyle + 1) % 3);
                  },
                ),
                const SizedBox(width: 6),

                // Yazı Boyutu Küçült / Büyüt
                IconButton.filledTonal(
                  icon: const Icon(Icons.text_decrease_rounded, size: 16),
                  onPressed: () {
                    if (_fontSizeMultiplier > 0.8) {
                      setState(() => _fontSizeMultiplier -= 0.1);
                    }
                  },
                  tooltip: 'Küçült',
                ),
                IconButton.filledTonal(
                  icon: const Icon(Icons.text_increase_rounded, size: 16),
                  onPressed: () {
                    if (_fontSizeMultiplier < 1.4) {
                      setState(() => _fontSizeMultiplier += 0.1);
                    }
                  },
                  tooltip: 'Büyüt',
                ),
                const SizedBox(width: 6),

                // Arapça Toggle
                FilterChip(
                  label: const Text('Arapça'),
                  selected: _showArabic,
                  onSelected: (val) => setState(() => _showArabic = val),
                  selectedColor: const Color(0xFF2DD4BF).withValues(alpha: 0.3),
                  labelStyle: const TextStyle(fontSize: 11.5),
                ),
                const SizedBox(width: 6),

                // Meâl Toggle
                FilterChip(
                  label: const Text('Meâl'),
                  selected: _showMeaning,
                  onSelected: (val) => setState(() => _showMeaning = val),
                  selectedColor: const Color(0xFF2DD4BF).withValues(alpha: 0.3),
                  labelStyle: const TextStyle(fontSize: 11.5),
                ),
                const SizedBox(width: 6),

                // Logo Toggle
                FilterChip(
                  label: const Text('Logo'),
                  selected: _showWatermark,
                  onSelected: (val) => setState(() => _showWatermark = val),
                  selectedColor: const Color(0xFF2DD4BF).withValues(alpha: 0.3),
                  labelStyle: const TextStyle(fontSize: 11.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 3. Büyük Paylaş & Kaydet Butonu
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _captureAndShare,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : const Icon(Icons.download_rounded),
              label: Text(
                _isSaving ? 'Görsel Hazırlanıyor...' : 'Duvar Kağıdı / Hikaye Olarak Paylaş',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

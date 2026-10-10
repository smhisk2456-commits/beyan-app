import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Estetik Ayet / Hikaye & Duvar Kağıdı Kart Stüdyosu
class VerseCardStudioScreen extends StatefulWidget {
  final String initialReference;
  final String initialArabic;
  final String initialMeaning;

  const VerseCardStudioScreen({
    super.key,
    required this.initialReference,
    required this.initialArabic,
    required this.initialMeaning,
  });

  @override
  State<VerseCardStudioScreen> createState() => _VerseCardStudioScreenState();
}

enum CardStudioBackground {
  mistyMosque,
  goldenSunset,
  starryNight,
  oledBlack,
  emeraldPattern,
}

class _VerseCardStudioScreenState extends State<VerseCardStudioScreen> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  late String _reference;
  late String _arabic;
  late String _meaning;

  CardStudioBackground _bg = CardStudioBackground.mistyMosque;
  bool _isStoryRatio = true; // true: 9:16, false: 1:1
  bool _showArabic = true;
  bool _showWatermark = true;
  int _fontStyle = 0; // 0: Zarif Serif, 1: Klasik Nesih, 2: Modern Minimal

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _reference = widget.initialReference;
    _arabic = widget.initialArabic;
    _meaning = widget.initialMeaning;
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

  BoxDecoration _getBackgroundDecoration() {
    switch (_bg) {
      case CardStudioBackground.mistyMosque:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF01211C),
              Color(0xFF043E34),
              Color(0xFF001511),
            ],
          ),
          border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.4), width: 1.5),
        );
      case CardStudioBackground.goldenSunset:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF3E2723),
              Color(0xFF5D4037),
              Color(0xFF8D6E63),
              Color(0xFF2E1C14),
            ],
          ),
          border: Border.all(color: const Color(0xFFFFD54F).withValues(alpha: 0.5), width: 1.5),
        );
      case CardStudioBackground.starryNight:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A1128),
              Color(0xFF1C2541),
              Color(0xFF050814),
            ],
          ),
          border: Border.all(color: const Color(0xFF64B5F6).withValues(alpha: 0.4), width: 1.5),
        );
      case CardStudioBackground.oledBlack:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.black,
          border: Border.all(color: Colors.white24, width: 1.2),
        );
      case CardStudioBackground.emeraldPattern:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF004D40),
              Color(0xFF00241E),
            ],
          ),
          border: Border.all(color: const Color(0xFFFFDF7A).withValues(alpha: 0.6), width: 1.5),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF011A16),
      appBar: AppBar(
        title: const Text(
          'Ayet & Hikaye Stüdyosu',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFDF7A)),
                  )
                : const Icon(Icons.share_rounded, color: Color(0xFFFFDF7A)),
            tooltip: 'Paylaş',
            onPressed: _isSaving ? null : _captureAndShare,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Canlı Önizleme Alanı ──────────────────────────────
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: RepaintBoundary(
                  key: _repaintBoundaryKey,
                  child: AspectRatio(
                    aspectRatio: _isStoryRatio ? 9 / 16 : 1 / 1,
                    child: Container(
                      decoration: _getBackgroundDecoration(),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Üst Hilal & Başlık
                          Column(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFD4AF37).withValues(alpha: 0.18),
                                  border: Border.all(
                                    color: const Color(0xFFFFDF7A).withValues(alpha: 0.5),
                                    width: 1,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.nights_stay_rounded,
                                    color: Color(0xFFFFDF7A),
                                    size: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _reference,
                                style: const TextStyle(
                                  color: Color(0xFFFFDF7A),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),

                          // Orta: Arapça ve Meal Metni
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_showArabic && _arabic.isNotEmpty) ...[
                                Text(
                                  _arabic,
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                    fontFamily: _fontStyle == 1 ? 'Amiri' : null,
                                    fontSize: _isStoryRatio ? 22 : 18,
                                    height: 1.8,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  width: 60,
                                  height: 1.2,
                                  color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                                ),
                                const SizedBox(height: 16),
                              ],
                              Text(
                                _meaning,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  fontSize: _isStoryRatio ? 15.5 : 13.5,
                                  height: 1.55,
                                  fontStyle: _fontStyle == 0 ? FontStyle.italic : FontStyle.normal,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          // Alt: Beyân Watermark
                          if (_showWatermark)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.mosque_rounded,
                                  size: 13,
                                  color: Color(0xFFFFDF7A),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Beyân • Namaz Vakitleri & Kur\'an',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 11,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            )
                          else
                            const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Kontrol Araçları Çubuğu (Toolbar) ──────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
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
                // Arka Plan Seçicisi
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildBgChip('Cami', CardStudioBackground.mistyMosque),
                      _buildBgChip('Gün Batımı', CardStudioBackground.goldenSunset),
                      _buildBgChip('Gece', CardStudioBackground.starryNight),
                      _buildBgChip('OLED Siyah', CardStudioBackground.oledBlack),
                      _buildBgChip('Zümrüt Desen', CardStudioBackground.emeraldPattern),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Seçenekler (Boyut, Font, Arapça, Logo)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Boyut (9:16 Story vs 1:1 Post)
                      ChoiceChip(
                        label: Text(_isStoryRatio ? '9:16 Hikaye' : '1:1 Kare'),
                        selected: true,
                        onSelected: (_) {
                          setState(() => _isStoryRatio = !_isStoryRatio);
                        },
                        selectedColor: const Color(0xFFD4AF37),
                        labelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const SizedBox(width: 8),

                      // Yazı Tipi (Serif / Nesih / Minimal)
                      ActionChip(
                        avatar: const Icon(Icons.text_fields_rounded, size: 14, color: Color(0xFFFFDF7A)),
                        label: Text(
                          _fontStyle == 0 ? 'Zarif Serif' : (_fontStyle == 1 ? 'Klasik Nesih' : 'Modern'),
                          style: const TextStyle(fontSize: 12, color: Color(0xFFFFDF7A)),
                        ),
                        backgroundColor: Colors.white.withValues(alpha: 0.08),
                        onPressed: () {
                          setState(() => _fontStyle = (_fontStyle + 1) % 3);
                        },
                      ),
                      const SizedBox(width: 8),

                      // Arapça Metin Aç/Kapa
                      FilterChip(
                        label: const Text('Arapça'),
                        selected: _showArabic,
                        onSelected: (val) => setState(() => _showArabic = val),
                        selectedColor: const Color(0xFF2DD4BF).withValues(alpha: 0.3),
                        labelStyle: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 8),

                      // Beyân Logosu
                      FilterChip(
                        label: const Text('Logo'),
                        selected: _showWatermark,
                        onSelected: (val) => setState(() => _showWatermark = val),
                        selectedColor: const Color(0xFF2DD4BF).withValues(alpha: 0.3),
                        labelStyle: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Paylaş & Kaydet Ana Butonu
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _captureAndShare,
                    icon: const Icon(Icons.download_rounded),
                    label: Text(
                      _isSaving ? 'Hazırlanıyor...' : 'Hikaye / Duvar Kağıdı Olarak Paylaş',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF01201D),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBgChip(String label, CardStudioBackground bg) {
    final isSelected = _bg == bg;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _bg = bg),
        selectedColor: const Color(0xFFD4AF37),
        labelStyle: TextStyle(
          color: isSelected ? Colors.black : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }
}

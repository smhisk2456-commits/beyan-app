import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/beyan_colors.dart';
import '../../quran/services/quran_audio_service.dart';
import '../../quran/services/quran_download_service.dart';
import '../../quran/providers/quran_providers.dart';

/// Tüm Kur'anî duaların ve namaz surelerinin ses kimlikleri (25 Sûre)
const List<int> kDuaAudioSurahIds = [
  1,   // Fâtiha
  2,   // Bakara (Âyetü'l-Kürsî, Âmenerresûlü, Rabbenâ Âtina)
  3,   // Âl-i İmrân
  7,   // A'râf
  12,  // Yûsuf
  14,  // İbrâhîm
  17,  // İsrâ
  20,  // Tâhâ
  21,  // Enbiyâ
  25,  // Furkân
  59,  // Haşr (Lev Enzelnâ)
  93,  // Duhâ
  94,  // İnşirâh
  97,  // Kadir
  103, // Asr
  105, // Fîl
  106, // Kureyş
  107, // Mâûn
  108, // Kevser
  109, // Kâfirûn
  110, // Nasr
  111, // Tebbet
  112, // İhlâs
  113, // Felak
  114, // Nâs
];

/// Tek Tıkla Tüm Dua Seslerini İndirme ve Yönetim Modalı
class DuaAudioDownloadSheet extends ConsumerStatefulWidget {
  const DuaAudioDownloadSheet({super.key});

  static void show(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => const DuaAudioDownloadSheet(),
    );
  }

  @override
  ConsumerState<DuaAudioDownloadSheet> createState() => _DuaAudioDownloadSheetState();
}

class _DuaAudioDownloadSheetState extends ConsumerState<DuaAudioDownloadSheet> {
  bool _isDownloading = false;
  int _downloadedCount = 0;
  int _totalToDownload = 0;
  String _currentSurahName = '';
  double _currentFileProgress = 0.0;
  bool _isCancelled = false;

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(quranAudioProvider);
    final reciter = audioState.selectedReciter;
    final downloadedKeys = ref.watch(quranDownloadsProvider);
    final allSurahs = ref.watch(allSurahsProvider).valueOrNull ?? [];

    final downloadedDuaSurahs = kDuaAudioSurahIds.where((id) {
      return downloadedKeys.contains('${reciter.id}_$id');
    }).toList();

    final isAllDownloaded = downloadedDuaSurahs.length == kDuaAudioSurahIds.length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? BeyanColors.tone(0xFF01241E) : BeyanColors.tone(0xFF03332B),
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle (Aşağı kaydırarak veya dokunarak kapatma)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragUpdate: (details) {
                  if (details.primaryDelta != null && details.primaryDelta! > 6) {
                    Navigator.pop(context);
                  }
                },
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Başlık Alanı
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
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
                    child: Center(
                      child: Icon(
                        isAllDownloaded ? Icons.check_circle_rounded : Icons.cloud_download_rounded,
                        color: BeyanColors.tone(0xFFFFDF7A),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tüm Dua Seslerini İndir',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'İnternetsiz Çevrimdışı Dinleme Paketi',
                          style: TextStyle(
                            color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.85),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (_isDownloading) {
                        _isCancelled = true;
                      }
                      Navigator.of(context).pop();
                    },
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

              const SizedBox(height: 18),

              // Bilgi Kartı (Kâri & Durum)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.record_voice_over_rounded,
                            size: 18, color: BeyanColors.tone(0xFFFFDF7A)),
                        const SizedBox(width: 8),
                        Text(
                          'Okuyucu (Kâri): ',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            reciter.nameTr,
                            style: TextStyle(
                              color: BeyanColors.tone(0xFFFFDF7A),
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Çevrimdışı Hazır Dualar:',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: isAllDownloaded
                                ? Colors.green.withValues(alpha: 0.2)
                                : BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isAllDownloaded
                                  ? Colors.greenAccent
                                  : BeyanColors.tone(0xFFFFDF7A),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            '${downloadedDuaSurahs.length} / ${kDuaAudioSurahIds.length} Sûre Hazır',
                            style: TextStyle(
                              color: isAllDownloaded
                                  ? Colors.greenAccent
                                  : BeyanColors.tone(0xFFFFDF7A),
                              fontWeight: FontWeight.bold,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // İndirme Sırasındaki Canlı İlerleme Çubuğu
              if (_isDownloading) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: BeyanColors.tone(0xFF011A16),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'İndiriliyor: $_currentSurahName',
                              style: TextStyle(
                                color: BeyanColors.tone(0xFFFFDF7A),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '$_downloadedCount / $_totalToDownload',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: _totalToDownload > 0
                              ? ((_downloadedCount + _currentFileProgress) / _totalToDownload)
                                  .clamp(0.0, 1.0)
                              : null,
                          backgroundColor: Colors.white12,
                          valueColor: AlwaysStoppedAnimation<Color>(BeyanColors.tone(0xFFFFDF7A)),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Açıklama Metni
              Text(
                'Bu paket Fâtiha, Âyetü\'l-Kürsî, Âmenerresûlü, İnşirâh, Kadir, İhlâs, Felak, Nâs ve Kur\'an-ı Kerim\'de geçen tüm peygamber dualarının tilavetlerini içerir. '
                'İndirdikten sonra internet bağlantınız olmasa dahi tüm duaları tek dokunuşla dinleyebilirsiniz.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 12,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // Ana Aksiyon Butonu
              if (_isDownloading)
                OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _isCancelled = true;
                      _isDownloading = false;
                    });
                  },
                  icon: const Icon(Icons.stop_circle_outlined, color: Colors.redAccent, size: 18),
                  label: const Text('İndirmeyi Durdur', style: TextStyle(color: Colors.redAccent)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                )
              else if (isAllDownloaded)
                Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Tüm Dua Sesleri Çevrimdışı Hazır ✓',
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: () => _confirmDeleteAll(reciter.id),
                      icon: const Icon(Icons.delete_sweep_rounded, size: 16, color: Colors.white60),
                      label: const Text(
                        'İndirilen Dua Seslerini Cihazdan Temizle',
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ),
                  ],
                )
              else
                ElevatedButton.icon(
                  onPressed: () => _startDownloadAll(reciter, downloadedKeys, allSurahs),
                  icon: const Icon(Icons.download_rounded, size: 20),
                  label: Text(
                    downloadedDuaSurahs.isEmpty
                        ? 'Tek Tıkla Tüm Dua Seslerini İndir'
                        : 'Kalan (${kDuaAudioSurahIds.length - downloadedDuaSurahs.length}) Dua Sesini İndir',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BeyanColors.tone(0xFFFFDF7A),
                    foregroundColor: BeyanColors.tone(0xFF01201B),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startDownloadAll(
    dynamic reciter,
    Set<String> downloadedKeys,
    List<dynamic> allSurahs,
  ) async {
    final toDownload = kDuaAudioSurahIds.where((id) {
      return !downloadedKeys.contains('${reciter.id}_$id');
    }).toList();

    if (toDownload.isEmpty) return;

    setState(() {
      _isDownloading = true;
      _isCancelled = false;
      _downloadedCount = 0;
      _totalToDownload = toDownload.length;
      _currentFileProgress = 0.0;
    });

    HapticFeedback.lightImpact();

    for (int i = 0; i < toDownload.length; i++) {
      if (_isCancelled || !mounted) break;

      final surahId = toDownload[i];
      final surahName = allSurahs
          .firstWhere((s) => s.id == surahId, orElse: () => null)
          ?.nameTurkish ?? 'Sûre $surahId';

      setState(() {
        _currentSurahName = surahName;
        _currentFileProgress = 0.0;
      });

      final url = reciter.getSurahAudioUrl(surahId);

      await ref.read(quranDownloadsProvider.notifier).download(
        reciterId: reciter.id,
        surahId: surahId,
        url: url,
        onProgress: (p) {
          if (mounted && !_isCancelled) {
            setState(() {
              _currentFileProgress = p;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _downloadedCount = i + 1;
        });
      }
    }

    if (!mounted) return;
    if (!_isCancelled) {
      setState(() {
        _isDownloading = false;
      });
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: BeyanColors.tone(0xFF012E2B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: BeyanColors.tone(0xFFD4AF37), width: 1.2),
          ),
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 20),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Tüm dua sesleri başarıyla indirildi. İnternetsiz dinleyebilirsiniz!'),
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _confirmDeleteAll(String reciterId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: BeyanColors.tone(0xFF022B24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Dua Seslerini Sil?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'İndirilen tüm dua sesleri cihazınızdan silinecektir. İstediğiniz zaman tekrar indirebilirsiniz.',
          style: TextStyle(color: Colors.white70, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      for (final surahId in kDuaAudioSurahIds) {
        await ref.read(quranDownloadsProvider.notifier).delete(
          reciterId: reciterId,
          surahId: surahId,
        );
      }
      HapticFeedback.mediumImpact();
    }
  }
}

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Kur'an-ı Kerim Sure Seslerini Çevrimdışı (Offline) İndirme ve Yönetim Servisi
class QuranDownloadService {
  static final QuranDownloadService instance = QuranDownloadService._();
  QuranDownloadService._();

  static Directory? _audioDir;

  static Future<Directory> _getAudioDirectory() async {
    if (_audioDir != null && await _audioDir!.exists()) return _audioDir!;
    // iOS iCloud yedekleme kuralı (Apple App Store Guideline 5.1.1):
    // İndirilebilir medya dosyaları getApplicationDocumentsDirectory'ye konulmamalı,
    // iCloud yedeğine girmeyen getApplicationSupportDirectory altında tutulmalıdır.
    Directory baseDir;
    try {
      baseDir = await getApplicationSupportDirectory();
    } catch (_) {
      baseDir = await getApplicationDocumentsDirectory();
    }
    final dir = Directory(p.join(baseDir.path, 'quran_audio'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // Eski belgeler dizininden (Documents) yeni destek dizinine sessiz taşıma (varsa)
    try {
      final legacyDir = Directory(p.join((await getApplicationDocumentsDirectory()).path, 'quran_audio'));
      if (await legacyDir.exists() && legacyDir.path != dir.path) {
        final legacyFiles = await legacyDir.list().toList();
        for (final item in legacyFiles) {
          if (item is File) {
            final target = File(p.join(dir.path, p.basename(item.path)));
            if (!await target.exists()) {
              await item.copy(target.path);
            }
            await item.delete();
          }
        }
      }
    } catch (_) {}

    _audioDir = dir;
    return dir;
  }

  static String _fileName(String reciterId, int surahId) => '${reciterId}_$surahId.mp3';

  Future<File?> getLocalFile(String reciterId, int surahId) async {
    try {
      final dir = await _getAudioDirectory();
      final file = File(p.join(dir.path, _fileName(reciterId, surahId)));
      if (await file.exists() && await file.length() >= 15000) {
        return file;
      }
    } catch (_) {}
    return null;
  }

  Future<bool> isDownloaded(String reciterId, int surahId) async {
    final file = await getLocalFile(reciterId, surahId);
    return file != null;
  }

  Future<bool> downloadSurah(
    String reciterId,
    int surahId,
    String url, {
    void Function(double progress)? onProgress,
  }) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 12);
    try {
      final dir = await _getAudioDirectory();
      final targetFile = File(p.join(dir.path, _fileName(reciterId, surahId)));
      final tempFile = File('${targetFile.path}.${DateTime.now().microsecondsSinceEpoch}.tmp');

      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close().timeout(const Duration(seconds: 30));
      if (response.statusCode != 200) {
        return false;
      }

      final contentLength = response.contentLength;
      var received = 0;
      final sink = tempFile.openWrite();

      try {
        await for (final chunk in response.timeout(const Duration(seconds: 45))) {
          sink.add(chunk);
          received += chunk.length;
          if (contentLength > 0 && onProgress != null) {
            onProgress((received / contentLength).clamp(0.0, 1.0));
          }
        }
        await sink.flush();
      } finally {
        await sink.close();
      }

      // ── Tamamlanma ve Bütünlük Kontrolü ─────────────────────────────────
      // 1. Content-Length bildirilmişse ve eksik indirilmişse yarım dosyayı sil
      if (contentLength > 0 && received != contentLength) {
        debugPrint('[QuranDownloadService] Eksik indirme algılandı: $received / $contentLength byte.');
        if (await tempFile.exists()) await tempFile.delete();
        return false;
      }
      // 2. Çok küçük / bozuk dosya kontrolü (en kısa sure bile ~15 KB üzerindedir)
      if (received < 15000) {
        debugPrint('[QuranDownloadService] Geçersiz dosya boyutu: $received byte.');
        if (await tempFile.exists()) await tempFile.delete();
        return false;
      }

      if (await targetFile.exists()) {
        await targetFile.delete();
      }
      await tempFile.rename(targetFile.path);
      return true;
    } catch (e) {
      debugPrint('[QuranDownloadService] Error downloading ($reciterId, $surahId): $e');
      try {
        final dir = await _getAudioDirectory();
        // Temizle: Olası eski/geçici .tmp dosyaları
        final list = dir.listSync();
        for (final f in list) {
          if (f is File && f.path.contains('${_fileName(reciterId, surahId)}.') && f.path.endsWith('.tmp')) {
            f.deleteSync();
          }
        }
      } catch (_) {}
      return false;
    } finally {
      client.close();
    }
  }

  Future<bool> deleteDownloadedSurah(String reciterId, int surahId) async {
    try {
      final file = await getLocalFile(reciterId, surahId);
      if (file != null && await file.exists()) {
        await file.delete();
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<Set<String>> getAllDownloadedSurahKeys() async {
    try {
      final dir = await _getAudioDirectory();
      if (!await dir.exists()) return {};
      final entities = await dir.list().toList();
      final keys = <String>{};
      for (final e in entities) {
        if (e is File && e.path.endsWith('.mp3')) {
          final base = p.basenameWithoutExtension(e.path);
          keys.add(base);
        }
      }
      return keys;
    } catch (_) {
      return {};
    }
  }
}

/// Çevrimdışı İndirilen Sureler State Notifier
class QuranDownloadsNotifier extends StateNotifier<Set<String>> {
  QuranDownloadsNotifier() : super({}) {
    _load();
  }

  Future<void> _load() async {
    final keys = await QuranDownloadService.instance.getAllDownloadedSurahKeys();
    state = keys;
  }

  bool isDownloaded(String reciterId, int surahId) =>
      state.contains('${reciterId}_$surahId');

  Future<bool> download({
    required String reciterId,
    required int surahId,
    required String url,
    void Function(double progress)? onProgress,
  }) async {
    final success = await QuranDownloadService.instance.downloadSurah(
      reciterId,
      surahId,
      url,
      onProgress: onProgress,
    );
    if (success) {
      state = {...state, '${reciterId}_$surahId'};
    }
    return success;
  }

  Future<bool> delete({
    required String reciterId,
    required int surahId,
  }) async {
    final success = await QuranDownloadService.instance.deleteDownloadedSurah(
      reciterId,
      surahId,
    );
    if (success) {
      final updated = Set<String>.from(state);
      updated.remove('${reciterId}_$surahId');
      state = updated;
    }
    return success;
  }
}

final quranDownloadsProvider =
    StateNotifierProvider<QuranDownloadsNotifier, Set<String>>((ref) {
  return QuranDownloadsNotifier();
});

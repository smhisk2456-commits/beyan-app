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
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, 'quran_audio'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _audioDir = dir;
    return dir;
  }

  static String _fileName(String reciterId, int surahId) => '${reciterId}_$surahId.mp3';

  Future<File?> getLocalFile(String reciterId, int surahId) async {
    try {
      final dir = await _getAudioDirectory();
      final file = File(p.join(dir.path, _fileName(reciterId, surahId)));
      if (await file.exists() && await file.length() > 5000) {
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
      final tempFile = File('${targetFile.path}.tmp');

      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close().timeout(const Duration(seconds: 30));
      if (response.statusCode != 200) {
        return false;
      }

      final contentLength = response.contentLength;
      var received = 0;
      final sink = tempFile.openWrite();

      await for (final chunk in response) {
        sink.add(chunk);
        received += chunk.length;
        if (contentLength > 0 && onProgress != null) {
          onProgress((received / contentLength).clamp(0.0, 1.0));
        }
      }
      await sink.flush();
      await sink.close();

      if (await targetFile.exists()) {
        await targetFile.delete();
      }
      await tempFile.rename(targetFile.path);
      return true;
    } catch (e) {
      debugPrint('[QuranDownloadService] Error downloading ($reciterId, $surahId): $e');
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

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/verse.dart';
import 'quran_download_service.dart';

/// Kur'an tilavetinde kelime kelime milisaniyelik zamanlama segmenti.
class WordSegment {
  final int wordIndex; // Quran.com API'den gelen 1 tabanlı kelime sırası
  final int startMs;
  final int endMs;

  const WordSegment({
    required this.wordIndex,
    required this.startMs,
    required this.endMs,
  });

  factory WordSegment.fromList(List<dynamic> list) {
    final wIdx = (list[0] as num).toInt();
    final start = (list[1] as num).round();
    final end = (list[2] as num).round();
    return WordSegment(wordIndex: wIdx, startMs: start, endMs: end);
  }
}

/// Kur'an tilavetinde ayet bazlı milisaniyelik zamanlama ve kelime segmentleri.
class VerseTiming {
  final int surahId;
  final int verseNumber;
  final int timestampFrom;
  final int timestampTo;
  final int duration;
  final List<WordSegment> segments;

  const VerseTiming({
    required this.surahId,
    required this.verseNumber,
    required this.timestampFrom,
    required this.timestampTo,
    required this.duration,
    required this.segments,
  });

  factory VerseTiming.fromJson(Map<String, dynamic> json) {
    final verseKey = json['verse_key'] as String? ?? '1:1';
    final parts = verseKey.split(':');
    final sId = parts.length > 1 ? int.tryParse(parts[0]) ?? 1 : 1;
    final vNum = parts.length > 1 ? int.tryParse(parts[1]) ?? 1 : 1;

    final from = (json['timestamp_from'] as num?)?.round() ?? 0;
    final to = (json['timestamp_to'] as num?)?.round() ?? 0;
    final dur = (json['duration'] as num?)?.round().abs() ?? (to - from).abs();

    final rawSegments = json['segments'] as List<dynamic>? ?? [];
    final segList = <WordSegment>[];
    for (final s in rawSegments) {
      if (s is List && s.length >= 3) {
        segList.add(WordSegment.fromList(s));
      }
    }

    return VerseTiming(
      surahId: sId,
      verseNumber: vNum,
      timestampFrom: from,
      timestampTo: to,
      duration: dur,
      segments: segList,
    );
  }
}

class QuranReciter {
  final String id;
  final String nameTr;
  final String nameAr;
  final String baseUrl;
  final int? quranComReciterId;
  final bool usesPadding;

  const QuranReciter({
    required this.id,
    required this.nameTr,
    required this.nameAr,
    required this.baseUrl,
    this.quranComReciterId,
    this.usesPadding = false,
  });

  String getSurahAudioUrl(int surahId) {
    if (usesPadding) {
      final code = surahId.toString().padLeft(3, '0');
      return '$baseUrl$code.mp3';
    }
    return '$baseUrl$surahId.mp3';
  }
}

final List<QuranReciter> quranRecitersList = [
  const QuranReciter(
    id: 'mishary',
    nameTr: 'Mishary Rashid Alafasy',
    nameAr: 'مشاري راشد العفاسي',
    baseUrl: 'https://download.quranicaudio.com/qdc/mishari_al_afasy/murattal/',
    quranComReciterId: 7,
    usesPadding: false,
  ),
  const QuranReciter(
    id: 'abdulbaset',
    nameTr: 'AbdulBaset AbdulSamad (Murattal)',
    nameAr: 'عبد الباسط عبد الصمد',
    baseUrl: 'https://download.quranicaudio.com/qdc/abdul_baset/murattal/',
    quranComReciterId: 2,
    usesPadding: false,
  ),
  const QuranReciter(
    id: 'sudais',
    nameTr: 'Abdur-Rahman as-Sudais',
    nameAr: 'عبد الرحمن السديس',
    baseUrl: 'https://download.quranicaudio.com/qdc/abdurrahmaan_as_sudais/murattal/',
    quranComReciterId: 3,
    usesPadding: false,
  ),
  const QuranReciter(
    id: 'husary',
    nameTr: 'Mahmoud Khalil Al-Husary',
    nameAr: 'محمود خليل الحصري',
    baseUrl: 'https://download.quranicaudio.com/qdc/khalil_al_husary/murattal/',
    quranComReciterId: 6,
    usesPadding: false,
  ),
  const QuranReciter(
    id: 'ghamdi',
    nameTr: 'Saad Al-Ghamdi',
    nameAr: 'سعد الغامدي',
    baseUrl: 'https://download.quranicaudio.com/quran/sa3d_al-ghaamidi/complete/',
    quranComReciterId: null,
    usesPadding: true,
  ),
  const QuranReciter(
    id: 'maher',
    nameTr: 'Maher Al-Muaiqly',
    nameAr: 'ماهر المعيقلي',
    baseUrl: 'https://download.quranicaudio.com/qdc/maher_almuaiqly/murattal/',
    quranComReciterId: 8,
    usesPadding: false,
  ),
  const QuranReciter(
    id: 'minshawi',
    nameTr: 'Mohamed Siddiq El-Minshawi',
    nameAr: 'محمد صديق المنشاوي',
    baseUrl: 'https://download.quranicaudio.com/qdc/siddiq_minshawi/murattal/',
    quranComReciterId: 9,
    usesPadding: false,
  ),
];

class QuranAudioState {
  final bool isPlaying;
  final bool isLoading;
  final int? currentSurahId;
  final String? currentSurahName;
  final QuranReciter selectedReciter;
  final Duration position;
  final Duration duration;
  final int? activeVerseNumber;
  final int? activeWordIndex;
  final double verseProgress;
  final bool isLiveTrackingEnabled;
  final bool isWordHighlightEnabled;

  const QuranAudioState({
    this.isPlaying = false,
    this.isLoading = false,
    this.currentSurahId,
    this.currentSurahName,
    required this.selectedReciter,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.activeVerseNumber,
    this.activeWordIndex,
    this.verseProgress = 0.0,
    this.isLiveTrackingEnabled = true,
    this.isWordHighlightEnabled = true,
  });

  QuranAudioState copyWith({
    bool? isPlaying,
    bool? isLoading,
    int? currentSurahId,
    String? currentSurahName,
    QuranReciter? selectedReciter,
    Duration? position,
    Duration? duration,
    int? activeVerseNumber,
    int? activeWordIndex,
    double? verseProgress,
    bool? isLiveTrackingEnabled,
    bool? isWordHighlightEnabled,
    bool clearCurrentSurah = false,
    bool clearActiveVerse = false,
    bool clearActiveWord = false,
  }) {
    return QuranAudioState(
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      currentSurahId: clearCurrentSurah ? null : (currentSurahId ?? this.currentSurahId),
      currentSurahName: clearCurrentSurah ? null : (currentSurahName ?? this.currentSurahName),
      selectedReciter: selectedReciter ?? this.selectedReciter,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      activeVerseNumber: (clearCurrentSurah || clearActiveVerse) ? null : (activeVerseNumber ?? this.activeVerseNumber),
      activeWordIndex: (clearCurrentSurah || clearActiveWord) ? null : (activeWordIndex ?? this.activeWordIndex),
      verseProgress: clearCurrentSurah ? 0.0 : (verseProgress ?? this.verseProgress),
      isLiveTrackingEnabled: isLiveTrackingEnabled ?? this.isLiveTrackingEnabled,
      isWordHighlightEnabled: isWordHighlightEnabled ?? this.isWordHighlightEnabled,
    );
  }
}

class QuranAudioNotifier extends StateNotifier<QuranAudioState> {
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription? _posSub;
  StreamSubscription? _durSub;
  StreamSubscription? _stateSub;
  List<Verse>? _currentVerses;

  QuranAudioNotifier()
      : super(QuranAudioState(selectedReciter: quranRecitersList.first)) {
    _initAudioSession();
    _initListeners();
  }

  void setVerses(List<Verse> verses) {
    _currentVerses = verses;
    if (state.isPlaying) {
      updateActiveVerseByProgress(verses);
    }
  }

  Future<void> _initAudioSession() async {
    try {
      await _player.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
          ),
          android: const AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: true,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.gain,
          ),
        ),
      );
    } catch (e) {
      debugPrint('QuranAudioNotifier audio context hatası: $e');
    }
  }

  void _initListeners() {
    _posSub = _player.onPositionChanged.listen((pos) {
      state = state.copyWith(position: pos);
      if (_currentVerses != null && _currentVerses!.isNotEmpty) {
        updateActiveVerseByProgress(_currentVerses!);
      }
    });

    _durSub = _player.onDurationChanged.listen((dur) {
      state = state.copyWith(duration: dur);
    });

    _stateSub = _player.onPlayerStateChanged.listen((playerState) {
      final isPlaying = playerState == PlayerState.playing;
      final isCompleted = playerState == PlayerState.completed;
      state = state.copyWith(
        isPlaying: isPlaying,
        isLoading: false,
        position: isCompleted ? Duration.zero : null,
      );
    });
  }

  void setReciter(QuranReciter reciter) {
    state = state.copyWith(selectedReciter: reciter);
    if (state.isPlaying && state.currentSurahId != null) {
      playSurah(state.currentSurahId!, state.currentSurahName ?? '');
    }
  }

  static final Map<String, List<VerseTiming>> _timingsCache = {};
  static final HttpClient _httpClient = HttpClient()..connectionTimeout = const Duration(seconds: 8);

  static Future<List<VerseTiming>?> _fetchVerseTimings(int reciterId, int surahId) async {
    try {
      final uri = Uri.parse('https://api.quran.com/api/v4/chapter_recitations/$reciterId/$surahId?segments=true');
      final request = await _httpClient.getUrl(uri);
      final response = await request.close().timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final json = jsonDecode(body) as Map<String, dynamic>;
        final audioFile = json['audio_file'] as Map<String, dynamic>?;
        final timestamps = audioFile?['timestamps'] as List<dynamic>?;
        if (timestamps != null) {
          return timestamps
              .whereType<Map<String, dynamic>>()
              .map((t) => VerseTiming.fromJson(t))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('[QuranAudio] Segments fetch error ($reciterId, $surahId): $e');
    }
    return null;
  }

  Future<void> playSurah(int surahId, String surahName) async {
    try {
      state = state.copyWith(
        isLoading: true,
        currentSurahId: surahId,
        currentSurahName: surahName,
      );

      final reciter = state.selectedReciter;
      final localFile = await QuranDownloadService.instance.getLocalFile(reciter.id, surahId);
      final audioUrl = reciter.getSurahAudioUrl(surahId);

      // Quran.com milisaniyelik kelime segmentlerini asenkron olarak getir ve önbelleğe al
      final cacheKey = '${reciter.id}_$surahId';
      if (reciter.quranComReciterId != null && !_timingsCache.containsKey(cacheKey)) {
        _fetchVerseTimings(reciter.quranComReciterId!, surahId).then((timings) {
          if (timings != null && timings.isNotEmpty) {
            _timingsCache[cacheKey] = timings;
            if (_currentVerses != null && _currentVerses!.isNotEmpty) {
              updateActiveVerseByProgress(_currentVerses!);
            }
          }
        });
      }

      await _player.stop();
      if (localFile != null && await localFile.exists()) {
        await _player.play(DeviceFileSource(localFile.path));
      } else {
        await _player.play(UrlSource(audioUrl));
      }
      state = state.copyWith(isPlaying: true, isLoading: false);
    } catch (e) {
      debugPrint('QuranAudio playSurah hatası: $e');
      state = state.copyWith(isLoading: false, isPlaying: false);
    }
  }

  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await _player.pause();
      state = state.copyWith(isPlaying: false);
    } else {
      await _player.resume();
      state = state.copyWith(isPlaying: true);
    }
  }

  void toggleLiveTracking() {
    state = state.copyWith(isLiveTrackingEnabled: !state.isLiveTrackingEnabled);
  }

  void toggleWordHighlight() {
    state = state.copyWith(isWordHighlightEnabled: !state.isWordHighlightEnabled);
  }

  void updateActiveVerseByProgress(List<Verse> verses) {
    if (verses.isEmpty) return;

    final currentMs = state.position.inMilliseconds;
    final totalMs = state.duration.inMilliseconds;
    final reciter = state.selectedReciter;
    final cacheKey = '${reciter.id}_${state.currentSurahId}';
    final timings = _timingsCache[cacheKey];

    // 1. ÖNCELİK: Quran.com Milisaniye Hassasiyetinde Gerçek Zamanlı Karaoke Senkronizasyonu
    if (timings != null && timings.isNotEmpty) {
      VerseTiming? activeTiming;
      for (int i = 0; i < timings.length; i++) {
        final t = timings[i];
        if (currentMs >= t.timestampFrom && currentMs < t.timestampTo) {
          activeTiming = t;
          break;
        }
      }

      if (activeTiming == null) {
        if (currentMs < timings.first.timestampFrom) {
          activeTiming = timings.first;
        } else {
          activeTiming = timings.last;
        }
      }

      final determinedVerse = activeTiming.verseNumber;
      final dur = activeTiming.duration > 0
          ? activeTiming.duration
          : (activeTiming.timestampTo - activeTiming.timestampFrom);
      final elapsed = (currentMs - activeTiming.timestampFrom).clamp(0, dur > 0 ? dur : 1);
      final progress = dur > 0 ? (elapsed / dur).clamp(0.0, 1.0) : 0.0;

      // Kelime bazlı milisaniyelik karaoke tespiti
      int determinedWord = 0;
      if (activeTiming.segments.isNotEmpty) {
        bool found = false;
        for (final seg in activeTiming.segments) {
          if (currentMs >= seg.startMs && currentMs < seg.endMs) {
            determinedWord = (seg.wordIndex - 1).clamp(0, 999);
            found = true;
            break;
          }
        }
        if (!found) {
          if (currentMs < activeTiming.segments.first.startMs) {
            determinedWord = (activeTiming.segments.first.wordIndex - 1).clamp(0, 999);
          } else {
            determinedWord = (activeTiming.segments.last.wordIndex - 1).clamp(0, 999);
          }
        }
      }

      if (state.activeVerseNumber != determinedVerse ||
          state.activeWordIndex != determinedWord ||
          (state.verseProgress - progress).abs() > 0.02) {
        state = state.copyWith(
          activeVerseNumber: determinedVerse,
          activeWordIndex: determinedWord,
          verseProgress: progress,
        );
      }
      return;
    }

    // 2. YEDEK (OFFLINE / DİĞER KÂRİLER): Harf Ağırlığı Oransal Hesaplama
    if (totalMs <= 0) return;

    int totalWeight = 0;
    final weights = verses.map((v) {
      final w = v.arabicText.length + 10;
      totalWeight += w;
      return w;
    }).toList();

    if (totalWeight <= 0) return;

    int accumulatedBefore = 0;
    int determinedVerse = verses.first.verseNumber;
    int activeVerseIdx = 0;
    int verseStartMs = 0;
    int verseEndMs = totalMs;

    for (int i = 0; i < verses.length; i++) {
      final prevAccum = accumulatedBefore;
      accumulatedBefore += weights[i];
      final currentVerseEndMs = ((accumulatedBefore / totalWeight) * totalMs).round();
      if (currentMs <= currentVerseEndMs || i == verses.length - 1) {
        determinedVerse = verses[i].verseNumber;
        activeVerseIdx = i;
        verseStartMs = ((prevAccum / totalWeight) * totalMs).round();
        verseEndMs = currentVerseEndMs;
        break;
      }
    }

    // Ayet içi ilerleme oranı (0.0 - 1.0)
    final verseDurationMs = verseEndMs - verseStartMs;
    final verseElapsedMs = (currentMs - verseStartMs).clamp(0, verseDurationMs > 0 ? verseDurationMs : 1);
    final progress = verseDurationMs > 0 ? (verseElapsedMs / verseDurationMs).clamp(0.0, 1.0) : 0.0;

    // Kelime kelime takip (Canlı Karaoke)
    int determinedWord = 0;
    final activeVerse = verses[activeVerseIdx];
    final words = activeVerse.arabicText.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isNotEmpty) {
      final wordWeights = words.map((w) => w.length + 2).toList();
      final totalWordWeight = wordWeights.fold<int>(0, (a, b) => a + b);
      if (totalWordWeight > 0) {
        final targetWordWeight = progress * totalWordWeight;
        int wordAccum = 0;
        for (int w = 0; w < words.length; w++) {
          wordAccum += wordWeights[w];
          if (wordAccum >= targetWordWeight || w == words.length - 1) {
            determinedWord = w;
            break;
          }
        }
      }
    }

    if (state.activeVerseNumber != determinedVerse ||
        state.activeWordIndex != determinedWord ||
        (state.verseProgress - progress).abs() > 0.03) {
      state = state.copyWith(
        activeVerseNumber: determinedVerse,
        activeWordIndex: determinedWord,
        verseProgress: progress,
      );
    }
  }

  Future<void> seekToWord(
    int verseNumber,
    int wordIndex,
    List<Verse> verses, {
    String? surahName,
  }) async {
    if (verses.isEmpty) return;

    final surahId = verses.first.surahId;
    if (state.currentSurahId != surahId || !state.isPlaying) {
      await playSurah(surahId, surahName ?? 'Surah $surahId');
    }

    final cacheKey = '${state.selectedReciter.id}_$surahId';
    final timings = _timingsCache[cacheKey];

    // 1. Quran.com Milisaniye Hassasiyetinde Kelimeye Atlama
    if (timings != null && timings.isNotEmpty) {
      VerseTiming? targetTiming;
      for (final t in timings) {
        if (t.verseNumber == verseNumber) {
          targetTiming = t;
          break;
        }
      }

      if (targetTiming != null) {
        int targetMs = targetTiming.timestampFrom;
        if (targetTiming.segments.isNotEmpty) {
          final targetWordNum = wordIndex + 1; // 1 tabanlı API indeksi
          WordSegment? seg;
          for (final s in targetTiming.segments) {
            if (s.wordIndex == targetWordNum) {
              seg = s;
              break;
            }
          }
          if (seg != null) {
            targetMs = seg.startMs;
          } else if (wordIndex < targetTiming.segments.length) {
            targetMs = targetTiming.segments[wordIndex].startMs;
          }
        }
        await seek(Duration(milliseconds: targetMs));
        state = state.copyWith(
          activeVerseNumber: verseNumber,
          activeWordIndex: wordIndex,
        );
        return;
      }
    }

    // 2. Yedek Oransal Atlama
    int totalWeight = 0;
    final weights = verses.map((v) {
      final w = v.arabicText.length + 10;
      totalWeight += w;
      return w;
    }).toList();

    int accumulatedBefore = 0;
    int verseWeight = 0;
    Verse? targetVerse;
    for (int i = 0; i < verses.length; i++) {
      if (verses[i].verseNumber == verseNumber) {
        targetVerse = verses[i];
        verseWeight = weights[i];
        break;
      }
      accumulatedBefore += weights[i];
    }

    final totalMs = state.duration.inMilliseconds;
    if (totalMs > 0 && totalWeight > 0 && targetVerse != null) {
      final verseStartMs = ((accumulatedBefore / totalWeight) * totalMs).round();
      final verseDurationMs = ((verseWeight / totalWeight) * totalMs).round();

      final words = targetVerse.arabicText.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
      double wordFraction = 0.0;
      if (words.isNotEmpty && wordIndex > 0) {
        final clampedIndex = wordIndex.clamp(0, words.length - 1);
        final wordWeights = words.map((w) => w.length + 2).toList();
        final totalWordWeight = wordWeights.fold<int>(0, (a, b) => a + b);
        int accumWordBefore = 0;
        for (int w = 0; w < clampedIndex; w++) {
          accumWordBefore += wordWeights[w];
        }
        wordFraction = totalWordWeight > 0 ? (accumWordBefore / totalWordWeight) : 0.0;
      }

      final targetMs = (verseStartMs + (wordFraction * verseDurationMs)).round();
      await seek(Duration(milliseconds: targetMs.clamp(0, totalMs)));
    }

    state = state.copyWith(
      activeVerseNumber: verseNumber,
      activeWordIndex: wordIndex,
    );
  }

  Future<void> seekToVerse(int verseNumber, List<Verse> verses, {String? surahName}) async {
    if (verses.isEmpty) return;

    final surahId = verses.first.surahId;
    if (state.currentSurahId != surahId || !state.isPlaying) {
      await playSurah(surahId, surahName ?? 'Surah $surahId');
    }

    final cacheKey = '${state.selectedReciter.id}_$surahId';
    final timings = _timingsCache[cacheKey];

    // 1. Quran.com Milisaniye Hassasiyetinde Ayete Atlama
    if (timings != null && timings.isNotEmpty) {
      for (final t in timings) {
        if (t.verseNumber == verseNumber) {
          await seek(Duration(milliseconds: t.timestampFrom));
          state = state.copyWith(
            activeVerseNumber: verseNumber,
            activeWordIndex: 0,
            verseProgress: 0.0,
          );
          return;
        }
      }
    }

    // 2. Yedek Oransal Atlama
    int totalWeight = 0;
    final weights = verses.map((v) {
      final w = v.arabicText.length + 10;
      totalWeight += w;
      return w;
    }).toList();

    int accumulatedBefore = 0;
    for (int i = 0; i < verses.length; i++) {
      if (verses[i].verseNumber == verseNumber) {
        break;
      }
      accumulatedBefore += weights[i];
    }

    final totalMs = state.duration.inMilliseconds;
    if (totalMs > 0 && totalWeight > 0) {
      final startMs = ((accumulatedBefore / totalWeight) * totalMs).round();
      await seek(Duration(milliseconds: startMs));
    }
    state = state.copyWith(
      activeVerseNumber: verseNumber,
      activeWordIndex: 0,
      verseProgress: 0.0,
    );
  }

  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position).timeout(const Duration(milliseconds: 300));
    } catch (_) {}
  }

  Future<void> seekRelative(int seconds) async {
    final target = state.position + Duration(seconds: seconds);
    final clamped = target < Duration.zero
        ? Duration.zero
        : (target > state.duration ? state.duration : target);
    await _player.seek(clamped);
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
    _currentVerses = null;
    state = state.copyWith(
      isPlaying: false,
      isLoading: false,
      clearCurrentSurah: true,
      clearActiveVerse: true,
      clearActiveWord: true,
      verseProgress: 0.0,
      position: Duration.zero,
      duration: Duration.zero,
    );
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _durSub?.cancel();
    _stateSub?.cancel();
    _player.dispose();
    super.dispose();
  }
}

final quranAudioProvider =
    StateNotifierProvider<QuranAudioNotifier, QuranAudioState>((ref) {
  return QuranAudioNotifier();
});

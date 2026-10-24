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
  final double wordProgress;
  final bool isLiveTrackingEnabled;
  final bool isWordHighlightEnabled;

  // 🔁 Ezber & Döngü Modu (A-B Loop)
  final int loopRepeatCount; // 1: normal, 3: 3x, 5: 5x, 10: 10x, -1: sonsuz
  final int currentLoopIteration; // 1, 2, ...
  final int? loopVerseNumber; // Tek âyet ezber tekrarı için

  // 🎧 Uyku Öncesi & Manevi Ambiyans (Sleep & Calm)
  final String? activeAmbience; // null, 'rain', 'ney', 'breeze'
  final double ambienceVolume; // 0.0 - 1.0 (varsayılan 0.45)
  final int? sleepTimerMinutes; // null, 15, 30, 45, 60
  final int? sleepTimerSecondsRemaining;

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
    this.wordProgress = 0.0,
    this.isLiveTrackingEnabled = true,
    this.isWordHighlightEnabled = true,
    this.loopRepeatCount = 1,
    this.currentLoopIteration = 1,
    this.loopVerseNumber,
    this.activeAmbience,
    this.ambienceVolume = 0.45,
    this.sleepTimerMinutes,
    this.sleepTimerSecondsRemaining,
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
    double? wordProgress,
    bool? isLiveTrackingEnabled,
    bool? isWordHighlightEnabled,
    int? loopRepeatCount,
    int? currentLoopIteration,
    int? loopVerseNumber,
    String? activeAmbience,
    double? ambienceVolume,
    int? sleepTimerMinutes,
    int? sleepTimerSecondsRemaining,
    bool clearCurrentSurah = false,
    bool clearActiveVerse = false,
    bool clearActiveWord = false,
    bool clearLoopVerse = false,
    bool clearAmbience = false,
    bool clearSleepTimer = false,
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
      wordProgress: (clearCurrentSurah || clearActiveWord) ? 0.0 : (wordProgress ?? this.wordProgress),
      isLiveTrackingEnabled: isLiveTrackingEnabled ?? this.isLiveTrackingEnabled,
      isWordHighlightEnabled: isWordHighlightEnabled ?? this.isWordHighlightEnabled,
      loopRepeatCount: loopRepeatCount ?? this.loopRepeatCount,
      currentLoopIteration: currentLoopIteration ?? this.currentLoopIteration,
      loopVerseNumber: clearLoopVerse ? null : (loopVerseNumber ?? this.loopVerseNumber),
      activeAmbience: clearAmbience ? null : (activeAmbience ?? this.activeAmbience),
      ambienceVolume: ambienceVolume ?? this.ambienceVolume,
      sleepTimerMinutes: clearSleepTimer ? null : (sleepTimerMinutes ?? this.sleepTimerMinutes),
      sleepTimerSecondsRemaining: clearSleepTimer ? null : (sleepTimerSecondsRemaining ?? this.sleepTimerSecondsRemaining),
    );
  }
}

class QuranAudioNotifier extends StateNotifier<QuranAudioState> {
  final AudioPlayer _player = AudioPlayer();
  final AudioPlayer _ambiencePlayer = AudioPlayer()..setReleaseMode(ReleaseMode.loop);
  Timer? _sleepTimer;
  Timer? _smoothSyncTimer;
  final Stopwatch _interpWatch = Stopwatch();
  Duration _lastAnchorPosition = Duration.zero;
  StreamSubscription? _posSub;
  StreamSubscription? _durSub;
  StreamSubscription? _stateSub;
  List<Verse>? _currentVerses;

  QuranAudioNotifier()
      : super(QuranAudioState(selectedReciter: quranRecitersList.first)) {
    _initAudioSession();
    _initListeners();
  }

  bool _isLoopSeeking = false;
  int? _pendingSeekMs;
  int? _stopAfterVerse;
  int? get stopAfterVerse => _stopAfterVerse;

  @visibleForTesting
  void setStopAfterVerse(int? v) => _stopAfterVerse = v;

  void setVerses(List<Verse> verses) {
    final isNewSurahList = _currentVerses == null ||
        _currentVerses!.isEmpty ||
        (verses.isNotEmpty && _currentVerses!.first.surahId != verses.first.surahId) ||
        _currentVerses!.length != verses.length;
    _currentVerses = verses;
    if (isNewSurahList && state.isPlaying) {
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

  void _startSmoothSyncTimer() {
    _smoothSyncTimer?.cancel();
    _interpWatch
      ..reset()
      ..start();
    _smoothSyncTimer = Timer.periodic(const Duration(milliseconds: 33), (_) {
      if (!mounted || !state.isPlaying) return;
      final interpMs = _lastAnchorPosition.inMilliseconds + _interpWatch.elapsedMilliseconds;
      final totalMs = state.duration.inMilliseconds;
      final clampedMs = totalMs > 0 ? interpMs.clamp(0, totalMs) : interpMs;
      if (_currentVerses != null && _currentVerses!.isNotEmpty) {
        updateActiveVerseByProgress(_currentVerses!, currentMs: clampedMs);
      } else {
        final newSec = clampedMs ~/ 1000;
        if (newSec != state.position.inSeconds) {
          state = state.copyWith(position: Duration(milliseconds: clampedMs));
        }
      }
    });
  }

  void _stopSmoothSyncTimer() {
    _smoothSyncTimer?.cancel();
    _smoothSyncTimer = null;
    _interpWatch.stop();
  }

  void _initListeners() {
    _posSub = _player.onPositionChanged.listen((pos) {
      if (!mounted) return;
      if (_pendingSeekMs != null) {
        final target = _pendingSeekMs!;
        if ((pos.inMilliseconds - target).abs() > 1500) {
          _player.seek(Duration(milliseconds: target));
          return;
        } else {
          _pendingSeekMs = null;
        }
      }
      _lastAnchorPosition = pos;
      if (state.isPlaying) {
        _interpWatch
          ..reset()
          ..start();
      }
      state = state.copyWith(position: pos);
      if (_currentVerses != null && _currentVerses!.isNotEmpty) {
        updateActiveVerseByProgress(_currentVerses!);
      }
    });

    _durSub = _player.onDurationChanged.listen((dur) {
      if (!mounted) return;
      state = state.copyWith(duration: dur);
      if (_pendingSeekMs != null && dur.inMilliseconds > 0) {
        final target = _pendingSeekMs!.clamp(0, dur.inMilliseconds);
        _pendingSeekMs = null;
        _lastAnchorPosition = Duration(milliseconds: target);
        if (state.isPlaying) {
          _interpWatch
            ..reset()
            ..start();
        }
        _player.seek(Duration(milliseconds: target));
      }
    });

    _stateSub = _player.onPlayerStateChanged.listen((playerState) {
      if (!mounted) return;
      final isPlaying = playerState == PlayerState.playing;
      final isCompleted = playerState == PlayerState.completed;

      if (isPlaying) {
        _startSmoothSyncTimer();
      } else {
        _stopSmoothSyncTimer();
      }

      if (isCompleted) {
        final loopV = state.loopVerseNumber;
        if (loopV != null && (state.loopRepeatCount == -1 || state.currentLoopIteration < state.loopRepeatCount)) {
          state = state.copyWith(
            currentLoopIteration: state.currentLoopIteration + 1,
            activeVerseNumber: loopV,
            activeWordIndex: 0,
            verseProgress: 0.0,
            wordProgress: 0.0,
          );
          if (_currentVerses != null && _currentVerses!.isNotEmpty) {
            seekToVerse(loopV, _currentVerses!, surahName: state.currentSurahName).then((_) => _player.resume());
          }
          return;
        } else if (loopV == null && (state.loopRepeatCount > 1 || state.loopRepeatCount == -1)) {
          if (state.loopRepeatCount != -1 && state.currentLoopIteration >= state.loopRepeatCount) {
            state = state.copyWith(currentLoopIteration: 1);
          } else {
            _lastAnchorPosition = Duration.zero;
            state = state.copyWith(
              currentLoopIteration: state.currentLoopIteration + 1,
              position: Duration.zero,
            );
            _player.seek(Duration.zero).then((_) => _player.resume());
            return;
          }
        } else {
          state = state.copyWith(currentLoopIteration: 1, clearLoopVerse: true);
        }
      }

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

  Future<List<VerseTiming>?> _ensureVerseTimings(QuranReciter reciter, int surahId) async {
    final cacheKey = '${reciter.id}_$surahId';
    if (_timingsCache.containsKey(cacheKey)) {
      return _timingsCache[cacheKey];
    }
    if (reciter.quranComReciterId == null) return null;
    final timings = await _fetchVerseTimings(reciter.quranComReciterId!, surahId);
    if (timings != null && timings.isNotEmpty) {
      _timingsCache[cacheKey] = timings;
    }
    return _timingsCache[cacheKey];
  }

  Future<void> playSurah(int surahId, String surahName, {int? initialVerseNumber}) async {
    try {
      _pendingSeekMs = null;
      _stopAfterVerse = null; // Normal sure tilaveti başlatıldığında eski ayet durdurma sınırını temizle
      state = state.copyWith(
        isLoading: true,
        currentSurahId: surahId,
        currentSurahName: surahName,
        activeVerseNumber: initialVerseNumber ?? 1,
        activeWordIndex: 0,
        verseProgress: 0.0,
        wordProgress: 0.0,
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
      _lastAnchorPosition = Duration.zero;
      if (localFile != null && await localFile.exists()) {
        await _player.play(DeviceFileSource(localFile.path));
      } else {
        await _player.play(UrlSource(audioUrl));
      }
      state = state.copyWith(isPlaying: true, isLoading: false);
      _startSmoothSyncTimer();
    } catch (e) {
      debugPrint('QuranAudio playSurah hatası: $e');
      state = state.copyWith(isLoading: false, isPlaying: false);
    }
  }

  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      _stopSmoothSyncTimer();
      await _player.pause();
      state = state.copyWith(isPlaying: false);
    } else {
      await _player.resume();
      state = state.copyWith(isPlaying: true);
      _startSmoothSyncTimer();
    }
  }

  void toggleLiveTracking() {
    state = state.copyWith(isLiveTrackingEnabled: !state.isLiveTrackingEnabled);
  }

  void toggleWordHighlight() {
    state = state.copyWith(isWordHighlightEnabled: !state.isWordHighlightEnabled);
  }

  void updateActiveVerseByProgress(List<Verse> verses, {int? currentMs}) {
    if (verses.isEmpty) return;

    final effectiveMs = currentMs ?? state.position.inMilliseconds;
    final rawTotalMs = state.duration.inMilliseconds;
    final reciter = state.selectedReciter;
    final cacheKey = '${reciter.id}_${state.currentSurahId}';
    final timings = _timingsCache[cacheKey];

    // 1. ÖNCELİK: Quran.com Milisaniye Hassasiyetinde Gerçek Zamanlı Karaoke & Harf Harf Akış Senkronizasyonu
    if (timings != null && timings.isNotEmpty) {
      VerseTiming? activeTiming;
      for (int i = 0; i < timings.length; i++) {
        final t = timings[i];
        if (effectiveMs >= t.timestampFrom && effectiveMs < t.timestampTo) {
          activeTiming = t;
          break;
        }
      }

      if (activeTiming == null) {
        // İki ayet arasında kısa nefes boşluğundaysak bir önceki ayette veya sıradakinde kal
        for (int i = timings.length - 1; i >= 0; i--) {
          if (effectiveMs >= timings[i].timestampFrom) {
            activeTiming = timings[i];
            break;
          }
        }
        activeTiming ??= timings.first;
      }

      final determinedVerse = activeTiming.verseNumber;
      final dur = activeTiming.duration > 0
          ? activeTiming.duration
          : (activeTiming.timestampTo - activeTiming.timestampFrom);
      final elapsed = (effectiveMs - activeTiming.timestampFrom).clamp(0, dur > 0 ? dur : 1);
      final progress = dur > 0 ? (elapsed / dur).clamp(0.0, 1.0) : 0.0;

      // Kelime ve Kelime-İçi Harf Akış Oranı (wordProgress: 0.0 -> 1.0)
      int determinedWord = 0;
      double determinedWordProg = 0.0;
      final matchedVerseObj = verses.where((v) => v.verseNumber == determinedVerse).firstOrNull;
      final localWordCount = matchedVerseObj != null ? matchedVerseObj.words.length : 0;

      if (activeTiming.segments.isNotEmpty) {
        WordSegment? activeSeg;
        for (int i = 0; i < activeTiming.segments.length; i++) {
          final seg = activeTiming.segments[i];
          if (effectiveMs >= seg.startMs && effectiveMs < seg.endMs) {
            activeSeg = seg;
            final segDur = (seg.endMs - seg.startMs).clamp(1, 60000);
            determinedWordProg = ((effectiveMs - seg.startMs) / segDur).clamp(0.0, 1.0);
            break;
          }
        }

        if (activeSeg == null) {
          // Kelimeler arası kısa nefes/vakıf boşluğundaysak: son geçilen kelimede kal (asla son kelimeye zıplama!)
          if (effectiveMs < activeTiming.segments.first.startMs) {
            activeSeg = activeTiming.segments.first;
            determinedWordProg = 0.0;
          } else {
            for (int i = activeTiming.segments.length - 1; i >= 0; i--) {
              if (effectiveMs >= activeTiming.segments[i].startMs) {
                activeSeg = activeTiming.segments[i];
                determinedWordProg = 1.0;
                break;
              }
            }
            activeSeg ??= activeTiming.segments.last;
          }
        }

        int rawIdx = (activeSeg.wordIndex - 1).clamp(0, 999);
        if (localWordCount > 0 && rawIdx >= localWordCount) {
          rawIdx = localWordCount - 1;
        }
        determinedWord = rawIdx;
      } else if (localWordCount > 0) {
        // Segment listesi boşsa harf ağırlığıyla akıcı kelime ve harf ilerlemesi hesapla
        final words = matchedVerseObj!.words;
        final wordWeights = words.map((w) => w.length + 2).toList();
        final totalWordWeight = wordWeights.fold<int>(0, (a, b) => a + b);
        if (totalWordWeight > 0) {
          final targetWordWeight = progress * totalWordWeight;
          int wordAccum = 0;
          for (int w = 0; w < words.length; w++) {
            final prevWordAccum = wordAccum;
            wordAccum += wordWeights[w];
            if (wordAccum >= targetWordWeight || w == words.length - 1) {
              determinedWord = w;
              determinedWordProg = ((targetWordWeight - prevWordAccum) / wordWeights[w]).clamp(0.0, 1.0);
              break;
            }
          }
        }
      }

      // Belirli bir ayet aralığı çalınıyorsa (örn: Dua kartı) ve hedef ayet bittiyse durdur
      if (_stopAfterVerse != null && determinedVerse > _stopAfterVerse!) {
        _stopAfterVerse = null;
        stop();
        return;
      }

      // Tek Âyet Ezber Tekrarı (loopVerseNumber aktifse ve sonraki âyete geçildiyse başa sar)
      if (!_isLoopSeeking &&
          state.loopVerseNumber != null &&
          state.activeVerseNumber == state.loopVerseNumber &&
          determinedVerse != state.loopVerseNumber) {
        if (state.loopRepeatCount == -1 || state.currentLoopIteration < state.loopRepeatCount) {
          _isLoopSeeking = true;
          final targetV = state.loopVerseNumber!;
          state = state.copyWith(
            currentLoopIteration: state.currentLoopIteration + 1,
            activeVerseNumber: targetV,
            activeWordIndex: 0,
            verseProgress: 0.0,
            wordProgress: 0.0,
          );
          seekToVerse(targetV, verses, surahName: state.currentSurahName).whenComplete(() {
            _isLoopSeeking = false;
          });
          return;
        } else {
          state = state.copyWith(
            currentLoopIteration: 1,
            clearLoopVerse: true,
          );
        }
      }

      final secChanged = (effectiveMs ~/ 1000) != state.position.inSeconds;
      if (state.activeVerseNumber != determinedVerse ||
          state.activeWordIndex != determinedWord ||
          secChanged ||
          (state.verseProgress - progress).abs() >= 0.008 ||
          (state.wordProgress - determinedWordProg).abs() >= 0.02) {
        state = state.copyWith(
          position: Duration(milliseconds: effectiveMs),
          activeVerseNumber: determinedVerse,
          activeWordIndex: determinedWord,
          verseProgress: progress,
          wordProgress: determinedWordProg,
        );
      }
      return;
    }

    // 2. YEDEK (OFFLINE / DİĞER KÂRİLER VEYA TIMINGS YÜKLENİRKEN): Harf Ağırlığı Oransal Hesaplama
    int totalWeight = 0;
    final weights = verses.map((v) {
      final w = v.arabicText.length + 10;
      totalWeight += w;
      return w;
    }).toList();

    if (totalWeight <= 0) return;

    final totalMs = rawTotalMs > 0 ? rawTotalMs : (totalWeight * 95).clamp(4000, 3600000);

    int accumulatedBefore = 0;
    int determinedVerse = verses.first.verseNumber;
    int activeVerseIdx = 0;
    int verseStartMs = 0;
    int verseEndMs = totalMs;

    for (int i = 0; i < verses.length; i++) {
      final prevAccum = accumulatedBefore;
      accumulatedBefore += weights[i];
      final currentVerseEndMs = ((accumulatedBefore / totalWeight) * totalMs).round();
      if (effectiveMs <= currentVerseEndMs || i == verses.length - 1) {
        determinedVerse = verses[i].verseNumber;
        activeVerseIdx = i;
        verseStartMs = ((prevAccum / totalWeight) * totalMs).round();
        verseEndMs = currentVerseEndMs;
        break;
      }
    }

    // Belirli bir ayet aralığı çalınıyorsa (örn: Dua kartı) ve hedef ayet bittiyse durdur (çevrimdışı / diğer kâriler)
    if (_stopAfterVerse != null && determinedVerse > _stopAfterVerse!) {
      _stopAfterVerse = null;
      stop();
      return;
    }

    final verseDurationMs = verseEndMs - verseStartMs;
    final verseElapsedMs = (effectiveMs - verseStartMs).clamp(0, verseDurationMs > 0 ? verseDurationMs : 1);
    final progress = verseDurationMs > 0 ? (verseElapsedMs / verseDurationMs).clamp(0.0, 1.0) : 0.0;

    int determinedWord = 0;
    double determinedWordProg = 0.0;
    final activeVerse = verses[activeVerseIdx];
    final words = activeVerse.words;
    if (words.isNotEmpty) {
      final wordWeights = words.map((w) => w.length + 2).toList();
      final totalWordWeight = wordWeights.fold<int>(0, (a, b) => a + b);
      if (totalWordWeight > 0) {
        final targetWordWeight = progress * totalWordWeight;
        int wordAccum = 0;
        for (int w = 0; w < words.length; w++) {
          final prevWordAccum = wordAccum;
          wordAccum += wordWeights[w];
          if (wordAccum >= targetWordWeight || w == words.length - 1) {
            determinedWord = w;
            determinedWordProg = ((targetWordWeight - prevWordAccum) / wordWeights[w]).clamp(0.0, 1.0);
            break;
          }
        }
      }
    }

    final secChanged = (effectiveMs ~/ 1000) != state.position.inSeconds;
    if (state.activeVerseNumber != determinedVerse ||
        state.activeWordIndex != determinedWord ||
        secChanged ||
        (state.verseProgress - progress).abs() >= 0.008 ||
        (state.wordProgress - determinedWordProg).abs() >= 0.02) {
      state = state.copyWith(
        position: Duration(milliseconds: effectiveMs),
        activeVerseNumber: determinedVerse,
        activeWordIndex: determinedWord,
        verseProgress: progress,
        wordProgress: determinedWordProg,
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
    setVerses(verses);

    final surahId = verses.first.surahId;
    if (state.currentSurahId != surahId || !state.isPlaying) {
      await playSurah(
        surahId,
        surahName ?? 'Surah $surahId',
        initialVerseNumber: verseNumber,
      );
    }

    state = state.copyWith(
      activeVerseNumber: verseNumber,
      activeWordIndex: wordIndex,
      wordProgress: 0.0,
    );

    final timings = await _ensureVerseTimings(state.selectedReciter, surahId);

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
        _pendingSeekMs = targetMs > 0 ? targetMs : null;
        await seek(Duration(milliseconds: targetMs));
        state = state.copyWith(
          position: Duration(milliseconds: targetMs),
          activeVerseNumber: verseNumber,
          activeWordIndex: wordIndex,
          wordProgress: 0.0,
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

      final targetMs = (verseStartMs + (wordFraction * verseDurationMs)).round().clamp(0, totalMs);
      _pendingSeekMs = targetMs > 0 ? targetMs : null;
      await seek(Duration(milliseconds: targetMs));
      state = state.copyWith(position: Duration(milliseconds: targetMs));
    }

    state = state.copyWith(
      activeVerseNumber: verseNumber,
      activeWordIndex: wordIndex,
      wordProgress: 0.0,
    );
  }

  Future<void> seekToVerse(int verseNumber, List<Verse> verses, {String? surahName}) async {
    if (verses.isEmpty) return;
    setVerses(verses);

    final surahId = verses.first.surahId;
    if (state.currentSurahId != surahId || !state.isPlaying) {
      await playSurah(
        surahId,
        surahName ?? 'Surah $surahId',
        initialVerseNumber: verseNumber,
      );
    }

    state = state.copyWith(
      activeVerseNumber: verseNumber,
      activeWordIndex: 0,
      verseProgress: 0.0,
      wordProgress: 0.0,
    );

    final timings = await _ensureVerseTimings(state.selectedReciter, surahId);

    // 1. Quran.com Milisaniye Hassasiyetinde Ayete Atlama
    if (timings != null && timings.isNotEmpty) {
      for (final t in timings) {
        if (t.verseNumber == verseNumber) {
          _pendingSeekMs = t.timestampFrom > 0 ? t.timestampFrom : null;
          await seek(Duration(milliseconds: t.timestampFrom));
          state = state.copyWith(
            position: Duration(milliseconds: t.timestampFrom),
            activeVerseNumber: verseNumber,
            activeWordIndex: 0,
            verseProgress: 0.0,
            wordProgress: 0.0,
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
      _pendingSeekMs = startMs > 0 ? startMs : null;
      await seek(Duration(milliseconds: startMs));
      state = state.copyWith(position: Duration(milliseconds: startMs));
    }
    state = state.copyWith(
      activeVerseNumber: verseNumber,
      activeWordIndex: 0,
      verseProgress: 0.0,
      wordProgress: 0.0,
    );
  }

  /// Belirli bir ayet aralığını (örn: Dua kartları için Bakara 255 veya Haşr 21-24) dinletir
  Future<void> playVerseRange(
    List<Verse> verses, {
    required int from,
    required int to,
    required String surahName,
  }) async {
    await seekToVerse(from, verses, surahName: surahName);
    _stopAfterVerse = to;
  }

  Future<void> seek(Duration position) async {
    _lastAnchorPosition = position;
    if (state.isPlaying) {
      _interpWatch
        ..reset()
        ..start();
    }
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

  // ── Ezber & Döngü Modu (A-B Loop) ───────────────────────────
  void cycleLoopRepeat() {
    final next = switch (state.loopRepeatCount) {
      1 => 3,
      3 => 5,
      5 => 10,
      10 => -1,
      _ => 1,
    };
    state = state.copyWith(loopRepeatCount: next, currentLoopIteration: 1);
  }

  void setLoopRepeat(int count) {
    state = state.copyWith(loopRepeatCount: count, currentLoopIteration: 1);
  }

  void setLoopVerse(int? verseNumber) {
    state = state.copyWith(
      loopVerseNumber: verseNumber,
      clearLoopVerse: verseNumber == null,
      currentLoopIteration: 1,
    );
  }

  // ── Gerçek Doğa & Huzur Ambiyans Sesleri (Yağmur/Orman, Deniz Dalgası, Esinti, Gece) ─────────────
  static const Map<String, String> _ambienceAssets = {
    'rain': 'audio/real_rain_forest.mp3',
    'waves': 'audio/real_sea_waves.wav',
    'breeze': 'audio/real_gentle_wind.mp3',
    'night': 'audio/real_night_peace.wav',
    // Geriye dönük uyumluluk:
    'ney': 'audio/real_sea_waves.wav',
  };

  static const Map<String, String> _ambienceRemoteUrls = {
    'rain': 'https://upload.wikimedia.org/wikipedia/commons/2/24/Bourne_woods_Birdsong_and_rain_2020-06-17_0742.mp3',
    'waves': 'https://upload.wikimedia.org/wikipedia/commons/8/84/Sea_waves.wav',
    'breeze': 'https://upload.wikimedia.org/wikipedia/commons/a/a3/Bourne_woods_windy_2020-05-05_0757.mp3',
    'night': 'https://upload.wikimedia.org/wikipedia/commons/5/5f/Night_original_format.wav',
  };

  Future<void> setAmbience(String? type) async {
    if (type == state.activeAmbience) return;
    state = state.copyWith(
      activeAmbience: type,
      clearAmbience: type == null,
    );
    try {
      await _ambiencePlayer.stop();
      if (type != null) {
        final asset = _ambienceAssets[type];
        await _ambiencePlayer.setReleaseMode(ReleaseMode.loop);
        await _ambiencePlayer.setVolume(state.ambienceVolume);
        if (asset != null) {
          try {
            await _ambiencePlayer.play(AssetSource(asset)).timeout(const Duration(seconds: 3));
            return;
          } catch (_) {}
        }
        final remoteUrl = _ambienceRemoteUrls[type];
        if (remoteUrl != null) {
          await _ambiencePlayer.play(UrlSource(remoteUrl)).timeout(const Duration(seconds: 6));
        }
      }
    } catch (_) {}
  }

  Future<void> setAmbienceVolume(double vol) async {
    final clamped = vol.clamp(0.0, 1.0);
    try {
      await _ambiencePlayer.setVolume(clamped);
    } catch (_) {}
    state = state.copyWith(ambienceVolume: clamped);
  }

  // ── Otomatik Uyku Zamanlayıcısı (Sleep Timer & Fade-out) ─────
  void startSleepTimer(int minutes) {
    _sleepTimer?.cancel();
    final totalSecs = minutes * 60;
    state = state.copyWith(
      sleepTimerMinutes: minutes,
      sleepTimerSecondsRemaining: totalSecs,
    );

    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final current = state.sleepTimerSecondsRemaining ?? 0;
      if (current <= 1) {
        timer.cancel();
        _sleepTimer = null;
        await stop();
        await setAmbience(null);
        try {
          await _player.setVolume(1.0);
          await _ambiencePlayer.setVolume(state.ambienceVolume);
        } catch (_) {}
        state = state.copyWith(clearSleepTimer: true);
      } else {
        // Son 15 saniyede zarif fade-out
        if (current <= 15) {
          final fadeFactor = (current / 15.0).clamp(0.0, 1.0);
          try {
            await _player.setVolume(fadeFactor);
            await _ambiencePlayer.setVolume(fadeFactor * state.ambienceVolume);
          } catch (_) {}
        }
        state = state.copyWith(sleepTimerSecondsRemaining: current - 1);
      }
    });
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    try {
      _player.setVolume(1.0);
      _ambiencePlayer.setVolume(state.ambienceVolume);
    } catch (_) {}
    state = state.copyWith(clearSleepTimer: true);
  }

  Future<void> stop() async {
    _stopAfterVerse = null;
    _stopSmoothSyncTimer();
    _lastAnchorPosition = Duration.zero;
    try {
      await _player.stop();
    } catch (_) {}
    _currentVerses = null;
    if (!mounted) return;
    state = state.copyWith(
      isPlaying: false,
      isLoading: false,
      clearCurrentSurah: true,
      clearActiveVerse: true,
      clearActiveWord: true,
      verseProgress: 0.0,
      wordProgress: 0.0,
      position: Duration.zero,
      duration: Duration.zero,
    );
  }

  @override
  void dispose() {
    _stopSmoothSyncTimer();
    _sleepTimer?.cancel();
    _posSub?.cancel();
    _durSub?.cancel();
    _stateSub?.cancel();
    _player.dispose();
    _ambiencePlayer.dispose();
    super.dispose();
  }
}

final quranAudioProvider =
    StateNotifierProvider<QuranAudioNotifier, QuranAudioState>((ref) {
  return QuranAudioNotifier();
});

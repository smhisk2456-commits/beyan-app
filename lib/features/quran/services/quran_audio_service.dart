import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/verse.dart';

class QuranReciter {
  final String id;
  final String nameTr;
  final String nameAr;
  final String baseUrl;

  const QuranReciter({
    required this.id,
    required this.nameTr,
    required this.nameAr,
    required this.baseUrl,
  });
}

final List<QuranReciter> quranRecitersList = [
  const QuranReciter(
    id: 'mishary',
    nameTr: 'Mishary Rashid Alafasy',
    nameAr: 'مشاري راشد العفاسي',
    baseUrl: 'https://download.quranicaudio.com/quran/mishaari_raashid_al_3afaasee/',
  ),
  const QuranReciter(
    id: 'abdulbaset',
    nameTr: 'AbdulBaset AbdulSamad (Murattal)',
    nameAr: 'عبد الباسط عبد الصمد',
    baseUrl: 'https://download.quranicaudio.com/quran/abdul_basit_murattal/',
  ),
  const QuranReciter(
    id: 'ghamdi',
    nameTr: 'Saad Al-Ghamdi',
    nameAr: 'سعد الغامدي',
    baseUrl: 'https://download.quranicaudio.com/quran/sa3d_al-ghaamidi/complete/',
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
      activeVerseNumber: clearActiveVerse ? null : (activeVerseNumber ?? this.activeVerseNumber),
      activeWordIndex: clearActiveWord ? null : (activeWordIndex ?? this.activeWordIndex),
      verseProgress: verseProgress ?? this.verseProgress,
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

  Future<void> playSurah(int surahId, String surahName) async {
    try {
      state = state.copyWith(
        isLoading: true,
        currentSurahId: surahId,
        currentSurahName: surahName,
      );

      final surahCode = surahId.toString().padLeft(3, '0');
      final audioUrl = '${state.selectedReciter.baseUrl}$surahCode.mp3';

      await _player.stop();
      await _player.play(UrlSource(audioUrl));
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
    if (verses.isEmpty || state.duration.inMilliseconds <= 0) return;

    final currentMs = state.position.inMilliseconds;
    final totalMs = state.duration.inMilliseconds;

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

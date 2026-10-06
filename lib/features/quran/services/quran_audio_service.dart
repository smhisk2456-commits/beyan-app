import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    baseUrl: 'https://server8.quranicaudio.com/quran/mishaari_raashid_al_3afaasee/',
  ),
  const QuranReciter(
    id: 'abdulbaset',
    nameTr: 'AbdulBaset AbdulSamad (Murattal)',
    nameAr: 'عبد الباسط عبد الصمد',
    baseUrl: 'https://server7.quranicaudio.com/quran/abdul_basit_murattal/',
  ),
  const QuranReciter(
    id: 'ghamdi',
    nameTr: 'Saad Al-Ghamdi',
    nameAr: 'سعد الغامدي',
    baseUrl: 'https://server7.quranicaudio.com/quran/sa3d_al-ghaamidi/complete/',
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

  const QuranAudioState({
    this.isPlaying = false,
    this.isLoading = false,
    this.currentSurahId,
    this.currentSurahName,
    required this.selectedReciter,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  QuranAudioState copyWith({
    bool? isPlaying,
    bool? isLoading,
    int? currentSurahId,
    String? currentSurahName,
    QuranReciter? selectedReciter,
    Duration? position,
    Duration? duration,
  }) {
    return QuranAudioState(
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      currentSurahId: currentSurahId ?? this.currentSurahId,
      currentSurahName: currentSurahName ?? this.currentSurahName,
      selectedReciter: selectedReciter ?? this.selectedReciter,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}

class QuranAudioNotifier extends StateNotifier<QuranAudioState> {
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription? _posSub;
  StreamSubscription? _durSub;
  StreamSubscription? _stateSub;

  QuranAudioNotifier()
      : super(QuranAudioState(selectedReciter: quranRecitersList.first)) {
    _initListeners();
  }

  void _initListeners() {
    _posSub = _player.onPositionChanged.listen((pos) {
      state = state.copyWith(position: pos);
    });

    _durSub = _player.onDurationChanged.listen((dur) {
      state = state.copyWith(duration: dur);
    });

    _stateSub = _player.onPlayerStateChanged.listen((playerState) {
      state = state.copyWith(
        isPlaying: playerState == PlayerState.playing,
        isLoading: false,
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

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> seekRelative(int seconds) async {
    final target = state.position + Duration(seconds: seconds);
    final clamped = target < Duration.zero
        ? Duration.zero
        : (target > state.duration ? state.duration : target);
    await _player.seek(clamped);
  }

  Future<void> stop() async {
    await _player.stop();
    state = state.copyWith(isPlaying: false, currentSurahId: null, currentSurahName: null);
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

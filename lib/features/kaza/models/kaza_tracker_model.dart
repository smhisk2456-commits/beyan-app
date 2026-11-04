import 'dart:convert';

/// Kaza namazı ve oruç türleri
enum KazaType {
  fajr, // Sabah (2 rekat farz)
  dhuhr, // Öğle (4 rekat farz)
  asr, // İkindi (4 rekat farz)
  maghrib, // Akşam (3 rekat farz)
  isha, // Yatsı (4 rekat farz)
  witr, // Vitir (3 rekat vacip)
  fasting, // Ramazan Orucu (gün)
}

extension KazaTypeExtension on KazaType {
  String get title {
    switch (this) {
      case KazaType.fajr:
        return 'Sabah Namazı';
      case KazaType.dhuhr:
        return 'Öğle Namazı';
      case KazaType.asr:
        return 'İkindi Namazı';
      case KazaType.maghrib:
        return 'Akşam Namazı';
      case KazaType.isha:
        return 'Yatsı Namazı';
      case KazaType.witr:
        return 'Vitir Vacip';
      case KazaType.fasting:
        return 'Ramazan Orucu';
    }
  }

  String get shortTitle {
    switch (this) {
      case KazaType.fajr:
        return 'Sabah';
      case KazaType.dhuhr:
        return 'Öğle';
      case KazaType.asr:
        return 'İkindi';
      case KazaType.maghrib:
        return 'Akşam';
      case KazaType.isha:
        return 'Yatsı';
      case KazaType.witr:
        return 'Vitir';
      case KazaType.fasting:
        return 'Oruç';
    }
  }

  String get rakatsInfo {
    switch (this) {
      case KazaType.fajr:
        return '2 Rekat Farz';
      case KazaType.dhuhr:
        return '4 Rekat Farz';
      case KazaType.asr:
        return '4 Rekat Farz';
      case KazaType.maghrib:
        return '3 Rekat Farz';
      case KazaType.isha:
        return '4 Rekat Farz';
      case KazaType.witr:
        return '3 Rekat Vacip';
      case KazaType.fasting:
        return '1 Gün Oruç';
    }
  }

  bool get isPrayer => this != KazaType.fasting;
}

/// Yapılan son kaza işlemlerini geri alabilmek için geçmiş kaydı
class KazaHistoryEntry {
  final KazaType type;
  final int change; // Genelde -1 (1 kaza kılındı borç azaldı) veya +1
  final DateTime timestamp;
  final bool isFullDailySet;

  const KazaHistoryEntry({
    required this.type,
    required this.change,
    required this.timestamp,
    this.isFullDailySet = false,
  });

  Map<String, dynamic> toMap() => {
        'type': type.name,
        'change': change,
        'timestamp': timestamp.toIso8601String(),
        'isFullDailySet': isFullDailySet,
      };

  factory KazaHistoryEntry.fromMap(Map<String, dynamic> map) {
    return KazaHistoryEntry(
      type: KazaType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => KazaType.fajr,
      ),
      change: map['change'] as int? ?? -1,
      timestamp: DateTime.tryParse(map['timestamp'] as String? ?? '') ?? DateTime.now(),
      isFullDailySet: map['isFullDailySet'] as bool? ?? false,
    );
  }
}

/// Kaza Namazı ve Oruç Takip Durumu Modeli
class KazaTrackerState {
  final Map<KazaType, int> remaining; // Kalan borç sayısı
  final Map<KazaType, int> initial; // Başlangıçtaki toplam borç (ilerleme oranı için)
  final int dailyGoalPrayers; // Kullanıcının günlük kaza hedefi (varsayılan: 1 tam gün = 6 vakit veya 2 vakit)
  final List<KazaHistoryEntry> history; // Son işlemler yığını (Undo için)

  const KazaTrackerState({
    required this.remaining,
    required this.initial,
    this.dailyGoalPrayers = 6,
    this.history = const [],
  });

  factory KazaTrackerState.empty() {
    final rem = <KazaType, int>{};
    final init = <KazaType, int>{};
    for (final type in KazaType.values) {
      rem[type] = 0;
      init[type] = 0;
    }
    return KazaTrackerState(
      remaining: rem,
      initial: init,
      dailyGoalPrayers: 6,
      history: const [],
    );
  }

  int getCount(KazaType type) => remaining[type] ?? 0;
  int getInitialCount(KazaType type) => initial[type] ?? 0;

  /// Kılınan (tamamlanan) toplam kaza namazı sayısı (6 vakit)
  int get completedPrayers {
    int total = 0;
    for (final type in KazaType.values) {
      if (type.isPrayer) {
        final init = getInitialCount(type);
        final rem = getCount(type);
        if (init > rem) {
          total += (init - rem);
        }
      }
    }
    return total;
  }

  /// Kalan toplam kaza namazı sayısı (Sabah + Öğle + İkindi + Akşam + Yatsı + Vitir)
  int get totalRemainingPrayers {
    int total = 0;
    for (final type in KazaType.values) {
      if (type.isPrayer) {
        total += getCount(type);
      }
    }
    return total;
  }

  /// Başlangıçtaki toplam namaz borcu
  int get totalInitialPrayers {
    int total = 0;
    for (final type in KazaType.values) {
      if (type.isPrayer) {
        total += getInitialCount(type);
      }
    }
    return total;
  }

  /// Kalan Ramazan orucu borcu (gün)
  int get remainingFasting => getCount(KazaType.fasting);

  /// Toplam kaza tamamlama oranı (0.0 - 1.0)
  double get progressRatio {
    final init = totalInitialPrayers;
    if (init <= 0) return 0.0;
    final done = completedPrayers;
    final ratio = done / init;
    return ratio.clamp(0.0, 1.0);
  }

  /// Her vakit eşit kılınırsa kalan kaç günlük tam kaza borcu var?
  int get remainingDaysOfPrayers {
    int maxRemaining = 0;
    for (final type in KazaType.values) {
      if (type.isPrayer) {
        final c = getCount(type);
        if (c > maxRemaining) maxRemaining = c;
      }
    }
    return maxRemaining;
  }

  /// Tahmin Motoru: Günde [dailyPacePrayers] vakit kılınırsa kaç günde biter?
  int estimatedDaysToFinish(int dailyPacePrayers) {
    if (dailyPacePrayers <= 0) return 0;
    final total = totalRemainingPrayers;
    if (total <= 0) return 0;
    return (total / dailyPacePrayers).ceil();
  }

  /// Tahmin Motoru: İnsan dostu süre açıklaması (Örn: "1 Yıl 3 Ay")
  static String formatEstimatedDuration(int totalDays) {
    if (totalDays <= 0) return 'Tamamlandı';
    if (totalDays < 30) return '$totalDays Gün';
    final years = totalDays ~/ 365;
    final remainingDays = totalDays % 365;
    final months = remainingDays ~/ 30;
    final days = remainingDays % 30;

    final parts = <String>[];
    if (years > 0) parts.add('$years Yıl');
    if (months > 0) parts.add('$months Ay');
    if (days > 0 && years == 0) parts.add('$days Gün');

    return parts.isEmpty ? '$totalDays Gün' : parts.join(' ');
  }

  KazaTrackerState copyWith({
    Map<KazaType, int>? remaining,
    Map<KazaType, int>? initial,
    int? dailyGoalPrayers,
    List<KazaHistoryEntry>? history,
  }) {
    return KazaTrackerState(
      remaining: remaining ?? this.remaining,
      initial: initial ?? this.initial,
      dailyGoalPrayers: dailyGoalPrayers ?? this.dailyGoalPrayers,
      history: history ?? this.history,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'remaining': remaining.map((k, v) => MapEntry(k.name, v)),
      'initial': initial.map((k, v) => MapEntry(k.name, v)),
      'dailyGoalPrayers': dailyGoalPrayers,
      'history': history.map((e) => e.toMap()).toList(),
    };
  }

  factory KazaTrackerState.fromMap(Map<String, dynamic> map) {
    final rem = <KazaType, int>{};
    final init = <KazaType, int>{};

    final remMap = map['remaining'] as Map<String, dynamic>? ?? {};
    final initMap = map['initial'] as Map<String, dynamic>? ?? {};

    for (final type in KazaType.values) {
      rem[type] = (remMap[type.name] as num?)?.toInt() ?? 0;
      init[type] = (initMap[type.name] as num?)?.toInt() ?? rem[type]!;
    }

    final histList = (map['history'] as List<dynamic>?)
            ?.map((e) => KazaHistoryEntry.fromMap(e as Map<String, dynamic>))
            .toList() ??
        [];

    return KazaTrackerState(
      remaining: rem,
      initial: init,
      dailyGoalPrayers: (map['dailyGoalPrayers'] as num?)?.toInt() ?? 6,
      history: histList,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory KazaTrackerState.fromJson(String jsonStr) {
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return KazaTrackerState.fromMap(map);
    } catch (_) {
      return KazaTrackerState.empty();
    }
  }
}

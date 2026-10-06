import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Günlük ibadet takip modeli (5 vakit namaz + Kuran + zikir)
class DailyWorshipEntry {
  final String dateKey; // YYYY-MM-DD
  final bool fajr;
  final bool dhuhr;
  final bool asr;
  final bool maghrib;
  final bool isha;
  final bool quran;
  final bool zikr;

  const DailyWorshipEntry({
    required this.dateKey,
    this.fajr = false,
    this.dhuhr = false,
    this.asr = false,
    this.maghrib = false,
    this.isha = false,
    this.quran = false,
    this.zikr = false,
  });

  int get completedCount {
    int count = 0;
    if (fajr) count++;
    if (dhuhr) count++;
    if (asr) count++;
    if (maghrib) count++;
    if (isha) count++;
    if (quran) count++;
    if (zikr) count++;
    return count;
  }

  double get completionRatio => completedCount / 7.0;

  bool get isFullyCompleted => completedCount == 7;

  DailyWorshipEntry copyWith({
    bool? fajr,
    bool? dhuhr,
    bool? asr,
    bool? maghrib,
    bool? isha,
    bool? quran,
    bool? zikr,
  }) {
    return DailyWorshipEntry(
      dateKey: dateKey,
      fajr: fajr ?? this.fajr,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
      quran: quran ?? this.quran,
      zikr: zikr ?? this.zikr,
    );
  }

  Map<String, dynamic> toMap() => {
    'dateKey': dateKey,
    'fajr': fajr,
    'dhuhr': dhuhr,
    'asr': asr,
    'maghrib': maghrib,
    'isha': isha,
    'quran': quran,
    'zikr': zikr,
  };

  factory DailyWorshipEntry.fromMap(Map<String, dynamic> map) {
    return DailyWorshipEntry(
      dateKey: map['dateKey'] as String,
      fajr: map['fajr'] as bool? ?? false,
      dhuhr: map['dhuhr'] as bool? ?? false,
      asr: map['asr'] as bool? ?? false,
      maghrib: map['maghrib'] as bool? ?? false,
      isha: map['isha'] as bool? ?? false,
      quran: map['quran'] as bool? ?? false,
      zikr: map['zikr'] as bool? ?? false,
    );
  }
}

/// İbadet Takvimi Günlük Seri Dönüm Noktaları & Manevi Ödülleri
class WorshipStreakMilestone {
  final int days;
  final String badgeName;
  final String badgeIcon;
  final String title;
  final String surahName;
  final String ayahReference;
  final String arabicText;
  final String turkishMeaning;
  final String rewardDescription;
  final String spiritualVirtue;

  const WorshipStreakMilestone({
    required this.days,
    required this.badgeName,
    required this.badgeIcon,
    required this.title,
    required this.surahName,
    required this.ayahReference,
    required this.arabicText,
    required this.turkishMeaning,
    required this.rewardDescription,
    required this.spiritualVirtue,
  });

  static const List<WorshipStreakMilestone> allMilestones = [
    WorshipStreakMilestone(
      days: 10,
      badgeName: '10 Günlük İstikamet Beratı',
      badgeIcon: '🥉',
      title: 'İstikamet Başlangıcı',
      surahName: 'Asr Suresi',
      ayahReference: 'Asr Suresi (103:1-3)',
      arabicText: 'وَالْعَصْرِ ۙ إِنَّ الْإِنسَانَ لَفِي خُسْرٍ ۙ إِلَّا الَّذِينَ آمَنُوا وَعَمِلُوا الصَّالِحَاتِ وَتَوَاصَوْا بِالْحَقِّ وَتَوَاصَوْا بِالصَّبْرِ',
      turkishMeaning: 'Zamana yemin olsun ki, insan mutlaka ziyan içindedir. Ancak iman edip salih ameller işleyenler, birbirlerine hakkı ve sabrı tavsiye edenler müstesnadır.',
      rewardDescription: '10 Gün Kesintisiz İbadet Rozeti & Asr Suresi Hikmeti',
      spiritualVirtue: 'İbadette sürekliliğin ilk altın anahtarı; zamana değer katan salih amellerdir.',
    ),
    WorshipStreakMilestone(
      days: 30,
      badgeName: '30 Günlük Sebat Ehli Beratı',
      badgeIcon: '🌙',
      title: 'Bir Aylık Sebat & Ferahlık',
      surahName: 'İnşirah Suresi',
      ayahReference: 'İnşirah Suresi (94:5-6)',
      arabicText: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا ۙ إِنَّ مَعَ الْعُسْرِ يُسْرًا ۙ فَإِذَا فَرَغْتَ فَانصَبْ ۙ وَإِلَىٰ رَبِّكَ فَارْغَب',
      turkishMeaning: 'Elbette her zorlukla beraber bir kolaylık vardır. Şüphesiz her güçlükle birlikte bir kolaylık vardır. Öyleyse bir işi bitirince hemen diğerine koyul ve yalnız Rabbine yönel.',
      rewardDescription: '30 Günlük Sebat Nişanı & Kalp İnşirahı',
      spiritualVirtue: 'Tam bir ay boyunca 5 vakit namaz ve zikre devam eden kulu, Rabbi ferahlık ve kolaylıkla müjdeler.',
    ),
    WorshipStreakMilestone(
      days: 50,
      badgeName: '50 Günlük Huşû ve Sabır Nişanı',
      badgeIcon: '⭐',
      title: 'Sabır & Huşû Zırhı',
      surahName: 'Bakara Suresi',
      ayahReference: 'Bakara Suresi (2:45)',
      arabicText: 'وَاسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ ۚ وَإِنَّهَا لَكَبِيرَةٌ إِلَّا عَلَى الْخَاشِعِينَ',
      turkishMeaning: 'Sabır ve namaz ile Allah\'tan yardım isteyin. Şüphesiz bu, kalbi Allah\'a saygı ve huşû ile dopdolu olanlardan başkasına pek ağır gelir.',
      rewardDescription: '50 Günlük Huşû Beratı & İlahi Yardım Kalkanı',
      spiritualVirtue: '50 gün kesintisiz ibadetle kulun kalbinde huşû yerleşir; namaz bir külfet değil, en tatlı huzur sığınağı olur.',
    ),
    WorshipStreakMilestone(
      days: 100,
      badgeName: '100 Günlük Namaz Muhafızı Beratı',
      badgeIcon: '👑',
      title: 'Namaz Muhafızı & Firdevs Müjdesi',
      surahName: 'Mü\'minûn Suresi',
      ayahReference: 'Mü\'minûn Suresi (23:1-2, 9-11)',
      arabicText: 'قَدْ أَفْلَحَ الْمُؤْمِنُونَ ۙ الَّذِينَ هُمْ فِي صَلَاتِهِمْ خَاشِعُونَ... وَالَّذِينَ هُمْ عَلَىٰ صَلَوَاتِهِمْ يُحَافِظُونَ ۙ أُولَٰئِكَ هُمُ الْوَارِثُونَ ۙ الَّذِينَ يَرِثُونَ الْفِرْدَوْسَ',
      turkishMeaning: 'Müminler gerçekten kurtuluşa ermişlerdir. Onlar ki namazlarında derin bir saygı ve huşû içindedirler... Ve onlar ki namazlarını titizlikle korurlar. İşte Firdevs cennetine varis olacak olanlar onlardır.',
      rewardDescription: '100 Günlük Altın İbadet Muhafızı Tacı',
      spiritualVirtue: '100 günlük istikamet, namazı bir mükellefiyetten öteye geçirip Firdevs cennetinin ebedi anahtarı haline getirir.',
    ),
    WorshipStreakMilestone(
      days: 200,
      badgeName: '200 Günlük Sekinet & Fetih Tacı',
      badgeIcon: '💎',
      title: 'Kalp Sekineti & Manevi Fetih',
      surahName: 'Fetih Suresi',
      ayahReference: 'Fetih Suresi (48:1, 4)',
      arabicText: 'إِنَّا فَتَحْنَا لَكَ فَتْحًا مُبِينًا... هُوَ الَّذِي أَنزَلَ السَّكِينَةَ فِي قُلُوبِ الْمُؤْمِنِينَ لِيَزْدَادُوا إِيمَانًا مَّعَ إِيمَانِهِمْ',
      turkishMeaning: 'Şüphesiz biz sana apaçık bir fetih ihsan ettik... İmanlarına iman katsınlar diye müminlerin kalplerine sekinet (huzur, güven ve sükûnet) indiren O\'dur.',
      rewardDescription: '200 Günlük Zümrüt Fetih Beratı & Kalp Sekineti',
      spiritualVirtue: '200 gün boyunca kulluk çizgisine sadık kalan kulun kalbine ilahi sekinet ve manevi fetih kapıları açılır.',
    ),
    WorshipStreakMilestone(
      days: 400,
      badgeName: '400 Günlük Rıdvan ve Mutmain Nefis Beratı',
      badgeIcon: '🌟',
      title: 'Rıdvan-ı Ekber & Mutmain Nefis',
      surahName: 'Fecr Suresi',
      ayahReference: 'Fecr Suresi (89:27-30)',
      arabicText: 'يَا أَيَّتُهَا النَّفْسُ الْمُطْمَئِنَّةُ ۙ ارْجِعِي إِلَىٰ رَبِّكِ رَاضِيَةً مَرْضِيَّةً ۙ فَادْخُلِي فِي عِبَادِي ۙ وَادْخُلِي جَنَّتِي',
      turkishMeaning: 'Ey huzura kavuşmuş olan mutmain nefis! Sen O\'ndan razı, O da senden razı olarak Rabbine dön! Salih kullarımın arasına katıl ve cennetime gir!',
      rewardDescription: '400 Günlük En Yüce Rıdvan Tacı',
      spiritualVirtue: '400 günlük devasa istikamet, nefsi mutmainne derecesine yükseltir; en yüce mükâfat Allah\'ın rızası (Rıdvan) ve ebedi cennettir.',
    ),
  ];
}

/// Reaktif Seri ve Ödül Durumu Modeli
class WorshipStreakData {
  final int currentStreak;
  final int bestStreak;
  final bool isTodayCompleted;
  final int todayCompletedCount;
  final WorshipStreakMilestone? nextMilestone;
  final List<WorshipStreakMilestone> unlockedMilestones;

  const WorshipStreakData({
    required this.currentStreak,
    required this.bestStreak,
    required this.isTodayCompleted,
    required this.todayCompletedCount,
    required this.nextMilestone,
    required this.unlockedMilestones,
  });

  int get daysToNextMilestone {
    if (nextMilestone == null) return 0;
    final rem = nextMilestone!.days - currentStreak;
    return rem > 0 ? rem : 0;
  }

  double get milestoneProgress {
    if (nextMilestone == null) return 1.0;
    return (currentStreak / nextMilestone!.days).clamp(0.0, 1.0);
  }
}

/// İbadet takip Notifier
class WorshipTrackerNotifier extends StateNotifier<Map<String, DailyWorshipEntry>> {
  static const _prefKey = 'worship_tracker_entries_v1';
  static const _bestStreakPrefKey = 'worship_tracker_best_streak_v1';

  int _bestStreak = 0;

  WorshipTrackerNotifier() : super({}) {
    _load();
  }

  int get bestStreak => _bestStreak;

  static String formatDateKey(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  static String todayKey() {
    return formatDateKey(DateTime.now());
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _bestStreak = prefs.getInt(_bestStreakPrefKey) ?? 0;
      final jsonStr = prefs.getString(_prefKey);
      if (jsonStr != null) {
        final decoded = json.decode(jsonStr) as Map<String, dynamic>;
        final map = <String, DailyWorshipEntry>{};
        decoded.forEach((k, v) {
          map[k] = DailyWorshipEntry.fromMap(v as Map<String, dynamic>);
        });
        state = map;
      }
    } catch (_) {}
  }

  DailyWorshipEntry getToday() {
    final key = todayKey();
    return state[key] ?? DailyWorshipEntry(dateKey: key);
  }

  /// Kesintisiz 7/7 tamamlanan günlük seriyi geriye doğru hesaplar
  int calculateCurrentStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayKeyStr = formatDateKey(today);
    final todayEntry = state[todayKeyStr];

    int streak = 0;
    DateTime checkDate;

    if (todayEntry != null && todayEntry.isFullyCompleted) {
      streak = 1;
      checkDate = today.subtract(const Duration(days: 1));
    } else {
      final yesterday = today.subtract(const Duration(days: 1));
      final yesterdayKey = formatDateKey(yesterday);
      final yesterdayEntry = state[yesterdayKey];
      if (yesterdayEntry != null && yesterdayEntry.isFullyCompleted) {
        streak = 1;
        checkDate = yesterday.subtract(const Duration(days: 1));
      } else {
        return 0;
      }
    }

    while (true) {
      final key = formatDateKey(checkDate);
      final entry = state[key];
      if (entry != null && entry.isFullyCompleted) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  int calculateBestStreak() {
    final current = calculateCurrentStreak();
    if (current > _bestStreak) {
      _bestStreak = current;
    }
    return _bestStreak;
  }

  Future<WorshipStreakMilestone?> toggleHabit({
    required String habitKey, // 'fajr', 'dhuhr', 'asr', 'maghrib', 'isha', 'quran', 'zikr'
  }) async {
    final key = todayKey();
    final current = getToday();
    final wasCompletedBefore = current.isFullyCompleted;
    DailyWorshipEntry updated;

    switch (habitKey) {
      case 'fajr':
        updated = current.copyWith(fajr: !current.fajr);
        break;
      case 'dhuhr':
        updated = current.copyWith(dhuhr: !current.dhuhr);
        break;
      case 'asr':
        updated = current.copyWith(asr: !current.asr);
        break;
      case 'maghrib':
        updated = current.copyWith(maghrib: !current.maghrib);
        break;
      case 'isha':
        updated = current.copyWith(isha: !current.isha);
        break;
      case 'quran':
        updated = current.copyWith(quran: !current.quran);
        break;
      case 'zikr':
        updated = current.copyWith(zikr: !current.zikr);
        break;
      default:
        return null;
    }

    final newMap = Map<String, DailyWorshipEntry>.from(state);
    newMap[key] = updated;
    state = newMap;

    WorshipStreakMilestone? newlyReachedMilestone;

    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = <String, dynamic>{};
      newMap.forEach((k, v) => encoded[k] = v.toMap());
      await prefs.setString(_prefKey, json.encode(encoded));

      // Eğer bu tıklamayla bugün ilk kez 7/7 tamamlandıysa seriyi kontrol et
      if (!wasCompletedBefore && updated.isFullyCompleted) {
        final newStreak = calculateCurrentStreak();
        if (newStreak > _bestStreak) {
          _bestStreak = newStreak;
          await prefs.setInt(_bestStreakPrefKey, _bestStreak);
        }

        // Dönüm noktası kontrolü (10, 30, 50, 100, 200, 400)
        for (final m in WorshipStreakMilestone.allMilestones) {
          if (m.days == newStreak) {
            newlyReachedMilestone = m;
            break;
          }
        }
      }
    } catch (_) {}

    return newlyReachedMilestone;
  }
}

final worshipTrackerProvider =
    StateNotifierProvider<WorshipTrackerNotifier, Map<String, DailyWorshipEntry>>((ref) {
  return WorshipTrackerNotifier();
});

/// Bugünün ibadet girdisini reaktif izleyen Provider (Tick anında UI yenilenir)
final todayWorshipEntryProvider = Provider<DailyWorshipEntry>((ref) {
  final map = ref.watch(worshipTrackerProvider);
  final key = WorshipTrackerNotifier.todayKey();
  return map[key] ?? DailyWorshipEntry(dateKey: key);
});

/// Reaktif Günlük Seri ve Dönüm Noktaları Provider'ı
final worshipStreakProvider = Provider<WorshipStreakData>((ref) {
  // map'i watch ederek state değiştiğinde otomatik tetiklenmesini sağla
  ref.watch(worshipTrackerProvider);
  final notifier = ref.watch(worshipTrackerProvider.notifier);
  final today = ref.watch(todayWorshipEntryProvider);

  final currentStreak = notifier.calculateCurrentStreak();
  final bestStreak = notifier.calculateBestStreak();

  final unlocked = WorshipStreakMilestone.allMilestones
      .where((m) => currentStreak >= m.days || bestStreak >= m.days)
      .toList();

  WorshipStreakMilestone? next;
  for (final m in WorshipStreakMilestone.allMilestones) {
    if (currentStreak < m.days) {
      next = m;
      break;
    }
  }

  return WorshipStreakData(
    currentStreak: currentStreak,
    bestStreak: bestStreak,
    isTodayCompleted: today.isFullyCompleted,
    todayCompletedCount: today.completedCount,
    nextMilestone: next,
    unlockedMilestones: unlocked,
  );
});

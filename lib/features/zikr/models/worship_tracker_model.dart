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

  String localizedBadgeName(String langCode) {
    if (langCode == 'en') {
      switch (days) {
        case 10: return '10-Day Steadfastness Certificate';
        case 30: return '30-Day Perseverance Certificate';
        case 50: return '50-Day Devotion & Patience Medal';
        case 100: return '100-Day Prayer Guardian Badge';
        case 200: return '200-Day Serenity & Victory Crown';
        case 400: return '400-Day Ridwan & Content Soul Badge';
        default: return '$days-Day Worship Streak Certificate';
      }
    } else if (langCode == 'ar') {
      switch (days) {
        case 10: return 'شهادة الاستقامة لـ ١٠ أيام';
        case 30: return 'شهادة الثبات لـ ٣٠ يوماً';
        case 50: return 'وسام الخشوع والصبر لـ ٥٠ يوماً';
        case 100: return 'وسام حارس الصلاة لـ ١٠٠ يوم';
        case 200: return 'تاج السكينة والفتح لـ ٢٠٠ يوم';
        case 400: return 'وسام الرضوان والنفس المطمئنة لـ ٤٠٠ يوم';
        default: return 'شهادة استمرار العبادة لـ $days يوماً';
      }
    }
    return badgeName;
  }

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

/// Tüm görevler (7/7) tamamlandığında ekranda her gün farklı gösterilen ilham verici Kur'an-ı Kerim ayetleri modeli
class DailyCompletionVerse {
  final String surahName;
  final String verseReference;
  final String arabicText;
  final String turkishMeaning;
  final String spiritualNote;

  const DailyCompletionVerse({
    required this.surahName,
    required this.verseReference,
    required this.arabicText,
    required this.turkishMeaning,
    required this.spiritualNote,
  });

  /// Her gün için farklı bir ayet döner (Yılın gününe göre otomatik döner)
  static DailyCompletionVerse getForDate([DateTime? date]) {
    final target = date ?? DateTime.now();
    final dayOfYear = target.difference(DateTime(target.year, 1, 1)).inDays;
    final index = (dayOfYear.abs()) % pool.length;
    return pool[index];
  }

  /// Belirli bir indexteki ayeti döner (kullanıcı değiştirmek isterse)
  static DailyCompletionVerse getByIndex(int index) {
    return pool[index.abs() % pool.length];
  }

  /// 31 Günlük Zengin ve Doğrulanmış Kur'an-ı Kerim Âyet Havuzu
  static const List<DailyCompletionVerse> pool = [
    DailyCompletionVerse(
      surahName: 'Bakara Suresi',
      verseReference: 'Bakara 2:277',
      arabicText: 'إِنَّ الَّذِينَ آمَنُوا وَعَمِلُوا الصَّالِحَاتِ وَأَقَامُوا الصَّلَاةَ وَآتَوُا الزَّكَاةَ لَهُمْ أَجْرُهُمْ عِندَ رَبِّهِمْ وَلَا خَوْفٌ عَلَيْهِمْ وَلَا هُمْ يَحْزَنُونَ',
      turkishMeaning: 'İman edip iyi ameller işleyen, namazı dosdoğru kılan ve zekâtı verenlerin Rableri katında mükâfatları vardır. Onlara korku yoktur ve mahzun da olmayacaklardır.',
      spiritualNote: 'Namazını dosdoğru kılıp salih ameller işleyenlere hem dünyada hem ukbada ebedi emniyet müjdelenmiştir.',
    ),
    DailyCompletionVerse(
      surahName: 'Ankebût Suresi',
      verseReference: 'Ankebût 29:45',
      arabicText: 'اتْلُ مَا أُوحِيَ إِلَيْكَ مِنَ الْكِتَابِ وَأَقِمِ الصَّلَاةَ ۖ إِنَّ الصَّلَاةَ تَنْهَىٰ عَنِ الْفَحْشَاءِ وَالْمُنكَرِ ۗ وَلَذِكْرُ اللَّهِ أَكْبَرُ',
      turkishMeaning: 'Sana vahyedilen Kitabı oku ve namazı dosdoğru kıl. Çünkü namaz insanı her türlü kötülükten ve hayasızlıktan alıkor. Allah\'ı zikretmek ise elbette en büyüktür.',
      spiritualNote: 'Günün 5 vaktini ve Kur\'an tilavetini tamamlayarak kalbini kötülüklerden koruyan bir manevi kalkan kazandın.',
    ),
    DailyCompletionVerse(
      surahName: 'Ra\'d Suresi',
      verseReference: 'Ra\'d 13:28',
      arabicText: 'الَّذِينَ آمَنُوا وَتَطْمَئِنُّ قُلُوبُهُم بِذِكْرِ اللَّهِ ۗ أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
      turkishMeaning: 'Onlar, inanan ve kalpleri Allah\'ı anmakla huzura kavuşan kimselerdir. İyi bilin ki, kalpler ancak Allah\'ın zikriyle mutmain olur (huzur bulur).',
      spiritualNote: 'Bugünkü zikir ve ibadetlerinle ruhunu ilahi sekinete ve gerçek huzura kavuşturdun.',
    ),
    DailyCompletionVerse(
      surahName: 'Tâ-Hâ Suresi',
      verseReference: 'Tâ-Hâ 20:130',
      arabicText: 'فَاصْبِرْ عَلَىٰ مَا يَقُولُونَ وَسَبِّحْ بِحَمْدِ رَبِّكَ قَبْلَ طُلُوعِ الشَّمْسِ وَقَبْلَ غُرُوبِهَا ۖ وَمِنْ آنَاءِ اللَّيْلِ فَسَبِّحْ وَأَطْرَافَ النَّهَارِ لَعَلَّكَ تَرْضَىٰ',
      turkishMeaning: 'Güneşin doğmasından önce de batmasından önce de Rabbini hamd ile tesbih et. Gecenin bir kısım vakitlerinde ve gündüzün etrafında da tesbih et ki rızaya eresin.',
      spiritualNote: 'Günün sabahından yatsısına kadar vakitleri ibadetle süsleyenler ilahi rızanın engin ikramına mazhar olur.',
    ),
    DailyCompletionVerse(
      surahName: 'Mü\'minûn Suresi',
      verseReference: 'Mü\'minûn 23:1-2',
      arabicText: 'قَدْ أَفْلَحَ الْمُؤْمِنُونَ ﴿١﴾ الَّذِينَ هُمْ فِي صَلَاتِهِمْ خَاشِعُونَ',
      turkishMeaning: 'Müminler kesinlikle kurtuluşa ermişlerdir; Onlar ki, namazlarında huşû ve derin bir saygı içindedirler.',
      spiritualNote: 'Namazında huşûyu muhafaza eden mümin, iki cihanın da asıl kurtuluşuna ermiştir.',
    ),
    DailyCompletionVerse(
      surahName: 'İsrâ Suresi',
      verseReference: 'İsrâ 17:78',
      arabicText: 'أَقِمِ الصَّلَاةَ لِدُلُوكِ الشَّمْسِ إِلَىٰ غَسَقِ اللَّيْلِ وَقُرْآنَ الْفَجْرِ ۖ إِنَّ قُرْآنَ الْفَجْرِ كَانَ مَشْهُودًا',
      turkishMeaning: 'Güneşin batıya kaymasından gecenin karanlığına kadar namazı kıl; bir de sabah Kur\'an tilavetini... Zira sabah Kur\'an\'ı şahitlidir (melekler hazır bulunur).',
      spiritualNote: 'Sabahın bereketli vaktinde meleklerin şahit olduğu bir kulluk defteri açtın ve gününü kemale erdirdin.',
    ),
    DailyCompletionVerse(
      surahName: 'Bakara Suresi',
      verseReference: 'Bakara 2:152-153',
      arabicText: 'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ ﴿١٥٢﴾ يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ ۚ إِنَّ اللَّهَ مَعَ الصَّابِرِينَ',
      turkishMeaning: 'Beni anın ki, ben de sizi anayım. Bana şükredin ve nankörlük etmeyin. Ey iman edenler! Sabır ve namaz ile Allah\'tan yardım dileyin. Şüphesiz Allah sabredenlerle beraberdir.',
      spiritualNote: 'Rabbin seni andı; çünkü sen gün boyu O\'nu zikretmeyi ve namazla O\'na sığınmayı seçtin.',
    ),
    DailyCompletionVerse(
      surahName: 'Fâtır Suresi',
      verseReference: 'Fâtır 35:29-30',
      arabicText: 'إِنَّ الَّذِينَ يَتْلُونَ كِتَابَ اللَّهِ وَأَقَامُوا الصَّلَاةَ وَأَنفَقُوا مِمَّا رَزَقْنَاهُمْ سِرًّا وَعَلَانِيَةً يَرْجُونَ تِجَارَةً لَّن تَبُورَ',
      turkishMeaning: 'Allah\'ın Kitabı\'nı okuyanlar, namazı dosdoğru kılanlar ve kendilerine rızık olarak verdiklerimizden infak edenler, asla batmayacak bir kazanç umarlar.',
      spiritualNote: 'Kur\'an tilaveti ve namazla geçirilen her gün, ebedi ahiret pazarında tükenmez bir kâr vesilesidir.',
    ),
    DailyCompletionVerse(
      surahName: 'Kâf Suresi',
      verseReference: 'Kâf 50:39-40',
      arabicText: 'فَاصْبِرْ عَلَىٰ مَا يَقُولُونَ وَسَبِّحْ بِحَمْدِ رَبِّكَ قَبْلَ طُلُوعِ الشَّمْسِ وَقَبْلَ الْغُرُوبِ ﴿٣٩﴾ وَمِنَ اللَّيْلِ فَسَبِّحْهُ وَأَدْبَارَ السُّجُودِ',
      turkishMeaning: 'Güneşin doğuşundan önce de batışından önce de Rabbini hamd ile tesbih et. Gecenin bir vaktinde ve secdelerin ardından da O\'nu tesbih etmeye devam et.',
      spiritualNote: 'Secdelerin ardından yükselen dualar ve tesbihler, kul ile Rabbi arasındaki perdeleri aralar.',
    ),
    DailyCompletionVerse(
      surahName: 'Âl-i İmrân Suresi',
      verseReference: 'Âl-i İmrân 3:191',
      arabicText: 'الَّذِينَ يَذْكُرُونَ اللَّهَ قِيَامًا وَقُعُودًا وَعَلَىٰ جُنُوبِهِمْ وَيَتَفَكَّرُونَ فِي خَلْقِ السَّمَاوَاتِ وَالْأَرْضِ رَبَّنَا مَا خَلَقْتَ هَٰذَا بَاطِلًا',
      turkishMeaning: 'Onlar ayaktayken, otururken ve yanları üzerinde yatarken Allah\'ı anarlar; göklerin ve yerin yaratılışını derin derin tefekkür ederler: "Rabbimiz! Sen bunu boşuna yaratmadın."',
      spiritualNote: 'Zikir ve tefekkürle yoğrulan bir ibadet günü, aklın ve kalbin en yüce olgunluk meyvesidir.',
    ),
    DailyCompletionVerse(
      surahName: 'Rûm Suresi',
      verseReference: 'Rûm 30:17-18',
      arabicText: 'فَسُبْحَانَ اللَّهِ حِينَ تُمْسُونَ وَحِينَ تُصْبِحُونَ ﴿١٧﴾ وَلَهُ الْحَمْدُ فِي السَّمَاوَاتِ وَالْأَرْضِ وَعَشِيًّا وَحِينَ تُظْهِرُونَ',
      turkishMeaning: 'Akşama erdiğinizde ve sabaha kavuştuğunuzda Allah\'ı tesbih edin. Göklerde ve yerde, ikindide ve öğle vaktinde de hamd yalnız O\'na aittir.',
      spiritualNote: 'Günün dönüm noktalarında kılınan namazlar, kâinatın zikir korosuna kulun en samimi iştirakidir.',
    ),
    DailyCompletionVerse(
      surahName: 'Nûr Suresi',
      verseReference: 'Nûr 24:36-37',
      arabicText: 'رِجَالٌ لَّا تُلْهِيهِمْ تِجَارَةٌ وَلَا بَيْعٌ عَن ذِكْرِ اللَّهِ وَإِقَامِ الصَّلَاةِ وَإِيتَاءِ الزَّكَاةِ ۙ يَخَافُونَ يَوْمًا تَتَقَلَّبُ فِيهِ الْقُلُوبُ وَالْأَبْصَارُ',
      turkishMeaning: 'Öyle erler vardır ki, ne ticaret ne de alışveriş onları Allah\'ı anmaktan, namazı kılmaktan ve zekâtı vermekten alıkoyamaz.',
      spiritualNote: 'Dünya meşgalesinin ortasında namazını ve zikrini aksatmayan erlerden olmak ne kutlu bir devlettir.',
    ),
    DailyCompletionVerse(
      surahName: 'Zümer Suresi',
      verseReference: 'Zümer 39:9',
      arabicText: 'أَمَّنْ هُوَ قَانِتٌ آنَاءَ اللَّيْلِ سَاجِدًا وَقَائِمًا يَحْذَرُ الْآخِرَةَ وَيَرْجُو رَحْمَةَ رَبِّهِ ۗ قُلْ هَلْ يَسْتَوِي الَّذِينَ يَعْلَمُونَ وَالَّذِينَ لَا يَعْلَمُونَ',
      turkishMeaning: 'Yoksa o, gece saatlerinde secde ederek ve kıyamda durarak boyun büken, ahiretten çekinip Rabbinin rahmetini uman gibi midir? De ki: Hiç bilenlerle bilmeyenler bir olur mu?',
      spiritualNote: 'İbadet ve secde bilinci, mümini cehalet karanlığından hakiki marifet ve ilim nuruna taşır.',
    ),
    DailyCompletionVerse(
      surahName: 'Hacc Suresi',
      verseReference: 'Hacc 22:77',
      arabicText: 'يَا أَيُّهَا الَّذِينَ آمَنُوا ارْكَعُوا وَاسْجُدُوا وَاعْبُدُوا رَبَّكُمْ وَافْعَلُوا الْخَيْرَ لَعَلَّكُمْ تُفْلِحُونَ',
      turkishMeaning: 'Ey iman edenler! Rükû edin, secdeye kapanın, Rabbinize ibadet edin ve hayır işleyin ki felaha (ebedi kurtuluşa) eresiniz.',
      spiritualNote: 'Rükû ve secdeyle tamamlanan her gün, felah kapısını biraz daha ardına kadar aralar.',
    ),
    DailyCompletionVerse(
      surahName: 'Furkân Suresi',
      verseReference: 'Furkân 25:63-64',
      arabicText: 'وَعِبَادُ الرَّحْمَٰنِ الَّذِينَ يَمْشُونَ عَلَى الْأَرْضِ هَوْنًا... وَالَّذِينَ يَبِيتُونَ لِرَبِّهِمْ سُجَّدًا وَقِيَامًا',
      turkishMeaning: 'Rahmân\'ın has kulları yeryüzünde tevazuyla yürürler... Ve onlar, gecelerini Rablerine secde ederek ve kıyamda durarak geçirirler.',
      spiritualNote: 'Tevazu ve secdelerle süslenen bir gün, kulunu "Rahmân\'ın seçkin kulu" mertebesine yükseltir.',
    ),
    DailyCompletionVerse(
      surahName: 'Zâriyât Suresi',
      verseReference: 'Zâriyât 51:56',
      arabicText: 'وَمَا خَلَقْتُ الْجِنَّ وَالْإِنسَ إِلَّا لِيَعْبُدُونِ',
      turkishMeaning: 'Ben cinleri ve insanları ancak bana kulluk ve ibadet etsinler diye yarattım.',
      spiritualNote: 'Bugün var oluş gayene sadık kaldın ve kâinatın en asil gayesini fiilen yerine getirdin.',
    ),
    DailyCompletionVerse(
      surahName: 'Ahzâb Suresi',
      verseReference: 'Ahzâb 33:41-42',
      arabicText: 'يَا أَيُّهَا الَّذِينَ آمَنُوا اذْكُرُوا اللَّهَ ذِكْرًا كَثِيرًا ﴿٤١﴾ وَسَبِّحُوهُ بُكْرَةً وَأَصِيلًا',
      turkishMeaning: 'Ey iman edenler! Allah\'ı çokça zikredin ve O\'nu sabah akşam tesbih edip yüceltin.',
      spiritualNote: 'Dillerde ve kalplerde çokça zikredilen Allah, o kalbi sevgisiyle doldurur.',
    ),
    DailyCompletionVerse(
      surahName: 'Bakara Suresi',
      verseReference: 'Bakara 2:238',
      arabicText: 'حَافِظُوا عَلَى الصَّلَوَاتِ وَالصَّلَاةِ الْوُسْطَىٰ وَقُومُوا لِلَّهِ قَانِتِينَ',
      turkishMeaning: 'Namazlara ve orta namaza (ikindiye) devam edin; tam bir saygı ve huşû ile Allah\'ın huzurunda durun.',
      spiritualNote: 'Vakitleri muhafaza eden mümini Allah Teâlâ dünyevi ve uhrevi tehlikelerden muhafaza eder.',
    ),
    DailyCompletionVerse(
      surahName: 'Meryem Suresi',
      verseReference: 'Meryem 19:31',
      arabicText: 'وَجَعَلَنِي مُبَارَكًا أَيْنَ مَا كُنتُ وَأَوْصَانِي بِالصَّلَاةِ وَالزَّكَاةِ مَا دُمْتُ حَيًّا',
      turkishMeaning: 'Nerede olursam olayım beni mübarek kıldı ve yaşadığım sürece bana namazı ve zekâtı emretti.',
      spiritualNote: 'Namaz hayatın can damarıdır; ona sımsıkı sarılan ömür bereket ve feyizle taçlanır.',
    ),
    DailyCompletionVerse(
      surahName: 'Lokmân Suresi',
      verseReference: 'Lokmân 31:17',
      arabicText: 'يَا بُنَيَّ أَقِمِ الصَّلَاةَ وَأْمُرْ بِالْمَعْرُوفِ وَانْهَ عَنِ الْمُنكَرِ وَاصْبِرْ عَلَىٰ مَا أَصَابَكَ ۖ إِنَّ ذَٰلِكَ مِنْ عَزْمِ الْأُمُورِ',
      turkishMeaning: 'Yavrucuğum! Namazı dosdoğru kıl, iyiliği emret, kötülükten sakındır ve başına gelene sabret. Şüphesiz bunlar azmedilmeye değer işlerdendir.',
      spiritualNote: 'Namaz insanı metanetli, sabırlı ve hayra öncülük eden yüce bir ahlak sahibi yapar.',
    ),
    DailyCompletionVerse(
      surahName: 'Nisâ Suresi',
      verseReference: 'Nisâ 4:103',
      arabicText: 'إِنَّ الصَّلَاةَ كَانَتْ عَلَى الْمُؤْمِنِينَ كِتَابًا مَّوْقُوتًا',
      turkishMeaning: 'Şüphesiz namaz, müminler üzerine vakitleri belirlenmiş bir farz kılınmıştır.',
      spiritualNote: 'Vakti vaktine kılınan namaz, kulun Allah katındaki sadakat ve nizam nişanesidir.',
    ),
    DailyCompletionVerse(
      surahName: 'Necm Suresi',
      verseReference: 'Necm 53:62',
      arabicText: 'فَاسْجُدُوا لِلَّهِ وَاعْبُدُوا ۩',
      turkishMeaning: 'Haydi artık yalnızca Allah\'a secde edin ve yalnız O\'na kulluk edin!',
      spiritualNote: 'Kulun Rabbine en yakın olduğu an secde anıdır; secdelerle geçen bir gün paha biçilemezdir.',
    ),
    DailyCompletionVerse(
      surahName: 'A\'lâ Suresi',
      verseReference: 'A\'lâ 87:14-15',
      arabicText: 'قَدْ أَفْلَحَ مَن تَزَكَّىٰ ﴿١٤﴾ وَذَكَرَ اسْمَ رَبِّهِ فَصَلَّىٰ',
      turkishMeaning: 'Nefsini günahlardan arındıran, Rabbinin adını anıp namaz kılan kesinlikle kurtuluşa ermiştir.',
      spiritualNote: 'Arınmanın ve manevi temizliğin en nurlu yolu, Allah\'ı anıp divana durmaktır.',
    ),
    DailyCompletionVerse(
      surahName: 'En\'âm Suresi',
      verseReference: 'En\'âm 6:162',
      arabicText: 'قُلْ إِنَّ صَلَاتِي وَنُسُكِي وَمَحْيَايَ وَمَمَاتِي لِلَّهِ رَبِّ الْعَالَمِينَ',
      turkishMeaning: 'De ki: Şüphesiz benim namazım, kurbanım, hayatım ve ölümüm âlemlerin Rabbi olan Allah içindir.',
      spiritualNote: 'Bütün bir günü Allah rızası için ibadetle donatmak, hayatı ibadete dönüştürmektir.',
    ),
    DailyCompletionVerse(
      surahName: 'İbrâhîm Suresi',
      verseReference: 'İbrâhîm 14:40',
      arabicText: 'رَبِّ اجْعَلْنِي مُقِيمَ الصَّلَاةِ وَمِن ذُرِّيَّتِي ۚ رَبَّنَا وَتَقَبَّلْ دُعَاءِ',
      turkishMeaning: 'Rabbim! Beni ve neslimi namazı dosdoğru kılanlardan eyle. Rabbimiz! Duamı kabul buyur.',
      spiritualNote: 'Hz. İbrahim\'in kutlu duasına ortak olarak namaz muhafızlığını sürdürdün.',
    ),
    DailyCompletionVerse(
      surahName: 'Enbiyâ Suresi',
      verseReference: 'Enbiyâ 21:73',
      arabicText: 'وَأَوْحَيْنَا إِلَيْهِمْ فِعْلَ الْخَيْرَاتِ وَإِقَامَ الصَّلَاةِ وَإِيتَاءَ الزَّكَاةِ ۖ وَكَانُوا لَنَا عَابِدِينَ',
      turkishMeaning: 'Biz onlara hayır işlemeyi, namaz kılmayı ve zekât vermeyi vahyettik. Onlar yalnızca bize kulluk eden kimselerdi.',
      spiritualNote: 'Peygamberler yolunun izinde bir gün daha hayırla ve namazla tamamlandı.',
    ),
    DailyCompletionVerse(
      surahName: 'Secde Suresi',
      verseReference: 'Secde 32:15-16',
      arabicText: 'إِنَّمَا يُؤْمِنُ بِآيَاتِنَا الَّذِينَ إِذَا ذُكِّرُوا بِهَا خَرُّوا سُجَّدًا وَسَبِّحُوا بِحَمْدِ رَبِّهِمْ... تَتَجَافَىٰ جُنُوبُهُمْ عَنِ الْمَضَاجِعِ',
      turkishMeaning: 'Ayetlerimize ancak öyle kimseler iman eder ki, kendilerine hatırlatıldığında secdeye kapanırlar ve Rablerini hamd ile tesbih ederler.',
      spiritualNote: 'Rabbinin ayetlerine saygıyla secde eden mümin, meleklerin gıpta ettiği bir mertebededir.',
    ),
    DailyCompletionVerse(
      surahName: 'Hûd Suresi',
      verseReference: 'Hûd 11:114',
      arabicText: 'وَأَقِمِ الصَّلَاةَ طَرَفَيِ النَّهَارِ وَزُلَفًا مِّنَ اللَّيْلِ ۚ إِنَّ الْحَسَنَاتِ يُذْهِبْنَ السَّيِّئَاتِ ۚ ذَٰلِكَ ذِكْرَىٰ لِلذَّاكِرِينَ',
      turkishMeaning: 'Gündüzün iki tarafında ve gecenin gündüze yakın saatlerinde namaz kıl. Muhakkak ki iyilikler kötülükleri silip süpürür.',
      spiritualNote: 'Bugün kıldığın namazlar ve döktüğün dualar, geçmiş hatalara en güzel kefarettir.',
    ),
    DailyCompletionVerse(
      surahName: 'İnsân Suresi',
      verseReference: 'İnsân 76:25-26',
      arabicText: 'وَاذْكُرِ اسْمَ رَبِّكَ بُكْرَةً وَأَصِيلًا ﴿٢٥﴾ وَمِنَ اللَّيْلِ فَاسْجُدْ لَهُ وَسَبِّحْهُ لَيْلًا طَوِيلًا',
      turkishMeaning: 'Sabah akşam Rabbinin adını an. Gecenin bir kısmında O\'na secde et ve geceleyin uzun uzadıya O\'nu tesbih et.',
      spiritualNote: 'Gece ve gündüz tesbihleriyle yoğrulan gönül, karanlıklardan selamete çıkar.',
    ),
    DailyCompletionVerse(
      surahName: 'İnşirâh Suresi',
      verseReference: 'İnşirâh 94:7-8',
      arabicText: 'فَإِذَا فَرَغْتَ فَانصَبْ ﴿٧﴾ وَإِلَىٰ رَبِّكَ فَارْغَب',
      turkishMeaning: 'Öyleyse bir işi bitirince hemen diğerine koyul (ibadete yönel) ve yalnız Rabbine rağbet et.',
      spiritualNote: 'Bir ibadeti tamamlayan kul daima bir sonrakine yönelir; kalp daima Mevlâ\'sına müteveccihtir.',
    ),
    DailyCompletionVerse(
      surahName: 'Fecr Suresi',
      verseReference: 'Fecr 89:27-30',
      arabicText: 'يَا أَيَّتُهَا النَّفْسُ الْمُطْمَئِنَّةُ ﴿٢٧﴾ ارْجِعِي إِلَىٰ رَبِّكِ رَاضِيَةً مَرْضِيَّةً ﴿٢٨﴾ فَادْخُلِي فِي عِبَادِي ﴿٢٩﴾ وَادْخُلِي جَنَّتِي',
      turkishMeaning: 'Ey huzura ermiş mutmain nefis! Sen O\'ndan razı, O da senden razı olarak Rabbine dön! Salih kullarımın arasına katıl ve cennetime gir!',
      spiritualNote: 'Günün tüm ibadetlerini ikmâl eden kalp, mutmain nefsin huzur veren meltemini hisseder.',
    ),
  ];
}


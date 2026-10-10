import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import '../../features/quran/repositories/quran_repository.dart';
import '../../features/quran/screens/surah_detail_screen.dart';
import '../../main.dart';

/// WidgetKit, Live Activity ve Deep Link yönlendirme servisi.
/// Widget'lara tıklandığında ilgili sure/ayet detay sayfasına veya namaz sekmesine yönlendirir.
class DeepLinkService {
  static final DeepLinkService instance = DeepLinkService._internal();
  factory DeepLinkService() => instance;
  DeepLinkService._internal();

  /// Global NavigatorKey – BuildContext async açıklarını engeller ve her yerden güvenli navigasyon sağlar.
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  StreamSubscription<Uri?>? _widgetSubscription;
  bool _isHandling = false;
  Uri? _pendingUri;

  bool get hasPendingLink => _pendingUri != null;

  void init(WidgetRef ref) {
    _widgetSubscription?.cancel();
    _widgetSubscription = HomeWidget.widgetClicked.listen((Uri? uri) {
      if (uri != null) {
        handleUri(ref, uri);
      }
    });

    // Soğuk açılışta (cold start) widget tıklaması
    HomeWidget.initiallyLaunchedFromHomeWidget().then((Uri? uri) {
      if (uri != null) {
        handleUri(ref, uri);
      }
    });
  }

  void dispose() {
    _widgetSubscription?.cancel();
    _widgetSubscription = null;
  }

  /// Bekleyen bir widget deep link'i varsa ana ekran yüklendiğinde işletir.
  Future<void> processPending(WidgetRef ref) async {
    final pending = _pendingUri;
    if (pending != null) {
      _pendingUri = null;
      await handleUri(ref, pending);
    }
  }

  Future<void> handleUri(WidgetRef ref, Uri uri) async {
    if (_isHandling) return;
    _isHandling = true;

    try {
      debugPrint('>>> DeepLinkService handleUri: $uri');
      if (uri.scheme != 'beyan') {
        _isHandling = false;
        return;
      }

      final context = navigatorKey.currentContext;
      if (context == null || !context.mounted) {
        debugPrint('>>> DeepLinkService context not ready, queuing pending uri: $uri');
        _pendingUri = uri;
        _isHandling = false;
        return;
      }

      // 1. Namaz vakitleri widget'ı: beyan://prayer
      if (uri.host == 'prayer' || uri.path.contains('prayer')) {
        ref.read(selectedTabProvider.notifier).state = 1;
        Navigator.of(context).popUntil((route) => route.isFirst);
        return;
      }

      // 2. Ayet widget'ı: beyan://verse?surah=2&verse=153&ref=...
      if (uri.host == 'verse' || uri.path.contains('verse')) {
        final target = parseVerseTarget(uri);
        int? surahId = target.surahId;
        final verseNum = target.verseNum;

        if (surahId == null && target.surahNameQuery != null && target.surahNameQuery!.isNotEmpty) {
          final results = await QuranRepository().searchSurahsByName(target.surahNameQuery!);
          if (results.isNotEmpty) {
            surahId = results.first.id;
          }
        }

        if (surahId != null && surahId >= 1 && surahId <= 114) {
          final surah = await QuranRepository().getSurahById(surahId);
          if (surah != null && context.mounted) {
            ref.read(selectedTabProvider.notifier).state = 2; // Kur'an sekmesi
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SurahDetailScreen(
                  surah: surah,
                  initialScrollToVerse: verseNum,
                ),
              ),
            );
            return;
          }
        }

        // Genel Kur'an sekmesine yönlendir
        if (context.mounted) {
          ref.read(selectedTabProvider.notifier).state = 2;
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } catch (e) {
      debugPrint('DeepLinkService yönlendirme hatası: $e');
    } finally {
      _isHandling = false;
    }
  }

  /// URI'den Sure ID ve Ayet Numarasını hassas ve öncelikli olarak ayrıştırır.
  @visibleForTesting
  static ({int? surahId, int? verseNum, String? surahNameQuery}) parseVerseTarget(Uri uri) {
    int? surahId;
    int? verseNum;
    String? surahNameQuery;

    if (uri.queryParameters.containsKey('surah')) {
      surahId = parseNumber(uri.queryParameters['surah']);
    }
    if (uri.queryParameters.containsKey('verse')) {
      verseNum = parseNumber(uri.queryParameters['verse']);
    }

    final refParam = uri.queryParameters['ref'];
    if (refParam != null && refParam.isNotEmpty) {
      final normalizedRef = normalizeArabicDigits(refParam);

      // 1. Durum: Sayı formatı (örn: "2:153", "Ra'd 13:28", "94:6", "Tâhâ 20:25-26")
      final colonMatch = RegExp(r'(\d+)\s*[:\.]\s*(\d+)').firstMatch(normalizedRef);
      if (colonMatch != null) {
        final parsedSurah = int.tryParse(colonMatch.group(1)!);
        final parsedVerse = int.tryParse(colonMatch.group(2)!);
        if (parsedSurah != null && parsedSurah >= 1 && parsedSurah <= 114) {
          surahId = parsedSurah;
        }
        if (parsedVerse != null && parsedVerse >= 1) {
          verseNum = parsedVerse;
        }
      } else {
        // 2. Durum: Sure adı ve ayet numarası (örn: "Bakara 153" veya "İnşirah 6")
        final nameAndNumMatch = RegExp(r'^([^\d:]+?)\s+(\d+)$').firstMatch(normalizedRef.trim());
        if (nameAndNumMatch != null) {
          surahNameQuery = nameAndNumMatch.group(1)!.trim();
          final vNum = int.tryParse(nameAndNumMatch.group(2)!);
          if (vNum != null && vNum >= 1) {
            verseNum = vNum;
          }
        } else if (surahId == null) {
          // 3. Durum: Sadece sure adı (örn: "Bakara")
          final cleanName = normalizedRef.split(RegExp(r'[\s0-9:]')).first.trim();
          if (cleanName.isNotEmpty) {
            surahNameQuery = cleanName;
          }
        }
      }
    }

    return (surahId: surahId, verseNum: verseNum, surahNameQuery: surahNameQuery);
  }

  /// Arapça-Hint rakamlarını (٠١٢٣٤٥٦٧٨٩) standart Latin rakamlarına (0-9) dönüştürür.
  @visibleForTesting
  static String normalizeArabicDigits(String input) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var result = input;
    for (int i = 0; i < arabicDigits.length; i++) {
      result = result.replaceAll(arabicDigits[i], i.toString());
    }
    return result;
  }

  /// Hem Latin hem de Arapça rakam içeren metinleri tam sayıya dönüştürür.
  @visibleForTesting
  static int? parseNumber(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final normalized = normalizeArabicDigits(raw);
    final match = RegExp(r'\d+').firstMatch(normalized);
    if (match != null) {
      return int.tryParse(match.group(0)!);
    }
    return null;
  }
}


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
        int? surahId;
        int? verseNum;

        if (uri.queryParameters.containsKey('surah')) {
          surahId = _parseNumber(uri.queryParameters['surah']);
        }
        if (uri.queryParameters.containsKey('verse')) {
          verseNum = _parseNumber(uri.queryParameters['verse']);
        }

        final refParam = uri.queryParameters['ref'];
        if (refParam != null && refParam.isNotEmpty) {
          final normalizedRef = _normalizeArabicDigits(refParam);

          // 1. Durum: Sayı formatı (örn: "2:153", "Ra'd 13:28", "94:6")
          final colonMatch = RegExp(r'(\d+)\s*[:\.]\s*(\d+)').firstMatch(normalizedRef);
          if (colonMatch != null) {
            surahId ??= int.tryParse(colonMatch.group(1)!);
            verseNum ??= int.tryParse(colonMatch.group(2)!);
          } else {
            // 2. Durum: Sure adı ve ayet numarası (örn: "Bakara 153" veya "İnşirah 6")
            final nameAndNumMatch = RegExp(r'^([^\d:]+?)\s+(\d+)$').firstMatch(normalizedRef.trim());
            if (nameAndNumMatch != null) {
              final sName = nameAndNumMatch.group(1)!.trim();
              final vNum = int.tryParse(nameAndNumMatch.group(2)!);
              verseNum ??= vNum;
              if (surahId == null && sName.isNotEmpty) {
                final results = await QuranRepository().searchSurahsByName(sName);
                if (results.isNotEmpty) {
                  surahId = results.first.id;
                }
              }
            } else if (surahId == null) {
              // 3. Durum: Sadece sure adı (örn: "Bakara")
              final cleanName = normalizedRef.split(RegExp(r'[\s0-9:]')).first.trim();
              if (cleanName.isNotEmpty) {
                final results = await QuranRepository().searchSurahsByName(cleanName);
                if (results.isNotEmpty) {
                  surahId = results.first.id;
                }
              }
            }
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

  /// Arapça-Hint rakamlarını (٠١٢٣٤٥٦٧٨٩) standart Latin rakamlarına (0-9) dönüştürür.
  static String _normalizeArabicDigits(String input) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var result = input;
    for (int i = 0; i < arabicDigits.length; i++) {
      result = result.replaceAll(arabicDigits[i], i.toString());
    }
    return result;
  }

  /// Hem Latin hem de Arapça rakam içeren metinleri tam sayıya dönüştürür.
  static int? _parseNumber(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final normalized = _normalizeArabicDigits(raw);
    final match = RegExp(r'\d+').firstMatch(normalized);
    if (match != null) {
      return int.tryParse(match.group(0)!);
    }
    return null;
  }
}


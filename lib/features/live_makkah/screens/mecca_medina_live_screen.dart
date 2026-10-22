import 'package:islamic_app/core/theme/beyan_colors.dart';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../../../core/localization/app_strings.dart';

/// 24/7 Mekke & Medine Uygulama İçi Canlı Yayın Ekranı (In-App Live Stream Player)
class MeccaMedinaLiveScreen extends ConsumerStatefulWidget {
  const MeccaMedinaLiveScreen({super.key});

  @override
  ConsumerState<MeccaMedinaLiveScreen> createState() => _MeccaMedinaLiveScreenState();
}

class _MeccaMedinaLiveScreenState extends ConsumerState<MeccaMedinaLiveScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Saudi Quran TV (Makkah): @SaudiQuranTv
  // Saudi Sunnah TV (Madinah): @SaudiSunnahTv
  static const String _makkahDefaultVideoId = 'eC4LfEVxvKg';
  static const String _madinahDefaultVideoId = 'Rs7St51oDDc';
  static const String _makkahHandle = '@SaudiQuranTv';
  static const String _madinahHandle = '@SaudiSunnahTv';

  String _makkahVideoId = _makkahDefaultVideoId;
  String _madinahVideoId = _madinahDefaultVideoId;

  late final WebViewController _makkahController;
  late final WebViewController _madinahController;

  bool _isMakkahLoading = true;
  bool _isMadinahLoading = true;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!mounted) return;
      if (_tabController.indexIsChanging) return;
      // İki yayının aynı anda ses çalmasını önlemek için aktif olmayan sekmedeki videoyu durdur
      if (_tabController.index == 0) {
        _madinahController
            .runJavaScript(
                'try { if(window.player && player.pauseVideo){player.pauseVideo();} var v=document.querySelector("video"); if(v){v.pause();} } catch(e){}')
            .catchError((_) {});
      } else {
        _makkahController
            .runJavaScript(
                'try { if(window.player && player.pauseVideo){player.pauseVideo();} var v=document.querySelector("video"); if(v){v.pause();} } catch(e){}')
            .catchError((_) {});
      }
      setState(() {});
    });

    _initControllers();
    _fetchLiveVideoIds();
  }

  static const String _browserUserAgent =
      'Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1';

  /// Gömülü oynatıcı için uygulamaya ait geçerli bir HTTPS origin.
  /// YouTube, origin/referrer olarak youtube.com taklit eden gömmeleri
  /// "Hata 152-4" ile reddeder; bu yüzden kendi origin'imizi kullanıyoruz.
  static const String _embedOrigin = 'https://beyan.app';

  // Gömülü oynatıcı hata verirse otomatik olarak mobil izleme sayfasına geçildi mi?
  bool _makkahFallbackUsed = false;
  bool _madinahFallbackUsed = false;

  WebViewController _createController(
    String name,
    VoidCallback onFinished,
    VoidCallback onPlayerError,
  ) {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    late final WebViewController controller;
    controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setUserAgent(_browserUserAgent)
      ..addJavaScriptChannel(
        'BeyanPlayer',
        onMessageReceived: (message) {
          debugPrint('$name player event: ${message.message}');
          if (message.message.startsWith('error')) {
            onPlayerError();
          } else if (message.message == 'ready' || message.message == 'playing') {
            onFinished();
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            onFinished();
            // Mobil izleme sayfasında YouTube üst menüsünü ve öneri alanlarını gizle
            if (url.contains('m.youtube.com/watch')) {
              controller.runJavaScript(_watchPageCleanupJs).catchError((_) {});
            }
          },
          onWebResourceError: (error) {
            debugPrint('$name stream error: ${error.description}');
            onFinished();
          },
          onNavigationRequest: (request) {
            // Uygulama dışına (youtube://, App Store vb.) yönlendirmeleri engelle
            final uri = Uri.tryParse(request.url);
            if (uri == null) return NavigationDecision.prevent;
            if (uri.scheme == 'https' || uri.scheme == 'http' || uri.scheme == 'about') {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      );
    return controller;
  }

  static const String _watchPageCleanupJs = '''
(function() {
  var css = 'ytm-mobile-topbar-renderer, header, .mobile-topbar-header, ytm-pivot-bar-renderer,'
    + ' ytm-item-section-renderer, ytm-comment-section-renderer, .related-chips-slot-wrapper,'
    + ' ytm-engagement-panel, ytm-slim-video-metadata-section-renderer { display:none !important; }'
    + ' body, html, ytm-app { background:#000 !important; }'
    + ' #player-container-id, .player-container { position:fixed !important; top:0 !important; left:0 !important;'
    + ' width:100vw !important; height:100vh !important; z-index:9999 !important; }'
    + ' video { object-fit: contain !important; }';
  var s = document.createElement('style'); s.innerHTML = css; document.head.appendChild(s);
  var v = document.querySelector('video');
  if (v) { v.setAttribute('playsinline', ''); if (v.play) { v.play().catch(function(){}); } }
})();
''';

  void _initControllers() {
    _makkahController = _createController(
      'Makkah',
      () {
        if (mounted && _isMakkahLoading) setState(() => _isMakkahLoading = false);
      },
      () {
        if (!_makkahFallbackUsed && mounted) {
          _makkahFallbackUsed = true;
          _loadWatchPage(_makkahController, _makkahVideoId);
        }
      },
    );
    _loadStream(_makkahController, _makkahVideoId);

    _madinahController = _createController(
      'Madinah',
      () {
        if (mounted && _isMadinahLoading) setState(() => _isMadinahLoading = false);
      },
      () {
        if (!_madinahFallbackUsed && mounted) {
          _madinahFallbackUsed = true;
          _loadWatchPage(_madinahController, _madinahVideoId);
        }
      },
    );
    _loadStream(_madinahController, _madinahVideoId);
  }

  /// YouTube IFrame Player API ile gömülü oynatıcıyı yükler.
  /// Oynatıcı hata verirse (gömme kısıtlaması vb.) Flutter'a bildirir.
  void _loadStream(WebViewController controller, String videoId) {
    final html = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <meta name="referrer" content="strict-origin-when-cross-origin">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; background-color: #000; }
    html, body { width: 100%; height: 100%; overflow: hidden; background: #000; }
    #player { position: absolute; top: 0; left: 0; width: 100%; height: 100%; border: 0; }
  </style>
</head>
<body>
  <div id="player"></div>
  <script>
    function post(m) { try { BeyanPlayer.postMessage(m); } catch (e) {} }
    var player;
    function onYouTubeIframeAPIReady() {
      player = new YT.Player('player', {
        width: '100%',
        height: '100%',
        videoId: '$videoId',
        playerVars: {
          autoplay: 1, playsinline: 1, rel: 0, modestbranding: 1, fs: 1,
          origin: '$_embedOrigin',
          widget_referrer: '$_embedOrigin'
        },
        events: {
          onReady: function(e) { post('ready'); try { e.target.playVideo(); } catch (x) {} },
          onStateChange: function(e) { if (e.data === 1) { started = true; post('playing'); } },
          onError: function(e) { post('error:' + e.data); }
        }
      });
    }
    var started = false;
    // Oynatıcı hata ekranında kalıp hiç oynatmazsa (ör. Hata 152) yedek moda geç
    setTimeout(function() { if (!started) post('error:noplay'); }, 15000);
    var tag = document.createElement('script');
    tag.src = 'https://www.youtube.com/iframe_api';
    tag.onerror = function() { post('error:api'); };
    document.head.appendChild(tag);
    // API 12 sn içinde hazır olmazsa yedek moda geç
    setTimeout(function() { if (!player) post('error:timeout'); }, 12000);
  </script>
</body>
</html>
''';
    controller.loadHtmlString(html, baseUrl: _embedOrigin);
  }

  /// Yedek mod: YouTube mobil izleme sayfasını doğrudan uygulama içinde oynatır.
  void _loadWatchPage(WebViewController controller, String videoId) {
    controller.loadRequest(
      Uri.parse('https://m.youtube.com/watch?v=$videoId&autoplay=1&playsinline=1'),
      headers: const {'Referer': 'https://m.youtube.com/'},
    );
  }

  /// Kanalın /live sayfasındaki canonical bağlantıdan güncel canlı yayın ID'sini çözer.
  Future<String?> _resolveLiveVideoId(HttpClient client, String handle) async {
    try {
      final req = await client.getUrl(Uri.parse('https://www.youtube.com/$handle/live'));
      req.followRedirects = true;
      req.headers.set('Accept-Language', 'en-US,en;q=0.8');
      req.headers.set('Cookie', 'CONSENT=YES+1');
      final res = await req.close().timeout(const Duration(seconds: 10));
      final body = await utf8.decoder.bind(res).join();
      final canonical = RegExp(
        r'<link rel="canonical" href="https://www\.youtube\.com/watch\?v=([a-zA-Z0-9_-]{11})"',
      ).firstMatch(body);
      if (canonical != null) return canonical.group(1);
    } catch (_) {}
    return null;
  }

  Future<void> _fetchLiveVideoIds() async {
    final client = HttpClient()..userAgent = _browserUserAgent;
    try {
      final makkahId = await _resolveLiveVideoId(client, _makkahHandle);
      if (makkahId != null && makkahId != _makkahVideoId && mounted) {
        _makkahVideoId = makkahId;
        _makkahFallbackUsed = false;
        _loadStream(_makkahController, _makkahVideoId);
      }

      final madinahId = await _resolveLiveVideoId(client, _madinahHandle);
      if (madinahId != null && madinahId != _madinahVideoId && mounted) {
        _madinahVideoId = madinahId;
        _madinahFallbackUsed = false;
        _loadStream(_madinahController, _madinahVideoId);
      }
    } finally {
      client.close();
    }
  }

  void _reloadCurrentStream() {
    HapticFeedback.lightImpact();
    if (_tabController.index == 0) {
      setState(() => _isMakkahLoading = true);
      _makkahFallbackUsed = false;
      _loadStream(_makkahController, _makkahVideoId);
    } else {
      setState(() => _isMadinahLoading = true);
      _madinahFallbackUsed = false;
      _loadStream(_madinahController, _madinahVideoId);
    }
  }

  /// "Doğrudan" modu: gömülü oynatıcıyı atlayıp canlı yayını uygulama içinde
  /// YouTube mobil izleme sayfasından oynatır.
  void _loadDirectStream() {
    HapticFeedback.lightImpact();
    if (_tabController.index == 0) {
      setState(() => _isMakkahLoading = true);
      _makkahFallbackUsed = true;
      _loadWatchPage(_makkahController, _makkahVideoId);
    } else {
      setState(() => _isMadinahLoading = true);
      _madinahFallbackUsed = true;
      _loadWatchPage(_madinahController, _madinahVideoId);
    }
  }

  Future<void> _openOfficialLiveChannel(String channelHandle) async {
    HapticFeedback.lightImpact();
    final appUri = Uri.parse('youtube://www.youtube.com/$channelHandle/live');
    final webUri = Uri.parse('https://www.youtube.com/$channelHandle/live');
    try {
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}
    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    try {
      _makkahController.loadRequest(Uri.parse('about:blank'));
      _madinahController.loadRequest(Uri.parse('about:blank'));
    } catch (_) {}
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);

    if (_isFullScreen) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: WebViewWidget(
                  controller: _tabController.index == 0 ? _makkahController : _madinahController,
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton.filled(
                  icon: const Icon(Icons.fullscreen_exit_rounded, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.6),
                  ),
                  onPressed: () => setState(() => _isFullScreen = false),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: BeyanColors.tone(0xFF011815),
      appBar: AppBar(
        title: Text(
          strings.liveBroadcastTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: BeyanColors.tone(0xFFFFDF7A)),
            tooltip: strings.refreshStream,
            onPressed: _reloadCurrentStream,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: BeyanColors.tone(0xFFFFDF7A),
          indicatorWeight: 3,
          labelColor: BeyanColors.tone(0xFFFFDF7A),
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(
              icon: const Icon(Icons.mosque_rounded),
              text: strings.makkahLiveTitle,
            ),
            Tab(
              icon: const Icon(Icons.nightlight_round),
              text: strings.madinahLiveTitle,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLiveTab(
            controller: _makkahController,
            isLoading: _isMakkahLoading,
            title: strings.makkahLiveTitle,
            subtitle: strings.makkahLiveSubtitle,
            badge: strings.liveBadgeMakkah,
            accentColor: BeyanColors.tone(0xFFD4AF37),
            handle: _makkahHandle,
            description: strings.makkahLiveDesc,
            hadith: strings.makkahLiveHadith,
            strings: strings,
          ),
          _buildLiveTab(
            controller: _madinahController,
            isLoading: _isMadinahLoading,
            title: strings.madinahLiveTitle,
            subtitle: strings.madinahLiveSubtitle,
            badge: strings.liveBadgeMadinah,
            accentColor: BeyanColors.tone(0xFF2DD4BF),
            handle: _madinahHandle,
            description: strings.madinahLiveDesc,
            hadith: strings.madinahLiveHadith,
            strings: strings,
          ),
        ],
      ),
    );
  }

  Widget _buildLiveTab({
    required WebViewController controller,
    required bool isLoading,
    required String title,
    required String subtitle,
    required String badge,
    required Color accentColor,
    required String handle,
    required String description,
    required String hadith,
    required AppStrings strings,
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 1. Uygulama İçi Video Oynatıcı Kartı ──────────────────────
          Container(
            height: 230,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: WebViewWidget(controller: controller),
                  ),

                  // Yükleniyor İndikatörü
                  if (isLoading)
                    Positioned.fill(
                      child: Container(
                        color: BeyanColors.tone(0xFF032620),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: accentColor),
                              const SizedBox(height: 12),
                              Text(
                                '$badge ${strings.connectingLive}',
                                style: TextStyle(
                                  color: accentColor,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Tam Ekran Butonu (Sağ Üst)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton.filled(
                      icon: const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.6),
                      ),
                      tooltip: strings.fullscreenTooltip,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        setState(() => _isFullScreen = true);
                      },
                    ),
                  ),

                  // Canlı Rozeti (Sol Üst)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            badge,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── 2. Kontrol ve Aksiyon Butonları ─────────────────────────
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _reloadCurrentStream,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(strings.refreshStream),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: BeyanColors.tone(0xFFFFDF7A),
                    side: BorderSide(color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _loadDirectStream,
                icon: const Icon(Icons.bolt_rounded, size: 18),
                label: Text(strings.directStream),
                style: OutlinedButton.styleFrom(
                  foregroundColor: BeyanColors.tone(0xFF2DD4BF),
                  side: BorderSide(color: BeyanColors.tone(0xFF2DD4BF).withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openOfficialLiveChannel(handle),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: Text(strings.openInYouTube),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── 3. Canlı Yayın Bilgi Kartı ───────────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: BeyanColors.tone(0xFF032620),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.live_tv_rounded, color: accentColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    hadith,
                    style: TextStyle(
                      color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.95),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

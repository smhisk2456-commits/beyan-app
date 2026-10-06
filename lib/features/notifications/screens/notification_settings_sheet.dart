import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../prayer_times/models/prayer_time_model.dart';
import '../services/notification_service.dart';

/// Ezan ve Namaz Bildirimleri Lüks Ayarlar Menüsü
class NotificationSettingsSheet extends StatefulWidget {
  const NotificationSettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const NotificationSettingsSheet(),
    );
  }

  @override
  State<NotificationSettingsSheet> createState() =>
      _NotificationSettingsSheetState();
}

class _NotificationSettingsSheetState extends State<NotificationSettingsSheet> {
  final _service = NotificationService.instance;

  bool _loading = true;
  bool _masterEnabled = true;
  bool _earlyReminder = true;
  final Map<PrayerName, bool> _prayerStates = {};

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final master = await _service.isMasterEnabled();
    final early = await _service.isEarlyReminderEnabled();

    for (final p in PrayerName.values) {
      _prayerStates[p] = await _service.isPrayerEnabled(p);
    }

    if (mounted) {
      setState(() {
        _masterEnabled = master;
        _earlyReminder = early;
        _loading = false;
      });
    }
  }

  Future<void> _toggleMaster(bool val) async {
    HapticFeedback.lightImpact();
    setState(() => _masterEnabled = val);
    await _service.setMasterEnabled(val);
  }

  Future<void> _toggleEarly(bool val) async {
    HapticFeedback.lightImpact();
    setState(() => _earlyReminder = val);
    await _service.setEarlyReminderEnabled(val);
  }

  Future<void> _togglePrayer(PrayerName prayer, bool val) async {
    HapticFeedback.lightImpact();
    setState(() => _prayerStates[prayer] = val);
    await _service.setPrayerEnabled(prayer, val);
  }

  Future<void> _sendTest() async {
    HapticFeedback.mediumImpact();
    await _service.requestPermissions();
    await _service.sendTestNotification();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFFFFDF7A), size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text('Test bildirimi cihazınıza gönderildi!'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF033E35),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF071F1B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: _loading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sürükleme Çubuğu
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Başlık & İkon
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                          ),
                        ),
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          color: Color(0xFFD4AF37),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ezan & Vakit Bildirimleri',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Namaz vakitlerinde ezan ve uyarı bildirimleri',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white60 : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Ana Açma / Kapama Kartı ──────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF033E35),
                          isDark ? const Color(0xFF01241F) : const Color(0xFF064D43),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.power_settings_new_rounded,
                          color: Color(0xFFFFDF7A),
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tüm Bildirimler',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'Ezan ve namaz bildirimlerini etkinleştir',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: _masterEnabled,
                          activeThumbColor: const Color(0xFFFFDF7A),
                          activeTrackColor: const Color(0xFFD4AF37),
                          onChanged: _toggleMaster,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── 15 Dakika Önce Hatırlat Kartı ────────────────
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _masterEnabled ? 1.0 : 0.4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0D2823) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? const Color(0xFF133B34) : Colors.grey.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            color: Color(0xFFD4AF37),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '15 Dakika Önce Hatırlat',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Vakit girmeden önce erken uyarı bildirimi',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? Colors.white54 : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch.adaptive(
                            value: _earlyReminder && _masterEnabled,
                            activeThumbColor: const Color(0xFFFFDF7A),
                            activeTrackColor: const Color(0xFFD4AF37),
                            onChanged: _masterEnabled ? _toggleEarly : null,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Vakit Bazlı Ayarlar ──────────────────────────
                  const Text(
                    'VAKİT BİLDİRİMLERİ',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                  const SizedBox(height: 10),

                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _masterEnabled ? 1.0 : 0.4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0D2823) : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDark ? const Color(0xFF133B34) : Colors.grey.shade200,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Column(
                          children: PrayerName.values.map((p) {
                            final enabled = (_prayerStates[p] ?? true) && _masterEnabled;
                            return Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: isDark ? Colors.white10 : Colors.grey.shade100,
                                    width: 0.8,
                                  ),
                                ),
                              ),
                              child: ListTile(
                                dense: true,
                                leading: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: enabled
                                        ? const Color(0xFFD4AF37).withValues(alpha: 0.15)
                                        : (isDark ? Colors.white10 : Colors.grey.shade100),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _getPrayerIcon(p),
                                    color: enabled
                                        ? const Color(0xFFD4AF37)
                                        : (isDark ? Colors.white38 : Colors.grey),
                                    size: 18,
                                  ),
                                ),
                                title: Text(
                                  p.turkish,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                subtitle: Text(
                                  _getPrayerDesc(p),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? Colors.white54 : AppColors.textSecondary,
                                  ),
                                ),
                                trailing: Switch.adaptive(
                                  value: enabled,
                                  activeThumbColor: const Color(0xFFFFDF7A),
                                  activeTrackColor: const Color(0xFFD4AF37),
                                  onChanged: _masterEnabled
                                      ? (v) => _togglePrayer(p, v)
                                      : null,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Test Bildirimi Butonu ───────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _sendTest,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFD4AF37), width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.notifications_active, color: Color(0xFFD4AF37), size: 18),
                      label: const Text(
                        'Test Bildirimi Gönder',
                        style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  IconData _getPrayerIcon(PrayerName p) {
    switch (p) {
      case PrayerName.fajr:
        return Icons.nights_stay_rounded;
      case PrayerName.sunrise:
        return Icons.wb_twilight_rounded;
      case PrayerName.dhuhr:
        return Icons.wb_sunny_rounded;
      case PrayerName.asr:
        return Icons.wb_sunny_outlined;
      case PrayerName.maghrib:
        return Icons.brightness_6_rounded;
      case PrayerName.isha:
        return Icons.dark_mode_rounded;
    }
  }

  String _getPrayerDesc(PrayerName p) {
    switch (p) {
      case PrayerName.fajr:
        return 'İmsak vakti girdiğinde ezan bildirimi';
      case PrayerName.sunrise:
        return 'Güneş doğuş vakti uyarısı';
      case PrayerName.dhuhr:
        return 'Öğle ezanı bildirimi';
      case PrayerName.asr:
        return 'İkindi ezanı bildirimi';
      case PrayerName.maghrib:
        return 'Akşam ezanı bildirimi';
      case PrayerName.isha:
        return 'Yatsı ezanı bildirimi';
    }
  }
}

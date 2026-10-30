import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../localization/app_strings.dart';
import '../theme/beyan_colors.dart';

enum BeyanSoftPermissionType {
  location,
  notification,
}

/// Apple İnceleme Kuralları ve Kullanıcı Deneyimi Uyumlu Kibar İzin Öncesi Bilgilendirme Diyaloğu.
/// Doğrudan sistem penceresi açmak yerine kullanıcının neden izin vermesi gerektiğini
/// şık ve manevi bir dille açıklar, izin verme oranını ve güven hissini artırır.
class BeyanSoftPermissionDialog extends ConsumerWidget {
  final BeyanSoftPermissionType type;

  const BeyanSoftPermissionDialog({
    super.key,
    required this.type,
  });

  /// Diyaloğu açar ve kullanıcının onaylayıp onaylamadığını döner.
  static Future<bool> show(
    BuildContext context, {
    required BeyanSoftPermissionType type,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (ctx) => BeyanSoftPermissionDialog(type: type),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final isLocation = type == BeyanSoftPermissionType.location;

    final title = isLocation ? strings.softLocationTitle : strings.softNotificationTitle;
    final desc = isLocation ? strings.softLocationDesc : strings.softNotificationDesc;
    final primaryBtnText = isLocation ? strings.softLocationAllowAction : strings.softNotificationAllowAction;
    final secondaryBtnText = isLocation ? strings.softLocationManualAction : strings.softNotificationLaterAction;

    final List<String> points = isLocation
        ? [
            strings.softLocationPoint1,
            strings.softLocationPoint2,
            strings.softLocationPoint3,
          ]
        : [
            strings.softNotificationPoint1,
            strings.softNotificationPoint2,
            strings.softNotificationPoint3,
          ];

    final iconData = isLocation ? Icons.near_me_rounded : Icons.notifications_active_rounded;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: BeyanColors.tone(0xFF02211C),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.15),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Tepe İkonu & Aura ──
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      BeyanColors.tone(0xFFFFDF7A),
                      BeyanColors.tone(0xFFD4AF37),
                      BeyanColors.tone(0xFF997A15),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.4),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    iconData,
                    size: 34,
                    color: const Color(0xFF021B16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Başlık ──
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: BeyanColors.tone(0xFFFFDF7A),
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 12),

              // ── Açıklama ──
              Text(
                desc,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 18),

              // ── Maddeler (Faydalar & Güvence) ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 0.8,
                  ),
                ),
                child: Column(
                  children: points.map((point) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: BeyanColors.tone(0xFFD4AF37),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              point,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.9),
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // ── Birincil Onay Butonu ──
              Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      BeyanColors.tone(0xFFFFDF7A),
                      BeyanColors.tone(0xFFD4AF37),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.of(context).pop(true);
                    },
                    child: Center(
                      child: Text(
                        primaryBtnText,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF03221C),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── İkincil / Vazgeç Butonu ──
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop(false);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white60,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                ),
                child: Text(
                  secondaryBtnText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: Colors.white54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

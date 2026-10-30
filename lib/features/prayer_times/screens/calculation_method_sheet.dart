import 'package:islamic_app/core/theme/beyan_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../models/calculation_settings_model.dart';
import '../providers/prayer_time_providers.dart';
import '../services/prayer_time_service.dart';

/// Namaz Vakti Hesaplama Yöntemi Seçim Sheet'i
class CalculationMethodSheet extends StatefulWidget {
  final WidgetRef ref;

  const CalculationMethodSheet({super.key, required this.ref});

  static void show(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => CalculationMethodSheet(ref: ref),
    );
  }

  @override
  State<CalculationMethodSheet> createState() => _CalculationMethodSheetState();
}

class _CalculationMethodSheetState extends State<CalculationMethodSheet> {
  PrayerCalculationMethod _currentMethod = PrayerCalculationMethod.diyanet;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final m = await PrayerTimeService.instance.getSavedCalculationMethod();
    if (mounted) setState(() => _currentMethod = m);
  }

  @override
  Widget build(BuildContext context) {
    final strings = widget.ref.watch(appStringsProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: BeyanColors.tone(0xFF02211C),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: BeyanColors.tone(0xFFD4AF37), width: 1.5)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragUpdate: (details) {
                if (details.primaryDelta != null && details.primaryDelta! > 6) {
                  Navigator.pop(context);
                }
              },
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white38,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.calculationMethodTitle,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: BeyanColors.tone(0xFFFFDF7A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          strings.calculationMethodDesc,
                          style: const TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
                    color: Colors.white70,
                    tooltip: 'Kapat',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 6),
            ...PrayerCalculationMethod.values.map((method) {
              final isSelected = _currentMethod == method;
              return ListTile(
                leading: Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: BeyanColors.tone(0xFFD4AF37),
                ),
                title: Text(
                  method.localizedName(strings.language.code),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  strings.language == AppLanguage.turkish ? method.enName : method.trName,
                  style: const TextStyle(color: Colors.white54, fontSize: 11.5),
                ),
                onTap: () async {
                  HapticFeedback.lightImpact();
                  await PrayerTimeService.instance.saveCalculationMethod(method);
                  setState(() => _currentMethod = method);
                  widget.ref.read(prayerTimesNotifierProvider.notifier).refresh();
                  if (context.mounted) Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      backgroundColor: Colors.transparent,
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF02211C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Color(0xFFD4AF37), width: 1.5)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Hesaplama Yöntemi',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFDF7A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Vakit hesaplarında yetkili kurum ve fetva meclisleri',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
            const SizedBox(height: 14),
            ...PrayerCalculationMethod.values.map((method) {
              final isSelected = _currentMethod == method;
              return ListTile(
                leading: Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: const Color(0xFFD4AF37),
                ),
                title: Text(
                  method.trName,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  method.enName,
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

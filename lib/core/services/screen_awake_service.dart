import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Cihaz ekranının açık kalmasını sağlayan servis (Başucu Gece Saati modu vb.)
class ScreenAwakeService {
  static const MethodChannel _channel = MethodChannel('com.example.islamic_app/screen');

  /// Ekranın uykuya dalmasını engeller veya serbest bırakır.
  static Future<void> setKeepScreenOn(bool enabled) async {
    if (kIsWeb) return;
    try {
      await _channel.invokeMethod('setKeepScreenOn', {'enabled': enabled});
    } catch (e) {
      debugPrint('[ScreenAwakeService] setKeepScreenOn hatası: $e');
    }
  }
}

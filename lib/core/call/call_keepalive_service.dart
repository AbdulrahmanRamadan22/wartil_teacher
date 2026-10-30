import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// خدمة Flutter لتشغيل/إيقاف الـ Foreground Service الأندرويد
/// الذي يُبقي اتصال Pusher حياً عند انتقال التطبيق للخلفية.
class CallKeepaliveService {
  static const _channel = MethodChannel('com.wartilteacher.app/keepalive');

  /// يبدأ الـ Foreground Service (أندرويد فقط).
  static Future<void> start() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('start');
      debugPrint('✅ [KEEPALIVE] Foreground service started');
    } catch (e) {
      debugPrint('⚠️ [KEEPALIVE] Failed to start foreground service: $e');
    }
  }

  /// يوقف الـ Foreground Service (أندرويد فقط).
  static Future<void> stop() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('stop');
      debugPrint('✅ [KEEPALIVE] Foreground service stopped');
    } catch (e) {
      debugPrint('⚠️ [KEEPALIVE] Failed to stop foreground service: $e');
    }
  }
}

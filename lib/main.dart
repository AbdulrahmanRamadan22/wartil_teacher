import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waratel_app/waratel_app.dart';
import 'package:waratel_app/core/di/dependency_injection.dart';
import 'package:waratel_app/core/cache/shared_preferences.dart';
import 'package:waratel_app/core/notifications/local_notification_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// نقطة البداية الرئيسية للتطبيق
void main() async {
  // ── Global Error Handling ──────────────────────────────────
  // يلتقط جميع أخطاء Flutter Framework غير المعالجة
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('❌ [FLUTTER ERROR] ${details.exception}');
    debugPrint('STK: ${details.stack}');
  };

  // يلتقط الأخطاء غير المتزامنة خارج إطار Flutter
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('❌ [PLATFORM ERROR] $error');
    debugPrint('STK: $stack');
    return true; // الاستمرار بدون إيقاف التطبيق
  };

  debugPrint('🚀 [APP START] بداية تشغيل التطبيق...');

  // التأكد من تهيئة Flutter
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('✅ [APP START] WidgetsFlutterBinding initialized');

  // تحميل ملفات البيئة
  await dotenv.load(fileName: ".env");
  debugPrint('✅ [APP START] Environment variables loaded');

  // تهيئة الإشعارات المحلية
  await LocalNotificationService.initialize();
  debugPrint('✅ [APP START] LocalNotificationService initialized');

  // ── تأمين الاتجاه عمودياً (Portrait) فقط ─────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── ضبط شريط الحالة ───────────────────────────────────────
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  try {
    debugPrint('🚀 [APP START] 1. Initializing SharedPreferences...');
    await SharedPreferencesService.init().timeout(
      const Duration(seconds: 5),
      onTimeout: () =>
          debugPrint('⚠️ [APP START] SharedPreferences init timed out'),
    );

    debugPrint('🚀 [APP START] 2. Setting up Dependency Injection...');
    await setupGetIt().timeout(
      const Duration(seconds: 5),
      onTimeout: () => debugPrint('⚠️ [APP START] setupGetIt timed out'),
    );

    debugPrint('🚀 [APP START] 3. Running App...');
    runApp(const WaratelApp());
    debugPrint('✅ [APP START] App launched successfully');
  } catch (e, stack) {
    debugPrint('❌ [APP START CRITICAL ERROR] $e');
    debugPrint('STK: $stack');
  }
}

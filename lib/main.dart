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
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // ملف .env قد لا يوجد في بعض بيئات الـ release
    debugPrint('⚠️ [APP START] dotenv load failed: $e');
  }

  // تهيئة الإشعارات المحلية
  try {
    await LocalNotificationService.initialize();
  } catch (e) {
    debugPrint('⚠️ [APP START] LocalNotificationService failed: $e');
  }

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

  // ── تهيئة SharedPreferences ──────────────────────────────
  try {
    await SharedPreferencesService.init();
  } catch (e, stack) {
    // لا نوقف التطبيق - نكمل حتى لو SharedPreferences فشل
    debugPrint('⚠️ [APP START] SharedPreferences error (continuing): $e');
    debugPrint('STK: $stack');
  }

  // ── تهيئة Dependency Injection ───────────────────────────
  try {
    await setupGetIt();
  } catch (e, stack) {
    // لا نوقف التطبيق - نسجّل الخطأ ونكمل
    debugPrint('❌ [APP START] setupGetIt error (continuing): $e');
    debugPrint('STK: $stack');
  }

  // ── تشغيل التطبيق دائماً بغض النظر عن أي خطأ سابق ───────
  debugPrint('🚀 [APP START] 3. Running App...');
  runApp(const WaratelApp());
  debugPrint('✅ [APP START] App launched successfully');
}

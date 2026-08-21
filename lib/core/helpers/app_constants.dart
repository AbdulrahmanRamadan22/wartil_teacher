/// ══════════════════════════════════════════════════════════════
/// App Constants — SOLID: Single Source of Truth
/// ══════════════════════════════════════════════════════════════
///
/// مركزة جميع الثوابت في مكان واحد بدلاً من التكرار في الكود.
/// يطبّق مبدأ Open/Closed: مفتوح للإضافة، مغلق للتعديل في أماكن أخرى.
abstract class AppConstants {
  AppConstants._(); // منع الإنشاء — static فقط

  // ── Base URLs ──────────────────────────────────────────────
  static const String imageBaseUrl = 'https://wartil.com/storage/';
  static const String appName = 'ورتّل للمعلم';

  // ── Animation Durations ───────────────────────────────────
  static const Duration pageTransitionDuration = Duration(milliseconds: 250);
  static const Duration pageTransitionReverseDuration =
      Duration(milliseconds: 200);
  static const Duration fadeTransitionDuration = Duration(milliseconds: 350);
  static const Duration adAutoScrollDuration = Duration(seconds: 5);
  static const Duration adSlideAnimationDuration = Duration(milliseconds: 350);
  static const Duration dotIndicatorDuration = Duration(milliseconds: 300);
  static const Duration imageFadeInDuration = Duration(milliseconds: 300);

  // ── Network Timeouts ──────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sslConnectionTimeout = Duration(seconds: 10);
  static const Duration sharedPrefsInitTimeout = Duration(seconds: 5);
  static const Duration getItSetupTimeout = Duration(seconds: 5);

  // ── Staggered Loading Delays ──────────────────────────────
  static const Duration homeLayoutInitialDelay = Duration(milliseconds: 300);
  static const Duration homeLoadStaggerDelay = Duration(milliseconds: 200);

  // ── Image Cache Sizes (pixels × 2 for high-density screens) ──
  static const int adImageCacheWidth = 160;
  static const int adImageCacheHeight = 160;

  // ── UI Dimensions ─────────────────────────────────────────
  static const double designWidth = 375;
  static const double designHeight = 812;

  // ── Languages ─────────────────────────────────────────────
  static const String langArabic = 'ar';
  static const String langEnglish = 'en';
}

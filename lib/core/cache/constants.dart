/// ثوابت التطبيق
class AppConstants {
  // ========== مفاتيح التخزين المحلي ==========

  /// مفتاح حفظ التوكن
  static const String tokenKey = 'user_token';

  /// مفتاح حفظ معلومات المستخدم
  static const String userDataKey = 'user_data';

  /// مفتاح حفظ اللغة
  static const String languageKey = 'app_language';

  /// مفتاح حفظ حالة تسجيل الدخول
  static const String isLoggedInKey = 'is_logged_in';

  /// مفتاح حفظ حالة عرض الـ Onboarding
  static const String hasSeenOnboardingKey = 'has_seen_onboarding';

  /// مفتاح حفظ معرف المعلم (للاستخدام في Pusher عند فتح التطبيق مجدداً)
  static const String teacherIdKey = 'teacher_id';

  /// مفتاح حفظ حالة الموافقة على الشروط
  static const String hasAgreedToTermsKey = 'has_agreed_to_terms';

  // ========== إعدادات التطبيق ==========

  /// اسم التطبيق
  static const String appName = 'ورتّل للمعلم';

  /// اللغة الافتراضية
  static const String defaultLanguage = 'ar';

  /// مدة الـ Timeout للطلبات
  static const Duration requestTimeout = Duration(seconds: 30);

  // ========== روابط API (مثال) ==========

  /// رابط API الأساسي
  static const String baseUrl = 'https://api.waratel.com';

  /// رابط تسجيل الدخول
  static const String loginEndpoint = '/auth/login';

  /// رابط التسجيل
  static const String registerEndpoint = '/auth/register';
}

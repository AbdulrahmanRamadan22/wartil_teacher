import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

/// خدمة إدارة التخزين المحلي
class SharedPreferencesService {
  static SharedPreferences? _preferences;

  /// تهيئة SharedPreferences (استدعِها مرة في main)
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  /// الحصول على instance بشكل آمن — يُهيّئ تلقائياً إذا لم يكن مُهيّأ
  static Future<SharedPreferences> _getInstance() async {
    _preferences ??= await SharedPreferences.getInstance();
    return _preferences!;
  }

  /// الحصول على instance المتزامن (يتطلب init() مسبقاً)
  static SharedPreferences get instance {
    if (_preferences == null) {
      throw Exception('SharedPreferences not initialized. Call init() first.');
    }
    return _preferences!;
  }

  // ========== حفظ البيانات ==========

  /// حفظ التوكن
  static Future<bool> saveToken(String token) async {
    final prefs = await _getInstance();
    return prefs.setString(AppConstants.tokenKey, token);
  }

  /// حفظ بيانات المستخدم
  static Future<bool> saveUserData(String userData) async {
    final prefs = await _getInstance();
    return prefs.setString(AppConstants.userDataKey, userData);
  }

  /// حفظ معرف المعلم
  static Future<bool> saveTeacherId(int teacherId) async {
    final prefs = await _getInstance();
    return prefs.setInt(AppConstants.teacherIdKey, teacherId);
  }

  /// حفظ حالة تسجيل الدخول
  static Future<bool> setLoggedIn(bool isLoggedIn) async {
    final prefs = await _getInstance();
    return prefs.setBool(AppConstants.isLoggedInKey, isLoggedIn);
  }

  /// حفظ حالة عرض الـ Onboarding
  static Future<bool> setHasSeenOnboarding(bool hasSeen) async {
    final prefs = await _getInstance();
    return prefs.setBool(AppConstants.hasSeenOnboardingKey, hasSeen);
  }

  /// حفظ حالة الموافقة على الشروط
  static Future<bool> setHasAgreedToTerms(bool hasAgreed) async {
    final prefs = await _getInstance();
    return prefs.setBool(AppConstants.hasAgreedToTermsKey, hasAgreed);
  }

  /// حفظ اللغة
  static Future<bool> saveLanguage(String languageCode) async {
    final prefs = await _getInstance();
    return prefs.setString(AppConstants.languageKey, languageCode);
  }

  // ========== استرجاع البيانات ==========

  /// الحصول على التوكن
  static String? getToken() {
    return _preferences?.getString(AppConstants.tokenKey);
  }

  /// الحصول على بيانات المستخدم
  static String? getUserData() {
    return _preferences?.getString(AppConstants.userDataKey);
  }

  /// التحقق من حالة تسجيل الدخول
  static bool isLoggedIn() {
    return _preferences?.getBool(AppConstants.isLoggedInKey) ?? false;
  }

  /// الحصول على معرف المعلم المحفوظ
  static int? getTeacherId() {
    return _preferences?.getInt(AppConstants.teacherIdKey);
  }

  /// التحقق من عرض الـ Onboarding
  static bool hasSeenOnboarding() {
    return _preferences?.getBool(AppConstants.hasSeenOnboardingKey) ?? false;
  }

  /// التحقق من الموافقة على الشروط
  static bool hasAgreedToTerms() {
    return _preferences?.getBool(AppConstants.hasAgreedToTermsKey) ?? false;
  }

  /// الحصول على اللغة المحفوظة
  static String getLanguage() {
    return _preferences?.getString(AppConstants.languageKey) ??
        AppConstants.defaultLanguage;
  }

  // ========== حذف البيانات ==========

  /// حذف التوكن
  static Future<bool> removeToken() async {
    final prefs = await _getInstance();
    return prefs.remove(AppConstants.tokenKey);
  }

  /// حذف بيانات المستخدم
  static Future<bool> removeUserData() async {
    final prefs = await _getInstance();
    return prefs.remove(AppConstants.userDataKey);
  }

  /// تسجيل الخروج (حذف جميع البيانات)
  static Future<bool> logout() async {
    await removeToken();
    await removeUserData();
    return setLoggedIn(false);
  }

  /// مسح جميع البيانات
  static Future<bool> clearAll() async {
    final prefs = await _getInstance();
    return prefs.clear();
  }
}

/// أنماط التحقق من صحة المدخلات
class AppRegex {
  /// التحقق من صحة البريد الإلكتروني
  static bool isEmailValid(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  /// التحقق من صحة كلمة المرور
  /// يجب أن تحتوي على 8 أحرف على الأقل
  static bool isPasswordValid(String password) {
    return password.length >= 8;
  }

  /// التحقق من صحة رقم الهاتف السعودي
  static bool isPhoneNumberValid(String phoneNumber) {
    return RegExp(r'^(05|5)[0-9]{8}$').hasMatch(phoneNumber);
  }

  /// التحقق من أن النص يحتوي على أحرف عربية فقط
  static bool isArabicOnly(String text) {
    return RegExp(r'^[\u0600-\u06FF\s]+$').hasMatch(text);
  }

  /// التحقق من أن النص يحتوي على أرقام فقط
  static bool isNumericOnly(String text) {
    return RegExp(r'^[0-9]+$').hasMatch(text);
  }

  /// التحقق من صحة الاسم (عربي أو إنجليزي)
  static bool isNameValid(String name) {
    return RegExp(r'^[a-zA-Z\u0600-\u06FF\s]+$').hasMatch(name);
  }
}

import 'package:flutter/material.dart';

/// إدارة مسارات الـ Assets في التطبيق
/// جميع الصور والأيقونات والأصوات
class AppAssets {
  // ========== الصور ==========

  /// مسار مجلد الصور
  static const String _imagesPath = 'assets/images';

  /// شعار التطبيق
  static const String logo = '$_iconsPath/ورتل-png-الوان-2 (1).png';

  /// صورة الخلفية
  static const String background = '$_imagesPath/background.png';

  /// صورة افتراضية للمستخدم
  static const String defaultAvatar = '$_imagesPath/default_avatar.png';

  /// صورة فارغة (placeholder)
  static const String placeholder = '$_imagesPath/placeholder.png';

  // ========== الأيقونات ==========

  /// مسار مجلد الأيقونات
  static const String _iconsPath = 'assets/icons';

  /// أيقونة الرئيسية
  static const String homeIcon = '$_iconsPath/home.png';

  /// أيقونة الإعدادات
  static const String settingsIcon = '$_iconsPath/settings.png';

  /// أيقونة الملف الشخصي
  static const String profileIcon = '$_iconsPath/profile.png';

  /// أيقونة الإشعارات
  static const String notificationIcon = '$_iconsPath/notification.png';

  // ========== الأصوات ==========

  /// مسار مجلد الأصوات
  static const String _soundsPath = 'assets/sounds';

  /// صوت النقر
  static const String clickSound = '$_soundsPath/click.mp3';

  /// صوت النجاح
  static const String successSound = '$_soundsPath/success.mp3';

  /// صوت الخطأ
  static const String errorSound = '$_soundsPath/error.mp3';

  /// صوت الإشعار
  static const String notificationSound = '$_soundsPath/notification.mp3';

  // ========== الخطوط ==========

  /// خط Cairo
  static const String cairoFont = 'Cairo';

  /// شعار ورتل الجديد (wartel_logo)
  static const String appLogo = '$_iconsPath/ورتل-png-الوان-2 (1).png';
}

/// امتداد لتسهيل استخدام الصور
extension ImageAssets on String {
  /// تحويل المسار إلى AssetImage
  AssetImage get assetImage => AssetImage(this);

  /// تحويل المسار إلى Image widget
  Image get image => Image.asset(this);
}

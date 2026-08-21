import 'package:flutter/material.dart';

/// امتدادات مساعدة للـ BuildContext
extension ContextExtensions on BuildContext {
  /// الحصول على MediaQuery
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// الحصول على ارتفاع الشاشة
  double get height => mediaQuery.size.height;

  /// الحصول على عرض الشاشة
  double get width => mediaQuery.size.width;

  /// الحصول على الثيم
  ThemeData get theme => Theme.of(this);

  /// الحصول على أنماط النصوص
  TextTheme get textTheme => theme.textTheme;

  /// الحصول على نظام الألوان
  ColorScheme get colorScheme => theme.colorScheme;

  /// التنقل إلى صفحة جديدة
  Future<T?> push<T>(Widget page) {
    return Navigator.of(this).push<T>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// التنقل إلى صفحة جديدة مع استبدال الحالية
  Future<T?> pushReplacement<T>(Widget page) {
    return Navigator.of(this).pushReplacement<T, void>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// الرجوع للصفحة السابقة
  void pop<T>([T? result]) {
    Navigator.of(this).pop(result);
  }

  /// إظهار SnackBar
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// امتدادات للـ String
extension StringExtensions on String {
  /// التحقق من أن النص ليس فارغاً
  bool get isNotNullOrEmpty => trim().isNotEmpty;

  /// تحويل أول حرف لحرف كبير
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// تنسيق النص كتاريخ
  String get formatToDate {
    try {
      final DateTime dateTime = DateTime.parse(this);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return this;
    }
  }

  /// تنسيق النص كوقت
  String get formatToTime {
    try {
      final DateTime dateTime = DateTime.parse(this);
      final String hour = (dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12)
          .toString()
          .padLeft(2, '0');
      final String minute = dateTime.minute.toString().padLeft(2, '0');
      final String period = dateTime.hour < 12 ? 'ص' : 'م';
      return '$hour:$minute $period';
    } catch (_) {
      return this;
    }
  }
}

/// امتدادات للـ DateTime
extension DateTimeExtensions on DateTime {
  /// تنسيق التاريخ بالعربية
  String get formattedArabic {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    return '$day ${months[month - 1]} $year';
  }

  /// التحقق من أن التاريخ اليوم
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}

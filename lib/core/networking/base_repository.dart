import 'package:dio/dio.dart';

/// ══════════════════════════════════════════════════════════════
/// Base Repository — SOLID: Single Responsibility + DRY
/// ══════════════════════════════════════════════════════════════
///
/// يوفّر دالة موحّدة لمعالجة أخطاء API في جميع Repositories
/// بدلاً من تكرار try/catch في كل مكان.
///
/// الاستخدام:
///   class LoginRepo extends BaseRepository { ... }
///   `Future<String> login() => handleApiCall(() => _api.login(...));`
abstract class BaseRepository {
  /// ينفّذ [apiCall] ويُحوّل أخطاء Dio إلى رسائل واضحة
  Future<T> handleApiCall<T>(Future<T> Function() apiCall) async {
    try {
      return await apiCall();
    } on DioException catch (e) {
      throw _mapDioError(e);
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع: $e');
    }
  }

  /// تحويل DioException إلى رسالة خطأ مفهومة للمستخدم
  Exception _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('انتهت مهلة الاتصال، تحقق من الإنترنت');
      case DioExceptionType.connectionError:
        return Exception('تعذّر الاتصال بالخادم، تحقق من الإنترنت');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = _extractMessage(e.response?.data);
        if (statusCode == 401) {
          return Exception('غير مصرح، يرجى تسجيل الدخول مجدداً');
        }
        if (statusCode == 403) {
          return Exception('ليس لديك صلاحية للوصول');
        }
        if (statusCode == 404) {
          return Exception('البيانات المطلوبة غير موجودة');
        }
        if (statusCode == 422) {
          return Exception(message ?? 'بيانات غير صحيحة');
        }
        if (statusCode != null && statusCode >= 500) {
          return Exception('خطأ في الخادم، حاول مرة أخرى لاحقاً');
        }
        return Exception(
            message ?? 'حدث خطأ في الاتصال (${statusCode ?? "?"})');
      case DioExceptionType.cancel:
        return Exception('تم إلغاء الطلب');
      default:
        return Exception('حدث خطأ غير متوقع');
    }
  }

  /// استخراج رسالة الخطأ من response body
  String? _extractMessage(dynamic data) {
    if (data == null) return null;
    if (data is Map) {
      return data['message']?.toString() ??
          data['error']?.toString() ??
          data['msg']?.toString();
    }
    return data.toString();
  }
}

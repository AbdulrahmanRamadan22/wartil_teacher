import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/login_api.dart';
import '../models/models.dart';

class LoginRepo {
  final LoginApi _loginApi;

  LoginRepo(this._loginApi);

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _loginApi.login(
        email: email,
        password: password,
      );

      // Save token and user info to SharedPreferences
      if (response.token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', response.token!);
        if (response.user != null) {
          await prefs.setInt('user_id', response.user!.id);
          await prefs.setString('user_name', response.user!.name);
          await prefs.setString('user_email', response.user!.email);
          await prefs.setString('user_role', response.user!.role);
        }
        if (response.profile != null) {
          await prefs.setString('salary', response.profile!.salary);
          await prefs.setInt('minutes', response.profile!.minutes);
          if (response.profile!.profilePhotoPath != null) {
            await prefs.setString(
                'profile_photo', response.profile!.profilePhotoPath!);
          }
        }
      }

      return response;
    } on DioException catch (e) {
      // Extract API error message if available
      final serverMessage = e.response?.data?['message'];
      throw Exception(
          serverMessage ?? 'فشل تسجيل الدخول. تحقق من بياناتك وحاول مجدداً');
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع. حاول مجدداً');
    }
  }
}

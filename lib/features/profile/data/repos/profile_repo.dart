import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/profile_api.dart';
import '../models/profile_models.dart';

class ProfileRepo {
  final ProfileApi _profileApi;

  ProfileRepo(this._profileApi);

  /// Fetch teacher profile from API
  Future<ProfileResponse> getProfile() async {
    try {
      return await _profileApi.getProfile();
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'];
      throw Exception(serverMessage ?? 'فشل جلب بيانات الملف الشخصي');
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع');
    }
  }

  /// Logout — clear saved token and user data
  Future<void> logout() async {
    try {
      await _profileApi.logout();
    } catch (_) {
      // Even if API call fails, clear local data
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    }
  }
}

import 'package:dio/dio.dart';
import '../../../../core/networking/api_constants.dart';
import '../models/profile_models.dart';

class ProfileApi {
  final Dio _dio;

  ProfileApi(this._dio);

  /// GET /teacher/profile — requires Bearer token (added by auth interceptor)
  Future<ProfileResponse> getProfile() async {
    final response = await _dio.get(ApiConstants.teacherProfile);
    return ProfileResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// POST /teacher/logout — requires Bearer token
  Future<Map<String, dynamic>> logout() async {
    final response = await _dio.post(ApiConstants.teacherLogout);
    return response.data as Map<String, dynamic>;
  }
}

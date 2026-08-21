import 'package:dio/dio.dart';
import '../../../../core/networking/api_constants.dart';
import '../models/models.dart';

class LoginApi {
  final Dio _dio;

  LoginApi(this._dio);

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiConstants.teacherLogin,
      data: {
        'email': email,
        'password': password,
      },
    );
    return LoginResponse.fromJson(response.data as Map<String, dynamic>);
  }
}

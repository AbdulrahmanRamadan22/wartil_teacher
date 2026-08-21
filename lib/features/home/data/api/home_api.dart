import 'package:dio/dio.dart';
import '../../../../core/networking/api_constants.dart';
import '../models/home_models.dart';

class HomeApi {
  final Dio _dio;

  HomeApi(this._dio);

  Future<ToggleOnlineResponse> toggleOnline() async {
    final response = await _dio.post(ApiConstants.teacherToggleOnline);
    return ToggleOnlineResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<dynamic> getSoon() async {
    final response = await _dio.get(ApiConstants.teacherSoon);
    return response.data;
  }
}

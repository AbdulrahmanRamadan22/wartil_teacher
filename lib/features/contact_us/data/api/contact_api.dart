import 'package:dio/dio.dart';
import '../../../../core/networking/api_constants.dart';
import '../models/contact_settings_model.dart';

class ContactApi {
  final Dio _dio;

  ContactApi(this._dio);

  Future<ContactSettingsResponse> getContactSettings() async {
    final response = await _dio.get(ApiConstants.teacherContactSettings);
    return ContactSettingsResponse.fromJson(
        response.data as Map<String, dynamic>);
  }
}

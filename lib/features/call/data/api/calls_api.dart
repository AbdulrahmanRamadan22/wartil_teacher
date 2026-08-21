import 'package:dio/dio.dart';
import 'package:waratel_app/core/networking/api_constants.dart';
import '../models/call_model.dart';

class CallsApi {
  final Dio _dio;

  CallsApi(this._dio);

  /// GET /teacher/calls
  Future<CallListResponse> getCalls({int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.teacherCalls,
      queryParameters: {'page': page},
    );
    return CallListResponse.fromJson(response.data);
  }

  /// GET /teacher/calls/{id}
  Future<CallDetailsResponse> getCallDetail(int callId) async {
    final response = await _dio.get(ApiConstants.teacherCallDetail(callId));
    return CallDetailsResponse.fromJson(response.data);
  }

  /// POST /teacher/call/{id}/join
  Future<JoinCallResponse> joinCall(int callId) async {
    final response = await _dio.post(ApiConstants.teacherJoinCall(callId));
    return JoinCallResponse.fromJson(response.data);
  }

  /// POST /teacher/call/{id}/end
  Future<EndCallResponse> endCall(int callId) async {
    final response = await _dio.post(ApiConstants.teacherEndCall(callId));
    return EndCallResponse.fromJson(response.data);
  }
}

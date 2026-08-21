import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:waratel_app/features/ratings/data/models/session_model.dart';
import 'package:waratel_app/core/networking/api_constants.dart';

part 'sessions_api.g.dart';

@RestApi()
abstract class SessionsApi {
  factory SessionsApi(Dio dio, {String baseUrl}) = _SessionsApi;

  /// GET /teacher/sessions/my-sessions
  @GET(ApiConstants.teacherMySessions)
  Future<SessionsResponse> getMySessions();

  /// POST /teacher/sessions/{id}/start
  @POST('teacher/sessions/{id}/start')
  Future<StartSessionResponse> startSession(@Path('id') int sessionId);

  /// POST /teacher/sessions/{id}/end
  @POST('teacher/sessions/{id}/end')
  Future<EndSessionResponse> endSession(@Path('id') int sessionId);

  /// GET /teacher/sessions/{id}/attendance
  @GET('teacher/sessions/{id}/attendance')
  Future<AttendanceResponse> getAttendance(@Path('id') int sessionId);
}

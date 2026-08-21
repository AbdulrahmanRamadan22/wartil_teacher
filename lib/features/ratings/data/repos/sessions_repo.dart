import 'package:waratel_app/core/networking/base_repository.dart';
import '../api/sessions_api.dart';
import '../models/session_model.dart';

class SessionsRepo extends BaseRepository {
  final SessionsApi _api;

  SessionsRepo(this._api);

  Future<List<SessionItem>> getMySessions() async {
    final response = await handleApiCall(() => _api.getMySessions());
    return response.data.sessions;
  }

  Future<SessionsResponse> getSessionsResponse() async {
    return handleApiCall(() => _api.getMySessions());
  }

  Future<StartSessionData> startSession(int sessionId) async {
    final response = await handleApiCall(() => _api.startSession(sessionId));
    return response.data;
  }

  Future<bool> endSession(int sessionId) async {
    final response = await handleApiCall(() => _api.endSession(sessionId));
    return response.status;
  }

  Future<AttendanceResponse> getAttendance(int sessionId) async {
    return handleApiCall(() => _api.getAttendance(sessionId));
  }
}

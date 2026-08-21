import 'package:waratel_app/core/networking/base_repository.dart';
import 'package:waratel_app/features/ratings/data/api/sessions_api.dart'; // Redirecting to sessions_api if needed or restoring original
import 'package:waratel_app/features/ratings/data/models/session_model.dart';

class QuranRecitationRepo extends BaseRepository {
  final SessionsApi _sessionsApi;

  QuranRecitationRepo(this._sessionsApi);

  Future<List<SessionItem>> getAvailableSessions() async {
    return handleApiCall(() async {
      final response = await _sessionsApi.getMySessions();
      return response.data.sessions;
    });
  }

  Future<StartSessionData> joinSession(int id) async {
    return handleApiCall(() async {
      final response = await _sessionsApi.startSession(id);
      return response.data;
    });
  }

  Future<EndSessionResponse> leaveSession(int id) async {
    return handleApiCall(() async {
      return await _sessionsApi.endSession(id);
    });
  }
}

import 'package:waratel_app/core/networking/base_repository.dart';
import '../api/calls_api.dart';
import '../models/call_model.dart';

class CallsRepo extends BaseRepository {
  final CallsApi _api;

  CallsRepo(this._api);

  Future<CallListResponse> getCalls({int page = 1}) async {
    return handleApiCall(() => _api.getCalls(page: page));
  }

  Future<CallDetailsResponse> getCallDetail(int callId) async {
    return handleApiCall(() => _api.getCallDetail(callId));
  }

  Future<JoinCallResponse> joinCall(int callId) async {
    return handleApiCall(() => _api.joinCall(callId));
  }

  Future<EndCallResponse> endCall(int callId) async {
    return handleApiCall(() => _api.endCall(callId));
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repo/quran_recitation_repo.dart';
import 'quran_recitation_state.dart';
import 'package:waratel_app/features/ratings/data/models/session_model.dart';

class QuranRecitationCubit extends Cubit<QuranRecitationState> {
  final QuranRecitationRepo _repo;

  QuranRecitationCubit(this._repo) : super(QuranRecitationInitial());

  List<SessionItem> sessions = [];
  bool isLoaded = false;
  int? lastJoinedSessionId;

  Future<void> getSessions({bool isRefresh = false}) async {
    if (!isRefresh && isLoaded) return;

    emit(GetSessionsLoading());
    try {
      sessions = await _repo.getAvailableSessions();
      isLoaded = true;
      emit(GetSessionsSuccess(sessions));
    } catch (e) {
      emit(GetSessionsFailure(e.toString()));
    }
  }

  Future<void> joinSession(int id) async {
    lastJoinedSessionId = id;
    emit(JoinSessionLoading());

    try {
      final response = await _repo.joinSession(id);
      emit(JoinSessionSuccess(response, sessions));
    } catch (e) {
      emit(JoinSessionFailure(e.toString()));
    }
  }

  Future<void> leaveSession(int id) async {
    emit(LeaveSessionLoading());

    try {
      final response = await _repo.leaveSession(id);
      emit(LeaveSessionSuccess(response, sessions));
      getSessions(isRefresh: true);
    } catch (e) {
      emit(LeaveSessionFailure(e.toString()));
    }
  }
}

import 'package:waratel_app/features/ratings/data/models/session_model.dart';

abstract class QuranRecitationState {
  const QuranRecitationState();
}

class QuranRecitationInitial extends QuranRecitationState {}

class GetSessionsLoading extends QuranRecitationState {}

class GetSessionsSuccess extends QuranRecitationState {
  final List<SessionItem> sessions;
  const GetSessionsSuccess(this.sessions);
}

class GetSessionsFailure extends QuranRecitationState {
  final String error;
  const GetSessionsFailure(this.error);
}

class JoinSessionLoading extends QuranRecitationState {}

class JoinSessionSuccess extends QuranRecitationState {
  final StartSessionData response;
  final List<SessionItem> sessions;
  const JoinSessionSuccess(this.response, this.sessions);
}

class JoinSessionFailure extends QuranRecitationState {
  final String error;
  const JoinSessionFailure(this.error);
}

class LeaveSessionLoading extends QuranRecitationState {}

class LeaveSessionSuccess extends QuranRecitationState {
  final EndSessionResponse response;
  final List<SessionItem> sessions;
  const LeaveSessionSuccess(this.response, this.sessions);
}

class LeaveSessionFailure extends QuranRecitationState {
  final String error;
  const LeaveSessionFailure(this.error);
}

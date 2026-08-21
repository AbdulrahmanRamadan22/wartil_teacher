abstract class CallState {}

class CallInitial extends CallState {}

class CallLoading extends CallState {}

class CallLoaded extends CallState {}

class CallError extends CallState {
  final String message;
  CallError(this.message);
}

class CallTogglesUpdated extends CallState {
  final bool isMicOn;
  final bool isCamOn;
  final bool isMushafOpen;
  final bool isSpeakerOn;

  CallTogglesUpdated({
    required this.isMicOn,
    required this.isCamOn,
    required this.isMushafOpen,
    required this.isSpeakerOn,
  });
}

class CallTimerUpdated extends CallState {
  final String duration;
  CallTimerUpdated(this.duration);
}

class CallRemoteUserJoined extends CallState {
  final int uid;
  CallRemoteUserJoined(this.uid);
}

class CallRemoteUserLeft extends CallState {
  final int uid;
  CallRemoteUserLeft(this.uid);
}

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/agora/agora_service.dart';
import '../../data/repos/calls_repo.dart';
import 'call_state.dart';

class CallCubit extends Cubit<CallState> {
  final AgoraService _agoraService;
  final CallsRepo _callsRepo;

  CallCubit(this._agoraService, this._callsRepo) : super(CallInitial());

  bool isMicOn = true;
  bool isCamOn = false; // ← مغلقة افتراضياً كما طلب المستخدم
  bool isSpeakerOn =
      true; // ← مكبر الصوت يعمل افتراضياً عادة في المكالات الجماعية/الفيديو
  bool isMushafOpen = false;
  Timer? _timer;
  int _secondsElapsed = 0;

  int? remoteUid;
  int? callId;

  String get currentDurationString => _formatDuration(_secondsElapsed);

  Future<void> joinAndStartCall(int callId) async {
    this.callId = callId;

    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    if (statuses[Permission.camera] != PermissionStatus.granted ||
        statuses[Permission.microphone] != PermissionStatus.granted) {
      if (!isClosed) {
        emit(CallError('يرجى منح صلاحيات الكاميرا والميكروفون للمتابعة'));
      }
      return;
    }

    if (!isClosed) emit(CallLoading());

    try {
      final response = await _callsRepo.joinCall(callId);

      if (response.status && response.data != null) {
        _setupAgoraHandlers();

        await _agoraService.joinChannel(
          token: response.data!.agoraToken,
          channelName: response.data!.channelName,
          uid: response.data!.uid,
        );

        // تأكيد حالة الكاميرا عند البدء (مغلقة كما في الـ State)
        await _agoraService.enableLocalVideo(isCamOn);

        _startTimer();
        if (!isClosed) {
          emit(CallLoaded());
          emitToggles();
        }
      } else {
        if (!isClosed) emit(CallError(response.message));
      }
    } catch (e) {
      if (!isClosed) emit(CallError(e.toString()));
    }
  }

  // Obsolete - Keeping for backwards compatibility if needed elsewhere temporarily
  Future<void> startCall({
    required String token,
    required String channelName,
    required int uid,
    int? callId,
  }) async {
    this.callId = callId;
    // ... rest of archaic implementation ...
  }

  void _setupAgoraHandlers() {
    _agoraService.onUserJoined = (uid) {
      remoteUid = uid;
      emit(CallLoaded()); // Refresh to show remote video
      emit(CallRemoteUserJoined(uid));
    };

    _agoraService.onUserLeft = (uid) {
      if (remoteUid == uid) {
        remoteUid = null;
        emit(CallLoaded());
        emit(CallRemoteUserLeft(uid));
      }
    };
  }

  void toggleMic() {
    isMicOn = !isMicOn;
    _agoraService.muteLocalMic(!isMicOn);
    emitToggles();
  }

  Future<void> toggleCam() async {
    isCamOn = !isCamOn;
    _agoraService.enableLocalVideo(isCamOn);
    emitToggles();
  }

  void toggleMushaf() {
    isMushafOpen = !isMushafOpen;
    emitToggles();
  }

  void toggleSpeaker() {
    isSpeakerOn = !isSpeakerOn;
    _agoraService.setEnableSpeakerphone(isSpeakerOn);
    emitToggles();
  }

  void emitToggles() {
    emit(CallTogglesUpdated(
      isMicOn: isMicOn,
      isCamOn: isCamOn,
      isMushafOpen: isMushafOpen,
      isSpeakerOn: isSpeakerOn,
    ));
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsElapsed = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _secondsElapsed++;
      emit(CallTimerUpdated(_formatDuration(_secondsElapsed)));
    });
  }

  String _formatDuration(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> endCall() async {
    _timer?.cancel();
    await _agoraService.leaveChannel();
    if (callId != null) {
      try {
        await _callsRepo.endCall(callId!);
      } catch (e) {
        // print('Error ending call on server: $e');
      }
    }
    _resetAgoraHandlers();
  }

  void _resetAgoraHandlers() {
    _agoraService.onUserJoined = null;
    _agoraService.onUserLeft = null;
  }

  @override
  Future<void> close() async {
    _timer?.cancel();
    await _agoraService.leaveChannel();
    _resetAgoraHandlers();
    return super.close();
  }
}

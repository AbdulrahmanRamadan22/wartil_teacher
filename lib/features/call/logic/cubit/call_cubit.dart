import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/agora/agora_service.dart';
import '../../../../core/call/call_service.dart';
import 'package:waratel_app/features/bookings/domain/repos/i_bookings_repo.dart';
import '../../data/repos/calls_repo.dart';
import 'call_state.dart';

class CallCubit extends Cubit<CallState> {
  final AgoraService _agoraService;
  final CallsRepo _callsRepo;
  final IBookingsRepo _bookingsRepo;

  CallCubit(
    this._agoraService,
    this._callsRepo,
    this._bookingsRepo,
  ) : super(CallInitial());

  bool isMicOn = true;
  bool isCamOn = false; // ← مغلقة افتراضياً كما طلب المستخدم
  bool isSpeakerOn =
      true; // ← مكبر الصوت يعمل افتراضياً عادة في المكالمات
  bool isMushafOpen = false;
  Timer? _timer;
  Timer? _statusCheckTimer;
  int _secondsElapsed = 0;
  bool _isEnding = false;

  int? remoteUid;
  int? callId;        // الـ call_session_id الحقيقي على السيرفر
  int? studentId;

  String get currentDurationString => _formatDuration(_secondsElapsed);

  Future<void> joinAndStartCall(int callId, {int? studentId}) async {
    this.callId = callId;
    this.studentId = studentId;
    _isEnding = false;

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
        _setupPusherListener();

        if ((this.studentId == null || this.studentId == 0) && callId > 0) {
          _callsRepo.getCallDetail(callId).then((detail) {
            if (detail.status && detail.data.student.id > 0) {
              this.studentId = detail.data.student.id;
              debugPrint(
                  '🧑 [CALL_CUBIT] Retrieved student ID: ${this.studentId}');
            }
          }).catchError((e) {
            debugPrint('⚠️ [CALL_CUBIT] Failed to fetch call details: $e');
          });
        }

        await _agoraService.joinChannel(
          token: response.data!.agoraToken,
          channelName: response.data!.channelName,
          uid: response.data!.uid,
        );

        await _agoraService.enableLocalVideo(isCamOn);

        _startTimer();
        _startStatusCheckTimer(callId);

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

  bool isBookingCall = false;

  /// يُستخدم عندما يكون لدينا Token جاهز مسبقاً (مثل تدفق Bookings /start)
  /// لا يُستدعى /join لأن Token أُعطي مباشرة من السيرفر
  Future<void> startWithToken({
    required String token,
    required String channelName,
    required int uid,
    required int callId,
    int? studentId,
  }) async {
    this.callId = callId;
    this.studentId = studentId;
    isBookingCall = true;
    _isEnding = false;

    // طلب صلاحيات الكاميرا والمايك — لكن مرة واحدة فقط
    try {
      final statuses = await [
        Permission.camera,
        Permission.microphone,
      ].request();

      if (statuses[Permission.microphone] != PermissionStatus.granted) {
        if (!isClosed) {
          emit(CallError('يرجى منح صلاحية الميكروفون للمتابعة'));
        }
        return;
      }
    } catch (e) {
      debugPrint('⚠️ [CALL_CUBIT] Permission request error: $e');
    }

    if (!isClosed) emit(CallLoading());

    try {
      _setupAgoraHandlers();
      _setupPusherListener();

      await _agoraService.joinChannel(
        token: token,
        channelName: channelName,
        uid: uid,
      );

      await _agoraService.enableLocalVideo(isCamOn);

      _startTimer();
      // لا نستدعي _startStatusCheckTimer في الحجوزات لأن callId هنا هو booking_id
      // ولا يمثل call_session_id في جدول المكالمات الفورية

      if (!isClosed) {
        emit(CallLoaded());
        emitToggles();
      }
    } catch (e) {
      if (!isClosed) emit(CallError(e.toString()));
    }
  }

  void _setupAgoraHandlers() {
    _agoraService.onUserJoined = (uid) {
      debugPrint('👥 [CALL_CUBIT] Remote user joined: $uid');
      remoteUid = uid;
      if (!isClosed && !_isEnding) {
        emit(CallLoaded());
        emit(CallRemoteUserJoined(uid));
      }
    };

    _agoraService.onUserLeft = (uid) {
      debugPrint(
          '👥 [CALL_CUBIT] Remote user left: $uid (current remoteUid: $remoteUid)');
      _handleRemoteUserLeft(uid);
    };
  }

  void _setupPusherListener() {
    CallService.onCallEndedByPeer = (endedCallId) {
      debugPrint(
          '🛑 [CALL_CUBIT] Received onCallEndedByPeer from Pusher: callId=$endedCallId');
      if (callId == null || endedCallId == 0 || callId == endedCallId) {
        _handleRemoteUserLeft(0);
      }
    };
  }

  void _startStatusCheckTimer(int callId) {
    _statusCheckTimer?.cancel();
    // فحص دوري خفيف كل 3 ثوان للتأكد من حالة المكالمة على السيرفر
    _statusCheckTimer =
        Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (isClosed || _isEnding) {
        timer.cancel();
        return;
      }
      try {
        final detail = await _callsRepo.getCallDetail(callId);
        if (detail.status) {
          final status = detail.data.status.toLowerCase();
          if (status == 'ended' ||
              status == 'completed' ||
              status == 'cancelled' ||
              status == 'canceled' ||
              status == 'rejected' ||
              status == 'finished') {
            debugPrint(
                '🛑 [CALL_CUBIT] Server reported call status as "$status". Ending call.');
            timer.cancel();
            _handleRemoteUserLeft(0);
          }
        }
      } catch (e) {
        // تجاهل أي خطأ مؤقت في الاتصال أثناء المكالمة
      }
    });
  }

  void _handleRemoteUserLeft(int uid) {
    if (_isEnding) return;
    _isEnding = true;
    debugPrint(
        '🛑 [CALL_CUBIT] Student ended the call or disconnected. Emitting CallRemoteUserLeft.');
    remoteUid = null;
    _timer?.cancel();
    _statusCheckTimer?.cancel();
    CallService.onCallEndedByPeer = null;

    if (!isClosed) {
      emit(CallRemoteUserLeft(uid));
    }
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
    if (isClosed) return;
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
      if (!isClosed && !_isEnding) {
        emit(CallTimerUpdated(_formatDuration(_secondsElapsed)));
      }
    });
  }

  String _formatDuration(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> endCall() async {
    _isEnding = true;
    _timer?.cancel();
    _statusCheckTimer?.cancel();
    CallService.onCallEndedByPeer = null;

    try {
      await _agoraService.leaveChannel();
    } catch (_) {}

    if (callId != null) {
      try {
        if (isBookingCall) {
          debugPrint(
              '🚀 [CALL CUBIT] Ending booking call with call_session_id: $callId');
          await _bookingsRepo.endBooking(callId!);
        } else {
          debugPrint(
              '🚀 [CALL CUBIT] Ending direct call with callId: $callId');
          await _callsRepo.endCall(callId!);
        }
      } catch (e) {
        debugPrint('⚠️ Error ending call on server: $e');
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
    _isEnding = true;
    _timer?.cancel();
    _statusCheckTimer?.cancel();
    CallService.onCallEndedByPeer = null;
    try {
      await _agoraService.leaveChannel();
    } catch (_) {}
    _resetAgoraHandlers();
    return super.close();
  }
}


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
  /// فحص السيرفر كـ Fallback فقط (المصدر الأساسي: Agora + Pusher)
  static const Duration _waitingPollInterval = Duration(seconds: 5);
  static const Duration _connectedPollInterval = Duration(seconds: 10);

  static const Set<String> _endedStatuses = {
    'ended',
    'missed',
    'completed',
    'cancelled',
    'canceled',
    'rejected',
    'finished',
  };

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
  bool isSpeakerOn = true; // ← مكبر الصوت يعمل افتراضياً عادة في المكالمات
  bool isMushafOpen = false;
  Timer? _timer;
  Timer? _statusCheckTimer;
  int _secondsElapsed = 0;

  bool _isEnding = false;
  bool _endCallRequested = false;
  bool _hasLeftChannel = false;
  bool _isCheckingStatus = false;
  int? _pollCallId;
  void Function(int)? _pusherCallback;

  int? remoteUid;
  int? callId; // الـ call_session_id الحقيقي على السيرفر
  int? studentId;

  String get currentDurationString => _formatDuration(_secondsElapsed);

  void _resetSessionFlags() {
    _isEnding = false;
    _endCallRequested = false;
    _hasLeftChannel = false;
    _isCheckingStatus = false;
    remoteUid = null;
  }

  Future<void> joinAndStartCall(int callId, {int? studentId}) async {
    this.callId = callId;
    this.studentId = studentId;
    _resetSessionFlags();

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

        if (await _leaveIfEndedDuringJoin()) return;

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
      _cleanupAfterFailedJoin();
      if (!isClosed) emit(CallError(e.toString()));
    }
  }

  bool isBookingCall = false;

  /// يُستخدم عندما يكون لدينا Token جاهز مسبقاً (مثل تدفق Bookings /start أو قبول المكالمة بعد /join)
  /// لا يُستدعى /join لأن Token أُعطي مباشرة من السيرفر
  Future<void> startWithToken({
    required String token,
    required String channelName,
    required int uid,
    required int callId,
    int? studentId,
    bool isBooking = false,
  }) async {
    this.callId = callId;
    this.studentId = studentId;
    isBookingCall = isBooking;
    _resetSessionFlags();

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

      if ((this.studentId == null || this.studentId == 0) &&
          callId > 0 &&
          !isBookingCall) {
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
        token: token,
        channelName: channelName,
        uid: uid,
      );

      if (await _leaveIfEndedDuringJoin()) return;

      await _agoraService.enableLocalVideo(isCamOn);

      _startTimer();
      if (!isBookingCall && callId > 0) {
        _startStatusCheckTimer(callId);
      }

      if (!isClosed) {
        emit(CallLoaded());
        emitToggles();
      }
    } catch (e) {
      _cleanupAfterFailedJoin();
      if (!isClosed) emit(CallError(e.toString()));
    }
  }

  /// لو المكالمة انتهت (call.ended / Agora) أثناء انضمامنا للقناة، نخرج منها فوراً.
  /// السبب: leaveChannel الأول بيتنفذ قبل اكتمال الانضمام فبيبقى بلا أثر،
  /// وبعدها joinChannel بيكمل ويسيب المعلم جوه القناة بعد انتهاء المكالمة.
  Future<bool> _leaveIfEndedDuringJoin() async {
    if (!_isEnding && !isClosed) return false;
    try {
      await _agoraService.leaveChannel();
    } catch (_) {}
    _hasLeftChannel = true;
    return true;
  }

  void _cleanupAfterFailedJoin() {
    _timer?.cancel();
    _stopStatusCheck();
    _clearPusherListener();
    _resetAgoraHandlers();
  }

  void _setupAgoraHandlers() {
    _agoraService.onUserJoined = (uid) {
      debugPrint('👥 [CALL_CUBIT] Remote user joined: $uid');
      remoteUid = uid;
      // الطالب دخل: نباعد فحص السيرفر (Fallback فقط)
      _scheduleStatusCheck();
      if (!isClosed && !_isEnding) {
        emit(CallLoaded());
        emit(CallRemoteUserJoined(uid));
      }
    };

    _agoraService.onUserLeft = (uid) {
      debugPrint(
          '👥 [CALL_CUBIT] Remote user left: $uid (current remoteUid: $remoteUid)');
      // تجاهل خروج أي UID غير الطالب الحالي
      if (uid != 0 && remoteUid != null && uid != remoteUid) return;
      _handleRemoteUserLeft(uid);
    };
  }

  void _setupPusherListener() {
    void callback(int endedCallId) {
      debugPrint(
          '🛑 [CALL_CUBIT] Received onCallEndedByPeer from Pusher: callId=$endedCallId');
      if (callId == null || endedCallId == 0 || callId == endedCallId) {
        _handleRemoteUserLeft(0);
      }
    }

    _pusherCallback = callback;
    CallService.onCallEndedByPeer = callback;
  }

  /// يمسح الـ callback فقط لو لسه بتاعنا (حتى لا نمسح callback كيوبت جديد)
  void _clearPusherListener() {
    if (identical(CallService.onCallEndedByPeer, _pusherCallback)) {
      CallService.onCallEndedByPeer = null;
    }
    _pusherCallback = null;
  }

  // ───────────────────────── Status check (Fallback) ─────────────────────────

  void _startStatusCheckTimer(int callId) {
    _pollCallId = callId;
    _scheduleStatusCheck();
  }

  /// يعيد جدولة الفحص بالمدة المناسبة:
  /// 5 ثوانٍ أثناء انتظار الطالب، 10 ثوانٍ بعد انضمامه.
  void _scheduleStatusCheck() {
    final id = _pollCallId;
    if (id == null || isClosed || _isEnding) return;

    _statusCheckTimer?.cancel();
    final interval =
        remoteUid != null ? _connectedPollInterval : _waitingPollInterval;
    _statusCheckTimer = Timer.periodic(interval, (_) => _checkCallStatus(id));
  }

  void _stopStatusCheck() {
    _statusCheckTimer?.cancel();
    _statusCheckTimer = null;
    _pollCallId = null;
  }

  Future<void> _checkCallStatus(int id) async {
    if (isClosed || _isEnding) {
      _stopStatusCheck();
      return;
    }
    // قفل: لا تُرسل طلب جديد والسابق لسه منتظر
    if (_isCheckingStatus) return;
    _isCheckingStatus = true;

    try {
      final detail = await _callsRepo.getCallDetail(id);
      if (isClosed || _isEnding) return;

      if (detail.status) {
        final status = detail.data.status.toLowerCase();
        if (_endedStatuses.contains(status)) {
          debugPrint(
              '🛑 [CALL_CUBIT] Server reported call status as "$status". Ending call.');
          _handleRemoteUserLeft(0);
        }
      }
    } catch (_) {
      // تجاهل أي خطأ مؤقت في الاتصال أثناء المكالمة
    } finally {
      _isCheckingStatus = false;
    }
  }

  // ───────────────────────────────────────────────────────────────────────────

  void _handleRemoteUserLeft(int uid) {
    if (_isEnding) return;
    _isEnding = true;
    debugPrint(
        '🛑 [CALL_CUBIT] Student ended the call or disconnected. Emitting CallRemoteUserLeft.');
    remoteUid = null;
    _timer?.cancel();
    _stopStatusCheck();
    _clearPusherListener();

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
    await _agoraService.enableLocalVideo(isCamOn);
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
    if (isClosed || _isEnding) return;
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

  /// leaveChannel مرة واحدة فقط (endCall + close ما يكررهاش)
  Future<void> _leaveChannelOnce() async {
    if (_hasLeftChannel) return;
    _hasLeftChannel = true;
    try {
      await _agoraService.leaveChannel();
    } catch (_) {}
  }

  Future<void> endCall() async {
    // منع الاستدعاء المزدوج (ضغطتين على زر الإنهاء مثلاً)
    if (_endCallRequested) return;
    _endCallRequested = true;

    _isEnding = true;
    _timer?.cancel();
    _stopStatusCheck();
    _clearPusherListener();
    _resetAgoraHandlers();

    await _leaveChannelOnce();

    if (callId != null) {
      try {
        if (isBookingCall) {
          debugPrint(
              '🚀 [CALL CUBIT] Ending booking call with call_session_id: $callId');
          await _bookingsRepo.endBooking(callId!);
        } else {
          debugPrint('🚀 [CALL CUBIT] Ending direct call with callId: $callId');
          await _callsRepo.endCall(callId!);
        }
      } catch (e) {
        debugPrint('⚠️ Error ending call on server: $e');
      }
    }
  }

  void _resetAgoraHandlers() {
    _agoraService.onUserJoined = null;
    _agoraService.onUserLeft = null;
  }

  @override
  Future<void> close() async {
    _isEnding = true;
    _timer?.cancel();
    _stopStatusCheck();
    _clearPusherListener();
    _resetAgoraHandlers();
    await _leaveChannelOnce();
    return super.close();
  }
}

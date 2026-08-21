import 'ratings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/agora/agora_service.dart';
import '../../../record/logic/cubit/record_cubit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:waratel_app/features/ratings/data/repos/sessions_repo.dart';
import 'package:intl/intl.dart';
import 'package:waratel_app/features/ratings/data/models/session_model.dart';
import '../../../record/data/models/session_model.dart' as record_model;

class RatingsCubit extends Cubit<RatingsState> {
  final SessionsRepo _sessionsRepo;
  final AgoraService _agoraService;
  final RecordCubit _recordCubit;

  RatingsCubit(this._sessionsRepo, this._agoraService, this._recordCubit)
      : super(RatingsInitial());

  List<SessionItem> _sessions = [];
  SessionItem? _activeSession;

  Future<void> checkStatus() async {
    emit(RatingsLoading());
    try {
      _sessions = await _sessionsRepo.getMySessions();

      // Determine if within active time (Simulated: Always active or logic based on business rules)
      bool isActiveTime = true;
      bool hasPermission = true;

      emit(RatingsLoaded(
        sessions: _sessions,
        isMaqraaActiveTime: isActiveTime,
        hasPermission: hasPermission,
      ));
    } catch (e) {
      emit(RatingsError(e.toString()));
    }
  }

  Future<void> startMaqraa(SessionItem session) async {
    // Request permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    if (statuses[Permission.camera] != PermissionStatus.granted ||
        statuses[Permission.microphone] != PermissionStatus.granted) {
      emit(RatingsError('يرجى منح صلاحيات الكاميرا والميكروفون للمتابعة'));
      return;
    }

    emit(RatingsLoading());
    try {
      final data = await _sessionsRepo.startSession(session.id);
      _activeSession = session;

      // Initialize and Join Agora
      if (session.title.contains('فيديو')) {
        // Checking for video based on title or model if available
        await _agoraService.joinChannel(
          token: data.agoraToken,
          channelName: data.channelName,
          uid: data.uid,
        );
      } else {
        await _agoraService.joinAudioChannel(
          token: data.agoraToken,
          channelName: data.channelName,
          uid: data.uid,
        );
      }

      emit(RatingsSessionStarted(
        session: session,
        agoraData: data,
      ));
    } catch (e) {
      emit(RatingsError(e.toString()));
    }
  }

  Future<void> endMaqraa() async {
    if (_activeSession == null) return;

    emit(RatingsLoading());
    try {
      await _sessionsRepo.endSession(_activeSession!.id);
      await _agoraService.leaveChannel();

      final session = _activeSession!;
      _activeSession = null;

      emit(RatingsSessionEnded(
        session: session,
        message: "تم إنهاء الجلسة بنجاح",
      ));
      await checkStatus();
    } catch (e) {
      emit(RatingsError("فشل إنهاء الجلسة: ${e.toString()}"));
    }
  }

  Future<void> endMaqraaWithReport({
    required Map<int, bool> attendance,
    required String notes,
  }) async {
    if (_activeSession == null) return;

    emit(RatingsLoading());
    try {
      final sessionItem = _activeSession!;

      // 1. End on server
      await _sessionsRepo.endSession(sessionItem.id);

      // 2. Leave Agora
      await _agoraService.leaveChannel();

      // 3. Save to local RecordCubit for history
      final now = DateTime.now();
      int presentCount = attendance.values.where((v) => v).length;

      final record = record_model.SessionModel(
        studentName: sessionItem.title, // Use title as name for group sessions
        date: DateFormat('yyyy-M-d').format(now),
        time: DateFormat.jm().format(now),
        duration: '--:--', // Duration for group sessions not currently tracked
        trackName: 'حلقة جماعية',
        status: 'مكتملة',
        notes: notes.isNotEmpty
            ? notes
            : 'حضور: $presentCount/${attendance.length} من الطلاب',
        nextAssignment: '',
        rating: 'ممتاز',
        isPresent: true,
      );
      _recordCubit.addSession(record);

      _activeSession = null;

      emit(RatingsSessionEnded(
        session: sessionItem,
        message: "تم حفظ التحضير وإنهاء المقرأة بنجاح",
      ));

      await checkStatus();
    } catch (e) {
      emit(RatingsError("فشل حفظ التقرير: ${e.toString()}"));
    }
  }

  Future<void> loadAttendance(int sessionId) async {
    try {
      final attendance = await _sessionsRepo.getAttendance(sessionId);
      emit(RatingsAttendanceLoaded(attendance: attendance));
    } catch (e) {
      emit(RatingsError("فشل جلب قائمة الحضور: ${e.toString()}"));
    }
  }

  // Camera/Mic toggles via AgoraService
  Future<void> toggleMic(bool isMuted) async {
    await _agoraService.muteLocalMic(isMuted);
  }

  Future<void> toggleCamera(bool isOff) async {
    await _agoraService.enableLocalVideo(!isOff);
  }

  @override
  Future<void> close() {
    _agoraService.dispose();
    return super.close();
  }
}

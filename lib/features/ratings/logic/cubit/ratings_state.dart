import 'package:flutter/material.dart';
import '../../data/models/maqraa_model.dart';
import '../../data/models/session_model.dart';

@immutable
abstract class RatingsState {}

class RatingsInitial extends RatingsState {}

class RatingsLoading extends RatingsState {}

/// الحالة الرئيسية: قائمة الجلسات
class RatingsLoaded extends RatingsState {
  final List<SessionItem> sessions;
  final bool isMaqraaActiveTime;
  final bool hasPermission;
  final MaqraaModel? ongoingMaqraa; // الجلسة التي يتم بثها الآن في الغرفة

  RatingsLoaded({
    required this.sessions,
    required this.isMaqraaActiveTime,
    required this.hasPermission,
    this.ongoingMaqraa,
  });
}

/// تم الانضمام للقناة بنجاح وجاهز للبث
class RatingsSessionStarted extends RatingsState {
  final SessionItem session;
  final StartSessionData agoraData;

  RatingsSessionStarted({
    required this.session,
    required this.agoraData,
  });
}

/// تم إنهاء الجلسة بنجاح
class RatingsSessionEnded extends RatingsState {
  final SessionItem session;
  final String message;

  RatingsSessionEnded({required this.session, required this.message});
}

class RatingsAttendanceLoaded extends RatingsState {
  final AttendanceResponse attendance;
  RatingsAttendanceLoaded({required this.attendance});
}

class RatingsError extends RatingsState {
  final String message;
  RatingsError(this.message);
}

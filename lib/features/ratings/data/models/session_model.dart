import 'package:json_annotation/json_annotation.dart';

part 'session_model.g.dart';

// ─────────────────────────────────────────────
// Response: GET /teacher/sessions/my-sessions
// ─────────────────────────────────────────────

@JsonSerializable(createToJson: false)
class SessionsResponse {
  final bool status;
  final String message;
  final SessionsPaginatedData data;

  SessionsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory SessionsResponse.fromJson(Map<String, dynamic> json) =>
      _$SessionsResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
class SessionsPaginatedData {
  @JsonKey(name: 'data')
  final List<SessionItem> sessions;
  final int? total;

  SessionsPaginatedData({required this.sessions, this.total});

  factory SessionsPaginatedData.fromJson(Map<String, dynamic> json) =>
      _$SessionsPaginatedDataFromJson(json);
}

@JsonSerializable(createToJson: false)
class SessionItem {
  final int id;
  final String title;
  final String? description;

  @JsonKey(name: 'channel_name')
  final String channelName;

  @JsonKey(name: 'start_at')
  final String startAt;

  @JsonKey(name: 'end_at')
  final String endAt;

  @JsonKey(name: 'duration_minutes')
  final int durationMinutes;

  @JsonKey(name: 'max_participants')
  final int maxParticipants;

  /// scheduled | ongoing | ended
  final String status;

  @JsonKey(name: 'is_teacher_joined')
  final int isTeacherJoined;

  final SessionTeacher? teacher;

  SessionItem({
    required this.id,
    required this.title,
    this.description,
    required this.channelName,
    required this.startAt,
    required this.endAt,
    required this.durationMinutes,
    required this.maxParticipants,
    required this.status,
    required this.isTeacherJoined,
    this.teacher,
  });

  factory SessionItem.fromJson(Map<String, dynamic> json) =>
      _$SessionItemFromJson(json);

  DateTime get startTime => DateTime.parse(startAt);
  DateTime get endTime => DateTime.parse(endAt);
  bool get isActive => status == 'ongoing' || status == 'scheduled';
  bool get isEnded => status == 'ended';
}

@JsonSerializable(createToJson: false)
class SessionTeacher {
  final int id;

  @JsonKey(name: 'profile_photo_path')
  final String? profilePhotoPath;

  final SessionUser? user;

  SessionTeacher({required this.id, this.profilePhotoPath, this.user});

  factory SessionTeacher.fromJson(Map<String, dynamic> json) =>
      _$SessionTeacherFromJson(json);
}

@JsonSerializable(createToJson: false)
class SessionUser {
  final int id;
  final String name;
  final String email;
  final String role;

  SessionUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory SessionUser.fromJson(Map<String, dynamic> json) =>
      _$SessionUserFromJson(json);
}

// ─────────────────────────────────────────────
// Response: POST /teacher/sessions/{id}/start
// ─────────────────────────────────────────────

@JsonSerializable(createToJson: false)
class StartSessionResponse {
  final bool status;
  final String message;
  final StartSessionData data;

  StartSessionResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory StartSessionResponse.fromJson(Map<String, dynamic> json) =>
      _$StartSessionResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
class StartSessionData {
  @JsonKey(name: 'agora_token')
  final String agoraToken;

  @JsonKey(name: 'channel_name')
  final String channelName;

  @JsonKey(name: 'app_id')
  final String appId;

  final int uid;
  final String role;

  @JsonKey(name: 'is_recording')
  final bool isRecording;

  StartSessionData({
    required this.agoraToken,
    required this.channelName,
    required this.appId,
    required this.uid,
    required this.role,
    required this.isRecording,
  });

  factory StartSessionData.fromJson(Map<String, dynamic> json) =>
      _$StartSessionDataFromJson(json);
}

// ─────────────────────────────────────────────
// Response: POST /teacher/sessions/{id}/end
// ─────────────────────────────────────────────

@JsonSerializable(createToJson: false)
class EndSessionResponse {
  final bool status;
  final String message;
  final EndSessionSummary? summary;

  EndSessionResponse(
      {required this.status, required this.message, this.summary});

  factory EndSessionResponse.fromJson(Map<String, dynamic> json) =>
      _$EndSessionResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
class EndSessionSummary {
  @JsonKey(name: 'ended_at')
  final String? endedAt;

  @JsonKey(name: 'recording_url')
  final String? recordingUrl;

  EndSessionSummary({this.endedAt, this.recordingUrl});

  factory EndSessionSummary.fromJson(Map<String, dynamic> json) =>
      _$EndSessionSummaryFromJson(json);
}

// ─────────────────────────────────────────────
// Response: GET /teacher/sessions/{id}/attendance
// ─────────────────────────────────────────────

@JsonSerializable(createToJson: false)
class AttendanceResponse {
  final bool status;
  final String message;

  @JsonKey(name: 'session_title')
  final String? sessionTitle;

  final AttendanceSummary summary;

  final List<AttendanceStudent> data;

  AttendanceResponse({
    required this.status,
    required this.message,
    this.sessionTitle,
    required this.summary,
    required this.data,
  });

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) =>
      _$AttendanceResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
class AttendanceSummary {
  @JsonKey(name: 'total_students')
  final int totalStudents;

  @JsonKey(name: 'active_now')
  final int activeNow;

  AttendanceSummary({required this.totalStudents, required this.activeNow});

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) =>
      _$AttendanceSummaryFromJson(json);
}

@JsonSerializable(createToJson: false)
class AttendanceStudent {
  final int id;
  final String? name;

  AttendanceStudent({required this.id, this.name});

  factory AttendanceStudent.fromJson(Map<String, dynamic> json) =>
      _$AttendanceStudentFromJson(json);
}

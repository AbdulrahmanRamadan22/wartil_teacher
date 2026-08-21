// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionsResponse _$SessionsResponseFromJson(Map<String, dynamic> json) =>
    SessionsResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      data:
          SessionsPaginatedData.fromJson(json['data'] as Map<String, dynamic>),
    );

SessionsPaginatedData _$SessionsPaginatedDataFromJson(
        Map<String, dynamic> json) =>
    SessionsPaginatedData(
      sessions: (json['data'] as List<dynamic>)
          .map((e) => SessionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toInt(),
    );

SessionItem _$SessionItemFromJson(Map<String, dynamic> json) => SessionItem(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      channelName: json['channel_name'] as String,
      startAt: json['start_at'] as String,
      endAt: json['end_at'] as String,
      durationMinutes: (json['duration_minutes'] as num).toInt(),
      maxParticipants: (json['max_participants'] as num).toInt(),
      status: json['status'] as String,
      isTeacherJoined: (json['is_teacher_joined'] as num).toInt(),
      teacher: json['teacher'] == null
          ? null
          : SessionTeacher.fromJson(json['teacher'] as Map<String, dynamic>),
    );

SessionTeacher _$SessionTeacherFromJson(Map<String, dynamic> json) =>
    SessionTeacher(
      id: (json['id'] as num).toInt(),
      profilePhotoPath: json['profile_photo_path'] as String?,
      user: json['user'] == null
          ? null
          : SessionUser.fromJson(json['user'] as Map<String, dynamic>),
    );

SessionUser _$SessionUserFromJson(Map<String, dynamic> json) => SessionUser(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );

StartSessionResponse _$StartSessionResponseFromJson(
        Map<String, dynamic> json) =>
    StartSessionResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: StartSessionData.fromJson(json['data'] as Map<String, dynamic>),
    );

StartSessionData _$StartSessionDataFromJson(Map<String, dynamic> json) =>
    StartSessionData(
      agoraToken: json['agora_token'] as String,
      channelName: json['channel_name'] as String,
      appId: json['app_id'] as String,
      uid: (json['uid'] as num).toInt(),
      role: json['role'] as String,
      isRecording: json['is_recording'] as bool,
    );

EndSessionResponse _$EndSessionResponseFromJson(Map<String, dynamic> json) =>
    EndSessionResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      summary: json['summary'] == null
          ? null
          : EndSessionSummary.fromJson(json['summary'] as Map<String, dynamic>),
    );

EndSessionSummary _$EndSessionSummaryFromJson(Map<String, dynamic> json) =>
    EndSessionSummary(
      endedAt: json['ended_at'] as String?,
      recordingUrl: json['recording_url'] as String?,
    );

AttendanceResponse _$AttendanceResponseFromJson(Map<String, dynamic> json) =>
    AttendanceResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      sessionTitle: json['session_title'] as String?,
      summary:
          AttendanceSummary.fromJson(json['summary'] as Map<String, dynamic>),
      data: (json['data'] as List<dynamic>)
          .map((e) => AttendanceStudent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

AttendanceSummary _$AttendanceSummaryFromJson(Map<String, dynamic> json) =>
    AttendanceSummary(
      totalStudents: (json['total_students'] as num).toInt(),
      activeNow: (json['active_now'] as num).toInt(),
    );

AttendanceStudent _$AttendanceStudentFromJson(Map<String, dynamic> json) =>
    AttendanceStudent(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
    );

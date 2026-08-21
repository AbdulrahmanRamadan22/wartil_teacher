class CallModel {
  final int id;
  final String studentName;
  final String status;
  final int durationMinutes;
  final String date;
  final String time;
  final dynamic rating;
  final String? recordingUrl;

  CallModel({
    required this.id,
    required this.studentName,
    required this.status,
    required this.durationMinutes,
    required this.date,
    required this.time,
    this.rating,
    this.recordingUrl,
  });

  factory CallModel.fromJson(Map<String, dynamic> json) {
    return CallModel(
      id: json['id'] ?? 0,
      studentName: json['student_name'] ?? '',
      status: json['status'] ?? '',
      durationMinutes: json['duration_minutes'] ?? 0,
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      rating: json['rating'],
      recordingUrl: json['recording_url']?.toString(),
    );
  }
}

class CallListResponse {
  final bool status;
  final CallPagination data;

  CallListResponse({required this.status, required this.data});

  factory CallListResponse.fromJson(Map<String, dynamic> json) {
    return CallListResponse(
      status: json['status'] ?? false,
      data: CallPagination.fromJson(
          (json['data'] is Map<String, dynamic>) ? json['data'] : {}),
    );
  }
}

class CallPagination {
  final int currentPage;
  final List<CallModel> data;
  final int lastPage;
  final int total;

  CallPagination({
    required this.currentPage,
    required this.data,
    required this.lastPage,
    required this.total,
  });

  factory CallPagination.fromJson(Map<String, dynamic> json) {
    return CallPagination(
      currentPage: json['current_page'] ?? 1,
      data: (json['data'] as List? ?? [])
          .map((item) => CallModel.fromJson(item))
          .toList(),
      lastPage: json['last_page'] ?? 1,
      total: json['total'] ?? 0,
    );
  }
}

// ── Call Details Models ────────────────────────────────────────────────────────

class CallDetailsResponse {
  final bool status;
  final CallDetailInfo data;

  CallDetailsResponse({required this.status, required this.data});

  factory CallDetailsResponse.fromJson(Map<String, dynamic> json) {
    return CallDetailsResponse(
      status: json['status'] ?? false,
      data: CallDetailInfo.fromJson(
          (json['data'] is Map<String, dynamic>) ? json['data'] : {}),
    );
  }
}

class CallDetailInfo {
  final int callId;
  final String status;
  final CallStudent student;
  final CallSessionInfo sessionInfo;

  CallDetailInfo({
    required this.callId,
    required this.status,
    required this.student,
    required this.sessionInfo,
  });

  factory CallDetailInfo.fromJson(Map<String, dynamic> json) {
    return CallDetailInfo(
      callId: json['call_id'] ?? 0,
      status: json['status'] ?? '',
      student: CallStudent.fromJson(
          (json['student'] is Map<String, dynamic>) ? json['student'] : {}),
      sessionInfo: CallSessionInfo.fromJson(
          (json['session_info'] is Map<String, dynamic>)
              ? json['session_info']
              : {}),
    );
  }
}

class CallStudent {
  final int id;
  final String name;
  final String email;

  CallStudent({
    required this.id,
    required this.name,
    required this.email,
  });

  factory CallStudent.fromJson(Map<String, dynamic> json) {
    return CallStudent(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class CallSessionInfo {
  final String channel;
  final int durationMinutes;
  final int minutesAddedToWallet;
  final String? recordingUrl;
  final CallTiming timing;

  CallSessionInfo({
    required this.channel,
    required this.durationMinutes,
    required this.minutesAddedToWallet,
    this.recordingUrl,
    required this.timing,
  });

  factory CallSessionInfo.fromJson(Map<String, dynamic> json) {
    return CallSessionInfo(
      channel: json['channel'] ?? '',
      durationMinutes: json['duration_minutes'] ?? 0,
      minutesAddedToWallet: json['minutes_added_to_wallet'] ?? 0,
      recordingUrl: json['recording_url']?.toString(),
      timing: CallTiming.fromJson(
          (json['timing'] is Map<String, dynamic>) ? json['timing'] : {}),
    );
  }
}

class CallTiming {
  final String date;
  final String startedAt;
  final String? endedAt;

  CallTiming({
    required this.date,
    required this.startedAt,
    this.endedAt,
  });

  factory CallTiming.fromJson(Map<String, dynamic> json) {
    return CallTiming(
      date: json['date'] ?? '',
      startedAt: json['started_at'] ?? '',
      endedAt: json['ended_at']?.toString(),
    );
  }
}

// ── Join Call Models ───────────────────────────────────────────────────────────

class JoinCallResponse {
  final bool status;
  final String message;
  final JoinCallData? data;

  JoinCallResponse({required this.status, required this.message, this.data});

  factory JoinCallResponse.fromJson(Map<String, dynamic> json) {
    return JoinCallResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] is Map<String, dynamic>)
          ? JoinCallData.fromJson(json['data'])
          : null,
    );
  }
}

class JoinCallData {
  final String channelName;
  final String agoraToken;
  final int uid;

  JoinCallData({
    required this.channelName,
    required this.agoraToken,
    required this.uid,
  });

  factory JoinCallData.fromJson(Map<String, dynamic> json) {
    return JoinCallData(
      channelName: json['channel_name'] ?? '',
      agoraToken: json['agora_token'] ?? '',
      uid: json['uid'] ?? 0,
    );
  }
}

// ── End Call Models ────────────────────────────────────────────────────────────

class EndCallResponse {
  final bool status;
  final String message;

  EndCallResponse({required this.status, required this.message});

  factory EndCallResponse.fromJson(Map<String, dynamic> json) {
    return EndCallResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

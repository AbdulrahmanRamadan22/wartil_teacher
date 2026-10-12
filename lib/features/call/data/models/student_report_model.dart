class StudentReportRequest {
  final int studentId;
  final String reportableType; // 'call', 'slot', 'session'
  final int reportableId;
  final String attendanceStatus; // 'present', 'absent'
  final String? receptionLevel; // 'excellent', 'very_good', 'good', 'needs_follow_up'
  final String? notes;
  final String? sessionContent;

  const StudentReportRequest({
    required this.studentId,
    required this.reportableType,
    required this.reportableId,
    required this.attendanceStatus,
    this.receptionLevel,
    this.notes,
    this.sessionContent,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'student_id': studentId,
      'reportable_type': reportableType,
      'reportable_id': reportableId,
      'attendance_status': attendanceStatus,
    };

    if (receptionLevel != null && receptionLevel!.isNotEmpty) {
      data['reception_level'] = receptionLevel;
    }
    if (notes != null && notes!.isNotEmpty) {
      data['notes'] = notes;
    }
    if (sessionContent != null && sessionContent!.isNotEmpty) {
      data['session_content'] = sessionContent;
    }

    return data;
  }
}

class StudentReportResponse {
  final bool status;
  final String message;

  const StudentReportResponse({
    required this.status,
    required this.message,
  });

  factory StudentReportResponse.fromJson(Map<String, dynamic> json) {
    return StudentReportResponse(
      status: json['status'] == true,
      message: (json['message'] ?? '').toString(),
    );
  }
}

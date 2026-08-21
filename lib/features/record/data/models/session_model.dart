class SessionModel {
  final String studentName;
  final String date;
  final String time;
  final String duration;
  final String trackName;
  final String status;
  final String notes;
  final String nextAssignment;
  final String rating;
  final bool isPresent;

  SessionModel({
    required this.studentName,
    required this.date,
    required this.time,
    required this.duration,
    required this.trackName,
    required this.status,
    required this.notes,
    required this.nextAssignment,
    required this.rating,
    required this.isPresent,
  });

  Map<String, dynamic> toJson() {
    return {
      'studentName': studentName,
      'date': date,
      'time': time,
      'duration': duration,
      'trackName': trackName,
      'status': status,
      'notes': notes,
      'nextAssignment': nextAssignment,
      'rating': rating,
      'isPresent': isPresent,
    };
  }

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      studentName: json['studentName']?.toString() ?? 'Unknown',
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '00:00',
      trackName: json['trackName']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      nextAssignment: json['nextAssignment']?.toString() ?? '',
      rating: json['rating']?.toString() ?? '',
      isPresent: json['isPresent'] == true ||
          json['isPresent'] == 'true' ||
          json['isPresent'] == 1,
    );
  }
}

enum MaqraaType { audio, video }

class MaqraaModel {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final int capacity;
  final int attendeesCount;
  final MaqraaType type;
  final bool isRecording;
  final bool isTeacher; // If the current user is the teacher

  MaqraaModel({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    required this.attendeesCount,
    required this.type,
    this.isRecording = false,
    this.isTeacher = false,
  });

  MaqraaModel copyWith({
    String? id,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    int? capacity,
    int? attendeesCount,
    MaqraaType? type,
    bool? isRecording,
    bool? isTeacher,
  }) {
    return MaqraaModel(
      id: id ?? this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      capacity: capacity ?? this.capacity,
      attendeesCount: attendeesCount ?? this.attendeesCount,
      type: type ?? this.type,
      isRecording: isRecording ?? this.isRecording,
      isTeacher: isTeacher ?? this.isTeacher,
    );
  }
}

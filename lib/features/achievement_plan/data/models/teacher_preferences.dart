class TeacherPreferences {
  final Map<String, int> learningPaths;
  final Map<String, int> ageGroups;
  final Map<String, int> studentLevels;
  final int workHoursPerWeek;

  TeacherPreferences({
    required this.learningPaths,
    required this.ageGroups,
    required this.studentLevels,
    required this.workHoursPerWeek,
  });

  factory TeacherPreferences.empty() {
    return TeacherPreferences(
      learningPaths: {},
      ageGroups: {},
      studentLevels: {},
      workHoursPerWeek: 0,
    );
  }

  factory TeacherPreferences.fromJson(Map<String, dynamic> json) {
    return TeacherPreferences(
      learningPaths: Map<String, int>.from(json['learningPaths'] ?? {}),
      ageGroups: Map<String, int>.from(json['ageGroups'] ?? {}),
      studentLevels: Map<String, int>.from(json['studentLevels'] ?? {}),
      workHoursPerWeek: json['workHoursPerWeek'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'learningPaths': learningPaths,
      'ageGroups': ageGroups,
      'studentLevels': studentLevels,
      'workHoursPerWeek': workHoursPerWeek,
    };
  }

  TeacherPreferences copyWith({
    Map<String, int>? learningPaths,
    Map<String, int>? ageGroups,
    Map<String, int>? studentLevels,
    int? workHoursPerWeek,
  }) {
    return TeacherPreferences(
      learningPaths: learningPaths ?? this.learningPaths,
      ageGroups: ageGroups ?? this.ageGroups,
      studentLevels: studentLevels ?? this.studentLevels,
      workHoursPerWeek: workHoursPerWeek ?? this.workHoursPerWeek,
    );
  }
}

/// Track model — used in both Application and Profile response
class TrackModel {
  final int id;
  final String name;
  final String? icon;
  final String targetGroup;
  final String marketingValue;
  final String description;
  final String status;

  const TrackModel({
    required this.id,
    required this.name,
    this.icon,
    required this.targetGroup,
    required this.marketingValue,
    required this.description,
    required this.status,
  });

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
      id: json['id'] as int,
      name: json['name'].toString(),
      icon: json['icon'] as String?,
      targetGroup: json['target_group'].toString(),
      marketingValue: json['marketing_value'].toString(),
      description: json['description'].toString(),
      status: json['status'].toString(),
    );
  }
}

/// Teacher Application inside the profile
class TeacherApplication {
  final int id;
  final String fullName;
  final String gender;
  final String email;
  final String phone;
  final String originCountry;
  final String residenceLocation;
  final String? profilePhotoPath;
  final String qualification;
  final List<String> languages;
  final int experienceYears;
  final int workHours;
  final String onlineExperience;
  final String internetQuality;
  final String techSkills;
  final String ijazasText;
  final String? cvPdfPath;
  final String status;
  final List<TrackModel> tracks;

  const TeacherApplication({
    required this.id,
    required this.fullName,
    required this.gender,
    required this.email,
    required this.phone,
    required this.originCountry,
    required this.residenceLocation,
    this.profilePhotoPath,
    required this.qualification,
    required this.languages,
    required this.experienceYears,
    required this.workHours,
    required this.onlineExperience,
    required this.internetQuality,
    required this.techSkills,
    required this.ijazasText,
    this.cvPdfPath,
    required this.status,
    required this.tracks,
  });

  factory TeacherApplication.fromJson(Map<String, dynamic> json) {
    return TeacherApplication(
      id: json['id'] as int,
      fullName: json['full_name'].toString(),
      gender: json['gender'].toString(),
      email: json['email'].toString(),
      phone: json['phone'].toString(),
      originCountry: json['origin_country'].toString(),
      residenceLocation: json['residence_location'].toString(),
      profilePhotoPath: json['profile_photo_path'] as String?,
      qualification: json['qualification'].toString(),
      languages: (json['languages'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      experienceYears: json['experience_years'] as int,
      workHours: json['work_hours'] as int,
      onlineExperience: json['online_experience'].toString(),
      internetQuality: json['internet_quality'].toString(),
      techSkills: json['tech_skills'].toString(),
      ijazasText: json['ijazas_text'].toString(),
      cvPdfPath: json['cv_pdf_path'] as String?,
      status: json['status'].toString(),
      tracks: (json['tracks'] as List<dynamic>)
          .map((e) => TrackModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Detailed profile with application embedded
class TeacherProfileDetail {
  final int id;
  final int userId;
  final int teacherApplicationId;
  final int minutes;
  final String salary;
  final String? profilePhotoPath;
  final TeacherApplication? application;

  const TeacherProfileDetail({
    required this.id,
    required this.userId,
    required this.teacherApplicationId,
    required this.minutes,
    required this.salary,
    this.profilePhotoPath,
    this.application,
  });

  factory TeacherProfileDetail.fromJson(Map<String, dynamic> json) {
    return TeacherProfileDetail(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      teacherApplicationId: json['teacher_application_id'] as int,
      minutes: json['minutes'] as int,
      salary: json['salary'].toString(),
      profilePhotoPath: json['profile_photo_path'] as String?,
      application: json['application'] != null
          ? TeacherApplication.fromJson(
              json['application'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Simple user summary inside profile response
class ProfileUser {
  final int id;
  final String name;
  final String email;

  const ProfileUser({
    required this.id,
    required this.name,
    required this.email,
  });

  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
      id: json['id'] as int,
      name: json['name'].toString(),
      email: json['email'].toString(),
    );
  }
}

/// Full API response for GET /teacher/profile
class ProfileResponse {
  final bool status;
  final String message;
  final ProfileUser? user;
  final TeacherProfileDetail? profile;
  final List<TrackModel> tracks;

  const ProfileResponse({
    required this.status,
    required this.message,
    this.user,
    this.profile,
    required this.tracks,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return ProfileResponse(
      status: json['status'] as bool,
      message: json['message'].toString(),
      user: data['user'] != null
          ? ProfileUser.fromJson(data['user'] as Map<String, dynamic>)
          : null,
      profile: data['profile'] != null
          ? TeacherProfileDetail.fromJson(
              data['profile'] as Map<String, dynamic>)
          : null,
      tracks: (data['tracks'] as List<dynamic>? ?? [])
          .map((e) => TrackModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

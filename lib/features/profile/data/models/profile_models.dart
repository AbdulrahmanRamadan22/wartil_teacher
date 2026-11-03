/// Minutes breakdown by student nationality
class MinutesSpent {
  final int egyptianMinutes;
  final int arabMinutes;
  final int foreignMinutes;

  const MinutesSpent({
    this.egyptianMinutes = 0,
    this.arabMinutes = 0,
    this.foreignMinutes = 0,
  });

  int get total => egyptianMinutes + arabMinutes + foreignMinutes;

  factory MinutesSpent.fromJson(Map<String, dynamic> json) {
    return MinutesSpent(
      egyptianMinutes: json['egyptian_minutes'] as int? ?? 0,
      arabMinutes: json['arab_minutes'] as int? ?? 0,
      foreignMinutes: json['foreign_minutes'] as int? ?? 0,
    );
  }
}

/// Teacher Category model inside Profile Response
class TeacherCategory {
  final int id;
  final String name;
  final String egyptRate;
  final String arabRate;
  final String foreignRate;
  final String teacherRate;
  final String? createdAt;
  final String? updatedAt;

  const TeacherCategory({
    required this.id,
    required this.name,
    required this.egyptRate,
    required this.arabRate,
    required this.foreignRate,
    required this.teacherRate,
    this.createdAt,
    this.updatedAt,
  });

  factory TeacherCategory.fromJson(Map<String, dynamic> json) {
    return TeacherCategory(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
      egyptRate: json['egypt_rate']?.toString() ?? '0.00',
      arabRate: json['arab_rate']?.toString() ?? '0.00',
      foreignRate: json['foreign_rate']?.toString() ?? '0.00',
      teacherRate: json['teacher_rate']?.toString() ?? '0.00',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}

/// Track model — used in both Application and Profile response
class TrackModel {
  final int id;
  final String name;
  final String? icon;
  final String targetGroup;
  final String marketingValue;
  final String description;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  const TrackModel({
    required this.id,
    required this.name,
    this.icon,
    required this.targetGroup,
    required this.marketingValue,
    required this.description,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
      icon: json['icon'] as String?,
      targetGroup: json['target_group']?.toString() ?? '',
      marketingValue: json['marketing_value']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}

/// Teacher Application inside the profile (optional legacy/extended support)
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
      id: json['id'] as int? ?? 0,
      fullName: json['full_name']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      originCountry: json['origin_country']?.toString() ?? '',
      residenceLocation: json['residence_location']?.toString() ?? '',
      profilePhotoPath: json['profile_photo_path'] as String?,
      qualification: json['qualification']?.toString() ?? '',
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      experienceYears: json['experience_years'] as int? ?? 0,
      workHours: json['work_hours'] as int? ?? 0,
      onlineExperience: json['online_experience']?.toString() ?? '',
      internetQuality: json['internet_quality']?.toString() ?? '',
      techSkills: json['tech_skills']?.toString() ?? '',
      ijazasText: json['ijazas_text']?.toString() ?? '',
      cvPdfPath: json['cv_pdf_path'] as String?,
      status: json['status']?.toString() ?? '',
      tracks: (json['tracks'] as List<dynamic>?)
              ?.map((e) => TrackModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Detailed profile with category, balance, rating, and status
class TeacherProfileDetail {
  final int id;
  final int userId;
  final int teacherApplicationId;
  final int minutes;
  final String salary;
  final String? profilePhotoPath;
  final bool isOnline;
  final int? categoryId;
  final String balance;
  final double averageRating;
  final String? createdAt;
  final String? updatedAt;
  final TeacherApplication? application;

  const TeacherProfileDetail({
    required this.id,
    required this.userId,
    required this.teacherApplicationId,
    required this.minutes,
    required this.salary,
    this.profilePhotoPath,
    this.isOnline = false,
    this.categoryId,
    this.balance = '0.00',
    this.averageRating = 0.0,
    this.createdAt,
    this.updatedAt,
    this.application,
  });

  factory TeacherProfileDetail.fromJson(Map<String, dynamic> json) {
    return TeacherProfileDetail(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      teacherApplicationId: json['teacher_application_id'] as int? ?? 0,
      minutes: json['minutes'] as int? ?? 0,
      salary: json['salary']?.toString() ?? '0.00',
      profilePhotoPath: json['profile_photo_path'] as String?,
      isOnline: json['is_online'] == 1 || json['is_online'] == true,
      categoryId: json['category_id'] as int?,
      balance: json['balance']?.toString() ?? '0.00',
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
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
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }
}

/// Full API response for GET /teacher/profile
class ProfileResponse {
  final bool status;
  final String message;
  final ProfileUser? user;
  final TeacherProfileDetail? profile;
  final TeacherCategory? category;
  final List<TrackModel> tracks;
  final String? countryCode;
  final MinutesSpent? minutesSpent;

  const ProfileResponse({
    required this.status,
    required this.message,
    this.user,
    this.profile,
    this.category,
    required this.tracks,
    this.countryCode,
    this.minutesSpent,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return ProfileResponse(
      status: json['status'] as bool? ?? true,
      message: json['message']?.toString() ?? '',
      user: data['user'] != null
          ? ProfileUser.fromJson(data['user'] as Map<String, dynamic>)
          : null,
      profile: data['profile'] != null
          ? TeacherProfileDetail.fromJson(
              data['profile'] as Map<String, dynamic>)
          : null,
      category: data['category'] != null
          ? TeacherCategory.fromJson(
              data['category'] as Map<String, dynamic>)
          : null,
      tracks: (data['tracks'] as List<dynamic>? ?? [])
          .map((e) => TrackModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      countryCode: data['country_code']?.toString(),
      minutesSpent: data['minutes_spent'] != null
          ? MinutesSpent.fromJson(
              data['minutes_spent'] as Map<String, dynamic>)
          : null,
    );
  }
}

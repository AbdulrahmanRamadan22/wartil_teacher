class TeacherProfile {
  final int id;
  final int userId;
  final int teacherApplicationId;
  final int minutes;
  final String salary;
  final String? profilePhotoPath;
  final String createdAt;
  final String updatedAt;

  const TeacherProfile({
    required this.id,
    required this.userId,
    required this.teacherApplicationId,
    required this.minutes,
    required this.salary,
    this.profilePhotoPath,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TeacherProfile.fromJson(Map<String, dynamic> json) {
    return TeacherProfile(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      teacherApplicationId: json['teacher_application_id'] as int,
      minutes: json['minutes'] as int,
      salary: json['salary'].toString(),
      profilePhotoPath: json['profile_photo_path'] as String?,
      createdAt: json['created_at'].toString(),
      updatedAt: json['updated_at'].toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'teacher_application_id': teacherApplicationId,
        'minutes': minutes,
        'salary': salary,
        'profile_photo_path': profilePhotoPath,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}

class UserModel {
  final int id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final String role;
  final String createdAt;
  final String updatedAt;
  final TeacherProfile? teacherProfile;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.teacherProfile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'].toString(),
      email: json['email'].toString(),
      emailVerifiedAt: json['email_verified_at'] as String?,
      role: json['role'].toString(),
      createdAt: json['created_at'].toString(),
      updatedAt: json['updated_at'].toString(),
      teacherProfile: json['teacher_profile'] != null
          ? TeacherProfile.fromJson(
              json['teacher_profile'] as Map<String, dynamic>)
          : null,
    );
  }
}

class LoginResponse {
  final bool status;
  final String message;
  final UserModel? user;
  final TeacherProfile? profile;
  final String? token;

  const LoginResponse({
    required this.status,
    required this.message,
    this.user,
    this.profile,
    this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'] as bool,
      message: json['message'].toString(),
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      profile: json['profile'] != null
          ? TeacherProfile.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
      token: json['token'] as String?,
    );
  }
}

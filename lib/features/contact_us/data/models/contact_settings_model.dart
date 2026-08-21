class ContactSettingsResponse {
  final bool status;
  final ContactSettingsData data;

  ContactSettingsResponse({
    required this.status,
    required this.data,
  });

  factory ContactSettingsResponse.fromJson(Map<String, dynamic> json) {
    return ContactSettingsResponse(
      status: json['status'] ?? false,
      data: ContactSettingsData.fromJson(
          (json['data'] is Map<String, dynamic>) ? json['data'] : {}),
    );
  }
}

class ContactSettingsData {
  final String email;
  final String phone;

  ContactSettingsData({
    required this.email,
    required this.phone,
  });

  factory ContactSettingsData.fromJson(Map<String, dynamic> json) {
    return ContactSettingsData(
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}

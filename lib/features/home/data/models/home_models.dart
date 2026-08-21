class ToggleOnlineResponse {
  final bool status;
  final String message;
  final ToggleOnlineData data;

  ToggleOnlineResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ToggleOnlineResponse.fromJson(Map<String, dynamic> json) {
    return ToggleOnlineResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: ToggleOnlineData.fromJson(
          (json['data'] is Map<String, dynamic>) ? json['data'] : {}),
    );
  }
}

class ToggleOnlineData {
  final bool isOnline;

  ToggleOnlineData({required this.isOnline});

  factory ToggleOnlineData.fromJson(Map<String, dynamic> json) {
    return ToggleOnlineData(
      isOnline: json['is_online'] ?? false,
    );
  }
}

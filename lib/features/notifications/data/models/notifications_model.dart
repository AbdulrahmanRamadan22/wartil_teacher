import 'package:json_annotation/json_annotation.dart';

part 'notifications_model.g.dart';

@JsonSerializable(createToJson: false)
class NotificationsResponse {
  final bool status;
  final String message;
  final NotificationsData data;

  NotificationsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationsResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
class NotificationsData {
  @JsonKey(name: 'unread_count')
  final int unreadCount;
  final NotificationsPagination notifications;

  NotificationsData({
    required this.unreadCount,
    required this.notifications,
  });

  factory NotificationsData.fromJson(Map<String, dynamic> json) =>
      _$NotificationsDataFromJson(json);
}

@JsonSerializable(createToJson: false)
class NotificationsPagination {
  @JsonKey(name: 'current_page')
  final int currentPage;
  final List<NotificationModel> data;
  @JsonKey(name: 'last_page')
  final int lastPage;
  final int total;

  NotificationsPagination({
    required this.currentPage,
    required this.data,
    required this.lastPage,
    required this.total,
  });

  factory NotificationsPagination.fromJson(Map<String, dynamic> json) =>
      _$NotificationsPaginationFromJson(json);
}

@JsonSerializable(createToJson: false)
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final dynamic payload;
  @JsonKey(name: 'is_read')
  final bool isRead;
  @JsonKey(name: 'created_at')
  final String createdAt;
  final String date;
  final String time;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.payload,
    required this.isRead,
    required this.createdAt,
    required this.date,
    required this.time,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
}

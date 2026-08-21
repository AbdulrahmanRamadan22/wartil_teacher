// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationsResponse _$NotificationsResponseFromJson(
        Map<String, dynamic> json) =>
    NotificationsResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: NotificationsData.fromJson(json['data'] as Map<String, dynamic>),
    );

NotificationsData _$NotificationsDataFromJson(Map<String, dynamic> json) =>
    NotificationsData(
      unreadCount: (json['unread_count'] as num).toInt(),
      notifications: NotificationsPagination.fromJson(
          json['notifications'] as Map<String, dynamic>),
    );

NotificationsPagination _$NotificationsPaginationFromJson(
        Map<String, dynamic> json) =>
    NotificationsPagination(
      currentPage: (json['current_page'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastPage: (json['last_page'] as num).toInt(),
      total: (json['total'] as num).toInt(),
    );

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      payload: json['payload'],
      isRead: json['is_read'] as bool,
      createdAt: json['created_at'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
    );

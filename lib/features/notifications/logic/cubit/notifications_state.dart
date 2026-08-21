import 'package:flutter/foundation.dart';
import '../../data/models/notifications_model.dart';

@immutable
abstract class NotificationsState {}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  NotificationsLoaded(this.notifications, this.unreadCount);
}

class NotificationsError extends NotificationsState {
  final String error;
  NotificationsError(this.error);
}

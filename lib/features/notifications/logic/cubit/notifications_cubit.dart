import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/notifications_repo.dart';
import '../../data/models/notifications_model.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepo _repo;

  NotificationsCubit(this._repo) : super(NotificationsInitial()) {
    loadNotifications();
  }

  int unreadCount = 0;

  Future<void> loadNotifications() async {
    try {
      if (state is! NotificationsLoaded) {
        emit(NotificationsLoading());
      }

      final response = await _repo.getNotifications();
      if (response.status) {
        unreadCount = response.data.unreadCount;
        emit(NotificationsLoaded(
          response.data.notifications.data,
          unreadCount,
        ));
      } else {
        emit(NotificationsError(response.message));
      }
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> markAsRead() async {
    try {
      await _repo.markAsRead();
      unreadCount = 0;
      if (state is NotificationsLoaded) {
        final currentState = state as NotificationsLoaded;
        emit(NotificationsLoaded(currentState.notifications, 0));
      }
    } catch (e) {
      // Keep current state but log error
    }
  }

  void addRealTimeNotification(Map<String, dynamic> data) {
    unreadCount++;
    if (state is NotificationsLoaded) {
      final currentState = state as NotificationsLoaded;

      final String id = data['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString();
      final String title = data['title']?.toString() ?? 'إشعار جديد';
      final String message = data['message']?.toString() ?? '';
      final String type = data['type']?.toString() ?? 'admin_broadcast';
      final dynamic payload = data['payload'];

      final newNotification = NotificationModel(
        id: id,
        title: title,
        message: message,
        type: type,
        payload: payload,
        isRead: false,
        createdAt: 'الآن',
        date: DateTime.now().toString().split(' ').first,
        time: '${DateTime.now().hour}:${DateTime.now().minute}',
      );

      final updatedList = [newNotification, ...currentState.notifications];
      emit(NotificationsLoaded(updatedList, unreadCount));
    } else {
      // If not loaded, we can just load from api to get the latest state
      loadNotifications();
    }
  }
}

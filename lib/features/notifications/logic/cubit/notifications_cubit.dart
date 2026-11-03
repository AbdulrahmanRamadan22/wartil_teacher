import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/notifications_repo.dart';
import '../../data/models/notifications_model.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepo _repo;

  NotificationsCubit(this._repo) : super(NotificationsInitial());

  int unreadCount = 0;

  Future<void> loadNotifications() async {
    try {
      emit(NotificationsLoading());

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
        final updatedList = currentState.notifications.map((item) {
          return NotificationModel(
            id: item.id,
            title: item.title,
            message: item.message,
            type: item.type,
            payload: item.payload,
            isRead: true,
            createdAt: item.createdAt,
            date: item.date,
            time: item.time,
          );
        }).toList();
        emit(NotificationsLoaded(updatedList, 0));
      }
    } catch (e) {
      // Keep current state but log error
    }
  }

  Future<bool> deleteNotification(String notificationId) async {
    try {
      final response = await _repo.deleteNotification(notificationId);
      if (response.status) {
        if (response.data?.unreadCount != null) {
          unreadCount = response.data!.unreadCount!;
        }
        if (state is NotificationsLoaded) {
          final currentState = state as NotificationsLoaded;
          final updatedList = currentState.notifications
              .where((item) => item.id != notificationId)
              .toList();
          emit(NotificationsLoaded(updatedList, unreadCount));
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteAllNotifications() async {
    try {
      await _repo.deleteAllNotifications();
      unreadCount = 0;
      if (state is NotificationsLoaded) {
        emit(NotificationsLoaded(const [], 0));
      }
      return true;
    } catch (e) {
      return false;
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

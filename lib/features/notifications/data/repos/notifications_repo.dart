import 'package:waratel_app/core/networking/base_repository.dart';
import '../api/notifications_api.dart';
import '../models/notifications_model.dart';

class NotificationsRepo extends BaseRepository {
  final NotificationsApi _api;

  NotificationsRepo(this._api);

  Future<NotificationsResponse> getNotifications() async {
    return handleApiCall(() => _api.getNotifications());
  }

  Future<void> markAsRead() async {
    await handleApiCall(() => _api.markAsRead());
  }
}

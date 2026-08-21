import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:waratel_app/core/networking/api_constants.dart';
import '../models/notifications_model.dart';

part 'notifications_api.g.dart';

@RestApi()
abstract class NotificationsApi {
  factory NotificationsApi(Dio dio, {String baseUrl}) = _NotificationsApi;

  @GET(ApiConstants.notifications)
  Future<NotificationsResponse> getNotifications();

  @POST(ApiConstants.notificationsMarkAsRead)
  Future<dynamic> markAsRead();
}

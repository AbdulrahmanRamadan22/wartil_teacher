import 'package:dio/dio.dart';
import 'package:waratel_app/core/networking/api_constants.dart';
import 'package:waratel_app/features/bookings/data/models/booking_model.dart';

class BookingsApi {
  final Dio _dio;

  BookingsApi(this._dio);

  Future<BookingsResponse> getBookings({int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.teacherBookings,
      queryParameters: {'page': page},
    );
    return BookingsResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<StartCallResponse> startBooking(int slotId, int callSessionId) async {
    final response = await _dio.post(
      ApiConstants.teacherBookingsStart,
      data: {
        'slot_id': slotId,
        'call_session_id': callSessionId,
      },
    );
    return StartCallResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CancelSlotResponse> cancelSlot(int slotId) async {
    final response = await _dio.post(
      ApiConstants.teacherSlotsCancel,
      data: {'slot_id': slotId},
    );
    return CancelSlotResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<SoonResponse> getSoon() async {
    final response = await _dio.get(ApiConstants.teacherSoon);
    return SoonResponse.fromJson(response.data as Map<String, dynamic>);
  }
}

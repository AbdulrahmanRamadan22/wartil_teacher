import 'package:dio/dio.dart';
import '../../../../core/networking/api_constants.dart';
import '../models/schedule_models.dart';

class ScheduleApi {
  final Dio _dio;

  ScheduleApi(this._dio);

  /// GET /teacher/my-slots
  Future<MySlotsResponse> getMySlots({int page = 1, int perPage = 5}) async {
    final response = await _dio.get(
      ApiConstants.teacherMySlots,
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
    );
    return MySlotsResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// POST /teacher/slots - one request per slot
  Future<bool> addSingleSlot({
    required String date,
    required String startTime,
    required String endTime,
  }) async {
    final response = await _dio.post(
      ApiConstants.teacherSlots,
      data: {
        'date': date,
        'start_time': startTime,
        'end_time': endTime,
      },
    );
    final result =
        AddSlotsResponse.fromJson(response.data as Map<String, dynamic>);
    return result.status;
  }

  // Keep for backwards compatibility
  Future<AddSlotsResponse> addBatchSlots({
    required String date,
    required List<String> startTimes,
    required List<String> endTimes,
  }) async {
    // Send all slot requests in parallel for faster submission
    await Future.wait(
      List.generate(
          startTimes.length,
          (i) => _dio.post(
                ApiConstants.teacherSlots,
                data: {
                  'date': date,
                  'start_time': startTimes[i],
                  'end_time': endTimes[i],
                },
              )),
    );
    return AddSlotsResponse(status: true, message: 'تم الإضافة بنجاح');
  }

  /// DELETE /teacher/slots/{id}
  Future<DeleteSlotResponse> deleteSlot(int slotId) async {
    final response = await _dio.delete(
      '${ApiConstants.teacherSlots}/$slotId',
    );
    return DeleteSlotResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// POST /teacher/slots-by-day  (server only supports POST for this route)
  Future<DeleteSlotsByDayResponse> deleteSlotsByDay(String date) async {
    final response = await _dio.post(
      ApiConstants.teacherSlotsByDay,
      data: {
        'date': date,
      },
    );
    return DeleteSlotsByDayResponse.fromJson(
        response.data as Map<String, dynamic>);
  }
}

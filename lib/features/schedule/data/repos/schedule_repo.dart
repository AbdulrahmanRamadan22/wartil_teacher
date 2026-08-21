import 'package:dio/dio.dart';
import '../api/schedule_api.dart';
import '../models/schedule_models.dart';
import 'package:flutter/foundation.dart';

class ScheduleRepo {
  final ScheduleApi _scheduleApi;

  ScheduleRepo(this._scheduleApi);

  Future<MySlotsResponse> getMySlots({int page = 1, int perPage = 5}) async {
    try {
      return await _scheduleApi.getMySlots(page: page, perPage: perPage);
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'];
      debugPrint('ScheduleRepo.getMySlots DioError: ${e.response?.data}');
      throw Exception(serverMessage ?? 'فشل في جلب المواعيد. حاول مجدداً');
    } catch (e) {
      debugPrint('ScheduleRepo.getMySlots Error: $e');
      throw Exception('فشل في جلب المواعيد: $e');
    }
  }

  Future<AddSlotsResponse> addBatchSlots({
    required String date,
    required List<String> startTimes,
    required List<String> endTimes,
  }) async {
    try {
      return await _scheduleApi.addBatchSlots(
        date: date,
        startTimes: startTimes,
        endTimes: endTimes,
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      debugPrint('ScheduleRepo.addBatchSlots DioError: $data');
      String errorMsg = 'فشل في إضافة المواعيد. حاول مجدداً';

      if (data is Map<String, dynamic>) {
        if (data['errors'] != null && data['errors'] is Map) {
          final errors = data['errors'] as Map;
          if (errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMsg = firstError.first.toString();
            } else {
              errorMsg = firstError.toString();
            }
          }
        } else {
          errorMsg = data['message']?.toString() ?? errorMsg;
        }
      }
      throw Exception(errorMsg);
    } catch (e) {
      debugPrint('ScheduleRepo.addBatchSlots Error: $e');
      throw Exception('فشل في إضافة المواعيد: $e');
    }
  }

  Future<DeleteSlotResponse> deleteSlot(int slotId) async {
    try {
      return await _scheduleApi.deleteSlot(slotId);
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'];
      debugPrint('ScheduleRepo.deleteSlot DioError: ${e.response?.data}');
      throw Exception(serverMessage ?? 'فشل في حذف الموعد. حاول مجدداً');
    } catch (e) {
      debugPrint('ScheduleRepo.deleteSlot Error: $e');
      throw Exception('فشل في حذف الموعد: $e');
    }
  }

  Future<DeleteSlotsByDayResponse> deleteSlotsByDay(String date) async {
    try {
      return await _scheduleApi.deleteSlotsByDay(date);
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'];
      debugPrint('ScheduleRepo.deleteSlotsByDay DioError: ${e.response?.data}');
      throw Exception(serverMessage ?? 'فشل في حذف مواعيد اليوم. حاول مجدداً');
    } catch (e) {
      debugPrint('ScheduleRepo.deleteSlotsByDay Error: $e');
      throw Exception('فشل في حذف مواعيد اليوم: $e');
    }
  }
}

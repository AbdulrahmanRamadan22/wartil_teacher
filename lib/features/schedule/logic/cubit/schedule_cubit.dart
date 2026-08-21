import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/schedule_repo.dart';
import '../../data/models/schedule_models.dart';
import 'schedule_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final ScheduleRepo scheduleRepo;

  ScheduleCubit(this.scheduleRepo) : super(ScheduleInitial());

  Map<String, List<SlotModel>> calendar = {};

  Future<void> loadSchedule({int page = 1, int perPage = 15}) async {
    if (!isClosed) emit(ScheduleLoading());
    try {
      final response =
          await scheduleRepo.getMySlots(page: page, perPage: perPage);

      if (response.status && response.data != null) {
        final newCalendar = response.data!.calendar;

        final Map<String, List<SlotModel>> filteredCalendar = {};
        newCalendar.forEach((date, slots) {
          final activeSlots = slots.where((slot) => !slot.isPast).toList();
          if (activeSlots.isNotEmpty) {
            filteredCalendar[date] = activeSlots;
          }
        });

        calendar = filteredCalendar;
        if (!isClosed) {
          emit(ScheduleLoaded(calendar, response.data!.pagination));
        }
      } else if (response.status && response.data == null) {
        calendar = {};
        if (!isClosed) emit(ScheduleLoaded(calendar, null));
      } else {
        if (!isClosed) emit(ScheduleError(response.message));
      }
    } catch (e) {
      if (!isClosed) {
        emit(ScheduleError(e.toString().replaceFirst('Exception: ', '')));
      }
    }
  }

  Future<void> addSlots({
    required String date,
    required List<Map<String, String>> slots,
  }) async {
    emit(AddSlotsLoading());
    try {
      final List<String> startTimes =
          slots.map((s) => s['start_time']!).toList();
      final List<String> endTimes = slots.map((s) => s['end_time']!).toList();

      final response = await scheduleRepo.addBatchSlots(
        date: date,
        startTimes: startTimes,
        endTimes: endTimes,
      );

      if (!response.status) {
        throw Exception(response.message);
      }

      if (!isClosed) {
        emit(AddSlotsSuccess('تم إضافة المواعيد بنجاح'));
      }
      await loadSchedule();
    } catch (e) {
      if (!isClosed) {
        emit(AddSlotsError(e.toString().replaceFirst('Exception: ', '')));
      }
    }
  }

  Future<void> deleteSlot(int slotId) async {
    if (!isClosed) emit(DeleteSlotLoading());
    try {
      final response = await scheduleRepo.deleteSlot(slotId);

      if (response.status) {
        if (!isClosed) emit(DeleteSlotSuccess(response.message));
        // Reload schedule after deleting
        await loadSchedule();
      } else {
        if (!isClosed) emit(DeleteSlotError(response.message));
      }
    } catch (e) {
      if (!isClosed) {
        emit(DeleteSlotError(e.toString().replaceFirst('Exception: ', '')));
      }
    }
  }

  Future<void> deleteSlotsByDay(String date) async {
    if (!isClosed) emit(DeleteSlotLoading());
    try {
      final response = await scheduleRepo.deleteSlotsByDay(date);

      if (response.status) {
        if (!isClosed) emit(DeleteSlotSuccess(response.message));
        // Reload schedule after deleting
        await loadSchedule();
      } else {
        if (!isClosed) emit(DeleteSlotError(response.message));
      }
    } catch (e) {
      if (!isClosed) {
        emit(DeleteSlotError(e.toString().replaceFirst('Exception: ', '')));
      }
    }
  }
}

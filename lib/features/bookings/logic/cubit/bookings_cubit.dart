import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waratel_app/features/bookings/domain/repos/i_bookings_repo.dart';
import 'package:waratel_app/features/bookings/data/models/booking_model.dart';
import 'package:waratel_app/features/bookings/logic/cubit/bookings_state.dart';

class BookingsCubit extends Cubit<BookingsState> {
  final IBookingsRepo _repo;

  BookingsCubit(this._repo) : super(BookingsInitial());

  List<BookingModel> _upcomingBookings = [];
  List<BookingModel> _historyBookings = [];

  Future<void> loadBookings({int page = 1}) async {
    emit(BookingsLoading());
    try {
      final response = await _repo.getBookings(page: page);
      if (response.status) {
        _upcomingBookings = response.upcoming;
        _historyBookings = response.history;
        final hasMore = response.pagination?.nextPageUrl != null;
        emit(BookingsLoaded(
          upcoming: List.from(_upcomingBookings),
          history: List.from(_historyBookings),
          hasMore: hasMore,
        ));
      } else {
        emit(BookingsError(response.message.isEmpty
            ? 'فشل تحميل الحجوزات'
            : response.message));
      }
    } catch (e) {
      if (!isClosed) {
        emit(BookingsError(e.toString().replaceFirst('Exception: ', '')));
      }
    }
  }

  Future<void> cancelSlot(int slotId) async {
    emit(CancelSlotLoading());
    try {
      final response = await _repo.cancelSlot(slotId);
      if (response.status) {
        emit(CancelSlotSuccess(response.message));
        await loadBookings();
      } else {
        emit(CancelSlotError(response.message));
      }
    } catch (e) {
      if (!isClosed) {
        emit(CancelSlotError(e.toString().replaceFirst('Exception: ', '')));
      }
    }
  }

  Future<void> startCall(
    int bookingId,
    String studentName, {
    int? studentId,
    int? slotId,
  }) async {
    if (bookingId <= 0) {
      emit(StartCallError('معرف الحجز غير صالح'));
      return;
    }
    emit(StartCallLoading());
    try {
      debugPrint(
          '🚀 [BOOKINGS CUBIT] Starting booking call with booking_id: $bookingId');
      final response = await _repo.startBooking(bookingId);
      if (response.status) {
        final int effectiveCallId =
            (response.callId != null && response.callId! > 0)
                ? response.callId!
                : bookingId;

        emit(StartCallSuccess(
          token: response.token,
          channel: response.channel,
          uid: response.uid,
          studentName: studentName,
          callId: effectiveCallId,
          studentId: studentId,
          slotId: slotId,
        ));
      } else {
        emit(StartCallError('فشل بدء المكالمة'));
      }
    } catch (e) {
      if (!isClosed) {
        emit(StartCallError(e.toString().replaceFirst('Exception: ', '')));
      }
    }
  }
}

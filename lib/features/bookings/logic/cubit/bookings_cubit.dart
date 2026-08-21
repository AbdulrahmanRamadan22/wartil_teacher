import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waratel_app/features/bookings/domain/repos/i_bookings_repo.dart';
import 'package:waratel_app/features/bookings/data/models/booking_model.dart';
import 'package:waratel_app/features/bookings/logic/cubit/bookings_state.dart';

class BookingsCubit extends Cubit<BookingsState> {
  final IBookingsRepo _repo;

  BookingsCubit(this._repo) : super(BookingsInitial()) {
    loadBookings();
  }

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

  Future<void> startCall(int slotId, int callSessionId, String studentName) async {
    emit(StartCallLoading());
    try {
      final response = await _repo.startBooking(slotId, callSessionId);
      if (response.status) {
        emit(StartCallSuccess(
          token: response.token,
          channel: response.channel,
          uid: response.uid,
          studentName: studentName,
          callId: callSessionId > 0 ? callSessionId : slotId, // Use slotId as fallback callId
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

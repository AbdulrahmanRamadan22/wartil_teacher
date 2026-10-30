import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waratel_app/core/di/dependency_injection.dart';
import 'package:waratel_app/features/bookings/domain/repos/i_bookings_repo.dart';
import 'package:waratel_app/features/home/data/repos/home_repo.dart';
import 'package:waratel_app/features/home/logic/cubit/home_state.dart';
import 'package:waratel_app/features/bookings/data/models/booking_model.dart'; // Contains BookingModel & SoonResponse

import 'package:waratel_app/features/ratings/data/repos/ratings_repo.dart';
import 'package:waratel_app/features/call/data/models/call_model.dart';
import 'package:waratel_app/features/call/data/repos/calls_repo.dart';

/// HomeCubit — manages Home screen state only.
/// Follows SRP: does NOT cancel, delete or modify bookings.
class HomeCubit extends Cubit<HomeState> {
  final HomeRepo _homeRepo;
  final RatingsRepo _ratingsRepo;
  final CallsRepo _callsRepo;

  HomeCubit(
    this._homeRepo,
    this._ratingsRepo,
    this._callsRepo,
  ) : super(HomeInitial());

  bool isOnline = false;
  double averageRating = 4.5; // Default fallback

  Future<void> getInitialOnlineStatus() async {
    isOnline = await _homeRepo.getLocalOnlineStatus();
    if (!isClosed) emit(HomeOnlineStatusLoaded(isOnline));
  }

  Future<void> getAverageRating() async {
    try {
      final response = await _ratingsRepo.getRatings(type: 'call');
      if (response.status) {
        averageRating = response.data.summary.averageRating.toDouble();
        if (!isClosed) emit(HomeOnlineStatusLoaded(isOnline));
      }
    } catch (e) {
      debugPrint('❌ [HOME CUBIT] Error fetching average rating: $e');
    }
  }

  Future<void> toggleOnline() async {
    if (!isClosed) emit(ToggleOnlineLoading());
    try {
      final response = await _homeRepo.toggleOnline();
      isOnline = response.data.isOnline;
      if (!isClosed) emit(ToggleOnlineSuccess(isOnline, response.message));
    } catch (e) {
      if (!isClosed) emit(ToggleOnlineError(e.toString()));
    }
  }

  BookingModel? soonBooking;

  Future<void> loadSoon() async {
    if (isClosed) return;
    if (!isClosed) emit(HomeSoonLoading());

    // Fire background loads (not awaited)
    _safeBackground(getAverageRating);
    _safeBackground(loadRecentCalls);

    try {
      // 1. First fetch upcoming bookings from IBookingsRepo
      // This is the direct source of truth and contains the true booking_id!
      try {
        final bookingsRes = await getIt<IBookingsRepo>().getBookings();
        if (bookingsRes.status && bookingsRes.upcoming.isNotEmpty) {
          final now = DateTime.now();
          // تصفية الجلسات التي لم ينته وقتها بعد
          final activeUpcoming = bookingsRes.upcoming
              .where((b) => b.endDateTime.isAfter(now))
              .toList();

          if (activeUpcoming.isNotEmpty) {
            // ترتيب تصاعدي: الأقرب بدءاً يظهر أولاً
            activeUpcoming.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
            soonBooking = activeUpcoming.first;
            debugPrint(
                '✅ [HOME CUBIT] Nearest session selected: booking_id=${soonBooking!.bookingId}, slot_id=${soonBooking!.slotId}, date=${soonBooking!.date}, time=${soonBooking!.startTime}');
            if (!isClosed) emit(HomeSoonLoaded(soonBooking));
            return;
          }
        }
      } catch (e) {
        debugPrint('⚠️ [HOME CUBIT] Bookings lookup error for soon: $e');
      }

      // 2. Fallback to teacher/soon if bookings list had no upcoming
      final response = await _homeRepo.getSoon();

      if (response == null) {
        soonBooking = null;
        if (!isClosed) emit(HomeSoonLoaded(null));
        return;
      }

      // Parse using the correct SoonResponse model
      final soonResponse = SoonResponse.fromJson(
          response is Map<String, dynamic> ? response : {});

      final booking = soonResponse.booking;

      if (booking == null) {
        soonBooking = null;
        if (!isClosed) emit(HomeSoonLoaded(null));
        return;
      }

      // If the session has already ended, hide it — do NOT cancel it.
      final now = DateTime.now();
      if (now.isAfter(booking.endDateTime)) {
        soonBooking = null;
        if (!isClosed) emit(HomeSoonLoaded(null));
        return;
      }

      soonBooking = booking;
      if (!isClosed) emit(HomeSoonLoaded(soonBooking));
    } catch (e) {
      debugPrint('❌ [HOME CUBIT] Error loading soon booking: $e');
      if (!isClosed) emit(HomeSoonError(e.toString()));
    }
  }

  void _safeBackground(Future<void> Function() fn) {
    fn().catchError((e) {
      debugPrint('❌ [HOME CUBIT] Background task error: $e');
    });
  }

  // ── Recent Calls ──────────────────────────────────────────────
  List<CallModel> recentCalls = [];

  Future<void> loadRecentCalls() async {
    if (isClosed) return;
    try {
      final response = await _callsRepo.getCalls(page: 1);
      if (response.status) {
        recentCalls = response.data.data.take(10).toList();
        if (!isClosed) emit(HomeRecentCallsUpdated());
      }
    } catch (e) {
      debugPrint('❌ [HOME CUBIT] Error loading recent calls: $e');
    }
  }

  void addCall(CallModel call) {
    recentCalls.insert(0, call);
    if (recentCalls.length > 10) recentCalls.removeLast();
    if (!isClosed) emit(HomeRecentCallsUpdated());
  }

  // ── Navigation ────────────────────────────────────────────────
  int currentIndex = 0;

  void changeBottomNav(int index) {
    if (currentIndex == index) return;
    currentIndex = index;
    if (!isClosed) emit(HomeChangeBottomNavState());
  }
}

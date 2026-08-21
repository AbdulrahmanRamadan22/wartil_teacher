import 'package:waratel_app/features/bookings/data/models/booking_model.dart';

abstract class BookingsState {}

class BookingsInitial extends BookingsState {}

class BookingsLoading extends BookingsState {}

class BookingsLoaded extends BookingsState {
  final List<BookingModel> upcoming;
  final List<BookingModel> history;
  final bool hasMore;
  BookingsLoaded({
    required this.upcoming,
    required this.history,
    this.hasMore = false,
  });
}

class BookingsError extends BookingsState {
  final String error;
  BookingsError(this.error);
}

class CancelSlotLoading extends BookingsState {}

class CancelSlotSuccess extends BookingsState {
  final String message;
  CancelSlotSuccess(this.message);
}

class CancelSlotError extends BookingsState {
  final String error;
  CancelSlotError(this.error);
}

class StartCallLoading extends BookingsState {}

class StartCallSuccess extends BookingsState {
  final String token;
  final String channel;
  final int uid;
  final String studentName;
  final int callId;
  StartCallSuccess({
    required this.token,
    required this.channel,
    required this.uid,
    required this.studentName,
    required this.callId,
  });
}

class StartCallError extends BookingsState {
  final String error;
  StartCallError(this.error);
}

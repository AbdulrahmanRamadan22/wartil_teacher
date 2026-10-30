import 'package:waratel_app/features/bookings/data/models/booking_model.dart';

abstract class IBookingsRepo {
  Future<BookingsResponse> getBookings({int page = 1});
  Future<StartCallResponse> startBooking(int bookingId);
  Future<dynamic> endBooking(int bookingId);
  Future<CancelSlotResponse> cancelSlot(int slotId);
  Future<SoonResponse> getSoon();
}

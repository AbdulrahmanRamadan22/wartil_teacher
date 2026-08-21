import 'package:waratel_app/core/networking/base_repository.dart';
import 'package:waratel_app/features/bookings/data/api/bookings_api.dart';
import 'package:waratel_app/features/bookings/data/models/booking_model.dart';
import 'package:waratel_app/features/bookings/domain/repos/i_bookings_repo.dart';

class BookingsRepo extends BaseRepository implements IBookingsRepo {
  final BookingsApi _api;

  BookingsRepo(this._api);

  @override
  Future<BookingsResponse> getBookings({int page = 1}) async {
    return handleApiCall(() => _api.getBookings(page: page));
  }

  @override
  Future<StartCallResponse> startBooking(int slotId, int callSessionId) async {
    return handleApiCall(() => _api.startBooking(slotId, callSessionId));
  }

  @override
  Future<CancelSlotResponse> cancelSlot(int slotId) async {
    return handleApiCall(() => _api.cancelSlot(slotId));
  }

  @override
  Future<SoonResponse> getSoon() async {
    return handleApiCall(() => _api.getSoon());
  }
}

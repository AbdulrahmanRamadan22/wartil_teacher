import 'package:waratel_app/core/networking/base_repository.dart';
import '../api/ratings_api.dart';
import '../models/rating_model.dart';

class RatingsRepo extends BaseRepository {
  final RatingsApi _api;

  RatingsRepo(this._api);

  Future<RatingResponse> getRatings(
      {String type = 'call', int page = 1}) async {
    return handleApiCall(() => _api.getRatings(type: type, page: page));
  }
}

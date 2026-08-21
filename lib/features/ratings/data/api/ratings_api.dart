import 'package:dio/dio.dart';
import 'package:waratel_app/core/networking/api_constants.dart';
import '../models/rating_model.dart';

class RatingsApi {
  final Dio _dio;

  RatingsApi(this._dio);

  Future<RatingResponse> getRatings(
      {String type = 'call', int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.teacherRatings,
      queryParameters: {
        'type': type,
        'page': page,
      },
    );
    return RatingResponse.fromJson(response.data);
  }
}

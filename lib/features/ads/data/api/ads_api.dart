import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/networking/api_constants.dart';
import '../models/ads_response.dart';

class AdsApi {
  final Dio _dio;

  AdsApi(this._dio);

  Future<AdsResponse> getAds({int page = 1, int perPage = 5}) async {
    try {
      debugPrint(
          '🚀 [ADS API] Fetching ads from: ${ApiConstants.baseUrl}${ApiConstants.teacherAds}');
      final response = await _dio.get(
        ApiConstants.teacherAds,
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );
      debugPrint('✅ [ADS API] Response received: ${response.statusCode}');
      return AdsResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ [ADS API] Error in getAds: $e');
      rethrow;
    }
  }
}

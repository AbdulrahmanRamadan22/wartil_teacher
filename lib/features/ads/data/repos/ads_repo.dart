import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../api/ads_api.dart';
import '../models/ads_response.dart';

class AdsRepo {
  final AdsApi _adsApi;

  AdsRepo(this._adsApi);

  Future<AdsResponse> getAds({int page = 1, int perPage = 5}) async {
    try {
      final response = await _adsApi.getAds(page: page, perPage: perPage);
      return response;
    } on DioException catch (e) {
      debugPrint('❌ [ADS REPO] DioException: ${e.message}');
      debugPrint('❌ [ADS REPO] Response: ${e.response?.data}');
      final serverMessage = e.response?.data?['message'];
      throw Exception(serverMessage ?? 'فشل في جلب الإعلانات. حاول مجدداً');
    } catch (e) {
      debugPrint('❌ [ADS REPO] Unexpected Error: $e');
      throw Exception('حدث خطأ غير متوقع. حاول مجدداً');
    }
  }
}

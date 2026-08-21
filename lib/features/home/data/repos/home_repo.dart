import 'package:flutter/foundation.dart';
import '../../../../core/cache/shared_preferences.dart';
import '../../../../core/networking/base_repository.dart';
import '../api/home_api.dart';
import '../models/home_models.dart';

class HomeRepo extends BaseRepository {
  final HomeApi _homeApi;

  HomeRepo(this._homeApi);

  Future<ToggleOnlineResponse> toggleOnline() async {
    final response = await handleApiCall(() => _homeApi.toggleOnline());
    await SharedPreferencesService.instance
        .setBool('is_online', response.data.isOnline);
    return response;
  }

  Future<bool> getLocalOnlineStatus() async {
    return SharedPreferencesService.instance.getBool('is_online') ?? false;
  }

  Future<dynamic> getSoon() async {
    try {
      return await handleApiCall(() => _homeApi.getSoon());
    } on Exception catch (e) {
      if (e.toString().contains('400')) {
        debugPrint('⚠️ [HOME REPO] 400 Bad Request on teacher/soon');
        return null; // Return null if no soon booking
      }
      rethrow;
    }
  }
}


import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/ads_repo.dart';
import 'ads_state.dart';

class AdsCubit extends Cubit<AdsState> {
  final AdsRepo adsRepo;

  AdsCubit(this.adsRepo) : super(AdsInitial());

  Future<void> getAds() async {
    emit(AdsLoading());
    try {
      // Add a safety timeout of 10 seconds for initial load
      final response =
          await adsRepo.getAds().timeout(const Duration(seconds: 10));

      debugPrint('📢 [ADS CUBIT] Ads Response status: ${response.status}');
      debugPrint('📢 [ADS CUBIT] Ads count: ${response.data.data.length}');

      if (response.status) {
        emit(AdsLoaded(response.data.data));
      } else {
        emit(AdsError(response.message));
      }
    } catch (e) {
      debugPrint('❌ [ADS CUBIT] Error getting ads: $e');
      emit(AdsError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waratel_app/features/profile/data/repos/profile_repo.dart';
import 'package:waratel_app/features/profile/data/models/profile_models.dart';
import 'package:waratel_app/features/profile/logic/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;

  ProfileCubit(this.profileRepo) : super(ProfileInitial());

  ProfileResponse? profileData;

  Future<void> getProfile() async {
    emit(ProfileLoading());
    try {
      final response = await profileRepo.getProfile();
      profileData = response;
      emit(ProfileLoaded(response));
    } catch (e) {
      emit(ProfileError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  /// Called on pull-to-refresh — shows shimmer overlay without losing existing data.
  Future<void> refreshProfile() async {
    emit(ProfileRefreshing());
    try {
      final response = await profileRepo.getProfile();
      profileData = response;
      emit(ProfileLoaded(response));
    } catch (e) {
      // Keep old data visible on refresh failure
      if (profileData != null) {
        emit(ProfileLoaded(profileData!));
      } else {
        emit(ProfileError(e.toString().replaceFirst('Exception: ', '')));
      }
    }
  }

  Future<void> logout() async {
    emit(LogoutLoading());
    try {
      await profileRepo.logout();
      emit(LogoutSuccess());
    } catch (e) {
      emit(LogoutError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> deleteAccount() async {
    emit(DeleteAccountLoading());
    try {
      final message = await profileRepo.deleteAccount();
      emit(DeleteAccountSuccess(message));
    } catch (e) {
      emit(DeleteAccountError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}

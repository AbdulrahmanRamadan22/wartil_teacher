import 'package:flutter/material.dart';
import 'package:waratel_app/features/profile/data/models/profile_models.dart';

@immutable
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileRefreshing extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileResponse profileResponse;
  ProfileLoaded(this.profileResponse);
}

class ProfileError extends ProfileState {
  final String error;
  ProfileError(this.error);
}

class LogoutLoading extends ProfileState {}

class LogoutSuccess extends ProfileState {}

class LogoutError extends ProfileState {
  final String error;
  LogoutError(this.error);
}

class DeleteAccountLoading extends ProfileState {}

class DeleteAccountSuccess extends ProfileState {
  final String message;
  DeleteAccountSuccess(this.message);
}

class DeleteAccountError extends ProfileState {
  final String error;
  DeleteAccountError(this.error);
}

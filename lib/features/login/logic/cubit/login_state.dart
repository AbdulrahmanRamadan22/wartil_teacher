import 'package:flutter/material.dart';
import 'package:waratel_app/features/login/data/models/models.dart';

@immutable
abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginPasswordVisibilityChanged extends LoginState {}

class LoginSuccess extends LoginState {
  final String successMessage;
  final LoginResponse loginResponse;
  LoginSuccess(this.successMessage, this.loginResponse);
}

class LoginError extends LoginState {
  final String errorMessage;
  LoginError(this.errorMessage);
}

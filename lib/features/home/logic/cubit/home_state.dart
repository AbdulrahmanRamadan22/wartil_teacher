import 'package:flutter/foundation.dart';

@immutable
abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeOnlineStatusLoaded extends HomeState {
  final bool isOnline;
  HomeOnlineStatusLoaded(this.isOnline);
}

class HomeChangeBottomNavState extends HomeState {}

class HomeRecentCallsUpdated extends HomeState {}

class ToggleOnlineLoading extends HomeState {}

class ToggleOnlineSuccess extends HomeState {
  final bool isOnline;
  final String message;
  ToggleOnlineSuccess(this.isOnline, this.message);
}

class ToggleOnlineError extends HomeState {
  final String error;
  ToggleOnlineError(this.error);
}

class HomeSoonLoading extends HomeState {}

class HomeSoonLoaded extends HomeState {
  final dynamic booking; // BookingModel?
  HomeSoonLoaded(this.booking);
}

class HomeSoonError extends HomeState {
  final String error;
  HomeSoonError(this.error);
}

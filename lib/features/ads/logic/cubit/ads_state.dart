import 'package:flutter/material.dart';
import '../../data/models/ads_response.dart';

@immutable
abstract class AdsState {}

class AdsInitial extends AdsState {}

class AdsLoading extends AdsState {}

class AdsLoaded extends AdsState {
  final List<Advertisement> ads;
  AdsLoaded(this.ads);
}

class AdsError extends AdsState {
  final String error;
  AdsError(this.error);
}

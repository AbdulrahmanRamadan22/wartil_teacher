import 'package:flutter/material.dart';
import '../../data/models/session_model.dart';

@immutable
abstract class RecordState {}

class RecordInitial extends RecordState {}

class RecordLoading extends RecordState {}

class RecordLoaded extends RecordState {
  final List<SessionModel> sessions;
  RecordLoaded(this.sessions);
}

class RecordError extends RecordState {
  final String error;
  RecordError(this.error);
}

class RecordFilterChangedState extends RecordState {
  final bool showCompletedCalls;
  RecordFilterChangedState(this.showCompletedCalls);
}

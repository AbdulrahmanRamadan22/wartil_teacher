import 'package:flutter/material.dart';
import '../../data/models/teacher_preferences.dart';

@immutable
abstract class AchievementPlanState {}

class AchievementPlanInitial extends AchievementPlanState {}

class AchievementPlanLoading extends AchievementPlanState {}

class AchievementPlanLoaded extends AchievementPlanState {
  final TeacherPreferences preferences;
  AchievementPlanLoaded(this.preferences);
}

class AchievementPlanSuccess extends AchievementPlanState {
  final String message;
  AchievementPlanSuccess(this.message);
}

class AchievementPlanError extends AchievementPlanState {
  final String error;
  AchievementPlanError(this.error);
}

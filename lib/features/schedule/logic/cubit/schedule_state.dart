import 'package:flutter/material.dart';
import '../../data/models/schedule_models.dart';

@immutable
abstract class ScheduleState {}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleLoaded extends ScheduleState {
  final Map<String, List<SlotModel>> calendar;
  final SlotsPagination? pagination;
  ScheduleLoaded(this.calendar, this.pagination);
}

class ScheduleError extends ScheduleState {
  final String error;
  ScheduleError(this.error);
}

// Add Slots States
class AddSlotsLoading extends ScheduleState {}

class AddSlotsSuccess extends ScheduleState {
  final String message;
  AddSlotsSuccess(this.message);
}

class AddSlotsError extends ScheduleState {
  final String error;
  AddSlotsError(this.error);
}

// Delete Slot States
class DeleteSlotLoading extends ScheduleState {}

class DeleteSlotSuccess extends ScheduleState {
  final String message;
  DeleteSlotSuccess(this.message);
}

class DeleteSlotError extends ScheduleState {
  final String error;
  DeleteSlotError(this.error);
}

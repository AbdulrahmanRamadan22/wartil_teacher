import 'package:waratel_app/features/call/data/models/call_model.dart';
import 'package:waratel_app/features/ratings/data/models/rating_model.dart';

abstract class StatisticsState {}

class StatisticsInitial extends StatisticsState {}

class StatisticsLoading extends StatisticsState {}

class StatisticsLoaded extends StatisticsState {
  final RatingData ratingData;
  final List<CallModel> calls;
  StatisticsLoaded(this.ratingData, this.calls);
}

class StatisticsError extends StatisticsState {
  final String error;
  StatisticsError(this.error);
}

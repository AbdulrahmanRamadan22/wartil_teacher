import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waratel_app/features/call/data/models/call_model.dart';
import 'package:waratel_app/features/call/data/repos/calls_repo.dart';
import 'package:waratel_app/features/ratings/data/models/rating_model.dart';
import 'package:waratel_app/features/ratings/data/models/session_model.dart';
import 'package:waratel_app/features/ratings/data/repos/ratings_repo.dart';
import 'package:waratel_app/features/ratings/data/repos/sessions_repo.dart';
import 'statistics_state.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  final RatingsRepo _ratingsRepo;
  final CallsRepo _callsRepo;
  final SessionsRepo _sessionsRepo;

  StatisticsCubit(
    this._ratingsRepo,
    this._callsRepo,
    this._sessionsRepo,
  ) : super(StatisticsInitial());

  Future<void> loadStatistics() async {
    emit(StatisticsLoading());
    try {
      // Fetch all required data in parallel to save time
      final results = await Future.wait([
        _ratingsRepo.getRatings(),
        _callsRepo.getCalls(),
        _sessionsRepo.getSessionsResponse(),
      ]);

      final ratingResponse = results[0] as RatingResponse;
      final callsResponse = results[1] as CallListResponse;
      final sessionsResponse = results[2] as SessionsResponse;

      if (ratingResponse.status) {
        // Merge real counts into the breakdown map for the UI
        final Map<String, int> updatedBreakdown =
            Map.from(ratingResponse.data.summary.breakdown);

        updatedBreakdown['calls'] = callsResponse.data.total;
        updatedBreakdown['sessions'] = sessionsResponse.data.total ??
            sessionsResponse.data.sessions.length;

        // Reconstruct the response with injected counts
        final updatedSummary = ratingResponse.data.summary.copyWith(
          breakdown: updatedBreakdown,
        );

        final updatedData = ratingResponse.data.copyWith(
          summary: updatedSummary,
        );

        emit(StatisticsLoaded(updatedData, callsResponse.data.data));
      } else {
        emit(StatisticsError('فشل تحميل الإحصائيات من السيرفر'));
      }
    } catch (e) {
      String message = e.toString();
      if (message.startsWith('Exception: ')) {
        message = message.replaceFirst('Exception: ', '');
      }
      emit(StatisticsError('خطأ في جلب البيانات: $message'));
    }
  }
}

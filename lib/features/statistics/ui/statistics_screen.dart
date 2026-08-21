import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:waratel_app/core/di/dependency_injection.dart';
import 'package:waratel_app/core/theming/colors.dart';
import 'package:waratel_app/features/localization/data/app_localizations.dart';
import 'package:waratel_app/features/call/data/models/call_model.dart';
import 'package:waratel_app/features/ratings/data/models/rating_model.dart';
import 'package:waratel_app/core/routing/routers.dart';
import 'package:waratel_app/features/record/logic/cubit/record_cubit.dart';
import 'package:waratel_app/features/record/logic/cubit/record_state.dart';
import 'package:waratel_app/features/record/data/models/session_model.dart';
import '../logic/cubit/statistics_cubit.dart';
import '../logic/cubit/statistics_state.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<StatisticsCubit>()..loadStatistics(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: ColorsManager.backgroundColor,
            appBar: AppBar(
              title: Text('stats'.tr(context)),
            ),
            body: RefreshIndicator(
              onRefresh: () async =>
                  context.read<StatisticsCubit>().loadStatistics(),
              color: ColorsManager.primaryColor,
              child: BlocBuilder<StatisticsCubit, StatisticsState>(
                builder: (context, state) {
                  return _buildBody(context, state);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, StatisticsState state) {
    if (state is StatisticsLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is StatisticsLoaded) {
      return _StatisticsContent(
        ratingData: state.ratingData,
        calls: state.calls,
      );
    } else if (state is StatisticsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.error),
            SizedBox(height: 10.h),
            ElevatedButton(
              onPressed: () => context.read<StatisticsCubit>().loadStatistics(),
              child: Text('retry'.tr(context)),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _StatisticsContent extends StatelessWidget {
  final RatingData ratingData;
  final List<CallModel> calls;

  const _StatisticsContent({
    required this.ratingData,
    required this.calls,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ── Header & Stats Grid ─────────────────────────────────────
        SliverPadding(
          padding: EdgeInsets.all(20.w),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
                  decoration: BoxDecoration(
                    gradient: ColorsManager.headerGradient,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'performance_overview'.tr(context),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        DateFormat('MMMM yyyy', 'ar').format(DateTime.now()),
                        style:
                            TextStyle(color: Colors.white70, fontSize: 13.sp),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 1.0,
                  children: [
                    _StatCard(
                      title: 'average_rating'.tr(context),
                      value:
                          ratingData.summary.averageRating.toStringAsFixed(1),
                      icon: Icons.star_rounded,
                      color: const Color(0xFFFFC107),
                    ),
                    _StatCard(
                      title: 'total_reviews'.tr(context),
                      value: ratingData.summary.totalReviews.toString(),
                      icon: Icons.reviews_rounded,
                      color: const Color(0xFF6C63FF),
                    ),
                    _StatCard(
                      title: 'calls'.tr(context),
                      value: (ratingData.summary.breakdown['calls'] ?? 0)
                          .toString(),
                      icon: Icons.phone_callback_rounded,
                      color: const Color(0xFF10B981),
                    ),
                    _StatCard(
                      title: 'sessions'.tr(context),
                      value: (ratingData.summary.breakdown['sessions'] ?? 0)
                          .toString(),
                      icon: Icons.video_call_rounded,
                      color: const Color(0xFFFF8C42),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ── Calls History Label ─────────────────────────────────────
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          sliver: SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Text(
                'successful_calls'.tr(context),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: ColorsManager.textPrimaryColor,
                ),
              ),
            ),
          ),
        ),

        // ── Calls History List (SliverList for Performance) ──────────
        if (calls.isEmpty)
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            sliver: SliverToBoxAdapter(
                child: _buildEmptyState(context, Icons.phone_missed_rounded,
                    'no_recent_calls'.tr(context))),
          )
        else
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: InkWell(
                      onTap: () {
                        // Find matching session in RecordCubit if available
                        final recordCubit = getIt<RecordCubit>();
                        final recordedSession = recordCubit.state
                                is RecordLoaded
                            ? (recordCubit.state as RecordLoaded)
                                .sessions
                                .firstWhere(
                                  (s) =>
                                      s.studentName ==
                                          calls[index].studentName &&
                                      s.date == calls[index].date,
                                  orElse: () => SessionModel(
                                    studentName: calls[index].studentName,
                                    date: calls[index].date,
                                    time: calls[index].time,
                                    duration:
                                        '${calls[index].durationMinutes} min',
                                    trackName: 'private_call'.tr(context),
                                    status: 'completed'.tr(context),
                                    notes: '',
                                    nextAssignment: '',
                                    rating:
                                        calls[index].rating?.toString() ?? '',
                                    isPresent: true,
                                  ),
                                )
                            : null;

                        if (recordedSession != null) {
                          Navigator.pushNamed(
                            context,
                            Routes.sessionDetails,
                            arguments: recordedSession,
                          );
                        }
                      },
                      child: _CallHistoryCard(call: calls[index]),
                    ),
                  );
                },
                childCount: calls.length,
              ),
            ),
          ),

        // ── Reviews Label ───────────────────────────────────────────
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 12.h),
          sliver: SliverToBoxAdapter(
            child: Text(
              'latest_reviews'.tr(context),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: ColorsManager.textPrimaryColor,
              ),
            ),
          ),
        ),

        // ── Reviews List (SliverList for Performance) ────────────────
        if (ratingData.reviews.data.isEmpty)
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            sliver: SliverToBoxAdapter(
                child: _buildEmptyState(context, Icons.rate_review_outlined,
                    'no_reviews_yet'.tr(context))),
          )
        else
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: _ReviewCard(review: ratingData.reviews.data[index]),
                  );
                },
                childCount: ratingData.reviews.data.length,
              ),
            ),
          ),

        // Footer Padding
        SliverToBoxAdapter(child: SizedBox(height: 30.h)),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, IconData icon, String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h),
      decoration: BoxDecoration(
        color: ColorsManager.surfaceColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(icon, size: 50.sp, color: Colors.grey[300]),
          SizedBox(height: 10.h),
          Text(
            message,
            style: TextStyle(color: Colors.grey, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }
}

class _CallHistoryCard extends StatelessWidget {
  final CallModel call;

  const _CallHistoryCard({required this.call});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: ColorsManager.surfaceColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: ColorsManager.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.phone_in_talk_rounded,
                color: ColorsManager.primaryColor, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  call.studentName,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${call.date} | ${call.time}',
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${call.durationMinutes} min',
                style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: ColorsManager.primaryColor),
              ),
              if (call.rating != null)
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: Colors.amber, size: 14.sp),
                    Text(
                      ' ${call.rating}',
                      style: TextStyle(
                          fontSize: 11.sp, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: ColorsManager.surfaceColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: ColorsManager.textPrimaryColor,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.sp,
              color: ColorsManager.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewItem review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: ColorsManager.surfaceColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundImage: review.studentPhoto != null
                    ? CachedNetworkImageProvider(review.studentPhoto!)
                        as ImageProvider
                    : null,
                child: review.studentPhoto == null
                    ? Icon(Icons.person, size: 18.sp)
                    : null,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.studentName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                    Text(
                      _formatDate(review.date),
                      style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              _buildRatingStars(review.rating),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              review.comment!,
              style: TextStyle(
                  fontSize: 13.sp, color: ColorsManager.textPrimaryColor),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingStars(num rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor()
              ? Icons.star_rounded
              : Icons.star_outline_rounded,
          color: const Color(0xFFFFC107),
          size: 16.sp,
        );
      }),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('yyyy/MM/dd').format(date);
    } catch (_) {
      return dateStr;
    }
  }
}

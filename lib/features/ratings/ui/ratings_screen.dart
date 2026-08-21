import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waratel_app/core/di/dependency_injection.dart';
import 'package:waratel_app/core/theming/colors.dart';
import 'package:waratel_app/core/widgets/custom_app_header.dart';
import 'package:waratel_app/features/localization/data/app_localizations.dart';
import 'package:waratel_app/features/ratings/data/models/session_model.dart';
import 'package:waratel_app/features/ratings/logic/cubit/ratings_cubit.dart';
import 'package:waratel_app/features/ratings/logic/cubit/ratings_state.dart';
import 'package:waratel_app/features/ratings/ui/maqraa_room_screen.dart';
import 'package:waratel_app/core/routing/routers.dart';
import 'package:waratel_app/features/record/data/models/session_model.dart';
import 'package:waratel_app/features/record/logic/cubit/record_cubit.dart';
import 'package:waratel_app/features/record/logic/cubit/record_state.dart';

class RatingsScreen extends StatefulWidget {
  const RatingsScreen({super.key});

  @override
  State<RatingsScreen> createState() => _RatingsScreenState();
}

class _RatingsScreenState extends State<RatingsScreen> {
  bool _isNavigating = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<RatingsCubit>()..checkStatus(),
      child: BlocConsumer<RatingsCubit, RatingsState>(
        listener: (context, state) {
          if (state is RatingsSessionStarted && !_isNavigating) {
            _isNavigating = true;
            Navigator.of(context)
                .push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<RatingsCubit>(),
                  child: MaqraaRoomScreen(
                    session: state.session,
                    agoraData: state.agoraData,
                  ),
                ),
              ),
            )
                .then((_) {
              _isNavigating = false;
              if (context.mounted) {
                context.read<RatingsCubit>().checkStatus();
              }
            });
          }
          if (state is RatingsSessionEnded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.green),
            );
          }
          if (state is RatingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        buildWhen: (previous, current) =>
            current is RatingsInitial ||
            current is RatingsLoading ||
            current is RatingsLoaded ||
            current is RatingsError,
        builder: (context, state) {
          return Column(
            children: [
              CustomAppHeader(title: 'maqraa_title'.tr(context)),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async =>
                      context.read<RatingsCubit>().checkStatus(),
                  color: ColorsManager.primaryColor,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.7,
                      ),
                      color: ColorsManager.backgroundColor,
                      padding: EdgeInsets.all(16.w),
                      child: _buildBody(context, state),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, RatingsState state) {
    if (state is RatingsLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is RatingsLoaded) {
      if (state.sessions.isEmpty) {
        return _buildEmptySessions(context);
      }
      return _buildSessionsList(context, state.sessions);
    } else if (state is RatingsError) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(state.message, textAlign: TextAlign.center),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: () => context.read<RatingsCubit>().checkStatus(),
            child: Text('retry'.tr(context)),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildEmptySessions(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80.sp, color: Colors.grey),
          SizedBox(height: 20.h),
          Text(
            'no_scheduled_sessions_now'.tr(context),
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsList(BuildContext context, List<SessionItem> sessions) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sessions.length,
      separatorBuilder: (context, index) => SizedBox(height: 15.h),
      itemBuilder: (context, index) {
        final session = sessions[index];
        return _buildSessionCard(context, session);
      },
    );
  }

  Widget _buildSessionCard(BuildContext context, SessionItem session) {
    bool isEnded = session.isEnded;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  session.title,
                  style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: ColorsManager.primaryColor),
                ),
              ),
              _statusChip(context, session.status),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.access_time, size: 16.sp, color: Colors.grey),
              SizedBox(width: 5.w),
              Text(
                '${session.startTime.hour}:${session.startTime.minute.toString().padLeft(2, "0")} - ${session.durationMinutes} ${'minutes_label'.tr(context)}',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.people, size: 16.sp, color: Colors.grey),
                  SizedBox(width: 5.w),
                  Text(
                    '${'capacity'.tr(context)} ${session.maxParticipants} ${'students_count'.tr(context)}',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
              if (!isEnded)
                ElevatedButton(
                  onPressed: () =>
                      context.read<RatingsCubit>().startMaqraa(session),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsManager.primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                  ),
                  child: Text('start_session'.tr(context),
                      style: const TextStyle(color: Colors.white)),
                )
              else
                TextButton.icon(
                  onPressed: () {
                    final recordCubit = getIt<RecordCubit>();
                    // Try to find a matching session in records by title/trackName or time
                    final recordedSession = recordCubit.state is RecordLoaded
                        ? (recordCubit.state as RecordLoaded)
                            .sessions
                            .firstWhere(
                              (s) =>
                                  s.trackName == session.title ||
                                  s.studentName == session.title,
                              orElse: () => SessionModel(
                                studentName: session.title,
                                date: session.startAt.split('T')[0],
                                time: session.startAt
                                    .split('T')[1]
                                    .substring(0, 5),
                                duration:
                                    '${session.durationMinutes} ${'minutes_label'.tr(context)}',
                                trackName: 'maqraa_session'.tr(context),
                                status: 'ended'.tr(context),
                                notes: '',
                                nextAssignment: '',
                                rating: '',
                                isPresent: true,
                              ),
                            )
                        : null;

                    if (recordedSession != null &&
                        recordedSession.notes.isNotEmpty) {
                      Navigator.pushNamed(
                        context,
                        Routes.sessionDetails,
                        arguments: recordedSession,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('no_report_available'.tr(context))),
                      );
                    }
                  },
                  icon: const Icon(Icons.assignment_outlined, size: 18),
                  label: Text('view_report'.tr(context),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(BuildContext context, String status) {
    Color color;
    String label;

    switch (status) {
      case 'ongoing':
        color = Colors.green;
        label = 'ongoing_now'.tr(context);
        break;
      case 'scheduled':
        color = Colors.blue;
        label = 'scheduled'.tr(context);
        break;
      case 'ended':
        color = Colors.grey;
        label = 'ended'.tr(context);
        break;
      default:
        color = Colors.orange;
        label = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 12.sp, fontWeight: FontWeight.bold),
      ),
    );
  }
}

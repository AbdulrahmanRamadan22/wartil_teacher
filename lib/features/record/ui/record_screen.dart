import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waratel_app/core/theming/colors.dart';
import 'package:waratel_app/features/localization/data/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waratel_app/core/di/dependency_injection.dart';
import 'package:waratel_app/core/widgets/custom_app_header.dart';
import 'package:waratel_app/features/record/logic/cubit/record_cubit.dart';
import 'package:waratel_app/features/record/logic/cubit/record_state.dart';
import 'package:waratel_app/features/record/ui/widgets/session_card.dart';
import 'package:waratel_app/core/routing/routers.dart';

class RecordScreen extends StatelessWidget {
  const RecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<RecordCubit>(),
      child: Column(
        children: [
          CustomAppHeader(title: 'sessions'.tr(context)),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => context.read<RecordCubit>().loadSessions(),
              color: ColorsManager.primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      'sessions_record'.tr(context),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: ColorsManager.textPrimaryColor,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // Subtitle
                    Text(
                      'sessions_history_subtitle'.tr(context),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Sessions List
                    BlocBuilder<RecordCubit, RecordState>(
                      builder: (context, state) {
                        if (state is RecordLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (state is RecordLoaded) {
                          if (state.sessions.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 80.h),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(24.r),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.assignment_outlined,
                                          size: 80.sp, color: Colors.grey[300]),
                                    ),
                                    SizedBox(height: 24.h),
                                    Text(
                                      'no_recorded_sessions'.tr(context),
                                      style: TextStyle(
                                          color: ColorsManager.textPrimaryColor
                                              .withValues(alpha: 0.6),
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      'sessions_history_subtitle'.tr(context),
                                      style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 13.sp),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.sessions.length,
                            itemBuilder: (context, index) {
                              final session = state.sessions[index];
                              return SessionCard(
                                studentName: session.studentName,
                                time: session.time,
                                duration: session.duration,
                                date: session.date,
                                status: session.isPresent
                                    ? 'present'.tr(context)
                                    : 'absent'.tr(context),
                                statusColor: session.isPresent
                                    ? Colors.blue
                                    : Colors.red,
                                reportCenter: 'view_report'.tr(context),
                                onReportTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    Routes.sessionDetails,
                                    arguments: session,
                                  );
                                },
                              );
                            },
                          );
                        } else if (state is RecordError) {
                          return Center(
                            child: Text(
                              state.error,
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

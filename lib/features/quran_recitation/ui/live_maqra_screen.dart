import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waratel_app/features/quran_recitation/logic/quran_recitation_cubit.dart';
import 'package:waratel_app/features/quran_recitation/logic/quran_recitation_state.dart';
import 'package:waratel_app/features/ratings/data/models/session_model.dart';
import 'package:waratel_app/core/helpers/extensions.dart';
import 'package:waratel_app/features/quran_recitation/ui/widgets/recitation_shimmer.dart';
import 'package:waratel_app/core/theming/colors.dart';

class QuranRecitationScreen extends StatelessWidget {
  const QuranRecitationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'المقرأة الجماعية',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0D5C4D),
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section Subtitle
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
              child: Text(
                'حلقات ذكر وتلاوة جماعية أونلاين، انضم لطلاب العلم من كل مكان.',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: ColorsManager.textPrimaryColor.withValues(alpha: 0.6),
                  height: 1.4,
                ),
              ),
            ),

            // Custom Tab Bar
            Container(
              margin: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              child: TabBar(
                indicatorColor: ColorsManager.primaryColor,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: ColorsManager.primaryColor,
                unselectedLabelColor:
                    ColorsManager.textPrimaryColor.withValues(alpha: 0.6),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  fontFamily: 'Cairo',
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                  fontFamily: 'Cairo',
                ),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'الجارية الآن'),
                  Tab(text: 'القادمة'),
                  Tab(text: 'المسجلة'),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: BlocBuilder<QuranRecitationCubit, QuranRecitationState>(
                builder: (context, state) {
                  if (state is GetSessionsLoading ||
                      (state is QuranRecitationInitial &&
                          !context.read<QuranRecitationCubit>().isLoaded)) {
                    return const RecitationShimmer();
                  } else if (state is GetSessionsFailure) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(state.error),
                          SizedBox(height: 16.h),
                          ElevatedButton(
                            onPressed: () => context
                                .read<QuranRecitationCubit>()
                                .getSessions(isRefresh: true),
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    );
                  }

                  final sessions = (state is GetSessionsSuccess)
                      ? state.sessions
                      : context.read<QuranRecitationCubit>().sessions;

                  return TabBarView(
                    children: [
                      _buildOngoingTab(context, sessions),
                      _buildUpcomingTab(context, sessions),
                      _buildRecordedTab(context, sessions),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOngoingTab(BuildContext context, List<SessionItem> sessions) {
    final ongoing = sessions
        .where((s) => s.status == 'ongoing' || s.status == 'live')
        .toList();

    if (ongoing.isEmpty) {
      return RefreshIndicator(
        onRefresh: () =>
            context.read<QuranRecitationCubit>().getSessions(isRefresh: true),
        color: ColorsManager.primaryColor,
        child: _buildEmptyState(
          icon: Icons.mic_off_rounded,
          title: 'لا يوجد حلقات جارية الآن',
          subtitle: 'سيتم إشعارك فور بدء أي حلقة جديدة.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          context.read<QuranRecitationCubit>().getSessions(isRefresh: true),
      color: ColorsManager.primaryColor,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 100.h),
        itemCount: ongoing.length,
        itemBuilder: (context, index) {
          final session = ongoing[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: _buildMaqraCard(
              context: context,
              session: session,
              icon: Icons.headset_mic_rounded,
              iconBg: ColorsManager.primaryColor.withValues(alpha: 0.1),
              iconColor: ColorsManager.primaryColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildUpcomingTab(BuildContext context, List<SessionItem> sessions) {
    final upcoming = sessions
        .where((s) => s.status == 'upcoming' || s.status == 'scheduled')
        .toList();

    if (upcoming.isEmpty) {
      return RefreshIndicator(
        onRefresh: () =>
            context.read<QuranRecitationCubit>().getSessions(isRefresh: true),
        color: ColorsManager.primaryColor,
        child: _buildEmptyState(
          icon: Icons.event_note_rounded,
          title: 'لا توجد حلقات قادمة حالياً',
          subtitle: 'ترقب الحلقات القادمة من معلميك المفضلين.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          context.read<QuranRecitationCubit>().getSessions(isRefresh: true),
      color: ColorsManager.primaryColor,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 100.h),
        itemCount: upcoming.length,
        itemBuilder: (context, index) {
          final session = upcoming[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: _buildMaqraCard(
              context: context,
              session: session,
              icon: Icons.auto_stories_rounded,
              iconBg: Colors.blue.withValues(alpha: 0.1),
              iconColor: Colors.blue,
              buttonText: 'تذكير',
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecordedTab(BuildContext context, List<SessionItem> sessions) {
    // For now, using mock data as in original, but fixing the call
    return RefreshIndicator(
      onRefresh: () =>
          context.read<QuranRecitationCubit>().getSessions(isRefresh: true),
      color: ColorsManager.primaryColor,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 100.h),
        children: [
          _buildMaqraCard(
            context: context,
            title: 'مراجعة أحكام التجويد',
            teacher: 'الشيخ أيمن سويد',
            participants: '850 مشاهدة',
            startDate: 'أمس',
            startTime: '04:00 م',
            endTime: '04:45 م',
            icon: Icons.videocam_rounded,
            iconBg: Colors.pink.withValues(alpha: 0.1),
            iconColor: Colors.pink,
            buttonText: 'مشاهدة',
          ),
        ],
      ),
    );
  }

  Widget _buildMaqraCard({
    required BuildContext context,
    SessionItem? session,
    String? title,
    String? teacher,
    String? participants,
    String? startDate,
    String? startTime,
    String? endTime,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    String buttonText = 'دخول',
  }) {
    final displayStartDate = session?.startAt.formatToDate ?? startDate ?? '';
    final displayStartTime = session?.startAt.formatToTime ?? startTime ?? '';
    final displayEndTime = session?.endAt.formatToTime ?? endTime ?? '';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(icon, color: iconColor, size: 24.sp),
              ),

              SizedBox(width: 12.w),

              // Title & Teacher
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session?.title ?? title ?? '',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      session?.teacher?.user?.name ?? teacher ?? '',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: ColorsManager.textPrimaryColor
                            .withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Action Button (Now on the Left in RTL)
              ElevatedButton(
                onPressed: () {
                  if (session?.id != null) {
                    context
                        .read<QuranRecitationCubit>()
                        .joinSession(session!.id);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsManager.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 8.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  buttonText,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),
          Divider(color: Colors.grey[100]),
          SizedBox(height: 12.h),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Participants
              Row(
                children: [
                  Icon(Icons.group_outlined, color: Colors.grey, size: 16.sp),
                  SizedBox(width: 4.w),
                  Text(
                    session != null
                        ? '0 مشارك' // SessionItem doesn't have participantsCount, will mock for now
                        : participants ?? '0 مشارك',
                    style: TextStyle(color: Colors.grey, fontSize: 11.sp),
                  ),
                ],
              ),

              // Time Info
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Date
                    if (displayStartDate.isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              color: ColorsManager.primaryColor, size: 14.sp),
                          SizedBox(width: 4.w),
                          Text(
                            displayStartDate,
                            style: TextStyle(
                              color: ColorsManager.primaryColor,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    if (displayStartDate.isNotEmpty &&
                        displayStartTime.isNotEmpty)
                      SizedBox(width: 8.w),
                    // From - To Time
                    if (displayStartTime.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'من $displayStartTime',
                              style: TextStyle(
                                color: Colors.orange[800],
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (displayEndTime.isNotEmpty) ...[
                              Text(
                                ' إلى ',
                                style: TextStyle(
                                  color: Colors.orange[400],
                                  fontSize: 9.sp,
                                ),
                              ),
                              Text(
                                displayEndTime,
                                style: TextStyle(
                                  color: Colors.orange[800],
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: 0.6.sh,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: ColorsManager.primaryColor.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 64.sp,
                  color: ColorsManager.primaryColor.withValues(alpha: 0.2),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: ColorsManager.textPrimaryColor,
                ),
              ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color:
                        ColorsManager.textPrimaryColor.withValues(alpha: 0.6),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

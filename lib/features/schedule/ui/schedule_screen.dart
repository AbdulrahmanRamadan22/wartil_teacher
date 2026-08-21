import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waratel_app/core/theming/colors.dart';
import 'package:waratel_app/core/widgets/info_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waratel_app/core/widgets/empty_state_display.dart';
import 'package:waratel_app/features/localization/data/app_localizations.dart';
import 'package:waratel_app/features/schedule/logic/cubit/schedule_state.dart';
import 'package:waratel_app/features/schedule/logic/cubit/schedule_cubit.dart';
import 'package:waratel_app/features/schedule/data/models/schedule_models.dart';
import 'package:waratel_app/core/di/dependency_injection.dart';
import 'package:waratel_app/core/widgets/custom_app_header.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<ScheduleCubit>()..loadSchedule(),
      child: BlocConsumer<ScheduleCubit, ScheduleState>(
        listener: (context, state) {
          if (state is DeleteSlotSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is DeleteSlotError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        buildWhen: (previous, current) =>
            current is ScheduleLoading ||
            current is ScheduleLoaded ||
            current is ScheduleError ||
            current is DeleteSlotLoading,
        builder: (context, state) {
          return Column(children: [
            CustomAppHeader(title: 'schedule_title'.tr(context)),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async =>
                    context.read<ScheduleCubit>().loadSchedule(),
                color: ColorsManager.primaryColor,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(color: Colors.white),
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                    child: Column(
                      children: [
                        // Warning Cards
                        _buildWarningCard(
                          context: context,
                          icon: Icons.calendar_today,
                          title: 'cancel_before_title'.tr(context),
                          subtitle: 'cancel_before_subtitle'.tr(context),
                          iconBgColor: Colors.amber,
                        ),
                        SizedBox(height: 16.h),
                        _buildWarningCard(
                          context: context,
                          icon: Icons.person,
                          title: 'no_show_title'.tr(context),
                          subtitle: 'no_show_subtitle'.tr(context),
                          iconBgColor: Colors.amber,
                        ),
                        SizedBox(height: 20.h),
                        // State handling
                        if (state is ScheduleLoading ||
                            state is DeleteSlotLoading)
                          SizedBox(
                            height: 200.h,
                            child: const Center(
                                child: CircularProgressIndicator()),
                          )
                        else if (state is ScheduleLoaded &&
                            state.calendar.isNotEmpty)
                          _buildCalendarList(context, state)
                        else if (state is ScheduleError)
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline,
                                    size: 48.sp, color: Colors.red),
                                SizedBox(height: 10.h),
                                Text(state.error,
                                    style: TextStyle(fontSize: 14.sp)),
                                SizedBox(height: 10.h),
                                ElevatedButton(
                                  onPressed: () => context
                                      .read<ScheduleCubit>()
                                      .loadSchedule(),
                                  child: Text('retry'.tr(context)),
                                ),
                              ],
                            ),
                          )
                        else
                          EmptyStateDisplay(
                            icon: Icons.calendar_month_outlined,
                            message: 'no_scheduled_appointments'.tr(context),
                            subMessage: 'regular_students_benefit'.tr(context),
                          ),
                        if (state is! ScheduleLoading &&
                            state is! DeleteSlotLoading) ...[
                          SizedBox(height: 10.h),
                          // Add Button
                          SizedBox(
                            width: double.infinity,
                            height: 50.h,
                            child: ElevatedButton(
                              onPressed: () async {
                                final result = await Navigator.pushNamed(
                                    context, '/addAppointment');
                                if (result == true && context.mounted) {
                                  context.read<ScheduleCubit>().loadSchedule();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: ColorsManager.primaryColor,
                                side: BorderSide(
                                    color: ColorsManager.primaryColor
                                        .withValues(alpha: 0.1)),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.r)),
                                elevation: 0,
                              ),
                              child: Text(
                                'add_appointments_now'.tr(context),
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                        ]
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }

  Widget _buildCalendarList(BuildContext context, ScheduleLoaded state) {
    final sortedDates = state.calendar.keys.toList()..sort();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final slots = state.calendar[date]!;
        return RepaintBoundary(
          child: _buildDayCard(context, date, slots),
        );
      },
    );
  }

  Widget _buildDayCard(
      BuildContext context, String date, List<SlotModel> slots) {
    // Format date
    String formattedDate;
    try {
      final parsedDate = DateTime.parse(date);
      formattedDate = DateFormat(
              'EEEE، d MMMM yyyy', Localizations.localeOf(context).languageCode)
          .format(parsedDate);
    } catch (_) {
      formattedDate = date;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Date Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: ColorsManager.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: ColorsManager.primaryColor,
                  ),
                ),
                // Delete all slots for this day
                GestureDetector(
                  onTap: () => _confirmDeleteAll(context, date),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.delete_sweep,
                            size: 16.sp, color: Colors.red),
                        SizedBox(width: 4.w),
                        Text(
                          'delete_all'.tr(context),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Slots
          ...slots.map((slot) => _buildSlotTile(context, slot)),
        ],
      ),
    );
  }

  Widget _buildSlotTile(BuildContext context, SlotModel slot) {
    final startTime = _formatTime(context, slot.startTime);
    final endTime = _formatTime(context, slot.endTime);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          // Time
          Icon(Icons.access_time,
              size: 18.sp, color: ColorsManager.primaryColor),
          SizedBox(width: 8.w),
          Text(
            '$startTime - $endTime',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          // Booked status
          if (slot.isBooked)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'booked'.tr(context),
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            GestureDetector(
              onTap: () => _confirmDeleteSlot(context, slot),
              child: Icon(
                Icons.delete_outline,
                size: 20.sp,
                color: Colors.red.shade300,
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(BuildContext context, String time) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'pm'.tr(context) : 'am'.tr(context);
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } catch (_) {
      return time;
    }
  }

  void _confirmDeleteSlot(BuildContext context, SlotModel slot) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('delete_appointment_title'.tr(context)),
        content: Text(
            '${'delete_appointment_confirm'.tr(context)} (${_formatTime(context, slot.startTime)} - ${_formatTime(context, slot.endTime)})'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('cancel'.tr(context)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ScheduleCubit>().deleteSlot(slot.id);
            },
            child: Text('delete'.tr(context),
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAll(BuildContext context, String date) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('delete_all_appointments_title'.tr(context)),
        content: Text('delete_all_appointments_confirm'.tr(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('cancel'.tr(context)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ScheduleCubit>().deleteSlotsByDay(date);
            },
            child: Text('delete_all'.tr(context),
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard(
      {required BuildContext context,
      required IconData icon,
      required String title,
      required String subtitle,
      required Color iconBgColor}) {
    return InfoCard(
      backgroundColor: const Color(0xFFFFF9E6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14.sp)),
                SizedBox(height: 5.h),
                Text(subtitle,
                    style: TextStyle(fontSize: 12.sp, color: Colors.black54)),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          CircleAvatar(
            backgroundColor: iconBgColor,
            radius: 20.r,
            child: Icon(icon, color: Colors.white, size: 20.sp),
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waratel_app/core/theming/colors.dart';
import 'package:waratel_app/core/di/dependency_injection.dart';
import 'package:waratel_app/features/home/logic/cubit/home_cubit.dart';
import 'package:waratel_app/features/record/logic/cubit/record_cubit.dart';
import 'package:waratel_app/features/record/data/models/session_model.dart';
import 'package:waratel_app/features/localization/data/app_localizations.dart';
import 'package:waratel_app/features/call/data/models/call_model.dart';
import 'package:waratel_app/features/bookings/logic/cubit/bookings_cubit.dart';
import 'package:waratel_app/features/schedule/logic/cubit/schedule_cubit.dart';
import 'package:intl/intl.dart';

class SessionReportDialog extends StatefulWidget {
  final String studentName;
  final String trackName;
  final String? startTime;
  final String? duration;
  final int? sessionId;
  final VoidCallback? onSuccess;

  const SessionReportDialog({
    super.key,
    required this.studentName,
    required this.trackName,
    this.startTime,
    this.duration,
    this.sessionId,
    this.onSuccess,
  });

  @override
  State<SessionReportDialog> createState() => _SessionReportDialogState();
}

class _SessionReportDialogState extends State<SessionReportDialog> {
  final notesController = TextEditingController();
  final nextAssignmentController = TextEditingController();
  String selectedRating = 'excellent';
  bool isPresent = true;

  @override
  void initState() {
    super.initState();
    selectedRating = 'excellent';
  }

  final List<String> ratings = [
    'excellent',
    'very_good',
    'good',
    'needs_follow_up'
  ];

  @override
  void dispose() {
    notesController.dispose();
    nextAssignmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);
    // Use jm() for localized 12h format (e.g. 6:57 PM or 6:57 م)
    final timeStr = widget.startTime ?? DateFormat.jm().format(now);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Container(
        padding: EdgeInsets.all(20.w),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'session_report'.tr(context),
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: ColorsManager.textPrimaryColor,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                'report_instruction'.tr(context),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),

              // Student Info Header (Compact)
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: ColorsManager.primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25.r,
                      backgroundColor:
                          ColorsManager.primaryColor.withValues(alpha: 0.12),
                      child: Icon(Icons.person,
                          color: ColorsManager.primaryColor, size: 30.sp),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.studentName,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: ColorsManager.textPrimaryColor,
                            ),
                          ),
                          Text(
                            widget.trackName,
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: ColorsManager.primaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 15.h),

              // Automatic Data (Date & Time)
              Row(
                children: [
                  _buildAutoDataBox(context, 'date'.tr(context), dateStr,
                      Icons.calendar_today, Colors.blue),
                  SizedBox(width: 8.w),
                  _buildAutoDataBox(context, 'session_time'.tr(context),
                      timeStr, Icons.access_time, Colors.orange),
                  SizedBox(width: 8.w),
                  _buildAutoDataBox(
                      context,
                      'duration_label'.tr(context),
                      widget.duration ?? '00:00',
                      Icons.timer_outlined,
                      Colors.green),
                ],
              ),

              Divider(height: 30.h, color: Colors.grey.shade100),

              // Attendance
              _buildSectionTitle('attendance_status'.tr(context)),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: _buildAttendanceOption(
                      label: 'absent'.tr(context),
                      isSelected: !isPresent,
                      onTap: () => setState(() => isPresent = false),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _buildAttendanceOption(
                      label: 'present'.tr(context),
                      isSelected: isPresent,
                      onTap: () => setState(() => isPresent = true),
                      isPositive: true,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // Rating
              _buildSectionTitle('reception_rating'.tr(context)),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                alignment: WrapAlignment.center,
                children: ratings.map((rating) {
                  return SizedBox(
                    width: (MediaQuery.of(context).size.width - 100.w) /
                        2, // Approx half width
                    child: _buildRatingOption(
                      label: rating.tr(context),
                      isSelected: selectedRating == rating,
                      onTap: () => setState(() => selectedRating = rating),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: 20.h),

              // Notes
              _buildSectionTitle('educational_notes'.tr(context)),
              SizedBox(height: 10.h),
              TextFormField(
                controller: notesController,
                maxLines: 3,
                style: TextStyle(fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: 'educational_notes_hint'.tr(context),
                  hintStyle:
                      TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: ColorsManager.primaryColor),
                  ),
                ),
              ),

              SizedBox(height: 20.h),
              // Next Assignment (Now called Session Content in localizations)
              _buildSectionTitle('next_assignment_label'.tr(context)),
              SizedBox(height: 10.h),
              TextFormField(
                controller: nextAssignmentController,
                style: TextStyle(fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: 'assignment_example'.tr(context),
                  hintStyle:
                      TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  prefixIcon: Icon(Icons.menu_book,
                      color: ColorsManager.primaryColor, size: 20.sp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: ColorsManager.primaryColor),
                  ),
                ),
              ),

              SizedBox(height: 30.h),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveAndEnd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsManager.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'save_report_end_session'.tr(context),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAutoDataBox(BuildContext context, String label, String value,
      IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 12.sp),
                SizedBox(width: 4.w),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(color: Colors.grey, fontSize: 9.sp),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              value,
              style: TextStyle(
                color: ColorsManager.textPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _saveAndEnd() async {
    final now = DateTime.now();

    // Create Session Model
    final session = SessionModel(
      studentName: widget.studentName,
      date: DateFormat('yyyy-MM-dd').format(now),
      time: widget.startTime ?? DateFormat.jm().format(now),
      duration: widget.duration ?? '00:00',
      trackName: widget.trackName,
      status: 'completed'.tr(context),
      notes: notesController.text,
      nextAssignment: nextAssignmentController.text,
      rating: selectedRating.tr(context),
      isPresent: isPresent,
    );

    // Save to RecordCubit
    getIt<RecordCubit>().addSession(session);

    // End Session on Server is already handled by CallCubit before opening this dialog.

    // Refresh All Data Providers
    getIt<HomeCubit>().loadSoon(); // Refresh Home card
    getIt<BookingsCubit>().loadBookings(); // Refresh "My Sessions" tab
    getIt<ScheduleCubit>().loadSchedule(); // Refresh "Schedule" tab

    // Compatibility update for HomeCubit recent calls
    final newReview = CallModel(
      id: 0,
      studentName: widget.studentName,
      status: 'ended',
      durationMinutes: 0,
      date: DateFormat('yyyy-MM-dd').format(now),
      time: DateFormat.jm().format(now),
      rating: 5,
    );
    getIt<HomeCubit>().addCall(newReview);

    // Close Dialog and Call Screen
    if (widget.onSuccess != null) {
      widget.onSuccess!();
    } else {
      if (mounted) {
        Navigator.of(context).pop(); // Close Dialog
        Navigator.of(context).pop(); // Close Call Screen
      }
    }
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.center,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: ColorsManager.primaryColor,
        ),
      ),
    );
  }

  Widget _buildAttendanceOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    bool isPositive = false,
  }) {
    Color activeColor =
        isPositive ? ColorsManager.primaryColor : Colors.redAccent;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey.shade300,
            width: 1.5.w,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? activeColor : Colors.grey.shade500,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? ColorsManager.primaryColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12.r),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : ColorsManager.textPrimaryColor.withValues(alpha: 0.7),
              fontWeight: FontWeight.bold,
              fontSize: 13.sp,
            ),
          ),
        ),
      ),
    );
  }
}

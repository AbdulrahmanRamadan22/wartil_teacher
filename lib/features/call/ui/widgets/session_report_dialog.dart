import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waratel_app/core/theming/colors.dart';
import 'package:waratel_app/core/di/dependency_injection.dart';
import 'package:waratel_app/features/home/logic/cubit/home_cubit.dart';
import 'package:waratel_app/features/record/logic/cubit/record_cubit.dart';
import 'package:waratel_app/features/record/data/models/session_model.dart';
import 'package:waratel_app/features/localization/data/app_localizations.dart';
import 'package:waratel_app/features/call/data/models/call_model.dart';
import 'package:waratel_app/features/call/data/models/student_report_model.dart';
import 'package:waratel_app/features/call/data/repos/calls_repo.dart';
import 'package:waratel_app/features/bookings/logic/cubit/bookings_cubit.dart';
import 'package:waratel_app/features/schedule/logic/cubit/schedule_cubit.dart';
import 'package:intl/intl.dart';

class SessionReportDialog extends StatefulWidget {
  final String studentName;
  final String trackName;
  final String? startTime;
  final String? duration;
  final int? sessionId;
  final int? studentId;
  final String reportableType; // 'call', 'slot', 'session'
  final int? reportableId;
  final bool? initialIsPresent;
  final bool isAttendanceLocked;
  final VoidCallback? onSuccess;
  final VoidCallback? onSkip;

  const SessionReportDialog({
    super.key,
    required this.studentName,
    required this.trackName,
    this.startTime,
    this.duration,
    this.sessionId,
    this.studentId,
    this.reportableType = 'call',
    this.reportableId,
    this.initialIsPresent,
    this.isAttendanceLocked = false,
    this.onSuccess,
    this.onSkip,
  });

  @override
  State<SessionReportDialog> createState() => _SessionReportDialogState();
}

class _SessionReportDialogState extends State<SessionReportDialog> {
  final notesController = TextEditingController();
  final nextAssignmentController = TextEditingController();
  String selectedRating = 'excellent';
  late bool isPresent;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    selectedRating = 'excellent';
    isPresent = widget.initialIsPresent ?? true;
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40), // Balance close icon
                  Expanded(
                    child: Text(
                      'session_report'.tr(context),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: ColorsManager.textPrimaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    splashRadius: 20.r,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      if (widget.onSkip != null) {
                        widget.onSkip!();
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
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

              // Attendance Status
              _buildSectionTitle('attendance_status'.tr(context)),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: _buildAttendanceOption(
                      label: 'absent'.tr(context),
                      isSelected: !isPresent,
                      isEnabled: !widget.isAttendanceLocked,
                      onTap: () {
                        if (!widget.isAttendanceLocked) {
                          setState(() => isPresent = false);
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _buildAttendanceOption(
                      label: 'present'.tr(context),
                      isSelected: isPresent,
                      isEnabled: !widget.isAttendanceLocked,
                      onTap: () {
                        if (!widget.isAttendanceLocked) {
                          setState(() => isPresent = true);
                        }
                      },
                      isPositive: true,
                    ),
                  ),
                ],
              ),

              // If Present: Show Level Rating & Content
              if (isPresent) ...[
                SizedBox(height: 20.h),
                // Reception Level Rating
                _buildSectionTitle('reception_rating'.tr(context)),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  alignment: WrapAlignment.center,
                  children: ratings.map((rating) {
                    return SizedBox(
                      width: (MediaQuery.of(context).size.width - 100.w) / 2,
                      child: _buildRatingOption(
                        label: rating.tr(context),
                        isSelected: selectedRating == rating,
                        onTap: () => setState(() => selectedRating = rating),
                      ),
                    );
                  }).toList(),
                ),
              ],

              SizedBox(height: 20.h),

              // Educational Notes
              _buildSectionTitle('educational_notes'.tr(context)),
              SizedBox(height: 10.h),
              TextFormField(
                controller: notesController,
                maxLines: 3,
                style: TextStyle(fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: isPresent
                      ? 'educational_notes_hint'.tr(context)
                      : 'notes'.tr(context),
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

              if (isPresent) ...[
                SizedBox(height: 20.h),
                // Session Content
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
              ],

              SizedBox(height: 30.h),

              // Submit Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _saveAndEnd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPresent
                        ? ColorsManager.primaryColor
                        : Colors.redAccent,
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: isSubmitting
                      ? SizedBox(
                          height: 20.h,
                          width: 20.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isPresent
                              ? 'save_report_end_session'.tr(context)
                              : 'record_absence'.tr(context),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 8.h),

              // Evaluate Later / Skip Button
              TextButton(
                onPressed: isSubmitting
                    ? null
                    : () {
                        if (widget.onSkip != null) {
                          widget.onSkip!();
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                child: Text(
                  'evaluate_later'.tr(context),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
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
    // ── 0. التقط جميع البيانات المعتمدة على context قبل أي async ─────────────
    if (!mounted) return;
    final statusStr =
        isPresent ? 'completed'.tr(context) : 'absent'.tr(context);
    final ratingStr =
        isPresent ? selectedRating.tr(context) : 'absent'.tr(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (mounted) setState(() => isSubmitting = true);

    final now = DateTime.now();
    final int repId = widget.reportableId ?? widget.sessionId ?? 0;
    int sId = widget.studentId ?? 0;

    // ── 1. Submit report to backend ──────────────────────────────────────────
    if (repId > 0) {
      // If studentId wasn't passed directly, fetch it from call details
      if (sId <= 0 && widget.reportableType == 'call') {
        try {
          final detail = await getIt<CallsRepo>().getCallDetail(repId);
          if (detail.status && detail.data.student.id > 0) {
            sId = detail.data.student.id;
            debugPrint('ℹ️ [REPORT] Retrieved student_id from call details: $sId');
          }
        } catch (e) {
          debugPrint('⚠️ [REPORT] Could not fetch call details for student_id: $e');
        }
      }

      final request = StudentReportRequest(
        studentId: sId,
        reportableType: widget.reportableType,
        reportableId: repId,
        attendanceStatus: isPresent ? 'present' : 'absent',
        receptionLevel: isPresent ? selectedRating : null,
        notes: notesController.text.trim().isNotEmpty
            ? notesController.text.trim()
            : null,
        sessionContent:
            isPresent && nextAssignmentController.text.trim().isNotEmpty
                ? nextAssignmentController.text.trim()
                : null,
      );

      try {
        debugPrint(
            '📤 [REPORT] Submitting → type=${widget.reportableType} '
            'reportable_id=$repId student_id=$sId '
            'attendance=${isPresent ? "present" : "absent"} '
            'level=${isPresent ? selectedRating : "-"}');

        await getIt<CallsRepo>().submitReport(request.toJson());

        debugPrint('✅ [REPORT] Submitted successfully');
      } catch (e) {
        debugPrint('❌ [REPORT] Failed: $e');

        if (mounted) {
          setState(() => isSubmitting = false);
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'فشل إرسال تقرير الجلسة: ${e.toString().replaceFirst("Exception: ", "")}',
                      style: TextStyle(fontSize: 13.sp),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'إعادة المحاولة',
                textColor: Colors.white,
                onPressed: _saveAndEnd,
              ),
            ),
          );
        }
        return; // Keep dialog open so teacher can retry
      }
    } else {
      debugPrint(
          '⚠️ [REPORT] Skipped API call — repId=$repId (no valid reportable ID)');
    }

    // ── 2. Save locally for session history ──────────────────────────────────
    final session = SessionModel(
      studentName: widget.studentName,
      date: DateFormat('yyyy-MM-dd').format(now),
      time: widget.startTime ?? DateFormat.jm().format(now),
      duration: widget.duration ?? '00:00',
      trackName: widget.trackName,
      status: statusStr,
      notes: notesController.text,
      nextAssignment: nextAssignmentController.text,
      rating: ratingStr,
      isPresent: isPresent,
    );
    getIt<RecordCubit>().addSession(session);

    // ── 3. Refresh providers ──────────────────────────────────────────────────
    getIt<HomeCubit>().loadSoon();
    getIt<BookingsCubit>().loadBookings();
    getIt<ScheduleCubit>().loadSchedule();
    getIt<HomeCubit>().addCall(CallModel(
      id: 0,
      studentName: widget.studentName,
      status: 'ended',
      durationMinutes: 0,
      date: DateFormat('yyyy-MM-dd').format(now),
      time: DateFormat.jm().format(now),
      rating: 5,
    ));

    if (mounted) setState(() => isSubmitting = false);

    // ── 4. Close dialog ───────────────────────────────────────────────────────
    if (widget.onSuccess != null) {
      widget.onSuccess!();
    } else {
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
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
    bool isEnabled = true,
    bool isPositive = false,
  }) {
    Color activeColor =
        isPositive ? ColorsManager.primaryColor : Colors.redAccent;

    // Disabled appearance
    if (!isEnabled) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1.w,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
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
      borderRadius: BorderRadius.circular(12.r),
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









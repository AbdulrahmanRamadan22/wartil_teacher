import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waratel_app/core/theming/colors.dart';
import 'package:waratel_app/features/localization/data/app_localizations.dart';
import 'package:waratel_app/features/record/data/models/session_model.dart';

class SessionDetailsScreen extends StatelessWidget {
  final SessionModel session;

  const SessionDetailsScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('session_details'.tr(context)),
        backgroundColor: ColorsManager.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with Student Info
            _buildHeader(context),

            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Core Info Cards
                  Row(
                    children: [
                      _buildInfoBox(context, 'date'.tr(context), session.date,
                          Icons.calendar_today, Colors.blue),
                    ],
                  ),
                  SizedBox(height: 15.h),
                  Row(
                    children: [
                      _buildInfoBox(context, 'duration_label'.tr(context),
                          session.duration, Icons.timer_outlined, Colors.green),
                      SizedBox(width: 15.w),
                      _buildInfoBox(context, 'rating_label'.tr(context),
                          session.rating, Icons.star_outline, Colors.amber),
                    ],
                  ),
                  SizedBox(height: 15.h),
                  Row(
                    children: [
                      _buildInfoBox(
                          context,
                          'status'.tr(context),
                          session.isPresent
                              ? 'present'.tr(context)
                              : 'absent'.tr(context),
                          Icons.check_circle_outline,
                          session.isPresent ? Colors.green : Colors.red),
                    ],
                  ),

                  SizedBox(height: 30.h),

                  // Notes Section
                  _buildContentSection(
                    context,
                    'educational_notes'.tr(context),
                    session.notes.isEmpty
                        ? 'no_notes'.tr(context)
                        : session.notes,
                    Icons.edit_note,
                  ),

                  SizedBox(height: 20.h),

                  // Next Assignment Section
                  _buildContentSection(
                    context,
                    'next_assignment'.tr(context),
                    session.nextAssignment.isEmpty
                        ? 'not_specified'.tr(context)
                        : session.nextAssignment,
                    Icons.menu_book,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          EdgeInsets.only(bottom: 30.h, left: 20.w, right: 20.w, top: 10.h),
      decoration: BoxDecoration(
        color: ColorsManager.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40.r,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Icon(Icons.person, size: 50.sp, color: Colors.white),
          ),
          SizedBox(height: 15.h),
          Text(
            session.studentName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            session.trackName,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(BuildContext context, String label, String value,
      IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24.sp),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(color: Colors.grey, fontSize: 12.sp),
            ),
            SizedBox(height: 4.h),
            Text(
              value,
              style: TextStyle(
                color: ColorsManager.textPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection(
      BuildContext context, String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: ColorsManager.primaryColor, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: ColorsManager.primaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(15.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 14.sp,
              color: ColorsManager.textPrimaryColor.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

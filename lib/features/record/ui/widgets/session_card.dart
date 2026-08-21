import 'package:flutter/material.dart';
import 'package:waratel_app/core/theming/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waratel_app/features/localization/data/app_localizations.dart';

class SessionCard extends StatelessWidget {
  final String studentName;
  final String time;
  final String duration;
  final String date;
  final String status;
  final VoidCallback? onReportTap;
  final String reportCenter;
  final Color statusColor;

  const SessionCard({
    super.key,
    required this.studentName,
    required this.time,
    required this.duration,
    required this.date,
    required this.status,
    required this.reportCenter,
    this.statusColor = Colors.blue,
    this.onReportTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onReportTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100, width: 1.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Student Name & Date
            Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor:
                      ColorsManager.primaryColor.withValues(alpha: 0.1),
                  child: Icon(Icons.person,
                      color: ColorsManager.primaryColor, size: 20.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: ColorsManager.textPrimaryColor,
                        ),
                      ),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            // Rating and Notes Preview
            if (onReportTap != null) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < 4
                            ? Icons.star
                            : Icons
                                .star_border, // Static for now, since rating is String 'ممتاز' etc.
                        color: Colors.amber,
                        size: 14.sp,
                      );
                    }),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'view_report'.tr(context),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Divider(color: Colors.grey.shade100, height: 1),
            ),

            // Time and Details Link
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 16.sp, color: Colors.grey[600]),
                    SizedBox(width: 6.w),
                    Text(
                      time,
                      style:
                          TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                    ),
                    SizedBox(width: 12.w),
                    Icon(Icons.timer_outlined,
                        size: 16.sp, color: Colors.grey[600]),
                    SizedBox(width: 6.w),
                    Text(
                      duration,
                      style:
                          TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'show_details'.tr(context),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: ColorsManager.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        color: ColorsManager.primaryColor, size: 20.sp),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

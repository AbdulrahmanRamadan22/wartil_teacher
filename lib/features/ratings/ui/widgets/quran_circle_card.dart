import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theming/colors.dart';

class QuranCircleCard extends StatelessWidget {
  final String title;
  final String status;
  final int studentCount;
  final int locationCount;
  final bool isActive;
  final double progress;
  final List<String> studentAvatars;

  const QuranCircleCard({
    super.key,
    required this.title,
    required this.status,
    required this.studentCount,
    required this.locationCount,
    required this.isActive,
    required this.progress,
    this.studentAvatars = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: ColorsManager.textPrimaryColor,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.delete_outline,
                        color: Colors.red, size: 20.sp),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.edit_outlined,
                        color: ColorsManager.primaryColor, size: 20.sp),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Status badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: ColorsManager.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: ColorsManager.accentColor,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Stats row
          Row(
            children: [
              _buildStat('الطلاب', studentCount.toString()),
              SizedBox(width: 16.w),
              _buildStat('المكان', locationCount.toString()),
              SizedBox(width: 16.w),
              _buildStat('الحالة', isActive ? 'نشط' : 'غير نشط'),
            ],
          ),
          SizedBox(height: 12.h),

          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'التقدم',
                    style: TextStyle(fontSize: 12.sp, color: Colors.black54),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: ColorsManager.primaryColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor:
                      AlwaysStoppedAnimation<Color>(ColorsManager.primaryColor),
                  minHeight: 8.h,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Student avatars
          if (studentAvatars.isNotEmpty)
            Row(
              children: [
                ...studentAvatars.take(3).map((avatar) => Container(
                      margin: EdgeInsets.only(left: 8.w),
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            ColorsManager.secondaryColor.withValues(alpha: 0.2),
                        border: Border.all(color: Colors.white, width: 2.w),
                      ),
                      child: Icon(Icons.person,
                          size: 16.sp, color: ColorsManager.secondaryColor),
                    )),
              ],
            ),
          SizedBox(height: 16.h),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.access_time, size: 18.sp),
                  label: Text('أوقات تجمع المقرأة',
                      style: TextStyle(fontSize: 12.sp)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColorsManager.textPrimaryColor,
                    side: BorderSide(color: Colors.grey[300]!),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r)),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.meeting_room, size: 18.sp),
                  label: Text('دخول لغرفة المعلم',
                      style: TextStyle(fontSize: 12.sp)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsManager.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(fontSize: 12.sp, color: Colors.black54),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: ColorsManager.textPrimaryColor,
          ),
        ),
      ],
    );
  }
}

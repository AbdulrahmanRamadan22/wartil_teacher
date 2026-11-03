import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waratel_app/core/theming/colors.dart';
import 'package:waratel_app/core/widgets/app_shimmer.dart';

class NotificationsShimmer extends StatelessWidget {
  const NotificationsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        itemCount: 6,
        itemBuilder: (context, index) => Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: ColorsManager.borderColor.withValues(alpha: 0.8),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Squircle icon placeholder
              ShimmerBox(
                width: 48.w,
                height: 48.w,
                radius: 14.r,
              ),

              SizedBox(width: 12.w),

              // Content column placeholder
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ShimmerBox(
                          width: 130.w,
                          height: 14.h,
                          radius: 6.r,
                        ),
                        const Spacer(),
                        ShimmerBox(
                          width: 38.w,
                          height: 16.h,
                          radius: 8.r,
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    ShimmerBox(
                      width: double.infinity,
                      height: 12.h,
                      radius: 4.r,
                    ),
                    SizedBox(height: 6.h),
                    ShimmerBox(
                      width: 160.w,
                      height: 12.h,
                      radius: 4.r,
                    ),
                    SizedBox(height: 10.h),
                    ShimmerBox(
                      width: 70.w,
                      height: 10.h,
                      radius: 4.r,
                    ),
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              // Delete button placeholder
              ShimmerBox(
                width: 32.w,
                height: 32.w,
                radius: 16.r,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

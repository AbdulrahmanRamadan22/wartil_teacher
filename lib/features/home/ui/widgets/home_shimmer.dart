import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waratel_app/core/widgets/app_shimmer.dart';

/// Skeleton loading screen for the home screen — shown while data is loading.
class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    const boneColor = Color(0xFFE4E9E7);

    return AppShimmer(
      baseColor: const Color(0xFFE4E9E7),
      highlightColor: const Color(0xFFF4F8F6),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Ads Banner Skeleton ────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
              child: ShimmerBox(height: 155.h, radius: 16, color: boneColor),
            ),
            SizedBox(height: 10.h),

            // ── Dots row ──────────────────────────────────────────────────
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  3,
                  (i) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                    child: ShimmerBox(
                      width: i == 0 ? 20.w : 8.w,
                      height: 8.h,
                      radius: 4,
                      color: boneColor,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // ── Stats toggle card ──────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: ShimmerBox(height: 80.h, radius: 12, color: boneColor),
            ),
            SizedBox(height: 16.h),

            // ── Next session card ──────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: ShimmerBox(height: 110.h, radius: 16, color: boneColor),
            ),
            SizedBox(height: 20.h),

            // ── Section header skeleton ────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerBox(width: 130.w, height: 14.h, radius: 4, color: boneColor),
                  ShimmerBox(width: 60.w, height: 12.h, radius: 4, color: boneColor),
                ],
              ),
            ),
            SizedBox(height: 12.h),

            // ── Recent calls list skeleton ─────────────────────────────────
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: 4,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (_, __) => Row(
                children: [
                  ShimmerBox(
                    width: 48.w,
                    height: 48.h,
                    radius: 12,
                    color: boneColor,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(
                          width: 120.w,
                          height: 13.h,
                          radius: 4,
                          color: boneColor,
                        ),
                        SizedBox(height: 6.h),
                        ShimmerBox(
                          width: 80.w,
                          height: 11.h,
                          radius: 4,
                          color: boneColor,
                        ),
                      ],
                    ),
                  ),
                  ShimmerBox(width: 50.w, height: 22.h, radius: 20, color: boneColor),
                ],
              ),
            ),
            SizedBox(height: 30.h),
          ],
        ),
      );
  }
}

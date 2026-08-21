import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waratel_app/core/theming/colors.dart';
import 'package:waratel_app/features/localization/data/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _features = [
    _FeatureData(
        'around_the_clock', 'around_the_clock_desc', Icons.access_time_filled),
    _FeatureData('different_ages', 'different_ages_desc', Icons.groups),
    _FeatureData('flexible_plans', 'flexible_plans_desc', Icons.calendar_month),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.backgroundColor,
      appBar: AppBar(title: Text('about_title'.tr(context))),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Gradient hero section ────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 40.h),
              decoration: const BoxDecoration(
                gradient: ColorsManager.headerGradient,
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(18.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child:
                        Icon(Icons.menu_book, color: Colors.white, size: 42.sp),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'why_us'.tr(context),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: ColorsManager.accentColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'unique_experience'.tr(context),
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'unique_experience_desc'.tr(context),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            // ── Feature cards ────────────────────────────────────────────
            ..._features.map((f) => _FeatureItem(
                  titleKey: f.titleKey,
                  descKey: f.descKey,
                  icon: f.icon,
                )),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}

class _FeatureData {
  const _FeatureData(this.titleKey, this.descKey, this.icon);
  final String titleKey, descKey;
  final IconData icon;
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.titleKey,
    required this.descKey,
    required this.icon,
  });

  final String titleKey, descKey;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: ColorsManager.surfaceColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: ColorsManager.accentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: ColorsManager.accentColor, size: 28.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleKey.tr(context),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: ColorsManager.textPrimaryColor,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  descKey.tr(context),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: ColorsManager.textSecondaryColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

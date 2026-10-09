import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waratel_app/core/di/dependency_injection.dart';
import 'package:waratel_app/core/routing/routers.dart';
import 'package:waratel_app/core/theming/colors.dart';
import 'package:waratel_app/features/achievement_plan/logic/cubit/achievement_plan_cubit.dart';
import 'package:waratel_app/features/achievement_plan/logic/cubit/achievement_plan_state.dart';
import 'package:waratel_app/features/achievement_plan/data/models/teacher_preferences.dart';

class AchievementPlanSummaryCard extends StatelessWidget {
  const AchievementPlanSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<AchievementPlanCubit>(),
      child: BlocBuilder<AchievementPlanCubit, AchievementPlanState>(
        builder: (context, state) {
          final prefs = state is AchievementPlanLoaded
              ? state.preferences
              : getIt<AchievementPlanCubit>().currentPreferences;

          final isEmpty = prefs.learningPaths.isEmpty &&
              prefs.ageGroups.isEmpty &&
              prefs.studentLevels.isEmpty &&
              prefs.workHoursPerWeek == 0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Section Header ────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6.r),
                          decoration: BoxDecoration(
                            gradient: ColorsManager.primaryGradient,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(Icons.emoji_events_rounded,
                              color: Colors.white, size: 16.sp),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'خطة الإنجاز',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: ColorsManager.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(
                          context, Routes.achievementPlan),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: ColorsManager.primaryColor
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.edit_rounded,
                                size: 13.sp,
                                color: ColorsManager.primaryColor),
                            SizedBox(width: 4.w),
                            Text(
                              'تعديل',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: ColorsManager.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Card ─────────────────────────────────────────────────
              isEmpty
                  ? _buildEmptyState(context)
                  : _buildFilledCard(context, prefs),
            ],
          );
        },
      ),
    );
  }

  // ── Empty State ─────────────────────────────────────────────────────────
  Widget _buildEmptyState(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, Routes.achievementPlan),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: ColorsManager.primaryColor.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: ColorsManager.primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add_chart_rounded,
                  color: ColorsManager.primaryColor, size: 30.sp),
            ),
            SizedBox(height: 12.h),
            Text(
              'لم تُحدّد خطة إنجازك بعد',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: ColorsManager.textPrimaryColor,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'اضغط هنا لتحديد تفضيلاتك التعليمية',
              style: TextStyle(
                fontSize: 12.sp,
                color: ColorsManager.textSecondaryColor,
              ),
            ),
            SizedBox(height: 14.h),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              decoration: BoxDecoration(
                gradient: ColorsManager.primaryGradient,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'إعداد خطة الإنجاز',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Filled Card ─────────────────────────────────────────────────────────
  Widget _buildFilledCard(BuildContext context, TeacherPreferences prefs) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Work Hours Banner ───────────────────────────────────────
          if (prefs.workHoursPerWeek > 0)
            Container(
              width: double.infinity,
              padding:
                  EdgeInsets.symmetric(vertical: 14.h, horizontal: 18.w),
              decoration: BoxDecoration(
                gradient: ColorsManager.primaryGradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.r),
                  topRight: Radius.circular(18.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.access_time_rounded,
                      color: Colors.white70, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'ساعات العمل الأسبوعية',
                    style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '${prefs.workHoursPerWeek} ساعة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // ── Learning Paths ────────────────────────────────────
                if (prefs.learningPaths.isNotEmpty) ...[
                  _buildCategoryRow(
                    icon: Icons.route_rounded,
                    title: 'مسارات التعلم',
                    color: ColorsManager.primaryColor,
                    items: prefs.learningPaths,
                    labelMap: const {
                      'talqin': 'تلقين',
                      'tilawat': 'تلاوة',
                      'tasmie': 'تسميع',
                      'iqra_ijaza': 'إقراء وإجازة',
                    },
                  ),
                  SizedBox(height: 14.h),
                ],

                // ── Age Groups ────────────────────────────────────────
                if (prefs.ageGroups.isNotEmpty) ...[
                  _buildCategoryRow(
                    icon: Icons.people_alt_rounded,
                    title: 'الفئات العمرية',
                    color: ColorsManager.secondaryColor,
                    items: prefs.ageGroups,
                    labelMap: const {},
                  ),
                  SizedBox(height: 14.h),
                ],

                // ── Student Levels ─────────────────────────────────────
                if (prefs.studentLevels.isNotEmpty)
                  _buildCategoryRow(
                    icon: Icons.school_rounded,
                    title: 'مستوى الطلاب',
                    color: ColorsManager.accentColor,
                    items: prefs.studentLevels,
                    labelMap: const {
                      'beginner': 'مبتدئ',
                      'intermediate': 'متوسط',
                      'advanced': 'متقدم',
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Category Row Builder ────────────────────────────────────────────────
  Widget _buildCategoryRow({
    required IconData icon,
    required String title,
    required Color color,
    required Map<String, int> items,
    required Map<String, String> labelMap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(5.r),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(7.r),
              ),
              child: Icon(icon, color: color, size: 14.sp),
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: ColorsManager.textPrimaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: items.entries.map((e) {
            final displayLabel = labelMap[e.key] ?? e.key;
            return _buildItemChip(
                label: displayLabel, value: e.value, color: color);
          }).toList(),
        ),
        SizedBox(height: 8.h),
        _buildProgressBar(items, color),
      ],
    );
  }

  // ── Item Chip ───────────────────────────────────────────────────────────
  Widget _buildItemChip({
    required String label,
    required int value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 5.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              '$value%',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Progress Bar ────────────────────────────────────────────────────────
  Widget _buildProgressBar(Map<String, int> items, Color color) {
    final total = items.values.fold(0, (sum, v) => sum + v);
    final isOver = total > 100;

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: (total / 100).clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(
                  isOver ? ColorsManager.errorColor : color),
              minHeight: 4.h,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          '$total%',
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
            color: isOver ? ColorsManager.errorColor : color,
          ),
        ),
      ],
    );
  }
}

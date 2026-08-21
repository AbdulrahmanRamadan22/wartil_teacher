import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waratel_app/core/theming/colors.dart';
import 'package:waratel_app/features/achievement_plan/logic/cubit/achievement_plan_cubit.dart';
import 'package:waratel_app/features/achievement_plan/logic/cubit/achievement_plan_state.dart';
import 'package:waratel_app/core/di/dependency_injection.dart';
import 'package:waratel_app/features/localization/data/app_localizations.dart';

class AchievementPlanScreen extends StatefulWidget {
  const AchievementPlanScreen({super.key});

  @override
  State<AchievementPlanScreen> createState() => _AchievementPlanScreenState();
}

class _AchievementPlanScreenState extends State<AchievementPlanScreen> {
  final TextEditingController _workHoursController = TextEditingController();

  @override
  void dispose() {
    _workHoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AchievementPlanCubit>(),
      child: BlocConsumer<AchievementPlanCubit, AchievementPlanState>(
        listener: (context, state) {
          if (state is AchievementPlanSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AchievementPlanError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AchievementPlanLoaded) {
            _workHoursController.text =
                state.preferences.workHoursPerWeek.toString();
          }
        },
        builder: (context, state) {
          final cubit = context.read<AchievementPlanCubit>();

          if (state is AchievementPlanLoading) {
            return Scaffold(
              backgroundColor: ColorsManager.backgroundColor,
              appBar: AppBar(
                title: Text('achievement_plan'.tr(context)),
                backgroundColor: ColorsManager.primaryColor,
                foregroundColor: Colors.white,
                centerTitle: true,
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          final prefs = state is AchievementPlanLoaded
              ? state.preferences
              : cubit.currentPreferences;

          return Scaffold(
            backgroundColor: ColorsManager.backgroundColor,
            appBar: AppBar(
              title: Text('achievement_plan'.tr(context)),
              backgroundColor: ColorsManager.primaryColor,
              foregroundColor: Colors.white,
              centerTitle: true,
            ),
            body: RefreshIndicator(
              onRefresh: () async => cubit.loadPreferences(),
              color: ColorsManager.primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.0.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      context: context,
                      title: 'learning_path_prefs'.tr(context),
                      items: {
                        'talqin'.tr(context): prefs.learningPaths['talqin'] ??
                            prefs.learningPaths['تلقين'],
                        'tilawat'.tr(context): prefs.learningPaths['tilawat'] ??
                            prefs.learningPaths['تلاوة'],
                        'tasmie'.tr(context): prefs.learningPaths['tasmie'] ??
                            prefs.learningPaths['تسميع'],
                        'iqra_ijaza'.tr(context):
                            prefs.learningPaths['iqra_ijaza'] ??
                                prefs.learningPaths['إقراء وإجازة'],
                      },
                      onToggle: (key) => cubit.toggleLearningPath(key),
                      onAdjust: (key, delta) =>
                          cubit.adjustPercentage('learningPaths', key, delta),
                      isWide: (key) => key == 'iqra_ijaza'.tr(context),
                    ),
                    SizedBox(height: 20.h),
                    _buildSection(
                      context: context,
                      title: 'age_group_prefs'.tr(context),
                      items: {
                        '5-12': prefs.ageGroups['5-12'],
                        '13-59': prefs.ageGroups['13-59'],
                        '+60': prefs.ageGroups['+60'],
                      },
                      onToggle: (key) => cubit.toggleAgeGroup(key),
                      onAdjust: (key, delta) =>
                          cubit.adjustPercentage('ageGroups', key, delta),
                    ),
                    SizedBox(height: 20.h),
                    _buildSection(
                      context: context,
                      title: 'student_level_prefs'.tr(context),
                      items: {
                        'beginner'.tr(context):
                            prefs.studentLevels['beginner'] ??
                                prefs.studentLevels['مبتدئ'],
                        'intermediate'.tr(context):
                            prefs.studentLevels['intermediate'] ??
                                prefs.studentLevels['متوسط'],
                        'advanced'.tr(context):
                            prefs.studentLevels['advanced'] ??
                                prefs.studentLevels['متقدم'],
                      },
                      onToggle: (key) => cubit.toggleStudentLevel(key),
                      onAdjust: (key, delta) =>
                          cubit.adjustPercentage('studentLevels', key, delta),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'expected_work_hours'.tr(context),
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.sp),
                    ),
                    SizedBox(height: 10.h),
                    TextField(
                      controller: _workHoursController,
                      decoration: InputDecoration(
                        hintText: '20',
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final hours = int.tryParse(value) ?? 0;
                        cubit.updateWorkHours(hours);
                      },
                    ),
                    SizedBox(height: 30.h),
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: () => cubit.savePreferences(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsManager.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 2,
                        ),
                        child: Text('save_preferences'.tr(context),
                            style: TextStyle(fontSize: 16.sp)),
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required Map<String, int?> items,
    required Function(String) onToggle,
    required Function(String, int) onAdjust,
    bool Function(String)? isWide,
  }) {
    final totalPercentage =
        items.values.where((v) => v != null).fold(0, (sum, v) => sum + v!);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.info_outline,
                  color: ColorsManager.secondaryColor, size: 24.sp),
              onPressed: () {},
            ),
            Text(title,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            Text('$totalPercentage%',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
          ],
        ),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          alignment: WrapAlignment.end,
          children: items.entries.map((entry) {
            final isSelected = entry.value != null;
            final wide = isWide?.call(entry.key) ?? false;

            return _buildPreferenceItem(
              label: entry.key,
              value: entry.value ?? 0,
              isSelected: isSelected,
              isWide: wide,
              onToggle: () => onToggle(entry.key),
              onIncrease: () => onAdjust(entry.key, 10),
              onDecrease: () => onAdjust(entry.key, -10),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPreferenceItem({
    required String label,
    required int value,
    required bool isSelected,
    required bool isWide,
    required VoidCallback onToggle,
    required VoidCallback onIncrease,
    required VoidCallback onDecrease,
  }) {
    return Container(
      width: isWide ? double.infinity : 100.w,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: isSelected ? ColorsManager.primaryColor : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: onToggle,
                child: Icon(
                  isSelected ? Icons.check_circle : Icons.check_circle_outline,
                  color: isSelected ? Colors.white : Colors.grey,
                  size: 16.sp,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(width: 4.w),
            ],
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: isSelected ? onDecrease : null,
                  child: Icon(
                    Icons.remove_circle_outline,
                    size: 16.sp,
                    color:
                        isSelected ? ColorsManager.secondaryColor : Colors.grey,
                  ),
                ),
                Text(
                  '$value%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.black : Colors.grey,
                  ),
                ),
                InkWell(
                  onTap: isSelected ? onIncrease : null,
                  child: Icon(
                    Icons.add_circle_outline,
                    size: 16.sp,
                    color:
                        isSelected ? ColorsManager.secondaryColor : Colors.grey,
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _AchievementPlanScreenState extends State<AchievementPlanScreen>
    with TickerProviderStateMixin {
  final TextEditingController _workHoursController = TextEditingController();
  late AnimationController _headerAnimCtrl;
  late Animation<double> _headerFadeAnim;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _headerAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerFadeAnim = CurvedAnimation(
      parent: _headerAnimCtrl,
      curve: Curves.easeOut,
    );
    _headerAnimCtrl.forward();
  }

  @override
  void dispose() {
    _workHoursController.dispose();
    _headerAnimCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<AchievementPlanCubit>(),
      child: BlocConsumer<AchievementPlanCubit, AchievementPlanState>(
        listener: (context, state) {
          if (state is AchievementPlanSuccess) {
            setState(() => _isSaving = false);
            _showSuccessSnackBar(context, state.message);
          } else if (state is AchievementPlanError) {
            setState(() => _isSaving = false);
            _showErrorSnackBar(context, state.error);
          } else if (state is AchievementPlanLoaded) {
            final hours = state.preferences.workHoursPerWeek;
            if (_workHoursController.text != hours.toString()) {
              _workHoursController.text = hours == 0 ? '' : hours.toString();
            }
          }
        },
        builder: (context, state) {
          final cubit = context.read<AchievementPlanCubit>();

          if (state is AchievementPlanLoading && !_isSaving) {
            return Scaffold(
              backgroundColor: ColorsManager.backgroundColor,
              body: Center(
                child: CircularProgressIndicator(
                    color: ColorsManager.primaryColor),
              ),
            );
          }

          final prefs = state is AchievementPlanLoaded
              ? state.preferences
              : cubit.currentPreferences;

          return Scaffold(
            backgroundColor: ColorsManager.backgroundColor,
            body: CustomScrollView(
              slivers: [
                // ── Gradient SliverAppBar ─────────────────────────────
                SliverAppBar(
                  expandedHeight: 165.h,
                  pinned: true,
                  backgroundColor: ColorsManager.primaryDark,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: FadeTransition(
                      opacity: _headerFadeAnim,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: ColorsManager.headerGradient,
                        ),
                        child: SafeArea(
                          bottom: false,
                          child: Center(
                            child: SingleChildScrollView(
                              physics: const NeverScrollableScrollPhysics(),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(height: 6.h),
                                  Container(
                                    padding: EdgeInsets.all(10.r),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.emoji_events_rounded,
                                        color: Colors.white, size: 28.sp),
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    'achievement_plan'.tr(context),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.cloud_done_rounded,
                                          color: Colors.white70, size: 12.sp),
                                      SizedBox(width: 4.w),
                                      Text(
                                        'يُحفظ تلقائياً',
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 11.sp),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Content ───────────────────────────────────────────
                SliverPadding(
                  padding: EdgeInsets.all(16.w),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildSectionCard(
                        context: context,
                        icon: Icons.route_rounded,
                        title: 'learning_path_prefs'.tr(context),
                        color: ColorsManager.primaryColor,
                        items: {
                          'talqin'.tr(context): prefs.learningPaths['talqin'] ??
                              prefs.learningPaths['تلقين'],
                          'tilawat'.tr(context):
                              prefs.learningPaths['tilawat'] ??
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
                      SizedBox(height: 16.h),
                      _buildSectionCard(
                        context: context,
                        icon: Icons.people_alt_rounded,
                        title: 'age_group_prefs'.tr(context),
                        color: ColorsManager.secondaryColor,
                        items: {
                          '5-12': prefs.ageGroups['5-12'],
                          '13-59': prefs.ageGroups['13-59'],
                          '+60': prefs.ageGroups['+60'],
                        },
                        onToggle: (key) => cubit.toggleAgeGroup(key),
                        onAdjust: (key, delta) =>
                            cubit.adjustPercentage('ageGroups', key, delta),
                      ),
                      SizedBox(height: 16.h),
                      _buildSectionCard(
                        context: context,
                        icon: Icons.school_rounded,
                        title: 'student_level_prefs'.tr(context),
                        color: ColorsManager.accentColor,
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
                      SizedBox(height: 16.h),
                      _buildWorkHoursCard(context, cubit),
                      SizedBox(height: 24.h),
                      _buildSaveButton(context, cubit),
                      SizedBox(height: 30.h),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required Map<String, int?> items,
    required Function(String) onToggle,
    required Function(String, int) onAdjust,
    bool Function(String)? isWide,
  }) {
    final totalPercentage =
        items.values.where((v) => v != null).fold(0, (sum, v) => sum + v!);
    final isOver = totalPercentage > 100;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.07),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(7.r),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(9.r),
                  ),
                  child: Icon(icon, color: color, size: 18.sp),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(title,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                          fontSize: 14.sp, fontWeight: FontWeight.bold)),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isOver
                        ? ColorsManager.errorColor.withValues(alpha: 0.10)
                        : color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                        color: isOver ? ColorsManager.errorColor : color),
                  ),
                  child: Text('$totalPercentage%',
                      style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: isOver ? ColorsManager.errorColor : color)),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: (totalPercentage / 100).clamp(0.0, 1.0),
                backgroundColor: Colors.grey.shade100,
                valueColor: AlwaysStoppedAnimation<Color>(
                    isOver ? ColorsManager.errorColor : color),
                minHeight: 5.h,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
            child: Wrap(
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
                  accentColor: color,
                  onToggle: () => onToggle(entry.key),
                  onIncrease: () => onAdjust(entry.key, 10),
                  onDecrease: () => onAdjust(entry.key, -10),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceItem({
    required String label,
    required int value,
    required bool isSelected,
    required bool isWide,
    required Color accentColor,
    required VoidCallback onToggle,
    required VoidCallback onIncrease,
    required VoidCallback onDecrease,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
      width: isWide ? double.infinity : 105.w,
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [accentColor, accentColor.withValues(alpha: 0.78)],
              )
            : null,
        color: isSelected ? null : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isSelected ? accentColor : Colors.grey.shade200,
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                    color: accentColor.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3))
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onToggle();
          },
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        key: ValueKey(isSelected),
                        color:
                            isSelected ? Colors.white : Colors.grey.shade400,
                        size: 16.sp,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : ColorsManager.textPrimaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 11.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                  ],
                ),
                SizedBox(height: 8.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.20)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: isSelected
                            ? () {
                                HapticFeedback.selectionClick();
                                onDecrease();
                              }
                            : null,
                        child: Icon(Icons.remove_rounded,
                            size: 16.sp,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade400),
                      ),
                      Text('$value%',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.sp,
                              color: isSelected ? Colors.white : Colors.grey)),
                      GestureDetector(
                        onTap: isSelected
                            ? () {
                                HapticFeedback.selectionClick();
                                onIncrease();
                              }
                            : null,
                        child: Icon(Icons.add_rounded,
                            size: 16.sp,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade400),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkHoursCard(
      BuildContext context, AchievementPlanCubit cubit) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.primaryColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(7.r),
                decoration: BoxDecoration(
                  color: ColorsManager.accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9.r),
                ),
                child: Icon(Icons.access_time_rounded,
                    color: ColorsManager.accentColor, size: 18.sp),
              ),
              SizedBox(width: 10.w),
              Text(
                'expected_work_hours'.tr(context),
                style: TextStyle(
                    fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          TextField(
            controller: _workHoursController,
            decoration: InputDecoration(
              hintText: '20',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              suffixText: 'ساعة/أسبوع',
              suffixStyle: TextStyle(
                color: ColorsManager.primaryColor,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
              filled: true,
              fillColor: ColorsManager.backgroundColor,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide:
                    BorderSide(color: ColorsManager.primaryColor, width: 1.5),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) {
              final hours = int.tryParse(value) ?? 0;
              cubit.updateWorkHours(hours);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, AchievementPlanCubit cubit) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [ColorsManager.primaryDark, ColorsManager.primaryLight],
          ),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: ColorsManager.primaryColor.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _isSaving
              ? null
              : () async {
                  setState(() => _isSaving = true);
                  HapticFeedback.mediumImpact();
                  await cubit.savePreferences();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r)),
          ),
          icon: _isSaving
              ? SizedBox(
                  width: 18.w,
                  height: 18.h,
                  child: const CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : Icon(Icons.save_rounded, color: Colors.white, size: 20.sp),
          label: Text(
            _isSaving ? 'جاري الحفظ...' : 'save_preferences'.tr(context),
            style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_rounded, color: Colors.white),
        SizedBox(width: 10.w),
        Expanded(child: Text(msg)),
      ]),
      backgroundColor: ColorsManager.successColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      margin: EdgeInsets.all(16.w),
    ));
  }

  void _showErrorSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error_rounded, color: Colors.white),
        SizedBox(width: 10.w),
        Expanded(child: Text(msg)),
      ]),
      backgroundColor: ColorsManager.errorColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      margin: EdgeInsets.all(16.w),
    ));
  }
}

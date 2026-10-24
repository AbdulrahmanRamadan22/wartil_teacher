import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waratel_app/core/theming/colors.dart';
import 'package:waratel_app/features/achievement_plan/logic/cubit/achievement_plan_cubit.dart';
import 'package:waratel_app/features/achievement_plan/logic/cubit/achievement_plan_state.dart';
import 'package:waratel_app/core/di/dependency_injection.dart';
import 'package:waratel_app/features/localization/data/app_localizations.dart';

class _PreferenceItemData {
  final String key;
  final String label;
  final String subtitle;
  final IconData icon;
  final int? value;

  const _PreferenceItemData({
    required this.key,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.value,
  });

  bool get isSelected => value != null;
}

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
            return const Scaffold(
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
                // ── Header SliverAppBar ──────────────────────────────
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
                                      color:
                                          Colors.white.withValues(alpha: 0.15),
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
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.cloud_done_rounded,
                                          color: Colors.white70, size: 14.sp),
                                      SizedBox(width: 4.w),
                                      Text(
                                        'يُحفظ تلقائياً عند أي تعديل',
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12.sp),
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
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Info Banner
                      _buildInfoBanner(context),
                      SizedBox(height: 16.h),

                      // Section 1: Learning Paths
                      _buildSectionCard(
                        context: context,
                        icon: Icons.route_rounded,
                        title: 'learning_path_prefs'.tr(context),
                        subtitle:
                            'حدد المسارات القرآنية المفضلة والنسبة المئوية لكل مسار',
                        color: ColorsManager.primaryColor,
                        items: [
                          _PreferenceItemData(
                            key: 'talqin',
                            label: 'talqin'.tr(context),
                            subtitle: 'تحفيظ القرآن بالتلقين والترديد للآيات',
                            icon: Icons.record_voice_over_rounded,
                            value: prefs.learningPaths['talqin'] ??
                                prefs.learningPaths['تلقين'],
                          ),
                          _PreferenceItemData(
                            key: 'tilawat',
                            label: 'tilawat'.tr(context),
                            subtitle: 'تصحيح وضبط التلاوة وأحكام التجويد',
                            icon: Icons.menu_book_rounded,
                            value: prefs.learningPaths['tilawat'] ??
                                prefs.learningPaths['تلاوة'],
                          ),
                          _PreferenceItemData(
                            key: 'tasmie',
                            label: 'tasmie'.tr(context),
                            subtitle: 'مراجعة وتسميع الحفظ والمثبت للطلاب',
                            icon: Icons.hearing_rounded,
                            value: prefs.learningPaths['tasmie'] ??
                                prefs.learningPaths['تسميع'],
                          ),
                          _PreferenceItemData(
                            key: 'iqra_ijaza',
                            label: 'iqra_ijaza'.tr(context),
                            subtitle: 'الإقراء بالسند المتصل ومنح الإجازة',
                            icon: Icons.workspace_premium_rounded,
                            value: prefs.learningPaths['iqra_ijaza'] ??
                                prefs.learningPaths['إقراء وإجازة'],
                          ),
                        ],
                        onToggle: (key) => cubit.toggleLearningPath(key),
                        onAdjust: (key, delta) =>
                            cubit.adjustPercentage('learningPaths', key, delta),
                      ),
                      SizedBox(height: 18.h),

                      // Section 2: Age Groups
                      _buildSectionCard(
                        context: context,
                        icon: Icons.groups_rounded,
                        title: 'age_group_prefs'.tr(context),
                        subtitle: 'حدد الفئات العمرية التي ترغب في استقبالها',
                        color: ColorsManager.secondaryColor,
                        items: [
                          _PreferenceItemData(
                            key: '5-12',
                            label: '5 - 12 سنة',
                            subtitle: 'فئة الأطفال والناشئة',
                            icon: Icons.child_care_rounded,
                            value: prefs.ageGroups['5-12'],
                          ),
                          _PreferenceItemData(
                            key: '13-59',
                            label: '13 - 59 سنة',
                            subtitle: 'فئة الشباب والبالغين',
                            icon: Icons.person_rounded,
                            value: prefs.ageGroups['13-59'],
                          ),
                          _PreferenceItemData(
                            key: '+60',
                            label: '+60 سنة',
                            subtitle: 'فئة كبار السن',
                            icon: Icons.elderly_rounded,
                            value: prefs.ageGroups['+60'],
                          ),
                        ],
                        onToggle: (key) => cubit.toggleAgeGroup(key),
                        onAdjust: (key, delta) =>
                            cubit.adjustPercentage('ageGroups', key, delta),
                      ),
                      SizedBox(height: 18.h),

                      // Section 3: Student Levels
                      _buildSectionCard(
                        context: context,
                        icon: Icons.school_rounded,
                        title: 'student_level_prefs'.tr(context),
                        subtitle:
                            'حدد مستويات الطلاب المناسبة لقدراتك التعليمية',
                        color: ColorsManager.accentColor,
                        items: [
                          _PreferenceItemData(
                            key: 'beginner',
                            label: 'beginner'.tr(context),
                            subtitle: 'تأسيس القراءة وأبجديات التجويد',
                            icon: Icons.trending_up_rounded,
                            value: prefs.studentLevels['beginner'] ??
                                prefs.studentLevels['مبتدئ'],
                          ),
                          _PreferenceItemData(
                            key: 'intermediate',
                            label: 'intermediate'.tr(context),
                            subtitle: 'ضبط مخارج الحروف والطلاقة في التلاوة',
                            icon: Icons.auto_awesome_rounded,
                            value: prefs.studentLevels['intermediate'] ??
                                prefs.studentLevels['متوسط'],
                          ),
                          _PreferenceItemData(
                            key: 'advanced',
                            label: 'advanced'.tr(context),
                            subtitle: 'القراءات والتجويد المتقدم والإتقان التام',
                            icon: Icons.military_tech_rounded,
                            value: prefs.studentLevels['advanced'] ??
                                prefs.studentLevels['متقدم'],
                          ),
                        ],
                        onToggle: (key) => cubit.toggleStudentLevel(key),
                        onAdjust: (key, delta) =>
                            cubit.adjustPercentage('studentLevels', key, delta),
                      ),
                      SizedBox(height: 18.h),

                      // Section 4: Work Hours Card
                      _buildWorkHoursCard(context, cubit),
                      SizedBox(height: 24.h),

                      // Save Button
                      _buildSaveButton(context, cubit),
                      SizedBox(height: 36.h),
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

  // ── Info Banner ─────────────────────────────────────────────────────────
  Widget _buildInfoBanner(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: ColorsManager.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: ColorsManager.primaryColor.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: ColorsManager.primaryColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.tips_and_updates_rounded,
                color: ColorsManager.primaryColor, size: 18.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تلميح لتوزيع الخطة',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: ColorsManager.primaryColor,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'قم بتفعيل الخيارات التي تناسبك واستخدم أزرار الزيادة والنقصان الكبيرة لتحديد النسبة. يُفضل أن يكون مجموع نسب كل قسم 100%.',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: ColorsManager.textSecondaryColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Card Builder ────────────────────────────────────────────────
  Widget _buildSectionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required List<_PreferenceItemData> items,
    required Function(String) onToggle,
    required Function(String, int) onAdjust,
  }) {
    final totalPercentage =
        items.where((it) => it.isSelected).fold(0, (sum, it) => sum + it.value!);
    final isOver = totalPercentage > 100;
    final isComplete = totalPercentage == 100;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.06),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.r),
                topRight: Radius.circular(18.r),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(icon, color: color, size: 20.sp),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: ColorsManager.textPrimaryColor,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: ColorsManager.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    // Total Percentage Badge
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: isOver
                            ? ColorsManager.errorColor.withValues(alpha: 0.12)
                            : isComplete
                                ? ColorsManager.successColor
                                    .withValues(alpha: 0.12)
                                : color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: isOver
                              ? ColorsManager.errorColor
                              : isComplete
                                  ? ColorsManager.successColor
                                  : color,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isComplete)
                            Padding(
                              padding: EdgeInsetsDirectional.only(end: 4.w),
                              child: Icon(Icons.check_circle_rounded,
                                  size: 13.sp,
                                  color: ColorsManager.successColor),
                            )
                          else if (isOver)
                            Padding(
                              padding: EdgeInsetsDirectional.only(end: 4.w),
                              child: Icon(Icons.warning_amber_rounded,
                                  size: 13.sp,
                                  color: ColorsManager.errorColor),
                            ),
                          Text(
                            '$totalPercentage%',
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.bold,
                              color: isOver
                                  ? ColorsManager.errorColor
                                  : isComplete
                                      ? ColorsManager.successColor
                                      : color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: (totalPercentage / 100).clamp(0.0, 1.0),
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isOver
                          ? ColorsManager.errorColor
                          : isComplete
                              ? ColorsManager.successColor
                              : color,
                    ),
                    minHeight: 6.h,
                  ),
                ),
                // Helper status text
                if (isOver) ...[
                  SizedBox(height: 6.h),
                  Text(
                    '⚠️ المجموع يتجاوز 100% ($totalPercentage%)، يرجى تخفيض إحدى النسب للموازنة.',
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      color: ColorsManager.errorColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ] else if (isComplete) ...[
                  SizedBox(height: 6.h),
                  Text(
                    '✓ المجموع متوازن تماماً (100%).',
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      color: ColorsManager.successColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ] else if (totalPercentage > 0) ...[
                  SizedBox(height: 6.h),
                  Text(
                    'متبقي ${100 - totalPercentage}% للوصول إلى النسبة المثالية (100%).',
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      color: ColorsManager.textSecondaryColor,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Items List
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              children: items.map((item) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: _buildPreferenceCard(
                    item: item,
                    accentColor: color,
                    onToggle: () => onToggle(item.key),
                    onIncrease: () => onAdjust(item.key, 10),
                    onDecrease: () => onAdjust(item.key, -10),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Preference Item Card with LARGE Stepper Buttons ────────────────────
  Widget _buildPreferenceCard({
    required _PreferenceItemData item,
    required Color accentColor,
    required VoidCallback onToggle,
    required VoidCallback onIncrease,
    required VoidCallback onDecrease,
  }) {
    final isSelected = item.isSelected;
    final value = item.value ?? 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isSelected
              ? accentColor.withValues(alpha: 0.35)
              : Colors.grey.shade200,
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: Column(
        children: [
          // Header Row (Tap to toggle)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onToggle();
              },
              borderRadius: BorderRadius.circular(14.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                child: Row(
                  children: [
                    // Item Icon
                    Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? accentColor.withValues(alpha: 0.15)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        item.icon,
                        size: 20.sp,
                        color: isSelected ? accentColor : Colors.grey.shade500,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // Item Title and Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? ColorsManager.textPrimaryColor
                                  : Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            item.subtitle,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: isSelected
                                  ? ColorsManager.textSecondaryColor
                                  : Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    // Toggle pill button / status
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onToggle();
                      },
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? accentColor
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.check_circle_rounded
                                  : Icons.add_circle_outline_rounded,
                              size: 14.sp,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.shade600,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              isSelected ? 'مفعل' : 'تفعيل',
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Stepper & Percentage Controls (When selected)
          if (isSelected) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Divider(
                height: 1,
                thickness: 1,
                color: accentColor.withValues(alpha: 0.12),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 12.h),
              child: Row(
                children: [
                  // Label for percentage
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'النسبة المخصصة:',
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w600,
                            color: ColorsManager.textSecondaryColor,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        // Mini progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3.r),
                          child: LinearProgressIndicator(
                            value: (value / 100).clamp(0.0, 1.0),
                            backgroundColor: Colors.grey.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              accentColor,
                            ),
                            minHeight: 5.h,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 14.w),

                  // ── Stepper Controls with LARGE TOUCH TARGETS ──
                  Container(
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.15),
                      ),
                    ),
                    padding: EdgeInsets.all(4.r),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Decrease Button (-)
                        _buildStepperButton(
                          icon: Icons.remove_rounded,
                          color: accentColor,
                          isEnabled: value > 0,
                          tooltip: 'إنقاص 10%',
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onDecrease();
                          },
                        ),

                        // Percentage Value Display
                        Container(
                          constraints: BoxConstraints(minWidth: 58.w),
                          height: 42.h,
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(horizontal: 6.w),
                          child: Text(
                            '$value%',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: ColorsManager.textPrimaryColor,
                            ),
                          ),
                        ),

                        // Increase Button (+)
                        _buildStepperButton(
                          icon: Icons.add_rounded,
                          color: accentColor,
                          isEnabled: value < 100,
                          tooltip: 'زيادة 10%',
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onIncrease();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Large Touch Target Stepper Button ──────────────────────────────────
  Widget _buildStepperButton({
    required IconData icon,
    required Color color,
    required bool isEnabled,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(10.r),
        child: Ink(
          width: 44.w,
          height: 42.h,
          decoration: BoxDecoration(
            color: isEnabled
                ? color.withValues(alpha: 0.15)
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isEnabled
                  ? color.withValues(alpha: 0.3)
                  : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 22.sp,
              color: isEnabled ? color : Colors.grey.shade400,
            ),
          ),
        ),
      ),
    );
  }

  // ── Work Hours Card ─────────────────────────────────────────────────────
  Widget _buildWorkHoursCard(
      BuildContext context, AchievementPlanCubit cubit) {
    final currentHours = cubit.workHours;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.primaryColor.withValues(alpha: 0.08),
            blurRadius: 14,
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
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: ColorsManager.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.access_time_filled_rounded,
                    color: ColorsManager.primaryColor, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'expected_work_hours'.tr(context),
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.bold,
                        color: ColorsManager.textPrimaryColor,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'عدد الساعات التي يمكنك تدريسها أسبوعياً',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: ColorsManager.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Stepper + TextField Row
          Row(
            children: [
              // Minus 5 hours button
              _buildLargeWorkHourButton(
                icon: Icons.remove_rounded,
                onTap: () {
                  HapticFeedback.selectionClick();
                  final current = int.tryParse(_workHoursController.text) ?? 0;
                  final newHours = (current - 5).clamp(0, 168);
                  _workHoursController.text =
                      newHours == 0 ? '' : newHours.toString();
                  cubit.updateWorkHours(newHours);
                },
              ),
              SizedBox(width: 10.w),

              // Hours TextField
              Expanded(
                child: TextField(
                  controller: _workHoursController,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: ColorsManager.textPrimaryColor,
                  ),
                  decoration: InputDecoration(
                    hintText: '20',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    suffixText: 'ساعة/أسبوع',
                    suffixStyle: TextStyle(
                      color: ColorsManager.primaryColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    filled: true,
                    fillColor: ColorsManager.backgroundColor,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(
                          color: ColorsManager.primaryColor, width: 1.5),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    final hours = int.tryParse(value) ?? 0;
                    cubit.updateWorkHours(hours);
                  },
                ),
              ),
              SizedBox(width: 10.w),

              // Plus 5 hours button
              _buildLargeWorkHourButton(
                icon: Icons.add_rounded,
                onTap: () {
                  HapticFeedback.selectionClick();
                  final current = int.tryParse(_workHoursController.text) ?? 0;
                  final newHours = (current + 5).clamp(0, 168);
                  _workHoursController.text = newHours.toString();
                  cubit.updateWorkHours(newHours);
                },
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Quick preset hour chips
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [10, 15, 20, 25, 30, 40].map((presetHours) {
              final isCurrent = currentHours == presetHours;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _workHoursController.text = presetHours.toString();
                    cubit.updateWorkHours(presetHours);
                  },
                  borderRadius: BorderRadius.circular(20.r),
                  child: Ink(
                    padding: EdgeInsets.symmetric(
                        horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? ColorsManager.primaryColor
                          : ColorsManager.primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: isCurrent
                            ? ColorsManager.primaryColor
                            : ColorsManager.primaryColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      '$presetHours ساعة',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.bold,
                        color: isCurrent
                            ? Colors.white
                            : ColorsManager.primaryColor,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Large Work Hour Button (+/-)
  Widget _buildLargeWorkHourButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Ink(
          width: 48.w,
          height: 48.h,
          decoration: BoxDecoration(
            color: ColorsManager.primaryColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: ColorsManager.primaryColor.withValues(alpha: 0.25),
            ),
          ),
          child: Center(
            child: Icon(icon, color: ColorsManager.primaryColor, size: 24.sp),
          ),
        ),
      ),
    );
  }

  // ── Save Button ─────────────────────────────────────────────────────────
  Widget _buildSaveButton(BuildContext context, AchievementPlanCubit cubit) {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [ColorsManager.primaryDark, ColorsManager.primaryLight],
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: ColorsManager.primaryColor.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 5),
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
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
          icon: _isSaving
              ? SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.2,
                  ),
                )
              : Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 22.sp),
          label: Text(
            _isSaving ? 'جاري الحفظ...' : 'save_preferences'.tr(context),
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
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

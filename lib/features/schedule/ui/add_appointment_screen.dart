import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:waratel_app/core/di/dependency_injection.dart';
import 'package:waratel_app/core/theming/colors.dart';
import 'package:waratel_app/core/widgets/info_card.dart';
import 'package:waratel_app/features/schedule/logic/cubit/schedule_cubit.dart';
import 'package:waratel_app/features/schedule/logic/cubit/schedule_state.dart';
import 'package:waratel_app/features/localization/data/app_localizations.dart';
import 'package:waratel_app/features/localization/logic/cubit/locale_cubit.dart';
import 'package:waratel_app/features/localization/logic/cubit/locale_state.dart';

enum ScheduleInputMode { autoSplitBlock, singleSlot }

class AddAppointmentScreen extends StatefulWidget {
  const AddAppointmentScreen({super.key});

  @override
  State<AddAppointmentScreen> createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  DateTime selectedDate = DateTime.now();

  // Selected time slots for the day [{start_time: '16:00', end_time: '16:30'}]
  final List<Map<String, String>> selectedTimeSlots = [];

  // Input mode: auto-split time block vs single 30-min slot
  ScheduleInputMode _inputMode = ScheduleInputMode.autoSplitBlock;

  // Auto-split block times
  TimeOfDay _blockStartTime = const TimeOfDay(hour: 16, minute: 0); // 04:00 PM
  TimeOfDay _blockEndTime = const TimeOfDay(hour: 20, minute: 0); // 08:00 PM

  // Single slot pickers
  int pickedHour = 10;
  int pickedMinute = 0;
  String pickedPeriod = 'am';

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<ScheduleCubit>(),
      child: BlocConsumer<ScheduleCubit, ScheduleState>(
        listener: (context, state) {
          if (state is AddSlotsSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.white),
                    SizedBox(width: 8.w),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: ColorsManager.successColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            );
            Navigator.pop(context, true);
          } else if (state is AddSlotsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: Colors.white),
                    SizedBox(width: 8.w),
                    Expanded(child: Text(state.error)),
                  ],
                ),
                backgroundColor: ColorsManager.errorColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: ColorsManager.primaryColor,
              title: Text(
                'add_appointments'.tr(context),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              elevation: 0,
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info & Warning Cards
                  _buildHeaderInfo(context),
                  SizedBox(height: 20.h),

                  // ── Date Selection Section ──────────────────────────
                  Text(
                    'select_date'.tr(context),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: ColorsManager.textPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  _buildDateSelector(context),
                  SizedBox(height: 8.h),
                  _buildQuickDateChips(),
                  SizedBox(height: 22.h),

                  // ── Mode Switch Tabs ────────────────────────────────
                  _buildModeSelector(),
                  SizedBox(height: 18.h),

                  // ── Active Mode Content ─────────────────────────────
                  if (_inputMode == ScheduleInputMode.autoSplitBlock)
                    _buildAutoSplitSection(context)
                  else
                    _buildSingleSlotPickerSection(context),

                  SizedBox(height: 24.h),

                  // ── Selected Slots Section ──────────────────────────
                  _buildSelectedSlotsSection(context),
                  SizedBox(height: 28.h),

                  // ── Submit Button ───────────────────────────────────
                  _buildSubmitButton(context, state),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Header Notice ────────────────────────────────────────────────────────
  Widget _buildHeaderInfo(BuildContext context) {
    return InfoCard(
      backgroundColor: const Color(0xFFFFF9E6),
      child: Row(
        children: [
          Icon(Icons.tips_and_updates_rounded,
              color: Colors.amber.shade800, size: 24.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'حدد فترة تواجدك وسيقوم النظام تلقائياً بتقسيمها إلى جلسات مدة كل منها 30 دقيقة.',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12.5.sp,
                color: Colors.black87,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Mode Switcher ────────────────────────────────────────────────────────
  Widget _buildModeSelector() {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          // Auto Split Mode Tab
          Expanded(
            child: _buildModeTabItem(
              title: 'تقسيم تلقائي للفترة ⚡',
              subtitle: 'اختر الفترة وسيقسمها تلقائياً',
              mode: ScheduleInputMode.autoSplitBlock,
            ),
          ),
          SizedBox(width: 6.w),
          // Single Slot Tab
          Expanded(
            child: _buildModeTabItem(
              title: 'موعد فردي 🕒',
              subtitle: 'إضافة جلسة واحدة محددة',
              mode: ScheduleInputMode.singleSlot,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTabItem({
    required String title,
    required String subtitle,
    required ScheduleInputMode mode,
  }) {
    final isSelected = _inputMode == mode;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _inputMode = mode);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(11.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? ColorsManager.primaryColor
                    : Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.sp,
                color: isSelected
                    ? ColorsManager.textSecondaryColor
                    : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Auto-Split Time Block Section ─────────────────────────────────────────
  Widget _buildAutoSplitSection(BuildContext context) {
    final generatedSlots = _calculateGeneratedSlots();
    final isValid = generatedSlots.isNotEmpty;
    final totalHours = (generatedSlots.length * 0.5);

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: ColorsManager.primaryColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: ColorsManager.primaryColor.withValues(alpha: 0.22),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: ColorsManager.primaryColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.auto_awesome_rounded,
                    color: ColorsManager.primaryColor, size: 18.sp),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'حدد فترة التواجد (البداية والنهاية)',
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.bold,
                    color: ColorsManager.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Time Range Cards (From -> To)
          Row(
            children: [
              // Start Time Card
              Expanded(
                child: _buildTimePickerCard(
                  label: 'من (وقت البدء)',
                  time: _blockStartTime,
                  icon: Icons.login_rounded,
                  onTap: () => _pickTime(
                    context,
                    initialTime: _blockStartTime,
                    onPicked: (picked) {
                      setState(() => _blockStartTime = picked);
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: ColorsManager.primaryColor,
                  size: 20.sp,
                ),
              ),
              // End Time Card
              Expanded(
                child: _buildTimePickerCard(
                  label: 'إلى (وقت النهاية)',
                  time: _blockEndTime,
                  icon: Icons.logout_rounded,
                  onTap: () => _pickTime(
                    context,
                    initialTime: _blockEndTime,
                    onPicked: (picked) {
                      setState(() => _blockEndTime = picked);
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Quick Shift Presets
          Text(
            'فترات شائعة سريعة:',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: ColorsManager.textSecondaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _buildPresetShiftChip(
                label: 'الذروة: 4 - 8 م ⭐',
                start: const TimeOfDay(hour: 16, minute: 0),
                end: const TimeOfDay(hour: 20, minute: 0),
                isHighlight: true,
              ),
              _buildPresetShiftChip(
                label: 'صباحي: 8 - 12 ص',
                start: const TimeOfDay(hour: 8, minute: 0),
                end: const TimeOfDay(hour: 12, minute: 0),
              ),
              _buildPresetShiftChip(
                label: 'ظهيرة: 12 - 4 م',
                start: const TimeOfDay(hour: 12, minute: 0),
                end: const TimeOfDay(hour: 16, minute: 0),
              ),
              _buildPresetShiftChip(
                label: 'مسائي: 8 - 11 م',
                start: const TimeOfDay(hour: 20, minute: 0),
                end: const TimeOfDay(hour: 23, minute: 0),
              ),
              _buildPresetShiftChip(
                label: 'ليلي: 10 م - 12 ص',
                start: const TimeOfDay(hour: 22, minute: 0),
                end: const TimeOfDay(hour: 0, minute: 0),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Live Preview calculation
          if (isValid) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: ColorsManager.primaryColor.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle_outline_rounded,
                          color: ColorsManager.successColor, size: 18.sp),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          'سيتم توليد ${generatedSlots.length} مواعيد (30 دقيقة لكل موعد - إجمالي $totalHours ساعة)',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: ColorsManager.textPrimaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  // Slots chips preview
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: generatedSlots.take(6).map((slot) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: ColorsManager.primaryColor
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          '${_formatTimeFrom24(context, slot['start_time']!)} - ${_formatTimeFrom24(context, slot['end_time']!)}',
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w600,
                            color: ColorsManager.primaryColor,
                          ),
                        ),
                      );
                    }).toList()
                      ..addAll(generatedSlots.length > 6
                          ? [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  '+${generatedSlots.length - 6} أخرى',
                                  style: TextStyle(
                                    fontSize: 10.5.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ]
                          : []),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: ColorsManager.errorColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: ColorsManager.errorColor.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: ColorsManager.errorColor, size: 18.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'يرجى تحديد فترة لا تقل عن 30 دقيقة (وقت النهاية بعد وقت البدء)',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        color: ColorsManager.errorColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 16.h),

          // Add Block Button
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton.icon(
              onPressed: isValid
                  ? () => _addAutoSplitSlots(generatedSlots)
                  : null,
              icon: const Icon(Icons.playlist_add_check_rounded),
              label: Text(
                'تقسيم وإضافة (${generatedSlots.length}) مواعيد تلقائياً',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsManager.primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Single Slot Picker Section ────────────────────────────────────────────
  Widget _buildSingleSlotPickerSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(
            'حدد وقت بدء الموعد (مدة الجلسة 30 دقيقة تلقائياً)',
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.bold,
              color: ColorsManager.primaryColor,
            ),
          ),
          SizedBox(height: 18.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hour
              _buildPickerColumn(
                context,
                items: List.generate(
                    12, (i) => (i + 1).toString().padLeft(2, '0')),
                value: pickedHour.toString().padLeft(2, '0'),
                label: 'ساعة',
                onChanged: (val) => setState(() => pickedHour = int.parse(val)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 25.h),
                child: Text(':',
                    style: TextStyle(
                        fontSize: 24.sp, fontWeight: FontWeight.bold)),
              ),
              // Minute
              _buildPickerColumn(
                context,
                items: List.generate(60, (i) => i.toString().padLeft(2, '0')),
                value: pickedMinute.toString().padLeft(2, '0'),
                label: 'دقيقة',
                onChanged: (val) =>
                    setState(() => pickedMinute = int.parse(val)),
              ),
              SizedBox(width: 20.w),
              // AM/PM Toggle
              _buildPeriodToggle(context),
            ],
          ),
          SizedBox(height: 20.h),
          ElevatedButton.icon(
            onPressed: _addCurrentSingleSelection,
            icon: const Icon(Icons.add_rounded),
            label: const Text('إضافة هذا الموعد (30 دقيقة)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
          ),
        ],
      ),
    );
  }

  // ── Selected Slots Section ────────────────────────────────────────────────
  Widget _buildSelectedSlotsSection(BuildContext context) {
    if (selectedTimeSlots.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            Icon(Icons.calendar_today_outlined,
                color: Colors.grey.shade400, size: 36.sp),
            SizedBox(height: 8.h),
            Text(
              'لم تقم بإضافة أي مواعيد بعد',
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'اختر فترة زمنية بالأعلى واضغط على "تقسيم وإضافة" لإنشائها بنقرة واحدة.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5.sp,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    final totalHours = (selectedTimeSlots.length * 0.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'المواعيد المختارة (${selectedTimeSlots.length} موعد - $totalHours س)',
              style: TextStyle(
                fontSize: 14.5.sp,
                fontWeight: FontWeight.bold,
                color: ColorsManager.textPrimaryColor,
              ),
            ),
            // Clear All Button
            TextButton.icon(
              onPressed: () {
                setState(() => selectedTimeSlots.clear());
                HapticFeedback.lightImpact();
              },
              icon: Icon(Icons.delete_sweep_rounded,
                  size: 18.sp, color: ColorsManager.errorColor),
              label: Text(
                'مسح الكل',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: ColorsManager.errorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: selectedTimeSlots.map((slot) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: ColorsManager.primaryColor,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: ColorsManager.primaryColor.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule_rounded,
                      color: Colors.white70, size: 14.sp),
                  SizedBox(width: 6.w),
                  Text(
                    '${_formatTimeFrom24(context, slot['start_time']!)} - ${_formatTimeFrom24(context, slot['end_time']!)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        selectedTimeSlots.remove(slot);
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(2.r),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close_rounded,
                          color: Colors.white, size: 14.sp),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Time Picker Card Helper ──────────────────────────────────────────────
  Widget _buildTimePickerCard({
    required String label,
    required TimeOfDay time,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: ColorsManager.textSecondaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatTimeOfDay(context, time),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: ColorsManager.primaryColor,
                    ),
                  ),
                  Icon(icon, color: ColorsManager.primaryColor, size: 18.sp),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Preset Shift Chip ─────────────────────────────────────────────────────
  Widget _buildPresetShiftChip({
    required String label,
    required TimeOfDay start,
    required TimeOfDay end,
    bool isHighlight = false,
  }) {
    final isSelected = _blockStartTime == start && _blockEndTime == end;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _blockStartTime = start;
            _blockEndTime = end;
          });
        },
        borderRadius: BorderRadius.circular(20.r),
        child: Ink(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: isSelected
                ? ColorsManager.primaryColor
                : isHighlight
                    ? Colors.amber.shade50
                    : Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isSelected
                  ? ColorsManager.primaryColor
                  : isHighlight
                      ? Colors.amber.shade400
                      : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? Colors.white
                  : isHighlight
                      ? Colors.amber.shade900
                      : ColorsManager.textPrimaryColor,
            ),
          ),
        ),
      ),
    );
  }

  // ── Auto-Split Logic ──────────────────────────────────────────────────────
  List<Map<String, String>> _calculateGeneratedSlots() {
    int startMinutes = _blockStartTime.hour * 60 + _blockStartTime.minute;
    int endMinutes = _blockEndTime.hour * 60 + _blockEndTime.minute;

    // Handle midnight (00:00) as end of day (24:00)
    if (endMinutes <= startMinutes &&
        _blockEndTime.hour == 0 &&
        _blockEndTime.minute == 0) {
      endMinutes = 24 * 60;
    }

    if (endMinutes <= startMinutes) return [];

    final List<Map<String, String>> slots = [];
    int current = startMinutes;

    while (current + 30 <= endMinutes) {
      int startH = (current ~/ 60) % 24;
      int startM = current % 60;

      int endH = ((current + 30) ~/ 60) % 24;
      int endM = (current + 30) % 60;

      final sStr =
          '${startH.toString().padLeft(2, '0')}:${startM.toString().padLeft(2, '0')}';
      final eStr =
          '${endH.toString().padLeft(2, '0')}:${endM.toString().padLeft(2, '0')}';

      slots.add({
        'start_time': sStr,
        'end_time': eStr,
      });

      current += 30;
    }

    return slots;
  }

  /// Returns true if a slot (given as 'HH:mm') on [selectedDate] is already past.
  bool _isSlotPast(String startTime24) {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final selDay = DateTime(
          selectedDate.year, selectedDate.month, selectedDate.day);
      // Only matters when the selected date is today
      if (selDay != today) return false;
      final parts = startTime24.split(':');
      final slotStart = DateTime(
          now.year, now.month, now.day,
          int.parse(parts[0]), int.parse(parts[1]));
      return now.isAfter(slotStart);
    } catch (_) {
      return false;
    }
  }

  void _addAutoSplitSlots(List<Map<String, String>> newSlots) {
    HapticFeedback.mediumImpact();
    int addedCount = 0;
    int skippedCount = 0;
    int pastCount = 0;

    for (final slot in newSlots) {
      // Reject slots that are already in the past
      if (_isSlotPast(slot['start_time']!)) {
        pastCount++;
        continue;
      }
      final exists =
          selectedTimeSlots.any((s) => s['start_time'] == slot['start_time']);
      if (!exists) {
        selectedTimeSlots.add(slot);
        addedCount++;
      } else {
        skippedCount++;
      }
    }

    if (addedCount == 0 && pastCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'جميع المواعيد المحددة انتهى وقتها. يرجى اختيار فترة مستقبلية.'),
          backgroundColor: ColorsManager.errorColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Sort chronologically
    selectedTimeSlots
        .sort((a, b) => a['start_time']!.compareTo(b['start_time']!));

    setState(() {});

    final msg = skippedCount > 0
        ? 'تمت إضافة $addedCount مواعيد بنجاح (تم تخطي $skippedCount مكرر)'
        : 'تمت إضافة $addedCount مواعيد بنجاح ✓';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: ColorsManager.primaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Single Slot Add ───────────────────────────────────────────────────────
  void _addCurrentSingleSelection() {
    int h24 = pickedHour;
    if (pickedPeriod == 'pm' && h24 < 12) h24 += 12;
    if (pickedPeriod == 'am' && h24 == 12) h24 = 0;

    final String startTime =
        '${h24.toString().padLeft(2, '0')}:${pickedMinute.toString().padLeft(2, '0')}';

    DateTime startDT = DateTime(2000, 1, 1, h24, pickedMinute);
    DateTime endDT = startDT.add(const Duration(minutes: 30));
    final String endTime =
        '${endDT.hour.toString().padLeft(2, '0')}:${endDT.minute.toString().padLeft(2, '0')}';

    // Reject if this slot is already in the past
    if (_isSlotPast(startTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'لا يمكن إضافة موعد في وقت مضى. يرجى اختيار وقت مستقبلي.'),
          backgroundColor: ColorsManager.errorColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final isDuplicate =
        selectedTimeSlots.any((s) => s['start_time'] == startTime);
    if (isDuplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('هذا الموعد مضاف بالفعل في القائمة'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HapticFeedback.selectionClick();
    setState(() {
      selectedTimeSlots.add({
        'start_time': startTime,
        'end_time': endTime,
      });
      selectedTimeSlots
          .sort((a, b) => a['start_time']!.compareTo(b['start_time']!));
    });
  }

  // ── TimePicker Dialog Trigger ─────────────────────────────────────────────
  Future<void> _pickTime(
    BuildContext context, {
    required TimeOfDay initialTime,
    required ValueChanged<TimeOfDay> onPicked,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ColorsManager.primaryColor,
              onPrimary: Colors.white,
              onSurface: ColorsManager.textPrimaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onPicked(picked);
    }
  }

  // ── Date Selector ─────────────────────────────────────────────────────────
  Widget _buildDateSelector(BuildContext context) {
    final lang = context.read<LocaleCubit>().state is ChangeLocaleState
        ? (context.read<LocaleCubit>().state as ChangeLocaleState)
            .locale
            .languageCode
        : 'ar';
    final dateStr = DateFormat('EEEE، d MMMM yyyy', lang).format(selectedDate);

    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime(2036),
          locale: Locale(lang),
        );
        if (picked != null) {
          setState(() {
            selectedDate = picked;
            selectedTimeSlots.clear();
          });
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          border: Border.all(color: ColorsManager.primaryColor, width: 1.2),
          borderRadius: BorderRadius.circular(14.r),
          color: ColorsManager.primaryColor.withValues(alpha: 0.05),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month_rounded,
                    color: ColorsManager.primaryColor, size: 22.sp),
                SizedBox(width: 10.w),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: ColorsManager.primaryColor,
                  ),
                ),
              ],
            ),
            Icon(Icons.arrow_drop_down_circle_outlined,
                color: ColorsManager.primaryColor, size: 18.sp),
          ],
        ),
      ),
    );
  }

  // ── Quick Date Chips ──────────────────────────────────────────────────────
  Widget _buildQuickDateChips() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final afterTomorrow = today.add(const Duration(days: 2));

    return Wrap(
      spacing: 8.w,
      children: [
        _buildDateChip('اليوم', today),
        _buildDateChip('غداً', tomorrow),
        _buildDateChip('بعد غد', afterTomorrow),
      ],
    );
  }

  Widget _buildDateChip(String label, DateTime targetDate) {
    final isSelected = selectedDate.year == targetDate.year &&
        selectedDate.month == targetDate.month &&
        selectedDate.day == targetDate.day;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            selectedDate = targetDate;
            selectedTimeSlots.clear();
          });
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Ink(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: isSelected
                ? ColorsManager.primaryColor
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isSelected
                  ? ColorsManager.primaryColor
                  : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  // ── Picker Helper Wheels ──────────────────────────────────────────────────
  Widget _buildPickerColumn(
    BuildContext context, {
    required List<String> items,
    required String value,
    required String label,
    required Function(String) onChanged,
  }) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
        SizedBox(height: 8.h),
        Container(
          height: 120.h,
          width: 60.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ListWheelScrollView.useDelegate(
            itemExtent: 40.h,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) => onChanged(items[index]),
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: items.length,
              builder: (context, index) {
                final isSelected = items[index] == value;
                return Center(
                  child: Text(
                    items[index],
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? ColorsManager.primaryColor
                          : Colors.black54,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodToggle(BuildContext context) {
    return Column(
      children: [
        Text('الفترة', style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              _buildPeriodOption(
                context,
                label: 'صباحاً',
                value: 'am',
                icon: Icons.wb_sunny,
                iconColor: Colors.amber,
              ),
              Container(height: 1, width: 60.w, color: Colors.grey.shade200),
              _buildPeriodOption(
                context,
                label: 'مساءً',
                value: 'pm',
                icon: Icons.nightlight_round,
                iconColor: ColorsManager.primaryColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodOption(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    final isSelected = pickedPeriod == value;
    return GestureDetector(
      onTap: () => setState(() => pickedPeriod = value),
      child: Container(
        width: 80.w,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorsManager.primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: value == 'am'
              ? BorderRadius.vertical(top: Radius.circular(12.r))
              : BorderRadius.vertical(bottom: Radius.circular(12.r)),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected ? iconColor : Colors.grey, size: 20.sp),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? ColorsManager.primaryColor : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Formatters ────────────────────────────────────────────────────────────
  String _formatTimeFrom24(BuildContext context, String time24) {
    try {
      final parts = time24.split(':');
      int h = int.parse(parts[0]);
      final m = parts[1];
      final p = h >= 12 ? 'pm'.tr(context) : 'am'.tr(context);
      if (h > 12) h -= 12;
      if (h == 0) h = 12;
      return '$h:$m $p';
    } catch (_) {
      return time24;
    }
  }

  String _formatTimeOfDay(BuildContext context, TimeOfDay time) {
    final h24 = time.hour;
    final m = time.minute.toString().padLeft(2, '0');
    final p = h24 >= 12 ? 'pm'.tr(context) : 'am'.tr(context);
    var h12 = h24 > 12 ? h24 - 12 : h24;
    if (h12 == 0) h12 = 12;
    return '$h12:$m $p';
  }

  // ── Submit Button ─────────────────────────────────────────────────────────
  Widget _buildSubmitButton(BuildContext context, ScheduleState state) {
    final hasSlots = selectedTimeSlots.isNotEmpty;
    final count = selectedTimeSlots.length;

    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: hasSlots
              ? const LinearGradient(
                  colors: [ColorsManager.primaryDark, ColorsManager.primaryLight],
                )
              : null,
          color: hasSlots ? null : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: hasSlots
              ? [
                  BoxShadow(
                    color: ColorsManager.primaryColor.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: ElevatedButton.icon(
          onPressed: state is AddSlotsLoading || !hasSlots
              ? null
              : () => _submitSlots(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            disabledForegroundColor: Colors.grey.shade500,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
          icon: state is AddSlotsLoading
              ? SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.2,
                  ),
                )
              : const Icon(Icons.cloud_upload_rounded, color: Colors.white),
          label: Text(
            state is AddSlotsLoading
                ? 'جاري حفظ المواعيد...'
                : hasSlots
                    ? 'حفظ المواعيد ($count موعد)'
                    : 'save_appointments'.tr(context),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _submitSlots(BuildContext context) {
    HapticFeedback.mediumImpact();
    final dateStr = DateFormat('yyyy-MM-dd', 'en').format(selectedDate);
    debugPrint('Submitting Slots: date=$dateStr slots=$selectedTimeSlots');

    context.read<ScheduleCubit>().addSlots(
          date: dateStr,
          slots: selectedTimeSlots,
        );
  }
}

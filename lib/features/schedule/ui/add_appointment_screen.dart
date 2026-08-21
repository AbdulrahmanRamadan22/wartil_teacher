import 'package:flutter/material.dart';
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

class AddAppointmentScreen extends StatefulWidget {
  const AddAppointmentScreen({super.key});

  @override
  State<AddAppointmentScreen> createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  DateTime selectedDate = DateTime.now();
  // Selected time slots for the day
  final List<Map<String, String>> selectedTimeSlots = [];

  // Current picker values
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
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is AddSlotsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
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
                  fontSize: 20.sp,
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
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  // Warning/Info Cards
                  _buildHeaderInfo(context),

                  SizedBox(height: 25.h),

                  // Date Picker
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('select_date'.tr(context),
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 10.h),
                  _buildDateSelector(context),

                  SizedBox(height: 30.h),

                  // New Time Picker Section
                  _buildTimePickerSection(context),

                  SizedBox(height: 30.h),

                  // Selected Slots List
                  if (selectedTimeSlots.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('المواعيد المختارة',
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(height: 10.h),
                    _buildSelectedSlotsList(context),
                    SizedBox(height: 30.h),
                  ],

                  // Submit Button
                  _buildSubmitButton(context, state),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderInfo(BuildContext context) {
    return Column(
      children: [
        InfoCard(
          backgroundColor: const Color(0xFFFFF9E6),
          child: Row(
            children: [
              Expanded(
                  child: Text('schedule_warning_1'.tr(context),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13.sp))),
              SizedBox(width: 8.w),
              Icon(Icons.flash_on, color: Colors.amber, size: 24.sp),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimePickerSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(
            'حدد وقت الموعد (كل موعد 30 دقيقة)',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: ColorsManager.primaryColor,
            ),
          ),
          SizedBox(height: 20.h),
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
              // AM/PM Toggle with Icons
              _buildPeriodToggle(context),
            ],
          ),
          SizedBox(height: 25.h),
          ElevatedButton.icon(
            onPressed: () {
              _addCurrentSelection();
            },
            icon: const Icon(Icons.add),
            label: const Text('إضافة هذا الموعد'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r)),
              padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildSelectedSlotsList(BuildContext context) {
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: selectedTimeSlots.map((slot) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: ColorsManager.primaryColor,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${_formatTimeFrom24(context, slot['start_time']!)} - ${_formatTimeFrom24(context, slot['end_time']!)}',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedTimeSlots.remove(slot);
                  });
                },
                child: Icon(Icons.cancel, color: Colors.white70, size: 18.sp),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubmitButton(BuildContext context, ScheduleState state) {
    return SizedBox(
      width: double.infinity,
      height: 55.h,
      child: ElevatedButton(
        onPressed: state is AddSlotsLoading || selectedTimeSlots.isEmpty
            ? null
            : () => _submitSlots(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorsManager.primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.r)),
          elevation: 2,
        ),
        child: state is AddSlotsLoading
            ? SizedBox(
                width: 24.w,
                height: 24.w,
                child: const CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Text(
                'save_appointments'.tr(context),
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  void _addCurrentSelection() {
    // Convert current pick to 24h format
    int h24 = pickedHour;
    if (pickedPeriod == 'pm' && h24 < 12) h24 += 12;
    if (pickedPeriod == 'am' && h24 == 12) h24 = 0;

    final String startTime =
        '${h24.toString().padLeft(2, '0')}:${pickedMinute.toString().padLeft(2, '0')}';

    // Default 30 min duration
    DateTime startDT = DateTime(2000, 1, 1, h24, pickedMinute);
    DateTime endDT = startDT.add(const Duration(minutes: 30));
    final String endTime =
        '${endDT.hour.toString().padLeft(2, '0')}:${endDT.minute.toString().padLeft(2, '0')}';

    // Check if duplicate
    final isDuplicate =
        selectedTimeSlots.any((s) => s['start_time'] == startTime);
    if (isDuplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('هذا الوقت مضاف بالفعل'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      selectedTimeSlots.add({
        'start_time': startTime,
        'end_time': endTime,
      });
      // Sort by start time
      selectedTimeSlots
          .sort((a, b) => a['start_time']!.compareTo(b['start_time']!));
    });
  }

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
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
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
          border: Border.all(color: ColorsManager.primaryColor),
          borderRadius: BorderRadius.circular(12.r),
          color: ColorsManager.primaryColor.withValues(alpha: 0.05),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dateStr,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: ColorsManager.primaryColor,
              ),
            ),
            Icon(Icons.calendar_today,
                color: ColorsManager.primaryColor, size: 20.sp),
          ],
        ),
      ),
    );
  }

  void _submitSlots(BuildContext context) {
    final dateStr = DateFormat('yyyy-MM-dd', 'en').format(selectedDate);
    debugPrint('Submitting Slots: date=$dateStr slots=$selectedTimeSlots');

    context.read<ScheduleCubit>().addSlots(
          date: dateStr,
          slots: selectedTimeSlots,
        );
  }
}

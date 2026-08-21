import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waratel_app/core/theming/colors.dart';
import 'package:waratel_app/features/localization/data/app_localizations.dart';
import 'package:waratel_app/features/ratings/data/models/session_model.dart';

class MaqraaAttendanceDialog extends StatefulWidget {
  final List<AttendanceStudent> students;
  final String sessionTitle;
  final Function(Map<int, bool> attendance, String notes) onSave;

  const MaqraaAttendanceDialog({
    super.key,
    required this.students,
    required this.sessionTitle,
    required this.onSave,
  });

  @override
  State<MaqraaAttendanceDialog> createState() => _MaqraaAttendanceDialogState();
}

class _MaqraaAttendanceDialogState extends State<MaqraaAttendanceDialog> {
  final Map<int, bool> _attendance = {};
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Default all students to present
    for (var student in widget.students) {
      _attendance[student.id] = true;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Container(
        padding: EdgeInsets.all(20.w),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'attendance_report'.tr(context),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: ColorsManager.primaryColor,
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              widget.sessionTitle,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
            const Divider(),
            SizedBox(
              height: 250.h,
              child: ListView.builder(
                itemCount: widget.students.length,
                itemBuilder: (context, index) {
                  final student = widget.students[index];
                  bool isPresent = _attendance[student.id] ?? false;
                  return CheckboxListTile(
                    title: Text(
                        student.name ??
                            '${'student_label'.tr(context)} ${student.id}',
                        style: TextStyle(fontSize: 14.sp)),
                    value: isPresent,
                    activeColor: ColorsManager.primaryColor,
                    onChanged: (val) {
                      setState(() {
                        _attendance[student.id] = val ?? false;
                      });
                    },
                  );
                },
              ),
            ),
            const Divider(),
            _buildSectionTitle(context, 'notes_label'.tr(context)),
            SizedBox(height: 10.h),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'no_notes'.tr(context),
                hintStyle: TextStyle(fontSize: 12.sp, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('cancel'.tr(context)),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        widget.onSave(_attendance, _notesController.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsManager.primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                    ),
                    child: Text('save_and_end'.tr(context),
                        style: TextStyle(color: Colors.white, fontSize: 13.sp)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: ColorsManager.primaryColor,
        ),
      ),
    );
  }
}

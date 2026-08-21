import 'package:waratel_app/core/theming/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

class EmptyStateDisplay extends StatelessWidget {
  final String message;
  final String? subMessage;
  final IconData? icon;

  const EmptyStateDisplay({
    super.key,
    required this.message,
    this.subMessage,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Container(
            padding: EdgeInsets.all(20.r),
            margin: EdgeInsets.only(bottom: 20.h),
            child: Icon(icon, size: 80.sp, color: ColorsManager.greenLight),
          ),
        ],
        Text(
          message,
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subMessage != null) ...[
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              subMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

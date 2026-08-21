import '../theming/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomPageHeader extends StatelessWidget {
  final String title;
  final Widget child;

  const CustomPageHeader({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 120.h,
              color: ColorsManager.primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.notifications_none, color: Colors.white),
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(Icons.menu, color: Colors.white),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 100.h),
              height: 20.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.r),
                  topRight: Radius.circular(30.r),
                ),
              ),
            ),
          ],
        ),
        Expanded(child: child),
      ],
    );
  }
}

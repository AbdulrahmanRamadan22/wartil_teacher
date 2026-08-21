import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waratel_app/core/theming/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waratel_app/features/home/logic/cubit/home_cubit.dart';
import 'package:waratel_app/features/home/logic/cubit/home_state.dart';
import 'package:waratel_app/features/localization/data/app_localizations.dart';

class RecentCallsList extends StatelessWidget {
  const RecentCallsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) => current is HomeRecentCallsUpdated,
      builder: (context, state) {
        final calls = context.read<HomeCubit>().recentCalls;

        if (calls.isEmpty) {
          return SizedBox(
            height: 100.h,
            child: Center(
              child: Text(
                'no_recent_calls'.tr(context),
                style: TextStyle(color: Colors.grey, fontSize: 13.sp),
              ),
            ),
          );
        }

        return SizedBox(
          height: 130.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            scrollDirection: Axis.horizontal,
            itemCount: calls.length,
            separatorBuilder: (ctx, i) => SizedBox(width: 14.w),
            itemBuilder: (context, index) {
              final call = calls[index];
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: ColorsManager.secondaryColor
                              .withValues(alpha: 0.3),
                          width: 2.w),
                      color: Colors.grey.shade100,
                    ),
                    child: Center(
                      child: Text(
                        _getInitials(call.studentName),
                        style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: ColorsManager.secondaryColor),
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  SizedBox(
                    width: 70.w,
                    child: Text(
                      call.studentName,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: ColorsManager.textPrimaryColor),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}

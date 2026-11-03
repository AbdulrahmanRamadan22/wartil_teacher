import 'package:cached_network_image/cached_network_image.dart';
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
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.grey,
                  fontSize: 13.sp,
                ),
              ),
            ),
          );
        }

        return SizedBox(
          height: 135.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            scrollDirection: Axis.horizontal,
            itemCount: calls.length,
            separatorBuilder: (ctx, i) => SizedBox(width: 14.w),
            itemBuilder: (context, index) {
              final call = calls[index];
              final hasImage = call.studentImageUrl != null &&
                  call.studentImageUrl!.trim().isNotEmpty;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 62.w,
                    height: 62.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ColorsManager.primaryColor.withValues(alpha: 0.25),
                        width: 2.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ColorsManager.primaryColor.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: hasImage
                          ? CachedNetworkImage(
                              imageUrl: call.studentImageUrl!,
                              width: 62.w,
                              height: 62.w,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey.shade100,
                                child: Center(
                                  child: SizedBox(
                                    width: 20.w,
                                    height: 20.w,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        ColorsManager.primaryColor
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  _buildInitialsAvatar(call.studentName),
                            )
                          : _buildInitialsAvatar(call.studentName),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  SizedBox(
                    width: 72.w,
                    child: Text(
                      call.studentName,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: ColorsManager.textPrimaryColor,
                      ),
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

  Widget _buildInitialsAvatar(String name) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorsManager.primaryColor.withValues(alpha: 0.12),
            ColorsManager.secondaryColor.withValues(alpha: 0.18),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          _getInitials(name),
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: ColorsManager.primaryColor,
          ),
        ),
      ),
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

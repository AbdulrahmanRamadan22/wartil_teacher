import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waratel_app/core/routing/routers.dart';
import 'package:waratel_app/core/theming/colors.dart';
import 'package:waratel_app/features/profile/logic/cubit/profile_cubit.dart';
import 'package:waratel_app/features/profile/logic/cubit/profile_state.dart';
import 'package:waratel_app/core/widgets/notification_icon_button.dart';
import 'package:waratel_app/features/localization/data/app_localizations.dart';
import 'package:waratel_app/features/notifications/logic/cubit/notifications_cubit.dart';
import 'package:waratel_app/features/notifications/logic/cubit/notifications_state.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// A clean, white home header — matches wrattel-development style.
/// No heavy gradient background; accent comes from the teal avatar ring.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (prev, curr) =>
          curr is ProfileLoaded || curr is ProfileLoading,
      builder: (context, state) {
        final name = state is ProfileLoaded
            ? (state.profileResponse.user?.name ?? 'teacher'.tr(context))
            : 'teacher'.tr(context);
        final photoPath = state is ProfileLoaded
            ? state.profileResponse.profile?.profilePhotoPath
            : null;

        return Container(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                // ── Menu button ──────────────────────────────────────────────
                InkWell(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: ColorsManager.backgroundColor,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.menu_rounded,
                      color: ColorsManager.textPrimaryColor,
                      size: 22.sp,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),

                // ── Profile avatar ───────────────────────────────────────────
                InkWell(
                  onTap: () => Navigator.pushNamed(context, Routes.profile),
                  borderRadius: BorderRadius.circular(24.r),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ColorsManager.primaryColor,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 20.r,
                      backgroundColor: ColorsManager.greenExtraLight,
                      backgroundImage: photoPath != null
                          ? CachedNetworkImageProvider(
                                  'https://wartil.com/storage/$photoPath')
                              as ImageProvider
                          : null,
                      child: photoPath == null
                          ? Icon(
                              Icons.person,
                              color: ColorsManager.primaryColor,
                              size: 22.sp,
                            )
                          : null,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),

                // ── Greeting text ────────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'welcome'.tr(context),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: ColorsManager.textSecondaryColor,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: ColorsManager.textPrimaryColor,
                          fontFamily: 'Cairo',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // ── Notification bell ────────────────────────────────────────
                BlocBuilder<NotificationsCubit, NotificationsState>(
                  builder: (context, state) {
                    int count = 0;
                    if (state is NotificationsLoaded) {
                      count = state.unreadCount;
                    } else {
                      count = context.read<NotificationsCubit>().unreadCount;
                    }
                    return NotificationIconButton(
                      onTap: () {
                        Navigator.pushNamed(context, Routes.notifications);
                        context.read<NotificationsCubit>().markAsRead();
                      },
                      notificationCount: count,
                      iconColor: ColorsManager.textPrimaryColor,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

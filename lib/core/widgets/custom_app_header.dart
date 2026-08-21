import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waratel_app/core/routing/routers.dart';
import 'package:waratel_app/core/theming/colors.dart';
import 'package:waratel_app/features/notifications/logic/cubit/notifications_cubit.dart';
import 'package:waratel_app/features/notifications/logic/cubit/notifications_state.dart';
import 'notification_icon_button.dart';

/// Inner-screen app header — clean white, dark text, matches wrattel-development.
class CustomAppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;

  const CustomAppHeader({
    super.key,
    this.title = 'ورتّل',
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 56.h,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Row(
            children: [
              // ── Left: back / menu ──────────────────────────────────────────
              IconButton(
                onPressed: () {
                  if (showBackButton) {
                    Navigator.pop(context);
                  } else {
                    Scaffold.of(context).openDrawer();
                  }
                },
                icon: Icon(
                  showBackButton
                      ? Icons.arrow_back_ios_new_rounded
                      : Icons.menu_rounded,
                  color: ColorsManager.textPrimaryColor,
                  size: 22.sp,
                ),
              ),

              // ── Center: Title ─────────────────────────────────────────────
              Expanded(
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: ColorsManager.textPrimaryColor,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ),

              // ── Right: Notifications ──────────────────────────────────────
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
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56.h + MediaQueryData.fromView(
        WidgetsBinding.instance.platformDispatcher.views.first,
      ).padding.top);
}

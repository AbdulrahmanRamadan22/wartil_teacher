import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waratel_app/core/di/dependency_injection.dart';
import 'package:waratel_app/core/theming/colors.dart';
import 'package:waratel_app/features/localization/data/app_localizations.dart';
import 'package:waratel_app/features/notifications/data/models/notifications_model.dart';
import 'package:waratel_app/features/notifications/logic/cubit/notifications_cubit.dart';
import 'package:waratel_app/features/notifications/logic/cubit/notifications_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<NotificationsCubit>(),
      child: Scaffold(
        backgroundColor: ColorsManager.backgroundColor,
        appBar: AppBar(
          title: Text('notifications'.tr(context)),
          actions: [
            TextButton(
              onPressed: () {
                context.read<NotificationsCubit>().markAsRead();
              },
              child: Text(
                'mark_all_read'.tr(context),
                style: TextStyle(color: Colors.white, fontSize: 12.sp),
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async =>
              getIt<NotificationsCubit>().loadNotifications(),
          color: ColorsManager.primaryColor,
          child: BlocBuilder<NotificationsCubit, NotificationsState>(
            buildWhen: (previous, current) =>
                current is NotificationsLoading ||
                current is NotificationsLoaded ||
                current is NotificationsError,
            builder: (context, state) {
              if (state is NotificationsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is NotificationsLoaded) {
                return _NotificationsList(
                  notifications: state.notifications,
                );
              } else if (state is NotificationsError) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: Center(child: Text(state.error)),
                  ),
                );
              }
              return const _EmptyState();
            },
          ),
        ),
      ),
    );
  }
}

class _NotificationsList extends StatelessWidget {
  const _NotificationsList({required this.notifications});
  final List<NotificationModel> notifications;

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) return const _EmptyState();

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(16.w),
      itemCount: notifications.length,
      itemBuilder: (context, index) =>
          _NotificationItem(notification: notifications[index]),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  const _NotificationItem({required this.notification});
  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    final typeColor = _colorForType(notification.type);
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: notification.isRead
            ? ColorsManager.surfaceColor
            : ColorsManager.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: notification.isRead
              ? ColorsManager.borderColor
              : ColorsManager.primaryColor.withValues(alpha: 0.18),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Container(
          width: 46.w,
          height: 46.w,
          decoration: BoxDecoration(
            color: typeColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(_iconForType(notification.type),
              color: typeColor, size: 22.sp),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: TextStyle(
                  fontWeight:
                      notification.isRead ? FontWeight.w500 : FontWeight.bold,
                  fontSize: 14.sp,
                  color: ColorsManager.textPrimaryColor,
                ),
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8.w,
                height: 8.w,
                decoration: const BoxDecoration(
                  color: ColorsManager.errorColor,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4.h),
            Text(
              notification.message,
              style: TextStyle(
                  fontSize: 12.sp, color: ColorsManager.textSecondaryColor),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
            Text(
              notification.createdAt,
              style: TextStyle(
                  fontSize: 11.sp, color: ColorsManager.textHintColor),
            ),
          ],
        ),
        onTap: () {},
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'session':
        return Icons.video_call;
      case 'payment':
        return Icons.payment;
      case 'achievement':
        return Icons.emoji_events;
      case 'reminder':
        return Icons.alarm;
      default:
        return Icons.notifications;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'session':
        return ColorsManager.primaryColor;
      case 'payment':
        return ColorsManager.successColor;
      case 'achievement':
        return ColorsManager.accentColor;
      case 'reminder':
        return ColorsManager.warningColor;
      default:
        return ColorsManager.textSecondaryColor;
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.notifications_none,
                  size: 80.sp, color: ColorsManager.borderColor),
              SizedBox(height: 16.h),
              Text(
                'no_notifications'.tr(context),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: ColorsManager.textSecondaryColor,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'new_notifications_here'.tr(context),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: ColorsManager.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

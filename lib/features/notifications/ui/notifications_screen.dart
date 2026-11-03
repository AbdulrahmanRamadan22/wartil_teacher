import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waratel_app/core/di/dependency_injection.dart';
import 'package:waratel_app/core/theming/colors.dart';
import 'package:waratel_app/features/localization/data/app_localizations.dart';
import 'package:waratel_app/features/notifications/data/models/notifications_model.dart';
import 'package:waratel_app/features/notifications/logic/cubit/notifications_cubit.dart';
import 'package:waratel_app/features/notifications/logic/cubit/notifications_state.dart';
import 'package:waratel_app/features/notifications/ui/widgets/notifications_shimmer.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<NotificationsCubit>(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: ColorsManager.backgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: Text(
                'notifications'.tr(context),
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: ColorsManager.textPrimaryColor,
                ),
              ),
              actions: [
                // زر تحديد الكل كمقروء
                TextButton.icon(
                  onPressed: () {
                    getIt<NotificationsCubit>().markAsRead();
                  },
                  icon: Icon(
                    Icons.done_all_rounded,
                    size: 18.sp,
                    color: ColorsManager.primaryColor,
                  ),
                  label: Text(
                    'mark_all_read'.tr(context),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: ColorsManager.primaryColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // زر حذف الكل (أيقونة حمراء بارزة)
                IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(7.w),
                    decoration: BoxDecoration(
                      color: ColorsManager.errorColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_sweep_rounded,
                      color: ColorsManager.errorColor,
                      size: 20.sp,
                    ),
                  ),
                  tooltip: 'delete_all'.tr(context),
                  onPressed: () => _confirmDeleteAll(context),
                ),
                SizedBox(width: 8.w),
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
                    return const NotificationsShimmer();
                  } else if (state is NotificationsLoaded) {
                    return _NotificationsList(
                      notifications: state.notifications,
                    );
                  } else if (state is NotificationsError) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: Center(
                          child: Text(
                            state.error,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              color: ColorsManager.textSecondaryColor,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return const _EmptyState();
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDeleteAll(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: ColorsManager.errorColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_sweep_rounded,
                color: ColorsManager.errorColor,
                size: 22,
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              'delete_all'.tr(context),
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: ColorsManager.textPrimaryColor,
              ),
            ),
          ],
        ),
        content: Text(
          'delete_all_notifications_confirm'.tr(context),
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13.sp,
            color: ColorsManager.textSecondaryColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(
              'cancel'.tr(context),
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.errorColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(
              'delete'.tr(context),
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success =
          await getIt<NotificationsCubit>().deleteAllNotifications();
      if (context.mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'all_notifications_deleted'.tr(context),
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: ColorsManager.textPrimaryColor,
          ),
        );
      }
    }
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
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: notifications.length,
      itemBuilder: (context, index) =>
          _NotificationItem(notification: notifications[index]),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  const _NotificationItem({required this.notification});
  final NotificationModel notification;

  Future<void> _confirmDeleteItem(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: ColorsManager.errorColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: ColorsManager.errorColor,
                size: 20,
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              'delete'.tr(context),
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: ColorsManager.textPrimaryColor,
              ),
            ),
          ],
        ),
        content: Text(
          'delete_notification_confirm'.tr(context),
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13.sp,
            color: ColorsManager.textSecondaryColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(
              'cancel'.tr(context),
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.errorColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(
              'delete'.tr(context),
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success =
          await getIt<NotificationsCubit>().deleteNotification(notification.id);
      if (context.mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'notification_deleted'.tr(context),
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: ColorsManager.textPrimaryColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = _gradientForType(notification.type);
    final glowColor = _primaryColorForType(notification.type);

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.horizontal,
      background: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 22.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 24),
            SizedBox(width: 8.w),
            Text(
              'delete'.tr(context),
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 22.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'delete'.tr(context),
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13.sp,
              ),
            ),
            SizedBox(width: 8.w),
            const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 24),
          ],
        ),
      ),
      onDismissed: (direction) {
        getIt<NotificationsCubit>().deleteNotification(notification.id);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'notification_deleted'.tr(context),
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: ColorsManager.textPrimaryColor,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.white
              : ColorsManager.primaryColor.withValues(alpha: 0.035),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: notification.isRead
                ? ColorsManager.borderColor.withValues(alpha: 0.8)
                : ColorsManager.primaryColor.withValues(alpha: 0.25),
            width: notification.isRead ? 1.0 : 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: notification.isRead
                  ? Colors.black.withValues(alpha: 0.02)
                  : ColorsManager.primaryColor.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(16.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Luxury Squircle Gradient Icon
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14.r),
                      boxShadow: [
                        BoxShadow(
                          color: glowColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      _iconForType(notification.type),
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // Notification Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title + Unread Badge
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: notification.isRead
                                      ? FontWeight.w600
                                      : FontWeight.bold,
                                  fontSize: 14.sp,
                                  color: ColorsManager.textPrimaryColor,
                                ),
                              ),
                            ),
                            if (!notification.isRead) ...[
                              SizedBox(width: 6.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: ColorsManager.primaryColor
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Text(
                                  'new'.tr(context),
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                    color: ColorsManager.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        SizedBox(height: 5.h),

                        // Message Body
                        Text(
                          notification.message,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12.5.sp,
                            height: 1.4,
                            color: ColorsManager.textSecondaryColor,
                          ),
                        ),

                        SizedBox(height: 8.h),

                        // Time Row
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 13.sp,
                              color: ColorsManager.textHintColor,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              notification.createdAt,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11.sp,
                                color: ColorsManager.textHintColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 6.w),

                  // Luxurious RED Delete Icon Button
                  IconButton(
                    icon: Container(
                      width: 34.w,
                      height: 34.w,
                      decoration: BoxDecoration(
                        color: ColorsManager.errorColor.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: ColorsManager.errorColor,
                        size: 18,
                      ),
                    ),
                    splashRadius: 20.r,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'delete'.tr(context),
                    onPressed: () => _confirmDeleteItem(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'session':
        return Icons.videocam_rounded;
      case 'payment':
        return Icons.account_balance_wallet_rounded;
      case 'achievement':
        return Icons.emoji_events_rounded;
      case 'reminder':
        return Icons.notifications_active_rounded;
      default:
        return Icons.campaign_rounded;
    }
  }

  Color _primaryColorForType(String type) {
    switch (type) {
      case 'session':
        return ColorsManager.primaryColor;
      case 'payment':
        return const Color(0xFF10B981);
      case 'achievement':
        return const Color(0xFFF59E0B);
      case 'reminder':
        return const Color(0xFF3B82F6);
      default:
        return ColorsManager.primaryColor;
    }
  }

  List<Color> _gradientForType(String type) {
    switch (type) {
      case 'session':
        return const [Color(0xFF0D8A74), Color(0xFF26A69A)];
      case 'payment':
        return const [Color(0xFF10B981), Color(0xFF059669)];
      case 'achievement':
        return const [Color(0xFFF59E0B), Color(0xFFFF8C42)];
      case 'reminder':
        return const [Color(0xFF3B82F6), Color(0xFF6366F1)];
      default:
        return const [Color(0xFF0D8A74), Color(0xFF2BB89A)];
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
              Container(
                width: 90.w,
                height: 90.w,
                decoration: BoxDecoration(
                  color: ColorsManager.primaryColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_none_rounded,
                  size: 48.sp,
                  color: ColorsManager.primaryColor,
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                'no_notifications'.tr(context),
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: ColorsManager.textPrimaryColor,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'new_notifications_here'.tr(context),
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13.sp,
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

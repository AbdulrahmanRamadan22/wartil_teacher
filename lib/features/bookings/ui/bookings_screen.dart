import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:waratel_app/core/routing/routers.dart';
import 'package:waratel_app/core/theming/colors.dart';
import 'package:waratel_app/core/widgets/custom_app_header.dart';
import 'package:waratel_app/core/widgets/empty_state_display.dart';
import 'package:waratel_app/features/localization/data/app_localizations.dart';
import 'package:waratel_app/features/bookings/logic/cubit/bookings_cubit.dart';
import 'package:waratel_app/features/bookings/logic/cubit/bookings_state.dart';
import 'package:waratel_app/features/bookings/data/models/booking_model.dart';
import 'package:waratel_app/features/call/ui/widgets/session_report_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<BookingsCubit>();
      if (cubit.state is BookingsInitial) {
        cubit.loadBookings();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingsCubit, BookingsState>(
      listener: (context, state) {
        if (state is StartCallSuccess) {
          Navigator.pushNamed(
            context,
            Routes.call,
            arguments: {
              'token': state.token,
              'channelName': state.channel,
              'uid': state.uid,
              'studentName': state.studentName,
              'callId': state.callId,
              'studentId': state.studentId,
              'hasPreloadedToken': true, // Token من /bookings/start — لا نحتاج /join
              'reportableType': 'slot',
              'reportableId': state.slotId ?? state.callId,
            },
          ).then((_) {
            if (context.mounted) {
              context.read<BookingsCubit>().loadBookings();
            }
          });
        } else if (state is StartCallError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        } else if (state is CancelSlotSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message), backgroundColor: Colors.green),
          );
        } else if (state is CancelSlotError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            CustomAppHeader(title: 'sessions'.tr(context)),
            TabBar(
              tabs: [
                Tab(text: 'upcoming'.tr(context)),
                Tab(text: 'history'.tr(context)),
              ],
              labelColor: ColorsManager.primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: ColorsManager.primaryColor,
            ),
            Expanded(
              child: BlocBuilder<BookingsCubit, BookingsState>(
                buildWhen: (previous, current) =>
                    current is BookingsLoading ||
                    current is BookingsLoaded ||
                    current is BookingsError,
                builder: (context, state) {
                  if (state is BookingsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is BookingsLoaded) {
                    return TabBarView(
                      children: [
                        _BookingsList(
                          bookings: state.upcoming,
                          emptyMessageKey: 'no_upcoming_sessions',
                          showCancel: true,
                        ),
                        _BookingsList(
                          bookings: state.history,
                          emptyMessageKey: 'no_recorded_sessions',
                          showCancel: false,
                        ),
                      ],
                    );
                  } else if (state is BookingsError) {
                    return RefreshIndicator(
                      onRefresh: () async =>
                          context.read<BookingsCubit>().loadBookings(),
                      color: ColorsManager.primaryColor,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(state.error),
                                SizedBox(height: 10.h),
                                ElevatedButton(
                                  onPressed: () => context
                                      .read<BookingsCubit>()
                                      .loadBookings(),
                                  child: Text('retry'.tr(context)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingsList extends StatelessWidget {
  final List<BookingModel> bookings;
  final String emptyMessageKey;
  final bool showCancel;

  const _BookingsList({
    required this.bookings,
    required this.emptyMessageKey,
    required this.showCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => context.read<BookingsCubit>().loadBookings(),
        color: ColorsManager.primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: EmptyStateDisplay(
              icon: Icons.assignment_turned_in_outlined,
              message: emptyMessageKey.tr(context),
              subMessage: 'sessions_history_subtitle'.tr(context),
            ),
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async => context.read<BookingsCubit>().loadBookings(),
      color: ColorsManager.primaryColor,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          return RepaintBoundary(
            child: _BookingCard(booking: bookings[index], showCancel: showCancel),
          );
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final bool showCancel;
  const _BookingCard({required this.booking, required this.showCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundColor:
                    ColorsManager.primaryColor.withValues(alpha: 0.1),
                backgroundImage: booking.student.photo != null
                    ? CachedNetworkImageProvider(booking.student.photo!)
                        as ImageProvider
                    : null,
                child: booking.student.photo == null
                    ? Icon(Icons.person,
                        color: ColorsManager.primaryColor, size: 24.sp)
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.student.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: ColorsManager.textPrimaryColor,
                      ),
                    ),
                    Text(
                      _formatDate(booking.date),
                      style:
                          TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: booking.bookingStatus),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time, size: 16.sp, color: Colors.grey[600]),
                  SizedBox(width: 4.w),
                  Text(
                    '${_formatTime(booking.startTime, context)} - ${_formatTime(booking.endTime, context)}',
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
              Row(
                children: [
                  if (showCancel && booking.bookingStatus == 'scheduled')
                    TextButton(
                      onPressed: () => _showCancelDialog(context),
                      child: Text(
                        'cancel'.tr(context),
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  if (booking.canStart)
                    ElevatedButton(
                      onPressed: () {
                        final int bookingId = booking.bookingId ?? 0;
                        if (bookingId <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تعذر العثور على معرف الحجز'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        context.read<BookingsCubit>().startCall(
                              bookingId,
                              booking.student.name,
                              studentId: booking.student.id,
                              slotId: booking.slotId,
                            );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsManager.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                      child: Text('enter'.tr(context)),
                    ),
                  if (!showCancel && booking.isPast && !booking.isReported)
                    ElevatedButton(
                      onPressed: () => _showEvaluationDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsManager.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                      child: Text(
                        'evaluate_student'.tr(context),
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  if (!showCancel && booking.isPast && booking.isReported)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded,
                              color: Colors.green, size: 14.sp),
                          SizedBox(width: 4.w),
                          Text(
                            'تم التقييم',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEvaluationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => SessionReportDialog(
        studentName: booking.student.name,
        trackName: 'memorization_track'.tr(context),
        studentId: booking.student.id,
        reportableType: 'slot',
        reportableId: booking.slotId,
        initialIsPresent: booking.bookingStatus != 'absent',
        isAttendanceLocked: false,
        onSuccess: () {
          Navigator.pop(dialogContext);
          context.read<BookingsCubit>().loadBookings();
        },
        onSkip: () {
          Navigator.pop(dialogContext);
        },
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final dt = DateTime.parse(date);
      return DateFormat('yyyy-MM-dd').format(dt);
    } catch (_) {
      return date;
    }
  }

  String _formatTime(String time, BuildContext context) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts[1];
      final amPm = hour >= 12 ? 'pm'.tr(context) : 'am'.tr(context);
      final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$h:$minute $amPm';
    } catch (_) {
      return time;
    }
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('confirm'.tr(context)),
        content: Text('cancel_session_confirm'.tr(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('cancel'.tr(context)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<BookingsCubit>().cancelSlot(booking.slotId);
            },
            child: Text('confirm'.tr(context),
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case 'scheduled':
        color = Colors.blue;
        label = 'scheduled'.tr(context);
        break;
      case 'ongoing':
        color = Colors.green;
        label = 'ongoing_now'.tr(context);
        break;
      case 'completed':
        color = Colors.grey;
        label = 'completed'.tr(context);
        break;
      default:
        color = Colors.orange;
        label = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

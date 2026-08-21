import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waratel_app/core/routing/routers.dart';
import 'package:waratel_app/core/theming/colors.dart';
import 'package:waratel_app/features/localization/data/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubit/home_cubit.dart';
import '../../logic/cubit/home_state.dart';
// Removed unused import
import 'package:waratel_app/features/bookings/logic/cubit/bookings_cubit.dart';
import 'package:waratel_app/features/bookings/logic/cubit/bookings_state.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NextSessionCard extends StatefulWidget {
  const NextSessionCard({super.key});

  @override
  State<NextSessionCard> createState() => _NextSessionCardState();
}

class _NextSessionCardState extends State<NextSessionCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Refresh the UI every minute to check the 5-minute window
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          current is HomeSoonLoading ||
          current is HomeSoonLoaded ||
          current is HomeSoonError,
      builder: (context, state) {
        if (state is HomeSoonLoading &&
            context.read<HomeCubit>().soonBooking == null) {
          return Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: ColorsManager.surfaceColor,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is HomeSoonError &&
            context.read<HomeCubit>().soonBooking == null) {
          return Center(
            child: TextButton.icon(
              onPressed: () => context.read<HomeCubit>().loadSoon(),
              icon: const Icon(Icons.refresh),
              label: Text('retry'.tr(context)),
            ),
          );
        }

        final booking = context.read<HomeCubit>().soonBooking;

        if (booking == null) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: ColorsManager.surfaceColor,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: ColorsManager.cardShadow,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Header row: session time  +  status ────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_formatTime(booking.startTime)} - ${_formatTime(booking.endTime)}',
                    style: TextStyle(
                      color: ColorsManager.textPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                  if (booking.bookingStatus == 'scheduled')
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: ColorsManager.greenExtraLight,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.timer_outlined,
                              size: 14.sp, color: ColorsManager.primaryColor),
                          SizedBox(width: 4.w),
                          Text(
                            'upcoming_booking'.tr(context),
                            style: TextStyle(
                              color: ColorsManager.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (booking.bookingStatus == 'ongoing')
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'ongoing_now'.tr(context),
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 15.h),

              // ── Content row: avatar, student info, enter button ────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      color:
                          ColorsManager.secondaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      image: booking.student.photo != null
                          ? DecorationImage(
                              image: CachedNetworkImageProvider(
                                  booking.student.photo!) as ImageProvider,
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: booking.student.photo == null
                        ? Icon(
                            Icons.person,
                            color: ColorsManager.secondaryColor,
                            size: 30.sp,
                          )
                        : null,
                  ),
                  SizedBox(width: 12.w),

                  // Student info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.student.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                            color: ColorsManager.textPrimaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'student'.tr(context),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: ColorsManager.textSecondaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),

                  // Enter button
                  if (booking.canStart)
                    BlocConsumer<BookingsCubit, BookingsState>(
                      listener: (context, state) {
                        if (state is StartCallSuccess) {
                          // Refresh home data immediately so the card disappears or status changes
                          context.read<HomeCubit>().loadSoon();

                          Navigator.pushNamed(
                            context,
                            Routes.call,
                            arguments: {
                              'token': state.token,
                              'channelName': state.channel,
                              'uid': state.uid,
                              'studentName': state.studentName,
                              'callId': state.callId,
                            },
                          );
                        }
                      },
                      builder: (context, state) {
                        return _EnterButton(
                          isLoading: state is StartCallLoading,
                          onPressed: () {
                            context.read<BookingsCubit>().startCall(
                                  booking.slotId,
                                  booking.callDetails?.id ?? 0,
                                  booking.student.name,
                                );
                          },
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(String time) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts[1];
      final amPm = hour >= 12 ? 'PM' : 'AM';
      final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$h:$minute $amPm';
    } catch (_) {
      return time;
    }
  }
}

class _EnterButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  const _EnterButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onPressed,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 50.w,
        height: 50.w,
        decoration: const BoxDecoration(
          gradient: ColorsManager.primaryGradient,
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            else ...[
              Icon(Icons.login, color: Colors.white, size: 20.sp),
              Text(
                'enter'.tr(context),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

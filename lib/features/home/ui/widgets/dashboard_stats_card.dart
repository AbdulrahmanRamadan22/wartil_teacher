import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waratel_app/core/theming/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waratel_app/features/home/logic/cubit/home_cubit.dart';
import 'package:waratel_app/features/home/logic/cubit/home_state.dart';
import 'package:waratel_app/features/home/ui/widgets/next_session_card.dart';
import 'package:waratel_app/features/localization/data/app_localizations.dart';

class DashboardStatsCard extends StatelessWidget {
  const DashboardStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    // PERF: BlocListener handles navigation/snackbar side-effects only.
    // The BlocBuilder below rebuilds ONLY for toggle-related states,
    // leaving the static star rating section completely untouched.
    return BlocListener<HomeCubit, HomeState>(
      listener: (context, state) {
        if (state is ToggleOnlineSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: ColorsManager.successColor,
            ),
          );
        } else if (state is ToggleOnlineError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: ColorsManager.errorColor,
            ),
          );
        }
      },
      child: Column(
        children: [
          // ── Toggle Card — rebuilds only for toggle states ──────────────
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: ColorsManager.surfaceColor,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: ColorsManager.cardShadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _AvailabilityToggleRow(),
                SizedBox(height: 8.h),
                // ── Star rating — fully static, zero rebuilds ──────────
                const _StarRatingRow(),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          const NextSessionCard(),
        ],
      ),
    );
  }
}

/// Rebuilds only for toggle-related states.
class _AvailabilityToggleRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (_, curr) =>
          curr is HomeInitial ||
          curr is HomeOnlineStatusLoaded ||
          curr is ToggleOnlineLoading ||
          curr is ToggleOnlineSuccess ||
          curr is ToggleOnlineError,
      builder: (context, state) {
        final cubit = context.read<HomeCubit>();
        final isAvailable = cubit.isOnline;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  isAvailable
                      ? 'available'.tr(context)
                      : 'unavailable'.tr(context),
                  style: TextStyle(
                    color: isAvailable
                        ? ColorsManager.primaryColor
                        : ColorsManager.textSecondaryColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8.w),
                if (state is ToggleOnlineLoading)
                  SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ColorsManager.primaryColor,
                    ),
                  )
                else
                  Switch(
                    value: isAvailable,
                    activeThumbColor: ColorsManager.primaryColor,
                    onChanged: (_) => cubit.toggleOnline(),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Fully static — uses `const` so Flutter never rebuilds this subtree.
class _StarRatingRow extends StatelessWidget {
  const _StarRatingRow();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (prev, curr) =>
          curr is HomeInitial || curr is HomeOnlineStatusLoaded,
      builder: (context, state) {
        final rating = context.read<HomeCubit>().averageRating;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'average_rating'.tr(context),
              style: TextStyle(
                color: ColorsManager.textSecondaryColor,
                fontSize: 13.sp,
              ),
            ),
            Row(
              children: [
                _buildStars(rating),
                SizedBox(width: 8.w),
                Text(
                  rating.toStringAsFixed(2),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: ColorsManager.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStars(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(
            Icon(Icons.star, color: ColorsManager.accentColor, size: 18.sp));
      } else if (i == fullStars && hasHalfStar) {
        stars.add(Icon(Icons.star_half,
            color: ColorsManager.accentColor, size: 18.sp));
      } else {
        stars.add(Icon(Icons.star_border,
            color: ColorsManager.accentColor, size: 18.sp));
      }
    }
    return Row(children: stars);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waratel_app/core/theming/colors.dart';
import 'package:waratel_app/features/ads/logic/cubit/ads_cubit.dart';
import 'package:waratel_app/features/ads/logic/cubit/ads_state.dart';
import 'package:waratel_app/features/home/ui/widgets/ads_slider.dart';
import 'package:waratel_app/features/home/ui/widgets/dashboard_stats_card.dart';
import 'package:waratel_app/features/home/ui/widgets/home_header.dart';
import 'package:waratel_app/features/home/ui/widgets/home_shimmer.dart';
import 'package:waratel_app/features/home/ui/widgets/recent_calls_list.dart';
import 'package:waratel_app/core/routing/routers.dart';
import 'package:waratel_app/features/home/logic/cubit/home_cubit.dart';
import 'package:waratel_app/features/home/logic/cubit/home_state.dart';
import 'package:waratel_app/features/localization/data/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Data loading is handled by HomeLayout to prevent double-fetching.
  }

  Future<void> _refreshData() async {
    if (mounted) {
      context.read<HomeCubit>().loadSoon();
      context.read<HomeCubit>().getInitialOnlineStatus();
      context.read<AdsCubit>().getAds();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: ColorsManager.primaryColor,
      displacement: 20,
      child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // ── Sticky white header ──────────────────────────────────────────
            const SliverToBoxAdapter(child: HomeHeader()),

            // ── Home content with shimmer while loading ──────────────────────
            BlocBuilder<HomeCubit, HomeState>(
              buildWhen: (_, curr) =>
                  curr is HomeSoonLoading ||
                  curr is HomeSoonLoaded ||
                  curr is HomeSoonError ||
                  curr is HomeInitial,
              builder: (context, homeState) {
                final isFirstLoad = homeState is HomeSoonLoading &&
                    context.read<HomeCubit>().soonBooking == null;

                if (isFirstLoad) {
                  return const SliverToBoxAdapter(
                    child: HomeShimmer(),
                  );
                }

                return SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12.h),

                      // ── Ads Slider ─────────────────────────────────────────
                      BlocBuilder<AdsCubit, AdsState>(
                        builder: (context, adsState) {
                          if (adsState is AdsLoading) {
                            return Container(
                              height: 155.h,
                              margin: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: ColorsManager.lightMint,
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            );
                          } else if (adsState is AdsLoaded &&
                              adsState.ads.isNotEmpty) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 6.h),
                              child: AdsSlider(ads: adsState.ads),
                            );
                          } else if (adsState is AdsError) {
                            return Padding(
                              padding: EdgeInsets.all(16.w),
                              child: TextButton.icon(
                                onPressed: () =>
                                    context.read<AdsCubit>().getAds(),
                                icon: const Icon(Icons.refresh),
                                label: Text('retry'.tr(context)),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      SizedBox(height: 8.h),

                      // ── Dashboard Stats + Next Session ─────────────────────
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: const DashboardStatsCard(),
                      ),

                      SizedBox(height: 16.h),

                      // ── Recent Calls section header ────────────────────────
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'successful_calls'.tr(context),
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: ColorsManager.textPrimaryColor,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                Routes.statistics,
                              ),
                              child: Text(
                                'view_all'.tr(context),
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: ColorsManager.primaryColor,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const RecentCallsList(),
                      SizedBox(height: 24.h),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
    );
  }
}

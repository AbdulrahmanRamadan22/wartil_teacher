import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:waratel_app/core/di/dependency_injection.dart';
import 'package:waratel_app/core/theming/colors.dart';
import 'package:waratel_app/features/localization/data/app_localizations.dart';
import 'package:waratel_app/features/profile/data/models/profile_models.dart';
import 'package:waratel_app/features/profile/logic/cubit/profile_cubit.dart';
import 'package:waratel_app/features/profile/logic/cubit/profile_state.dart';
import 'package:waratel_app/features/profile/ui/widgets/achievement_plan_summary_card.dart';
import 'package:waratel_app/core/widgets/app_shimmer.dart';
import 'package:waratel_app/core/routing/routers.dart';
import 'package:flutter/services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatPhotoUrl(String? path) {
    if (path == null || path.trim().isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    return 'https://wartil.com/storage/$path';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<ProfileCubit>(),
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is LogoutSuccess) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              Routes.login,
              (route) => false,
            );
          } else if (state is LogoutError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.error,
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                backgroundColor: ColorsManager.errorColor,
              ),
            );
          } else if (state is DeleteAccountSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                backgroundColor: ColorsManager.primaryColor,
              ),
            );
            Navigator.of(context).pushNamedAndRemoveUntil(
              Routes.login,
              (route) => false,
            );
          } else if (state is DeleteAccountError) {
            Navigator.of(context, rootNavigator: true).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.error,
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                backgroundColor: ColorsManager.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          // ── Initial loading shimmer ──────────────────────────────────────
          if (state is ProfileLoading &&
              getIt<ProfileCubit>().profileData == null) {
            return Scaffold(
              backgroundColor: ColorsManager.backgroundColor,
              appBar: _buildAppBar(context),
              body: _buildProfileBodyShimmer(),
            );
          }

          if (state is ProfileError &&
              getIt<ProfileCubit>().profileData == null) {
            return Scaffold(
              backgroundColor: ColorsManager.backgroundColor,
              body: Center(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: ColorsManager.errorColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.error_outline_rounded,
                          size: 48.sp,
                          color: ColorsManager.errorColor,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        state.error,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14.sp,
                          color: ColorsManager.textPrimaryColor,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      ElevatedButton.icon(
                        onPressed: () =>
                            getIt<ProfileCubit>().getProfile(),
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(
                          'retry'.tr(context),
                          style: const TextStyle(fontFamily: 'Cairo'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsManager.primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24.w, vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final profileResponse = state is ProfileLoaded
              ? state.profileResponse
              : getIt<ProfileCubit>().profileData;

          final user = profileResponse?.user;
          final profile = profileResponse?.profile;
          final category = profileResponse?.category;
          final tracks = profileResponse?.tracks ?? [];
          final countryCode = profileResponse?.countryCode;
          final minutesSpent = profileResponse?.minutesSpent;

          return Scaffold(
            backgroundColor: ColorsManager.backgroundColor,
            appBar: _buildAppBar(context),
            body: Stack(
              children: [
                NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      // ── Profile Executive Header ───────────────────────
                      SliverToBoxAdapter(
                        child: _buildExecutiveHeader(
                          context: context,
                          user: user,
                          profile: profile,
                          category: category,
                        ),
                      ),
                      // ── Spacing between profile header and TabBar ──────
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 12),
                      ),
                      // ── Pinned TabBar ──────────────────────────────────
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _TabBarHeaderDelegate(
                          tabBar: TabBar(
                            controller: _tabController,
                            indicator: BoxDecoration(
                              color: ColorsManager.primaryColor
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: ColorsManager.primaryColor
                                    .withValues(alpha: 0.25),
                              ),
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            dividerColor: Colors.transparent,
                            labelColor: ColorsManager.primaryColor,
                            unselectedLabelColor:
                                ColorsManager.textSecondaryColor,
                            labelStyle: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            unselectedLabelStyle: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            tabs: [
                              Tab(
                                icon: const Icon(
                                    Icons.dashboard_rounded,
                                    size: 20),
                                text: 'information'.tr(context),
                              ),
                              Tab(
                                icon: const Icon(
                                    Icons.auto_stories_rounded,
                                    size: 20),
                                text:
                                    '${'tracks'.tr(context)} (${tracks.length})',
                              ),
                              Tab(
                                icon: const Icon(
                                    Icons.emoji_events_rounded,
                                    size: 20),
                                text: 'achievement_plan'.tr(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ];
                  },
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab 1: Overview
                      RefreshIndicator(
                        onRefresh: () =>
                            getIt<ProfileCubit>().refreshProfile(),
                        color: ColorsManager.primaryColor,
                        backgroundColor: Colors.white,
                        strokeWidth: 2.5,
                        child: _buildOverviewTab(
                          context: context,
                          user: user,
                          profile: profile,
                          category: category,
                          countryCode: countryCode,
                          minutesSpent: minutesSpent,
                        ),
                      ),
                      // Tab 2: Tracks
                      RefreshIndicator(
                        onRefresh: () =>
                            getIt<ProfileCubit>().refreshProfile(),
                        color: ColorsManager.primaryColor,
                        backgroundColor: Colors.white,
                        strokeWidth: 2.5,
                        child: _buildTracksTab(
                          context: context,
                          tracks: tracks,
                        ),
                      ),
                      // Tab 3: Achievement Plan
                      RefreshIndicator(
                        onRefresh: () =>
                            getIt<ProfileCubit>().refreshProfile(),
                        color: ColorsManager.primaryColor,
                        backgroundColor: Colors.white,
                        strokeWidth: 2.5,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 16.h),
                          child: const AchievementPlanSummaryCard(),
                        ),
                      ),
                    ],
                  ),
                ),
                // ── Refresh shimmer overlay ────────────────────────────
                if (state is ProfileRefreshing)
                  Positioned.fill(
                    child: Container(
                      color: ColorsManager.backgroundColor,
                      child: _buildProfileBodyShimmer(),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Unified Sticky AppBar ──────────────────────────────────────────────────
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF065A4B),
              Color(0xFF0D8A74),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 22,
        ),
        tooltip: 'close'.tr(context),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: Text(
        'profile'.tr(context),
        style: TextStyle(
          fontFamily: 'Cairo',
          color: Colors.white,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  // ── Full-Page Luxury Profile Shimmer Skeleton ──────────────────────────────
  Widget _buildProfileBodyShimmer() {
    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            // ── Header skeleton (matches exact gradient and curvature) ──────
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0D8A74),
                    Color(0xFF109B83),
                    Color(0xFF14B8A6),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28.r),
                  bottomRight: Radius.circular(28.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: ColorsManager.primaryColor.withValues(alpha: 0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar Circle
                  ShimmerBox(
                    width: 92.r,
                    height: 92.r,
                    radius: 46.r,
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                  SizedBox(height: 12.h),

                  // Name
                  ShimmerBox(
                    width: 150.w,
                    height: 18.h,
                    radius: 9,
                    color: Colors.white.withValues(alpha: 0.28),
                  ),
                  SizedBox(height: 6.h),

                  // Email
                  ShimmerBox(
                    width: 170.w,
                    height: 12.h,
                    radius: 6,
                    color: Colors.white.withValues(alpha: 0.20),
                  ),
                  SizedBox(height: 14.h),

                  // Category Badge skeleton
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.w),
                    padding: EdgeInsets.symmetric(
                        horizontal: 18.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                        width: 1.5.w,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ShimmerBox(
                          width: 32.r,
                          height: 32.r,
                          radius: 16.r,
                          color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                        ),
                        SizedBox(width: 12.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ShimmerBox(
                              width: 60.w,
                              height: 9.h,
                              radius: 4,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                            SizedBox(height: 4.h),
                            ShimmerBox(
                              width: 90.w,
                              height: 14.h,
                              radius: 6,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ],
                        ),
                        SizedBox(width: 16.w),
                        ShimmerBox(
                          width: 65.w,
                          height: 22.h,
                          radius: 12,
                          color: const Color(0xFFFFD700).withValues(alpha: 0.25),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 18.h),

                  // Stats grid card skeleton
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Row(
                      children: List.generate(
                        3,
                        (index) => Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ShimmerBox(
                                width: 22.r,
                                height: 22.r,
                                radius: 11.r,
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                              SizedBox(height: 6.h),
                              ShimmerBox(
                                width: 38.w,
                                height: 12.h,
                                radius: 6,
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                              SizedBox(height: 4.h),
                              ShimmerBox(
                                width: 48.w,
                                height: 9.h,
                                radius: 4,
                                color: Colors.white.withValues(alpha: 0.25),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            // ── TabBar skeleton (3 pill tabs) ──────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Expanded(
                    child: ShimmerBox(
                      width: double.infinity,
                      height: 44.h,
                      radius: 12,
                      color: ColorsManager.primaryColor.withValues(alpha: 0.15),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: ShimmerBox(
                      width: double.infinity,
                      height: 44.h,
                      radius: 12,
                      color: const Color(0xFFE5E7EB),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: ShimmerBox(
                      width: double.infinity,
                      height: 44.h,
                      radius: 12,
                      color: const Color(0xFFE5E7EB),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // ── Rates card skeleton ────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(
                    color: ColorsManager.borderColor.withValues(alpha: 0.8),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        ShimmerBox(width: 36.r, height: 36.r, radius: 12),
                        SizedBox(width: 10.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerBox(width: 90.w, height: 14.h, radius: 6),
                            SizedBox(height: 4.h),
                            ShimmerBox(width: 130.w, height: 10.h, radius: 4),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      children: [
                        Expanded(
                          child: ShimmerBox(
                            width: double.infinity,
                            height: 68.h,
                            radius: 14,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: ShimmerBox(
                            width: double.infinity,
                            height: 68.h,
                            radius: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Expanded(
                          child: ShimmerBox(
                            width: double.infinity,
                            height: 68.h,
                            radius: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // ── Personal Info card skeleton ────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 32.h),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(
                    color: ColorsManager.borderColor.withValues(alpha: 0.8),
                  ),
                ),
                child: Column(
                  children: List.generate(
                    4,
                    (i) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Row(
                        children: [
                          ShimmerBox(width: 24.r, height: 24.r, radius: 12),
                          SizedBox(width: 12.w),
                          ShimmerBox(width: 90.w, height: 12.h, radius: 6),
                          const Spacer(),
                          ShimmerBox(width: 110.w, height: 14.h, radius: 6),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Executive Luxury Header with prominent Category Badge ─────────────────
  Widget _buildExecutiveHeader({
    required BuildContext context,
    required ProfileUser? user,
    required TeacherProfileDetail? profile,
    required TeacherCategory? category,
  }) {
    final photoUrl = _formatPhotoUrl(profile?.profilePhotoPath);
    final isOnline = profile?.isOnline ?? false;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0D8A74),
            Color(0xFF109B83),
            Color(0xFF14B8A6),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.primaryColor.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28.r),
          bottomRight: Radius.circular(28.r),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar with Online Status
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFF2BB89A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 46.r,
                      backgroundColor: const Color(0xFF084F42),
                      backgroundImage: photoUrl.isNotEmpty
                          ? CachedNetworkImageProvider(photoUrl)
                          : null,
                      child: photoUrl.isEmpty
                          ? Icon(Icons.person_rounded,
                              size: 50.sp, color: Colors.white)
                          : null,
                    ),
                  ),

                  // Active / Online Status Badge
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: isOnline
                          ? const Color(0xFF10B981)
                          : Colors.grey.shade600,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.white, width: 2.w),
                      boxShadow: [
                        BoxShadow(
                          color: (isOnline
                                  ? const Color(0xFF10B981)
                                  : Colors.black)
                              .withValues(alpha: 0.35),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7.w,
                          height: 7.w,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          isOnline
                              ? 'online_now'.tr(context)
                              : 'offline_now'.tr(context),
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Teacher Name & Verified Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      user?.name ?? 'teacher'.tr(context),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 21.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Icon(
                    Icons.verified_rounded,
                    color: const Color(0xFF4ECBA6),
                    size: 20.sp,
                  ),
                ],
              ),

              SizedBox(height: 3.h),

              // Teacher Email
              if (user?.email != null && user!.email.isNotEmpty)
                Text(
                  user.email,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.sp,
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),

              SizedBox(height: 14.h),

              // ═════════════════════════════════════════════════════════════
              // 👑 PROMINENT LUXURY CATEGORY BADGE (Requested by User!)
              // ═════════════════════════════════════════════════════════════
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF042F24),
                      Color(0xFF074838),
                      Color(0xFF0E634F),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.75),
                    width: 1.5.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Golden Crown / Badge Icon
                    Container(
                      padding: EdgeInsets.all(7.w),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: Color(0xFF281E00),
                        size: 22,
                      ),
                    ),

                    SizedBox(width: 12.w),

                    // Category Name & Tag
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'teacher_category'.tr(context),
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFFD700).withValues(alpha: 0.85),
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          category?.name.isNotEmpty == true
                              ? category!.name
                              : 'الفئة المعتمدة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(width: 12.w),

                    // Tier Pill
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        '★ معتمد',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFFD700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 18.h),

              // ── Quick Stats Grid Card (Glassmorphic) ───────────────────────
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                ),
                child: Row(
                  children: [
                    _buildStatItem(
                      icon: Icons.star_rounded,
                      iconColor: const Color(0xFFFFB800),
                      value: profile?.averageRating.toStringAsFixed(1) ?? '0.0',
                      label: 'average_rating'.tr(context),
                    ),
                    _buildStatDivider(),
                    _buildStatItem(
                      icon: Icons.timer_rounded,
                      iconColor: const Color(0xFFFF9F43),
                      value: '${profile?.minutes ?? 0}',
                      label: 'minutes'.tr(context),
                    ),
                    _buildStatDivider(),
                    _buildStatItem(
                      icon: Icons.account_balance_wallet_rounded,
                      iconColor: const Color(0xFF69F0AE),
                      value: '${profile?.balance ?? '0.00'} ${'egp'.tr(context)}',
                      label: 'current_balance'.tr(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(7.w),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: iconColor.withValues(alpha: 0.45),
                width: 1.w,
              ),
            ),
            child: Icon(icon, color: iconColor, size: 20.sp),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 9.5.sp,
              color: Colors.white.withValues(alpha: 0.85),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1.w,
      height: 32.h,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }

  // ── Tab 1: Overview & Rates ───────────────────────────────────────────────
  Widget _buildOverviewTab({
    required BuildContext context,
    required ProfileUser? user,
    required TeacherProfileDetail? profile,
    required TeacherCategory? category,
    String? countryCode,
    MinutesSpent? minutesSpent,
  }) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      children: [
        // Category Rates Breakdown Card
        _buildSectionTitle(
          title: 'category_rates'.tr(context),
          icon: Icons.monetization_on_rounded,
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: ColorsManager.borderColor.withValues(alpha: 0.8),
            ),
            boxShadow: [
              BoxShadow(
                color: ColorsManager.primaryColor.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: ColorsManager.primaryColor,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category?.name.isNotEmpty == true
                              ? category!.name
                              : 'فئة الحساب',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: ColorsManager.textPrimaryColor,
                          ),
                        ),
                        Text(
                          'تسعير الجلسات المعتمدة لك بحسب الدولة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.5.sp,
                            color: ColorsManager.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(height: 24.h, color: Colors.grey.shade100),

              // Rates Grid (Egypt, Arab, Foreign)
              Row(
                children: [
                  _buildRateTile(
                    label: 'egypt_rate'.tr(context),
                    rate: '${category?.egyptRate ?? '80.00'} ${'egp'.tr(context)}',
                    flagEmoji: '🇪🇬',
                    color: const Color(0xFF0D8A74),
                  ),
                  SizedBox(width: 10.w),
                  _buildRateTile(
                    label: 'arab_rate'.tr(context),
                    rate: '${category?.arabRate ?? '100.00'} ${'egp'.tr(context)}',
                    flagEmoji: '🇸🇦',
                    color: const Color(0xFF059669),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  _buildRateTile(
                    label: 'foreign_rate'.tr(context),
                    rate: '${category?.foreignRate ?? '120.00'} ${'egp'.tr(context)}',
                    flagEmoji: '🌍',
                    color: const Color(0xFFD97706),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 20.h),

        // ── Teaching Minutes by Nationality Card ──────────────────────────
        _buildSectionTitle(
          title: 'minutes_by_nationality'.tr(context),
          icon: Icons.timer_outlined,
        ),
        SizedBox(height: 8.h),
        _buildMinutesByNationalityCard(
          context: context,
          minutesSpent: minutesSpent,
          countryCode: countryCode,
        ),

        SizedBox(height: 20.h),

        // Account & Profile Details Card
        _buildSectionTitle(
          title: 'personal_data'.tr(context),
          icon: Icons.person_pin_rounded,
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: ColorsManager.borderColor.withValues(alpha: 0.8),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildDetailRow(
                icon: Icons.person_outline_rounded,
                label: 'full_name'.tr(context),
                value: user?.name ?? '-',
              ),
              _buildDivider(),
              _buildDetailRow(
                icon: Icons.email_outlined,
                label: 'email'.tr(context),
                value: user?.email ?? '-',
              ),
              _buildDivider(),
              _buildDetailRow(
                icon: Icons.circle,
                iconColor: profile?.isOnline == true
                    ? const Color(0xFF10B981)
                    : Colors.grey,
                label: 'active_status'.tr(context),
                value: profile?.isOnline == true
                    ? 'online_now'.tr(context)
                    : 'offline_now'.tr(context),
                valueColor: profile?.isOnline == true
                    ? const Color(0xFF10B981)
                    : ColorsManager.textSecondaryColor,
              ),
              if (countryCode != null && countryCode.isNotEmpty) ...[
                _buildDivider(),
                _buildDetailRow(
                  icon: Icons.flag_rounded,
                  label: 'teacher_country'.tr(context),
                  value: countryCode,
                ),
              ],
            ],
          ),
        ),

        SizedBox(height: 24.h),

        // ── Logout Action Button ──────────────────────────────────────
        Container(
          width: double.infinity,
          height: 50.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: ColorsManager.borderColor,
            ),
          ),
          child: TextButton.icon(
            onPressed: () => _confirmLogout(context),
            icon: Icon(
              Icons.logout_rounded,
              color: ColorsManager.textPrimaryColor,
              size: 20.sp,
            ),
            label: Text(
              'logout'.tr(context),
              style: TextStyle(
                fontFamily: 'Cairo',
                color: ColorsManager.textPrimaryColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        SizedBox(height: 12.h),

        // ── Delete Account Action Button (Danger Zone) ────────────────
        Container(
          width: double.infinity,
          height: 50.h,
          decoration: BoxDecoration(
            color: ColorsManager.errorColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: ColorsManager.errorColor.withValues(alpha: 0.25),
            ),
          ),
          child: TextButton.icon(
            onPressed: () => _confirmDeleteAccount(context),
            icon: Icon(
              Icons.delete_forever_rounded,
              color: ColorsManager.errorColor,
              size: 20.sp,
            ),
            label: Text(
              'delete_account'.tr(context),
              style: TextStyle(
                fontFamily: 'Cairo',
                color: ColorsManager.errorColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 32.h),
      ],
    );
  }

  Widget _buildRateTile({
    required String label,
    required String rate,
    required String flagEmoji,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(flagEmoji, style: TextStyle(fontSize: 14.sp)),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: ColorsManager.textSecondaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              rate,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Minutes By Nationality Card ───────────────────────────────────────────
  Widget _buildMinutesByNationalityCard({
    required BuildContext context,
    MinutesSpent? minutesSpent,
    String? countryCode,
  }) {
    final egyptian = minutesSpent?.egyptianMinutes ?? 0;
    final arab = minutesSpent?.arabMinutes ?? 0;
    final foreign = minutesSpent?.foreignMinutes ?? 0;
    final total = egyptian + arab + foreign;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: ColorsManager.borderColor.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.primaryColor.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──────────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.bar_chart_rounded,
                  color: const Color(0xFF6366F1),
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'minutes_by_nationality'.tr(context),
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: ColorsManager.textPrimaryColor,
                      ),
                    ),
                    Text(
                      'minutes_by_nationality_sub'.tr(context),
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10.5.sp,
                        color: ColorsManager.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              // Total badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$total',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6366F1),
                      ),
                    ),
                    Text(
                      'min_label'.tr(context),
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 9.sp,
                        color: const Color(0xFF6366F1).withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Divider(height: 20.h, color: Colors.grey.shade100),

          // ── 3 Nationality Rows ───────────────────────────────────────────
          _buildNationalityMinuteRow(
            context: context,
            label: 'egyptian_minutes'.tr(context),
            flagEmoji: '🇪🇬',
            minutes: egyptian,
            total: total,
            color: const Color(0xFF0D8A74),
          ),
          SizedBox(height: 10.h),
          _buildNationalityMinuteRow(
            context: context,
            label: 'arab_minutes'.tr(context),
            flagEmoji: '🇸🇦',
            minutes: arab,
            total: total,
            color: const Color(0xFF059669),
          ),
          SizedBox(height: 10.h),
          _buildNationalityMinuteRow(
            context: context,
            label: 'foreign_minutes'.tr(context),
            flagEmoji: '🌍',
            minutes: foreign,
            total: total,
            color: const Color(0xFFD97706),
          ),
        ],
      ),
    );
  }

  Widget _buildNationalityMinuteRow({
    required BuildContext context,
    required String label,
    required String flagEmoji,
    required int minutes,
    required int total,
    required Color color,
  }) {
    final double fraction = total > 0 ? (minutes / total).clamp(0.0, 1.0) : 0.0;
    final String minLabel = 'min_label'.tr(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(flagEmoji, style: TextStyle(fontSize: 16.sp)),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: ColorsManager.textSecondaryColor,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                '$minutes $minLabel',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(6.r),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 6.h,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }


  Widget _buildTracksTab({
    required BuildContext context,
    required List<TrackModel> tracks,
  }) {
    if (tracks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_rounded,
              size: 60.sp,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 12.h),
            Text(
              'no_tracks_selected'.tr(context),
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 15.sp,
                color: ColorsManager.textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final track = tracks[index];
        final trackGradients = _gradientForTrackIndex(index);

        return Container(
          margin: EdgeInsets.only(bottom: 14.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: ColorsManager.borderColor.withValues(alpha: 0.8),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Track Icon
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: trackGradients,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: trackGradients.first.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        _iconForTrack(track.id),
                        color: Colors.white,
                        size: 22.sp,
                      ),
                    ),

                    SizedBox(width: 12.w),

                    // Track Title & Badges
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.name,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: ColorsManager.textPrimaryColor,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Wrap(
                            spacing: 6.w,
                            runSpacing: 4.h,
                            children: [
                              // Marketing Value Badge
                              if (track.marketingValue.isNotEmpty)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: ColorsManager.accentColor
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    track.marketingValue,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 10.5.sp,
                                      fontWeight: FontWeight.bold,
                                      color: ColorsManager.accentColor,
                                    ),
                                  ),
                                ),

                              // Target Group Pill
                              if (track.targetGroup.isNotEmpty)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: ColorsManager.primaryColor
                                        .withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    track.targetGroup,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 10.5.sp,
                                      fontWeight: FontWeight.w600,
                                      color: ColorsManager.primaryColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                if (track.description.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: ColorsManager.backgroundColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      track.description,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.sp,
                        height: 1.45,
                        color: ColorsManager.textSecondaryColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  List<Color> _gradientForTrackIndex(int index) {
    switch (index % 5) {
      case 0:
        return const [Color(0xFF0D8A74), Color(0xFF26A69A)];
      case 1:
        return const [Color(0xFF0F766E), Color(0xFF2DD4BF)];
      case 2:
        return const [Color(0xFFD97706), Color(0xFFF59E0B)];
      case 3:
        return const [Color(0xFF7C3AED), Color(0xFFA78BFA)];
      case 4:
      default:
        return const [Color(0xFF059669), Color(0xFF10B981)];
    }
  }

  IconData _iconForTrack(int trackId) {
    switch (trackId) {
      case 1:
        return Icons.menu_book_rounded;
      case 2:
        return Icons.record_voice_over_rounded;
      case 3:
        return Icons.workspace_premium_rounded;
      case 4:
        return Icons.child_care_rounded;
      case 5:
        return Icons.repeat_rounded;
      default:
        return Icons.auto_stories_rounded;
    }
  }

  Widget _buildSectionTitle({
    required String title,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, color: ColorsManager.primaryColor, size: 20.sp),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: ColorsManager.textPrimaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    Color? iconColor,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor ?? ColorsManager.primaryColor,
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13.sp,
              color: ColorsManager.textSecondaryColor,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13.5.sp,
              fontWeight: FontWeight.bold,
              color: valueColor ?? ColorsManager.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey.shade100);
  }

  Future<void> _confirmLogout(BuildContext context) async {
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
                Icons.logout_rounded,
                color: ColorsManager.errorColor,
                size: 20,
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              'logout'.tr(context),
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
          'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
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
              'logout'.tr(context),
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
      await getIt<ProfileCubit>().logout();
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle Bar
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 20.h),

              // Warning Icon with red container
              Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  color: ColorsManager.errorColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 46.w,
                    height: 46.w,
                    decoration: const BoxDecoration(
                      color: ColorsManager.errorColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_forever_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Title
              Text(
                'delete_account_confirm_title'.tr(context),
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: ColorsManager.textPrimaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.h),

              // Description
              Text(
                'delete_account_confirm_desc'.tr(context),
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13.sp,
                  color: ColorsManager.textSecondaryColor,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 18.h),

              // Warning Points Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Column(
                  children: [
                    _buildWarningBullet(
                      context,
                      'delete_account_warning_1'.tr(context),
                    ),
                    SizedBox(height: 8.h),
                    _buildWarningBullet(
                      context,
                      'delete_account_warning_2'.tr(context),
                    ),
                    SizedBox(height: 8.h),
                    _buildWarningBullet(
                      context,
                      'delete_account_warning_3'.tr(context),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Actions: Cancel & Delete
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetCtx, false),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'cancel'.tr(context),
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                          color: ColorsManager.textSecondaryColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(sheetCtx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsManager.errorColor,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'yes_delete_account'.tr(context),
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (loadingCtx) => PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Row(
                children: [
                  const CircularProgressIndicator(
                    color: ColorsManager.errorColor,
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Text(
                      'deleting_account'.tr(context),
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14.sp,
                        color: ColorsManager.textPrimaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await getIt<ProfileCubit>().deleteAccount();
    }
  }

  Widget _buildWarningBullet(BuildContext context, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.error_outline_rounded,
          color: ColorsManager.errorColor,
          size: 16.sp,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11.5.sp,
              color: const Color(0xFF991B1B),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

// ── TabBar Sliver Delegate ──────────────────────────────────────────────────
class _TabBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarHeaderDelegate({required this.tabBar});

  @override
  double get minExtent => tabBar.preferredSize.height + 10.h;

  @override
  double get maxExtent => tabBar.preferredSize.height + 10.h;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: ColorsManager.backgroundColor,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: ColorsManager.primaryColor.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(_TabBarHeaderDelegate oldDelegate) {
    return false;
  }
}

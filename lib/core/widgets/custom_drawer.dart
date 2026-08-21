import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waratel_app/core/routing/routers.dart';
import 'package:waratel_app/core/theming/colors.dart';
import 'package:waratel_app/features/profile/logic/cubit/profile_cubit.dart';
import 'package:waratel_app/features/profile/logic/cubit/profile_state.dart';
import 'package:waratel_app/features/profile/data/models/profile_models.dart';
import 'package:waratel_app/features/localization/data/app_localizations.dart';
import 'package:waratel_app/features/localization/logic/cubit/locale_cubit.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        // Gradient drawer background for a premium look
        decoration: const BoxDecoration(
          gradient: ColorsManager.headerGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ───────────────────────────────────────────────────
              // PERF: buildWhen ensures header only rebuilds when profile
              // data loads — not on logout / error / other unrelated states.
              BlocBuilder<ProfileCubit, ProfileState>(
                buildWhen: (_, curr) =>
                    curr is ProfileLoaded || curr is ProfileLoading,
                builder: (context, state) {
                  ProfileUser? user;
                  String? photoPath;
                  String salary = '0.00';
                  if (state is ProfileLoaded) {
                    user = state.profileResponse.user;
                    photoPath = state.profileResponse.profile?.profilePhotoPath;
                    salary = state.profileResponse.profile?.salary ?? '0.00';
                  }
                  return Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30.r,
                          backgroundColor: Colors.white.withValues(alpha: 0.25),
                          backgroundImage: photoPath != null
                              ? CachedNetworkImageProvider(
                                      'https://wartil.com/storage/$photoPath')
                                  as ImageProvider
                              : null,
                          child: photoPath == null
                              ? Icon(Icons.person,
                                  size: 38.sp, color: Colors.white)
                              : null,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name ?? 'teacher'.tr(context),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '$salary ${'usd'.tr(context)}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // ── Menu Items ───────────────────────────────────────────────
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  children: [
                    _DrawerMenuItem(
                      icon: Icons.person_outline,
                      label: 'profile'.tr(context),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/profile');
                      },
                    ),
                    _DrawerMenuItem(
                      icon: Icons.emoji_events,
                      label: 'achievement_plan'.tr(context),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/achievementPlan');
                      },
                    ),
                    _DrawerMenuItem(
                      icon: Icons.info_outline,
                      label: 'about'.tr(context),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, Routes.about);
                      },
                    ),
                    _DrawerMenuItem(
                      icon: Icons.menu_book,
                      label: 'holy_quran_title'.tr(context),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, Routes.quran);
                      },
                    ),

                    _DrawerMenuItem(
                      icon: Icons.headset_mic_outlined,
                      label: 'contact_us'.tr(context),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, Routes.contactUs);
                      },
                    ),
                    _DrawerMenuItem(
                      icon: Icons.auto_awesome_rounded,
                      label: 'ورتل الذكي', // Manually added as it might not be in localization yet
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, Routes.aiChat);
                      },
                    ),
                    _DrawerMenuItem(
                      icon: Icons.description_outlined,
                      label: 'terms'.tr(context),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, Routes.terms);
                      },
                    ),
                    _DrawerMenuItem(
                      icon: Icons.language,
                      label: 'change_language'.tr(context),
                      onTap: () => _showLanguageDialog(context),
                    ),
                    _DrawerMenuItem(
                      icon: Icons.bar_chart,
                      label: 'stats'.tr(context),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, Routes.statistics);
                      },
                    ),

                    Divider(
                      color: Colors.white.withValues(alpha: 0.2),
                      height: 24.h,
                      indent: 16.w,
                      endIndent: 16.w,
                    ),

                    // ── Logout ──────────────────────────────────────────
                    BlocBuilder<ProfileCubit, ProfileState>(
                      buildWhen: (_, curr) =>
                          curr is LogoutLoading ||
                          curr is LogoutSuccess ||
                          curr is LogoutError,
                      builder: (context, state) {
                        final isLoading = state is LogoutLoading;
                        return ListTile(
                          leading: isLoading
                              ? SizedBox(
                                  width: 22.w,
                                  height: 22.w,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(Icons.logout,
                                  color: Colors.white70, size: 26.sp),
                          title: Text(
                            'logout'.tr(context),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: isLoading
                              ? null
                              : () => context.read<ProfileCubit>().logout(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 24.w, vertical: 4.h),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('select_language'.tr(context)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('arabic'.tr(context)),
                onTap: () {
                  context.read<LocaleCubit>().changeLanguage('ar');
                  Navigator.pop(dialogContext);
                },
              ),
              ListTile(
                title: Text('english'.tr(context)),
                onTap: () {
                  context.read<LocaleCubit>().changeLanguage('en');
                  Navigator.pop(dialogContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Extracted as a proper widget — the build method is minimal and
/// Flutter's element tree can diff it efficiently in the ListView.
class _DrawerMenuItem extends StatelessWidget {
  const _DrawerMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 26.sp),
      title: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 2.h),
      splashColor: Colors.white12,
      hoverColor: Colors.white10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

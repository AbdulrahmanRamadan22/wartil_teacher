import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waratel_app/core/theming/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waratel_app/core/di/dependency_injection.dart';
import 'package:waratel_app/features/profile/logic/cubit/profile_cubit.dart';
import 'package:waratel_app/features/profile/logic/cubit/profile_state.dart';
import 'package:waratel_app/features/profile/data/models/profile_models.dart';
import 'package:waratel_app/features/localization/data/app_localizations.dart';
import 'package:waratel_app/features/localization/logic/cubit/locale_cubit.dart';
import 'package:waratel_app/features/localization/logic/cubit/locale_state.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<ProfileCubit>(),
      child: DefaultTabController(
        length: 2,
        child: BlocBuilder<ProfileCubit, ProfileState>(
          buildWhen: (previous, current) =>
              current is ProfileLoading ||
              current is ProfileLoaded ||
              current is ProfileError ||
              current is LogoutLoading ||
              current is LogoutSuccess ||
              current is LogoutError,
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (state is ProfileError) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 60.sp, color: Colors.red),
                      SizedBox(height: 16.h),
                      Text(state.error,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14.sp)),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<ProfileCubit>().getProfile(),
                        child: Text('retry'.tr(context)),
                      ),
                    ],
                  ),
                ),
              );
            }

            final profile = state is ProfileLoaded
                ? state.profileResponse
                : context.read<ProfileCubit>().profileData;
            final application = profile?.profile?.application;
            final user = profile?.user;

            return Scaffold(
              backgroundColor: ColorsManager.backgroundColor,
              body: Column(
                children: [
                  // Header
                  _buildHeader(context, user, profile),

                  // Tab Bar
                  Container(
                    color: Colors.white,
                    child: TabBar(
                      labelColor: ColorsManager.primaryColor,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: ColorsManager.primaryColor,
                      indicatorWeight: 3.h,
                      labelStyle: TextStyle(
                          fontSize: 14.sp, fontWeight: FontWeight.bold),
                      tabs: [
                        Tab(text: 'information'.tr(context)),
                        Tab(text: 'experience'.tr(context)),
                      ],
                    ),
                  ),

                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildInfoTab(context, application, profile?.user),
                        _buildExperienceTab(context, application, profile),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, ProfileUser? user, ProfileResponse? profile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 50.h, bottom: 25.h),
      decoration: BoxDecoration(
        color: ColorsManager.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        children: [
          // Profile Photo
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3.w),
            ),
            child: CircleAvatar(
              radius: 45.r,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              backgroundImage: profile?.profile?.profilePhotoPath != null
                  ? CachedNetworkImageProvider(
                          'https://wartil.com/storage/${profile!.profile!.profilePhotoPath}')
                      as ImageProvider
                  : null,
              child: profile?.profile?.profilePhotoPath == null
                  ? Icon(Icons.person, size: 55.sp, color: Colors.white)
                  : null,
            ),
          ),
          SizedBox(height: 12.h),

          // Name
          Text(
            user?.name ?? 'teacher'.tr(context),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),

          // Salary & Minutes
          if (profile?.profile != null)
            Text(
              '${'salary'.tr(context)} ${profile!.profile!.salary} | ${'minutes'.tr(context)} ${profile.profile!.minutes}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12.sp,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoTab(
      BuildContext context, TeacherApplication? app, ProfileUser? user) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        _buildSectionTitle(context, 'personal_data'.tr(context)),
        _buildInfoCard([
          _buildInfoRow(context, Icons.person_outline, 'full_name'.tr(context),
              app?.fullName ?? '-'),
          _buildInfoRow(
              context,
              Icons.wc,
              'gender'.tr(context),
              app?.gender == 'male'
                  ? 'male'.tr(context)
                  : (app?.gender == 'female'
                      ? 'female'.tr(context)
                      : (app?.gender ?? '-'))),
          _buildInfoRow(context, Icons.email_outlined, 'email'.tr(context),
              user?.email ?? '-'),
          _buildInfoRow(context, Icons.phone_android,
              'whatsapp_number'.tr(context), app?.phone ?? '-'),
        ]),
        SizedBox(height: 20.h),
        _buildSectionTitle(context, 'location_residence'.tr(context)),
        _buildInfoCard([
          _buildInfoRow(context, Icons.public, 'origin_country'.tr(context),
              app?.originCountry ?? '-'),
          _buildInfoRow(context, Icons.location_on_outlined,
              'residence_location'.tr(context), app?.residenceLocation ?? '-'),
        ]),
        SizedBox(height: 20.h),
        _buildSectionTitle(context, 'educational_background'.tr(context)),
        _buildInfoCard([
          _buildInfoRow(context, Icons.school_outlined,
              'qualification'.tr(context), app?.qualification ?? '-'),
        ]),
        SizedBox(height: 20.h),
        _buildSectionTitle(context, 'languages'.tr(context)),
        _buildInfoCard([
          _buildInfoRow(context, Icons.language, 'languages'.tr(context),
              app?.languages.join('، ') ?? '-'),
        ]),
      ],
    );
  }

  Widget _buildExperienceTab(
      BuildContext context, TeacherApplication? app, ProfileResponse? profile) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        _buildSectionTitle(context, 'teaching_tracks'.tr(context)),
        SizedBox(height: 10.h),
        if (profile?.tracks.isNotEmpty == true)
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: profile!.tracks.map((t) => _buildChip(t.name)).toList(),
          )
        else
          Text('no_tracks_selected'.tr(context),
              style: TextStyle(fontSize: 13.sp, color: Colors.grey)),
        SizedBox(height: 25.h),
        _buildSectionTitle(context, 'experience_capabilities'.tr(context)),
        _buildInfoCard([
          _buildInfoRow(context, Icons.history, 'experience_years'.tr(context),
              '${app?.experienceYears ?? 0} ${'experience_years'.tr(context)}'),
          _buildInfoRow(
              context,
              Icons.access_time,
              'daily_work_hours'.tr(context),
              '${app?.workHours ?? 0} ${'minutes'.tr(context)}'),
          _buildInfoRow(
              context,
              Icons.laptop_chromebook,
              'online_teaching'.tr(context),
              _translateLevel(context, app?.onlineExperience)),
          _buildInfoRow(context, Icons.speed, 'internet_quality'.tr(context),
              _translateLevel(context, app?.internetQuality)),
          _buildInfoRow(
              context,
              Icons.settings_suggest,
              'tech_skills'.tr(context),
              _translateLevel(context, app?.techSkills)),
        ]),
        SizedBox(height: 20.h),
        if (app?.cvPdfPath != null) ...[
          _buildSectionTitle(context, 'attachments_certificates'.tr(context)),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.all(15.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                  color: ColorsManager.primaryColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.picture_as_pdf, color: Colors.red, size: 30.sp),
                SizedBox(width: 15.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('cv_certificates'.tr(context),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13.sp)),
                      Text('pdf_file'.tr(context),
                          style:
                              TextStyle(color: Colors.grey, fontSize: 11.sp)),
                    ],
                  ),
                ),
                Icon(Icons.download, color: ColorsManager.primaryColor),
              ],
            ),
          ),
        ],
        SizedBox(height: 20.h),
      ],
    );
  }

  String _translateLevel(BuildContext context, String? level) {
    switch (level?.toLowerCase()) {
      case 'expert':
      case 'خبير':
        return 'expert'.tr(context);
      case 'intermediate':
      case 'متوسط':
        return 'intermediate'.tr(context);
      case 'beginner':
      case 'مبتدئ':
        return 'beginner'.tr(context);
      case 'good':
      case 'جيد':
        return 'good'.tr(context);
      case 'very_good':
      case 'جيد جداً':
        return 'very_good'.tr(context);
      case 'excellent':
      case 'ممتاز':
        return 'excellent'.tr(context);
      case 'needs_follow_up':
      case 'يحتاج متابعة':
        return 'needs_follow_up'.tr(context);
      default:
        return level ?? '-';
    }
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: ColorsManager.primaryColor,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        textDirection: context.read<LocaleCubit>().state is ChangeLocaleState &&
                (context.read<LocaleCubit>().state as ChangeLocaleState)
                        .locale
                        .languageCode ==
                    'en'
            ? TextDirection.ltr
            : TextDirection.rtl,
        children: [
          Icon(icon, color: ColorsManager.primaryColor, size: 22.sp),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                Text(value,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14.sp)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, {bool isAccent = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isAccent ? ColorsManager.primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: ColorsManager.primaryColor),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isAccent ? Colors.white : ColorsManager.primaryColor,
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

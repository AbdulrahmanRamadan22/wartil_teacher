import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:waratel_app/core/di/dependency_injection.dart';
import 'package:waratel_app/core/theming/colors.dart';
import 'package:waratel_app/features/contact_us/logic/cubit/contact_cubit.dart';
import 'package:waratel_app/features/contact_us/logic/cubit/contact_state.dart';
import 'package:waratel_app/features/contact_us/data/models/contact_settings_model.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  static const String _twitter = 'https://x.com/wartil_app';
  static const String _instagramUrl =
      'https://www.instagram.com/wartil20?igsh=MWxidnk0cjl4YXpwNw%3D%3D';
  static const String _facebookUrl =
      'https://www.facebook.com/profile.php?id=61587242675052&mibextid=wwXIfr&rdid=Y7JqZLVEVXZXd5u9&share_url=https%3A%2F%2Fwww.facebook.com%2Fshare%2F1AxkW1TqfE%2F%3Fmibextid%3DwwXIfr#';

  Future<void> _launchEmail(String email) async {
    final String trimmedEmail = email.trim();
    final Uri emailLaunchUri = Uri(scheme: 'mailto', path: trimmedEmail);
    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      }
    } catch (e) {
      debugPrint('Error launching email: $e');
    }
  }

  Future<void> _launchWhatsapp(String phone) async {
    final String trimmedPhone = phone.trim().replaceAll(' ', '').replaceAll('+', '');
    final String url = 'https://wa.me/$trimmedPhone';
    final Uri whatsappUri = Uri.parse(url);
    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
    }
  }

  Future<void> _launchUrl(String url) async {
    final String trimmedUrl = url.trim();
    final Uri uri = Uri.parse(trimmedUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ContactCubit>()..getContactSettings(),
      child: BlocBuilder<ContactCubit, ContactState>(
        builder: (context, state) {
          final bool isLoading = state is ContactLoading;
          ContactSettingsData? contactData;
          if (state is ContactSuccess) {
            contactData = state.contactSettings;
          }

          return Scaffold(
            backgroundColor: const Color(0xFFF0F7F5),
            body: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(context),
                SliverToBoxAdapter(
                  child: isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 80),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 40.h),
                          child: Column(
                            children: [
                              _buildHeroCard(),
                              SizedBox(height: 28.h),
                              _buildContactMethodsSection(
                                context,
                                email:
                                    contactData?.email ?? 'support@wartil.com',
                                phone: contactData?.phone ?? '+966500000000',
                              ),
                              SizedBox(height: 28.h),
                              _buildWorkingHoursCard(),
                              SizedBox(height: 28.h),
                              _buildSocialCard(context),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200.h,
      pinned: true,
      elevation: 0,
      backgroundColor: ColorsManager.primaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ColorsManager.primaryColor,
                ColorsManager.primaryColor.withValues(alpha: 0.7),
                const Color(0xFF0A8F6E),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -30.h,
                right: -20.w,
                child: Container(
                  width: 160.w,
                  height: 160.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
              ),
              Positioned(
                bottom: 10.h,
                left: -40.w,
                child: Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 40.h),
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.support_agent_rounded,
                        color: Colors.white,
                        size: 40.sp,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'تواصل معنا',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    Text(
                      'نحن هنا لمساعدتك دائماً',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white.withValues(alpha: 0.85),
                        fontFamily: 'Cairo',
                      ),
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

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorsManager.primaryColor.withValues(alpha: 0.08),
            const Color(0xFF0A8F6E).withValues(alpha: 0.05),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: ColorsManager.primaryColor.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.chat_bubble_outline_rounded,
              color: ColorsManager.primaryColor, size: 28.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'كيف يمكننا مساعدتك؟',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: ColorsManager.primaryColor,
                    fontFamily: 'Cairo',
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'فريق الدعم لدينا متاح للرد على استفساراتك وحل أي مشكلة تواجهها.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                    fontFamily: 'Cairo',
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactMethodsSection(
    BuildContext context, {
    required String email,
    required String phone,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('وسائل التواصل'),
        SizedBox(height: 12.h),
        _buildContactCard(
          context: context,
          icon: Icons.email_outlined,
          iconBg: const Color(0xFFE3F2FD),
          iconColor: Colors.blue[700]!,
          label: 'البريد الإلكتروني',
          value: email,
          onTap: () => _launchEmail(email),
          actionLabel: 'تواصل',
          actionIcon: Icons.send_rounded,
        ),
        SizedBox(height: 12.h),
        _buildContactCard(
          context: context,
          icon: Icons.phone_in_talk_outlined,
          iconBg: const Color(0xFFE8F5E9),
          iconColor: Colors.green[700]!,
          label: 'واتساب',
          value: phone,
          onTap: () => _launchWhatsapp(phone),
          actionLabel: 'مراسلة',
          actionIcon: Icons.chat_rounded,
        ),
      ],
    );
  }

  Widget _buildWorkingHoursCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.access_time_rounded,
                    color: Colors.orange[700], size: 22.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                'ساعات العمل',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildHourRow('الأحد – الخميس', '9:00 ص – 10:00 م'),
          SizedBox(height: 8.h),
          _buildHourRow('الجمعة – السبت', '2:00 م – 8:00 م'),
        ],
      ),
    );
  }

  Widget _buildHourRow(String day, String hours) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          day,
          style: TextStyle(
              fontSize: 13.sp, color: Colors.grey[600], fontFamily: 'Cairo'),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: ColorsManager.primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            hours,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: ColorsManager.primaryColor,
              fontFamily: 'Cairo',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EAF6),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.public_rounded,
                    color: Colors.indigo[600], size: 22.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                'تابعنا على',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildSocialItem(
            context: context,
            icon: Icons.alternate_email_rounded,
            color: Colors.indigo,
            label: 'تويتر (X)', // More descriptive label
            onTap: () => _launchUrl(_twitter),
            isCopy: false,
          ),
          SizedBox(height: 12.h),
          _buildSocialItem(
            context: context,
            icon: Icons.camera_alt_rounded,
            color: const Color(0xFFE1306C),
            label: 'انستقرام',
            onTap: () => _launchUrl(_instagramUrl),
          ),
          SizedBox(height: 12.h),
          _buildSocialItem(
            context: context,
            icon: Icons.facebook_rounded,
            color: const Color(0xFF1877F2),
            label: 'فيسبوك',
            onTap: () => _launchUrl(_facebookUrl),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialItem({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
    bool isCopy = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: color.withValues(alpha: 0.9),
                  fontFamily: 'Cairo',
                ),
              ),
            ),
            Icon(isCopy ? Icons.copy_rounded : Icons.open_in_new_rounded,
                size: 16.sp, color: color.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required BuildContext context,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
    required VoidCallback onTap,
    required String actionLabel,
    required IconData actionIcon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(icon, color: iconColor, size: 24.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey[500],
                      fontFamily: 'Cairo',
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(actionIcon, size: 14.sp, color: iconColor),
                  SizedBox(width: 4.w),
                  Text(
                    actionLabel,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(right: 4.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF1E293B),
          fontFamily: 'Cairo',
        ),
      ),
    );
  }

}

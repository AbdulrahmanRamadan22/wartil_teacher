import 'package:flutter/material.dart';
import 'package:waratel_app/core/theming/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waratel_app/features/localization/data/app_localizations.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  static const _sections = [
    _TermData('terms_p1_title', 'terms_p1_content', Icons.info_outline_rounded),
    _TermData(
        'terms_p2_title', 'terms_p2_content', Icons.person_outline_rounded),
    _TermData('terms_p3_title', 'terms_p3_content', Icons.video_call_outlined),
    _TermData('terms_p4_title', 'terms_p4_content', Icons.payments_outlined),
    _TermData('terms_p5_title', 'terms_p5_content', Icons.gavel_rounded),
    _TermData('terms_p6_title', 'terms_p6_content', Icons.cloud_off_rounded),
    _TermData('terms_p7_title', 'terms_p7_content', Icons.public_rounded),
    _TermData('terms_p8_title', 'terms_p8_content', Icons.copyright_rounded),
    _TermData(
        'terms_p9_title', 'terms_p9_content', Icons.warning_amber_rounded),
    _TermData('terms_p10_title', 'terms_p10_content', Icons.group_off_rounded),
    _TermData('terms_p11_title', 'terms_p11_content', Icons.balance_rounded),
    _TermData(
        'privacy_p12_title', 'privacy_p12_content', Icons.data_usage_rounded),
    _TermData(
        'privacy_p13_title', 'privacy_p13_content', Icons.fact_check_rounded),
    _TermData(
        'privacy_p14_title', 'privacy_p14_content', Icons.history_rounded),
    _TermData(
        'privacy_p15_title', 'privacy_p15_content', Icons.sync_alt_rounded),
    _TermData(
        'privacy_p16_title', 'privacy_p16_content', Icons.security_rounded),
    _TermData('privacy_p17_title', 'privacy_p17_content',
        Icons.notifications_active_rounded),
    _TermData('privacy_p18_title', 'privacy_p18_content',
        Icons.accessibility_new_rounded),
    _TermData(
        'privacy_p19_title', 'privacy_p19_content', Icons.child_care_rounded),
    _TermData('privacy_p20_title', 'privacy_p20_content',
        Icons.business_center_rounded),
    _TermData('privacy_p21_title', 'privacy_p21_content',
        Icons.mark_as_unread_rounded),
    _TermData(
        'privacy_p22_title', 'privacy_p22_content', Icons.edit_note_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.backgroundColor,
      appBar: AppBar(title: Text('terms_title'.tr(context))),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Intro banner ─────────────────────────────────────────────
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: ColorsManager.primaryColor.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                    color: ColorsManager.primaryColor.withValues(alpha: 0.15)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline,
                      color: ColorsManager.primaryColor, size: 20.sp),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'terms_intro'.tr(context),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: ColorsManager.textPrimaryColor,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // ── Term sections ────────────────────────────────────────────
            ..._sections.map((s) => _TermSection(
                  titleKey: s.titleKey,
                  contentKey: s.contentKey,
                  icon: s.icon,
                )),

            SizedBox(height: 24.h),
            Center(
              child: Text(
                'Waratel App © 2026',
                style: TextStyle(
                    color: ColorsManager.textHintColor, fontSize: 12.sp),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}

class _TermData {
  const _TermData(this.titleKey, this.contentKey, this.icon);
  final String titleKey, contentKey;
  final IconData icon;
}

class _TermSection extends StatelessWidget {
  const _TermSection({
    required this.titleKey,
    required this.contentKey,
    required this.icon,
  });

  final String titleKey, contentKey;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child:
                    Icon(icon, color: ColorsManager.primaryColor, size: 20.sp),
              ),
              SizedBox(width: 10.w),
              Text(
                titleKey.tr(context),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: ColorsManager.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: Text(
              contentKey.tr(context),
              style: TextStyle(
                fontSize: 14.sp,
                color: ColorsManager.textSecondaryColor,
                height: 1.6,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Divider(color: ColorsManager.dividerColor, thickness: 1),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// النصوص المزخرفة في شاشة Splash
class SplashAnimatedText extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  const SplashAnimatedText({
    super.key,
    required this.fadeAnimation,
    required this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: Column(
          children: [
            // العنوان الرئيسي مع زخرفة قرآنية
            _buildMainTitle(),
            SizedBox(height: 16.h),
            // زخرفة إسلامية فاصلة
            _buildDecorativeDivider(),
            SizedBox(height: 40.h),
            // النص الفرعي مع تأثير قرآني
            _buildSubtitle(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainTitle() {
    return Stack(
      children: [
        // ظل خارجي ذهبي
        Text(
          '• ورتّل •',
          style: TextStyles.font32BoldTextPrimary.copyWith(
            fontSize: 42.sp,
            fontWeight: FontWeight.w900,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 6
              ..color = ColorsManager.accentColor.withValues(alpha: 0.5),
            letterSpacing: 3,
            height: 1.2,
          ),
        ),
        // النص الأساسي مع تدرج ذهبي-أبيض
        Text(
          '• ورتّل •',
          style: TextStyles.font32BoldTextPrimary.copyWith(
            fontSize: 42.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
            height: 1.2,
            shadows: [
              Shadow(
                color: const Color.fromARGB(255, 228, 226, 226)
                    .withValues(alpha: 0.3),
                offset: const Offset(0, 4),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDecorativeDivider() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDecorativeLine(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            '۞',
            style: TextStyle(
              fontSize: 24.sp,
              color: ColorsManager.accentColor,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
        _buildDecorativeLine(),
      ],
    );
  }

  Widget _buildDecorativeLine() {
    return Container(
      width: 60.w,
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            ColorsManager.accentColor
                .withValues(alpha: 0.4), // درجة ذهبية هادئة جداً
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorsManager.greenDark.withValues(alpha: 0.3),
            ColorsManager.greenDark.withValues(alpha: 0.1),
            ColorsManager.greenDark.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: ColorsManager.accentColor
              .withValues(alpha: 0.2), // إطار خفيف جداً
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(
        '✦ منصةالمعلم لتعليم القرآن الكريم ✦',
        textAlign: TextAlign.center,
        style: TextStyles.font16RegularTextPrimary.copyWith(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 2,
          height: 1.5,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.3),
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
      ),
    );
  }
}

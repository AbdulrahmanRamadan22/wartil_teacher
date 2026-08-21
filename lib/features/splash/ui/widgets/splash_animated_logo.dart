import 'package:flutter/material.dart';
import '../../../../core/helpers/assets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// لوجو التطبيق مع الأنيميشن في شاشة Splash
class SplashAnimatedLogo extends StatelessWidget {
  final Animation<double> scaleAnimation;
  final Animation<double> fadeAnimation;
  final Animation<double> rotationAnimation;

  const SplashAnimatedLogo({
    super.key,
    required this.scaleAnimation,
    required this.fadeAnimation,
    required this.rotationAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: scaleAnimation.value,
          child: Transform.rotate(
            angle: rotationAnimation.value,
            child: Opacity(
              opacity: fadeAnimation.value,
              child: SizedBox(
                width: 250.w,
                height: 250.w,
                child: Image.asset(
                  AppAssets.appLogo,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

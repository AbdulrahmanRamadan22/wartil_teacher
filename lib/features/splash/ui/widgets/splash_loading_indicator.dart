import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theming/colors.dart';

/// مؤشر التحميل في شاشة Splash
class SplashLoadingIndicator extends StatelessWidget {
  final Animation<double> fadeAnimation;

  const SplashLoadingIndicator({
    super.key,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: SizedBox(
        width: 40.w,
        height: 40.w,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            ColorsManager.surfaceColor.withValues(alpha: 0.7),
          ),
          strokeWidth: 3,
        ),
      ),
    );
  }
}

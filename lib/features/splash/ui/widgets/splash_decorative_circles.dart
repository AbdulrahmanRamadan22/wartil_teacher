import 'package:flutter/material.dart';
import '../../../../core/theming/colors.dart';

/// الدوائر الزخرفية في خلفية الـ Splash
class SplashDecorativeCircles extends StatelessWidget {
  const SplashDecorativeCircles({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // دائرة ذهبية في الأعلى
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  ColorsManager.accentColor.withValues(alpha: 0.2),
                  ColorsManager.accentColor.withValues(alpha: 0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // دائرة خضراء فاتحة في الأسفل
        Positioned(
          bottom: -150,
          left: -150,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  ColorsManager.accentColor.withValues(alpha: 0.1),
                  ColorsManager.accentColor.withValues(alpha: 0.02),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // دائرة ذهبية صغيرة إضافية
        Positioned(
          top: 200,
          left: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  ColorsManager.accentColor.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

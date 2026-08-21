import 'package:flutter/material.dart';
import 'package:waratel_app/core/theming/colors.dart';
import 'package:waratel_app/core/routing/routers.dart';
import 'package:waratel_app/core/cache/shared_preferences.dart';
import 'package:waratel_app/core/call/call_service.dart';
import 'package:waratel_app/core/di/dependency_injection.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    // Navigate after splash animation
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _navigateNext();
      }
    });
  }

  /// التحقق من الجلسة المحفوظة والانتقال للشاشة المناسبة
  void _navigateNext() {
    final bool loggedIn = SharedPreferencesService.isLoggedIn();
    final String? token = SharedPreferencesService.getToken();

    if (loggedIn && token != null && token.isNotEmpty) {
      // ✅ المعلم كان مسجلاً — أعد تفعيل Pusher ثم اذهب للرئيسية
      final int? teacherId = SharedPreferencesService.getTeacherId();
      if (teacherId != null) {
        getIt<CallService>().initPusher(teacherId);
        debugPrint('✅ [SPLASH] Auto-Login: تفعيل Pusher للمعلم $teacherId');
      }
      Navigator.pushReplacementNamed(context, Routes.home);
    } else {
      // ❌ لم يسجل دخول — تحقق من الموافقة على الشروط
      final bool hasAgreed = SharedPreferencesService.hasAgreedToTerms();
      if (hasAgreed) {
        Navigator.pushReplacementNamed(context, Routes.login);
      } else {
        Navigator.pushReplacementNamed(context, Routes.termsAgreement);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Gradient decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300.w,
              height: 300.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: ColorsManager.primaryColor,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200.w,
              height: 200.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: ColorsManager.primaryColor,
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 140.w,
                      height: 140.w,
                      decoration: BoxDecoration(
                        color: ColorsManager.primaryColor,
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30.r),
                        child: Image.asset(
                          'assets/icons/ورتل ايقون (1).png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    const Text(
                      "ورتل",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: ColorsManager.primaryColor,
                        fontFamily: 'Cairo',
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      "ورتل القرآن ترتيلاً",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[400],
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

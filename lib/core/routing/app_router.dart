import 'package:flutter/material.dart';
import 'package:waratel_app/core/routing/routers.dart';
import 'package:waratel_app/features/splash/ui/splash_screen.dart';
import 'package:waratel_app/features/login/ui/screens/login_screen.dart';
import 'package:waratel_app/features/home/ui/home_layout.dart';
import 'package:waratel_app/features/achievement_plan/ui/achievement_plan_screen.dart';
import 'package:waratel_app/features/profile/ui/profile_screen.dart';
import 'package:waratel_app/features/schedule/ui/add_appointment_screen.dart';
import 'package:waratel_app/features/call/ui/call_screen.dart';
import 'package:waratel_app/features/notifications/ui/notifications_screen.dart';
import 'package:waratel_app/features/record/ui/session_details_screen.dart';
import 'package:waratel_app/features/record/data/models/session_model.dart';
import 'package:waratel_app/features/about/ui/about_screen.dart';
import 'package:waratel_app/features/contact_us/ui/contact_us_screen.dart';
import 'package:waratel_app/features/statistics/ui/statistics_screen.dart';
import 'package:waratel_app/features/terms/ui/terms_screen.dart';
import 'package:waratel_app/features/terms/ui/terms_agreement_screen.dart';
import 'package:waratel_app/features/quran_recitation/ui/live_maqra_screen.dart';
import 'package:waratel_app/features/quran_recitation/ui/quran_screen.dart';
import 'package:waratel_app/features/ai_chat/ui/ai_chat_screen.dart';

/// إدارة التوجيه في التطبيق - العودة للـ MaterialPageRoute لضمان الاستقرار
class AppRouter {
  /// توليد المسارات
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case Routes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case Routes.home:
        return MaterialPageRoute(builder: (_) => const HomeLayout());

      case Routes.achievementPlan:
        return MaterialPageRoute(builder: (_) => const AchievementPlanScreen());

      case Routes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case Routes.addAppointment:
        return MaterialPageRoute(builder: (_) => const AddAppointmentScreen());

      case Routes.call:
        final dynamic rawArgs = settings.arguments;
        final Map<String, dynamic> args =
            (rawArgs is Map<String, dynamic>) ? rawArgs : {};
        return MaterialPageRoute(
          builder: (_) => CallScreen(
            token: args['token'] ?? '',
            channelName: args['channelName'] ?? '',
            uid: args['uid'] ?? 0,
            studentName: args['studentName'] ?? 'طالب',
            callId: args['callId'] is int
                ? args['callId']
                : int.tryParse(args['callId']?.toString() ?? ''),
          ),
        );

      case Routes.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());

      case Routes.sessionDetails:
        final session = settings.arguments as SessionModel;
        return MaterialPageRoute(
          builder: (_) => SessionDetailsScreen(session: session),
        );

      case Routes.about:
        return MaterialPageRoute(builder: (_) => const AboutScreen());

      case Routes.contactUs:
        return MaterialPageRoute(builder: (_) => const ContactUsScreen());

      case Routes.statistics:
        return MaterialPageRoute(builder: (_) => const StatisticsScreen());

      case Routes.terms:
        return MaterialPageRoute(builder: (_) => const TermsScreen());

      case Routes.termsAgreement:
        return MaterialPageRoute(builder: (_) => const TermsAgreementScreen());

      case Routes.quran:
        return MaterialPageRoute(builder: (_) => const QuranScreen());

      case Routes.maqraa:
        return MaterialPageRoute(builder: (_) => const QuranRecitationScreen());

      case Routes.aiChat:
        return MaterialPageRoute(builder: (_) => const AiChatScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}

import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // Base URL - Standardized with trailing slash
  static const String baseUrl = 'https://wartil.com/api/';
  static String groqApiKey = dotenv.get('GROQ_API_KEY', fallback: '');

  // Auth Endpoints - Standardized without leading slash
  static const String teacherLogin = 'teacher/login';
  static const String teacherLogout = 'teacher/logout';

  // Profile Endpoints
  static const String teacherProfile = 'teacher/profile';

  // Ads Endpoints
  static const String teacherAds = 'teacher/ads';

  // Schedule Endpoints
  static const String teacherSlots = 'teacher/slots';
  static const String teacherMySlots = 'teacher/my-slots';
  static const String teacherSlotsByDay = 'teacher/slots-by-day';

  // Sessions (Maqraa) Endpoints
  static const String teacherMySessions = 'teacher/sessions/my-sessions';
  static String teacherStartSession(int sessionId) =>
      'teacher/sessions/$sessionId/start';
  static String teacherEndSession(int sessionId) =>
      'teacher/sessions/$sessionId/end';
  static String teacherSessionAttendance(int sessionId) =>
      'teacher/sessions/$sessionId/attendance';
  static const String teacherToggleOnline = 'teacher/toggle-online';

  // Call Endpoints
  static const String teacherCalls = 'teacher/calls';
  static String teacherCallDetail(int callId) => 'teacher/calls/$callId';
  static String teacherJoinCall(int callId) => 'teacher/call/$callId/join';
  static String teacherEndCall(int callId) => 'teacher/call/$callId/end';

  // Agora
  static String agoraAppId = dotenv.get('AGORA_APP_ID', fallback: '');

  // Wallet Endpoints
  static const String teacherWallet = 'teacher/wallet';
  static const String teacherWalletWithdraw = 'teacher/wallet/withdraw';
  static const String teacherWalletRequests = 'teacher/wallet/requests';
  static String teacherCancelWalletRequest(int requestId) =>
      'teacher/wallet/requests/$requestId/cancel';

  // Bookings Endpoints
  static const String teacherBookings = 'teacher/bookings';
  static const String teacherBookingsStart = 'teacher/bookings/start';
  static const String teacherSlotsCancel = 'teacher/slots/cancel';
  static const String teacherSoon = 'teacher/soon';
  static const String teacherRatings = 'teacher/ratings';
  static const String teacherContactSettings = 'teacher/contact-settings';

  // Notifications Endpoints
  static const String notifications = 'notifications';
  static const String notificationsMarkAsRead = 'notifications/mark-as-read';
}

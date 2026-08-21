import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:waratel_app/core/cache/shared_preferences.dart';
import 'package:waratel_app/core/di/dependency_injection.dart';
import 'package:waratel_app/core/routing/routers.dart';
import 'package:waratel_app/core/call/call_api_service.dart';
import 'package:waratel_app/features/notifications/logic/cubit/notifications_cubit.dart';
import 'package:waratel_app/core/notifications/local_notification_service.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';

// ────────────────────────────────────────────────────────────
//  navigatorKey — يُستخدم للتنقل بين الشاشات من خارج الـ context
// ────────────────────────────────────────────────────────────
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// خدمة Pusher + CallKit للمعلم
/// - تستمع لقناة teacher.{teacherId} وتُظهر شاشة رنين مكالمة
/// - عند القبول: تستدعي /join → تنتقل لـ CallScreen بـ Agora
/// - عند الرفض/انتهاء الوقت: تستدعي /end لإلغاء المكالمة
class CallService {
  PusherChannelsFlutter? _pusherInstance;

  // Lazy getter for Pusher instance
  Future<PusherChannelsFlutter> get _pusher async {
    if (_pusherInstance == null) {
      debugPrint('🔌 [PUSHER] Getting PusherChannelsFlutter instance...');
      _pusherInstance = PusherChannelsFlutter.getInstance();
    }
    return _pusherInstance!;
  }

  // ✅ حارس التهيئة — يمنع استدعاء init() مرتين
  bool _isInitialized = false;
  int? _currentTeacherId;

  // ───────────────── 1. تهيئة Pusher ─────────────────────
  /// يُستدعى بعد نجاح تسجيل الدخول أو عند إعادة فتح التطبيق
  Future<void> initPusher(int teacherId) async {
    try {
      debugPrint('🔌 [PUSHER] Starting initPusher for teacher: $teacherId');

      // Skip if already initialized for the same teacher
      if (_isInitialized && _currentTeacherId == teacherId) {
        debugPrint('✅ [PUSHER] Already initialized for teacher: $teacherId');
        return;
      }

      // 1. Disconnect previous connection if any with timeout
      if (_isInitialized) {
        debugPrint(' [PUSHER] Disconnecting existing connection...');
        try {
          final pusher = await _pusher;
          await pusher.disconnect().timeout(
                const Duration(seconds: 3),
                onTimeout: () => debugPrint(
                    '⚠️ [PUSHER] Disconnect timed out, proceeding...'),
              );
        } catch (e) {
          debugPrint('⚠️ [PUSHER] Disconnect error: $e');
        }
      }

      // 2. Initialize
      debugPrint('🔌 [PUSHER] Initializing Pusher...');
      final pusher = await _pusher;
      await pusher
          .init(
            apiKey: '59ebef9ba8db4e38530b',
            cluster: 'eu',
            useTLS: true,
            activityTimeout: 60000,
            pongTimeout: 30000,
            maxReconnectionAttempts: 10,
            maxReconnectGapInSeconds: 30,
            onAuthorizer: _onAuthorizer,
            onError: (message, code, error) => debugPrint(
                '❌ [PUSHER ERROR] message: $message, code: $code, error: $error'),
            onSubscriptionSucceeded: (channelName, data) =>
                debugPrint('✅ [PUSHER] Subscribed: $channelName'),
            onEvent: _onPusherEvent,
            onConnectionStateChange: (currentState, previousState) {
              debugPrint('🔌 [PUSHER] State: $previousState → $currentState');
            },
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('Pusher init timed out'),
          );

      // 3. Subscribe
      final channelName = 'private-teacher.$teacherId';
      debugPrint('🔌 [PUSHER] Subscribing to $channelName');
      await pusher.subscribe(channelName: channelName).timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw Exception('Pusher subscribe timed out'),
          );

      final groupChannelName = 'private-group.teachers';
      debugPrint('🔌 [PUSHER] Subscribing to $groupChannelName');
      await pusher.subscribe(channelName: groupChannelName).timeout(
            const Duration(seconds: 5),
            onTimeout: () =>
                throw Exception('Pusher group subscribe timed out'),
          );

      // 4. Connect
      debugPrint('🔌 [PUSHER] Connecting...');
      await pusher.connect().timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('Pusher connect timed out'),
          );

      _isInitialized = true;
      _currentTeacherId = teacherId;
      debugPrint('✅ [PUSHER] Pusher setup completed successfully');
    } catch (e) {
      _isInitialized = false;
      debugPrint('❌ [PUSHER SETUP FAILED] $e');
    }
  }

  // Authorizer extracted for clarity
  Future<dynamic> _onAuthorizer(
      String channelName, String socketId, dynamic options) async {
    final token = SharedPreferencesService.getToken();
    debugPrint('🔐 [PUSHER AUTH] Requesting auth for channel: $channelName');
    try {
      final response = await getIt<Dio>().post(
        'https://wartil.com/api/broadcasting/auth',
        data: {
          'socket_id': socketId,
          'channel_name': channelName,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      debugPrint('✅ [PUSHER AUTH] Auth successful for channel: $channelName');
      return response.data;
    } catch (e) {
      debugPrint(
          '❌ [PUSHER AUTH ERROR] Auth failed for channel $channelName: $e');
      return {"error": "Auth failed"};
    }
  }

  // ───────────────── 2. استقبال الحدث ────────────────────
  void _onPusherEvent(PusherEvent event) async {
    final name = event.eventName;
    final dynamic rawData = event.data;
    final String dataString = rawData.toString();

    debugPrint('🔔 [PUSHER EVENT] ============================');
    debugPrint('🔔 [PUSHER EVENT] القناة : "${event.channelName}"');
    debugPrint('🔔 [PUSHER EVENT] الحدث  : "$name"');
    debugPrint('🔔 [PUSHER EVENT] البيانات: $dataString');
    debugPrint('🔔 [PUSHER EVENT] ============================');

    // تجاهل أحداث Pusher الداخلية
    if (name.startsWith('pusher:') || name.startsWith('pusher_internal:')) {
      return;
    }

    // تمييز حدث المكالمة بشكل مرن — يقبل أي اسم يحتوي على 'call' أو 'incoming'
    final nameLower = name.toLowerCase();
    final bool isIncomingCall =
        nameLower.contains('call') || nameLower.contains('incoming');

    if (isIncomingCall) {
      debugPrint('🚀 [PUSHER] ✅ تم التعرف على مكالمة واردة! (حدث: "$name")');
      try {
        final Map<String, dynamic> data = (rawData is String)
            ? jsonDecode(rawData) as Map<String, dynamic>
            : rawData as Map<String, dynamic>;

        debugPrint('🔔 [PUSHER] بيانات المكالمة المفككة: $data');

        final String callId = (data['call_id'] ?? data['id'] ?? '').toString();
        final String studentName =
            (data['student_name'] ?? data['caller_name'] ?? 'طالب').toString();
        final String channelName = (data['channel_name'] ?? '').toString();

        if (callId.isEmpty) {
          debugPrint(
              '⚠️ [PUSHER] لم نجد call_id في البيانات — مفاتيح البيانات: ${data.keys.toList()}');
          return;
        }

        debugPrint(
            '📞 [PUSHER] جاري إظهار شاشة الرنين: callId=$callId, student=$studentName, channel=$channelName');

        await _showIncomingCall(
          callId: callId,
          studentName: studentName,
          channelName: channelName,
        );
      } catch (e) {
        debugPrint('❌ [PUSHER] فشل فك تشفير بيانات الحدث: $e');
        debugPrint('❌ [PUSHER] البيانات الخام: $rawData');
      }
    } else if (name.contains('AdminBroadcast')) {
      debugPrint(
          '🚀 [PUSHER] ✅ تم التعرف على إشعار من الإدارة! (حدث: "$name")');
      try {
        final Map<String, dynamic> data = (rawData is String)
            ? jsonDecode(rawData) as Map<String, dynamic>
            : rawData as Map<String, dynamic>;

        debugPrint(
            '🔔 [PUSHER] الإشعار: ${data['title']} - ${data['message']}');

        getIt<NotificationsCubit>().addRealTimeNotification(data);

        // عرض الإشعار في نظام الموبايل
        LocalNotificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: data['title']?.toString() ?? 'إشعار جديد',
          body: data['message']?.toString() ?? '',
          payload: jsonEncode(data),
        );
      } catch (e) {
        debugPrint('❌ [PUSHER] فشل فك إشعار الإدارة: $e');
      }
    } else {
      debugPrint('ℹ️ [PUSHER] حدث غير معروف تم تجاهله: "$name"');
    }
  }

  // ───────────────── 3. إظهار شاشة الرنين ────────────────
  Future<void> _showIncomingCall({
    required String callId,
    required String studentName,
    required String channelName,
  }) async {
    final params = CallKitParams(
      id: callId,
      nameCaller: studentName,
      appName: 'ورتّل',
      avatar:
          'https://ui-avatars.com/api/?name=$studentName&background=0d9488&color=fff',
      handle: 'مكالمة واردة',
      type: 0, // 0 = صوت فقط (زر القبول يظهر أيقونة هاتف)
      duration: 30000, // 30 ثانية ثم يُلغى تلقائياً
      missedCallNotification: const NotificationParams(
        showNotification: true,
        isShowCallback: false,
        subtitle: 'مكالمة فائتة من طالب',
        callbackText: 'رد',
      ),
      extra: <String, dynamic>{
        'channel_name': channelName,
        'call_id': callId,
      },
      android: const AndroidParams(
        isCustomNotification: false,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0d9488',
        backgroundUrl: '',
        actionColor: '#4CAF50',
        textColor: '#ffffff',
        incomingCallNotificationChannelName: "Incoming Call",
        missedCallNotificationChannelName: "Missed Call",
        textAccept: 'قبول',
        textDecline: 'رفض',
      ),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(params);
    debugPrint('✅ [CALLKIT] تم إظهار شاشة رنّ المكالمة بنجاح');
  }

  // ───────────────── 4. الاستماع لقرار المعلم ────────────
  /// يُستدعى مرة واحدة فقط في main.dart قبل runApp
  static void listenToCallEvents(CallApiService api) {
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
      if (event == null) return;

      switch (event) {
        // ✅ المعلم ضغط "قبول"
        case CallEventActionCallAccept(:final callKitParams):
          final String callId = callKitParams.id;
          final String studentName = callKitParams.nameCaller ?? '';
          final String channelName = (callKitParams.extra?['channel_name'] ?? '').toString();

          debugPrint(
              '✅ [CALLKIT] قبول المكالمة: $callId | الطالب: $studentName | قناة: $channelName');
          await _handleAccept(
            callId: callId,
            channelName: channelName,
            studentName: studentName,
            api: api,
          );
          break;

        // ❌ المعلم ضغط "رفض" أو انتهى وقت الرنين
        case CallEventActionCallDecline(:final callKitParams):
          final String callId = callKitParams.id;
          debugPrint('❌ [CALLKIT] رفض المكالمة: $callId');
          if (callId.isNotEmpty) {
            await api.endCall(int.tryParse(callId) ?? 0);
          }
          break;

        case CallEventActionCallTimeout(:final id):
          debugPrint('❌ [CALLKIT] انتهاء وقت المكالمة: $id');
          if (id.isNotEmpty) {
            await api.endCall(int.tryParse(id) ?? 0);
          }
          break;

        default:
          debugPrint('ℹ️ [CALLKIT] حدث غير معالج: ${event.eventName}');
          break;
      }
    });
  }

  // ───────────────── 5. معالجة القبول ────────────────────
  static Future<void> _handleAccept({
    required String callId,
    required String channelName,
    required String studentName,
    required CallApiService api,
  }) async {
    final int id = int.tryParse(callId) ?? 0;
    if (id == 0) {
      debugPrint('❌ [CALLKIT] callId غير صالح: "$callId"');
      return;
    }

    // استدعاء /join للحصول على توكن Agora
    debugPrint('🔄 [CALLKIT] جاري استدعاء joinCall($id)...');
    final joinData = await api.joinCall(id);
    if (joinData == null) {
      debugPrint('❌ [CALLKIT] فشل الحصول على بيانات الانضمام');
      return;
    }
    debugPrint('✅ [CALLKIT] تم الحصول على بيانات الانضمام للمكالمة');

    // انتظر حتى يصبح الـ Navigator جاهزاً
    int retryCount = 0;
    while (navigatorKey.currentState == null && retryCount < 20) {
      debugPrint('⏳ [NAV] Navigator غير جاهز، محاولة ${retryCount + 1}/20...');
      await Future.delayed(const Duration(milliseconds: 500));
      retryCount++;
    }

    if (navigatorKey.currentState == null) {
      debugPrint('❌ [NAV] فشل الوصول للـ Navigator حتى بعد الانتظار!');
      return;
    }

    // الانتقال لشاشة المكالمة
    debugPrint('🚀 [NAV] الانتقال لـ CallScreen للطالب "$studentName"...');
    navigatorKey.currentState?.pushNamed(
      Routes.call,
      arguments: {
        'token': joinData.agoraToken,
        'channelName': joinData.channelName,
        'uid': joinData.uid,
        'studentName': studentName,
        'callId': id,
      },
    );
  }

  // ───────────────── 6. قطع الاتصال عند الخروج ────────────
  Future<void> dispose() async {
    try {
      final pusher = await _pusher;
      await pusher.disconnect().timeout(
            const Duration(seconds: 2),
            onTimeout: () =>
                debugPrint('⚠️ [PUSHER] Disconnect timeout in dispose'),
          );
      _isInitialized = false;
      _currentTeacherId = null;
      debugPrint('🔌 [PUSHER] تم قطع الاتصال');
    } catch (e) {
      debugPrint('⚠️ [PUSHER] خطأ عند قطع الاتصال: $e');
    }
  }
}

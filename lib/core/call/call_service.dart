import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:waratel_app/core/cache/shared_preferences.dart';
import 'package:waratel_app/core/di/dependency_injection.dart';
import 'package:waratel_app/core/routing/routers.dart';
import 'package:waratel_app/core/call/call_api_service.dart';
import 'package:waratel_app/core/call/call_keepalive_service.dart';
import 'package:waratel_app/features/notifications/logic/cubit/notifications_cubit.dart';
import 'package:waratel_app/features/bookings/logic/cubit/bookings_cubit.dart';
import 'package:waratel_app/features/home/logic/cubit/home_cubit.dart';
import 'package:waratel_app/core/notifications/local_notification_service.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

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

      // ── بدء Foreground Service لإبقاء الـ WebSocket حياً في الخلفية ──
      await CallKeepaliveService.start();
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

  // Callback when a call-ended/cancelled event is received via Pusher
  static void Function(int callId)? onCallEndedByPeer;

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

    final nameLower = name.toLowerCase();

    // فك تشفير البيانات مسبقاً للتحقق من الحالة
    Map<String, dynamic>? data;
    try {
      if (rawData is String && rawData.trim().startsWith('{')) {
        data = jsonDecode(rawData) as Map<String, dynamic>;
      } else if (rawData is Map<String, dynamic>) {
        data = rawData;
      }
    } catch (e) {
      debugPrint('⚠️ [PUSHER] فشل فك بيانات JSON: $e');
    }

    final statusStr = (data?['status'] ?? data?['call_status'] ?? '')
        .toString()
        .toLowerCase();

    // 1. التحقق أولاً إذا كان الحدث يمثل انتهاء أو إلغاء للمكالمة
    final bool isCallEnd = nameLower.contains('end') ||
        nameLower.contains('cancel') ||
        nameLower.contains('reject') ||
        nameLower.contains('terminate') ||
        nameLower.contains('finish') ||
        statusStr == 'ended' ||
        statusStr == 'cancelled' ||
        statusStr == 'canceled' ||
        statusStr == 'completed';

    if (isCallEnd) {
      debugPrint('🛑 [PUSHER] ✅ تم التعرف على انتهاء/إلغاء المكالمة! (حدث: "$name")');
      final String callIdStr =
          (data?['call_id'] ?? data?['id'] ?? '').toString();
      final int callIdInt = int.tryParse(callIdStr) ?? 0;

      // إغلاق أي شاشة رنين نشطة في CallKit والديالوج داخل التطبيق
      _dismissInAppDialog();
      if (callIdStr.isNotEmpty) {
        await FlutterCallkitIncoming.endCall(callUuid(callIdStr));
      } else {
        await FlutterCallkitIncoming.endAllCalls();
      }

      // إخطار شاشة المكالمة الحالية لإنهائها فوراً
      onCallEndedByPeer?.call(callIdInt);
      return;
    }

    // 2. التحقق من مكالمة واردة
    final bool isIncomingCall =
        nameLower.contains('call') || nameLower.contains('incoming');

    if (isIncomingCall) {
      debugPrint('🚀 [PUSHER] ✅ تم التعرف على مكالمة واردة! (حدث: "$name")');
      try {
        final Map<String, dynamic> callData = data ??
            ((rawData is String)
                ? jsonDecode(rawData) as Map<String, dynamic>
                : rawData as Map<String, dynamic>);

        debugPrint('🔔 [PUSHER] بيانات المكالمة المفككة: $callData');

        final String callId =
            (callData['call_id'] ?? callData['id'] ?? '').toString();
        final String studentName =
            (callData['student_name'] ?? callData['caller_name'] ?? 'طالب')
                .toString();
        final String channelName =
            (callData['channel_name'] ?? '').toString();

        if (callId.isEmpty) {
          debugPrint(
              '⚠️ [PUSHER] لم نجد call_id في البيانات — مفاتيح البيانات: ${callData.keys.toList()}');
          return;
        }

        final String studentIdStr =
            (callData['student_id'] ?? callData['caller_id'] ?? callData['user_id'] ?? '')
                .toString();
        final int? studentId = int.tryParse(studentIdStr);

        debugPrint(
            '📞 [PUSHER] جاري إظهار شاشة الرنين: callId=$callId, student=$studentName, channel=$channelName, studentId=$studentId');

        await _showIncomingCall(
          callId: callId,
          studentName: studentName,
          channelName: channelName,
          studentId: studentId,
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
    } else if (name.contains('StudentJoined') || nameLower.contains('studentjoined')) {
      debugPrint('🎓 [PUSHER] ✅ انضمام طالب للجلسة المجدولة! (حدث: "$name")');
      try {
        final Map<String, dynamic> eventData = data ??
            ((rawData is String)
                ? jsonDecode(rawData) as Map<String, dynamic>
                : rawData as Map<String, dynamic>);

        final callDetails =
            eventData['call_details'] as Map<String, dynamic>?;
        final studentName =
            callDetails?['student_name']?.toString() ?? 'طالب';

        // تحديث الحجوزات والشاشة الرئيسية
        try {
          getIt<BookingsCubit>().loadBookings();
          getIt<HomeCubit>().loadSoon();
        } catch (_) {}

        // إشعار محلي للمعلم
        LocalNotificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: 'انضمام طالب للجلسة المجدولة',
          body: 'الطالب $studentName انضم وبانتظارك لبدء الجلسة',
          payload: jsonEncode(eventData),
        );
      } catch (e) {
        debugPrint('⚠️ [PUSHER] خطأ معالجة حدث StudentJoined: $e');
      }
    } else {
      debugPrint('ℹ️ [PUSHER] حدث غير معروف تم تجاهله: "$name"');
    }
  }

  // ───────────────── 3. إظهار شاشة الرنين ────────────────
  static DateTime? _lastIncomingCallTime;
  static BuildContext? _inAppDialogContext;

  static void _dismissInAppDialog() {
    if (_inAppDialogContext != null && _inAppDialogContext!.mounted) {
      try {
        Navigator.of(_inAppDialogContext!).pop();
      } catch (_) {}
      _inAppDialogContext = null;
    }
  }

  /// إظهار شاشة / نافذة رنين داخل التطبيق في حال كان المعلم فاتح التطبيق
  static void _showInAppCallDialog({
    required String callId,
    required String studentName,
    required String channelName,
    int? studentId,
  }) {
    final context = navigatorKey.currentContext;
    if (context == null || !context.mounted) return;

    _dismissInAppDialog();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        _inAppDialogContext = dialogCtx;
        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                CircleAvatar(
                  radius: 36,
                  backgroundColor: const Color(0xFF0D9488),
                  child: Text(
                    studentName.isNotEmpty ? studentName[0] : 'ط',
                    style: const TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  studentName,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                const Text(
                  'مكالمة واردة...',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // زر الرفض
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      onPressed: () async {
                        _dismissInAppDialog();
                        await FlutterCallkitIncoming.endAllCalls();
                        if (callId.isNotEmpty) {
                          try {
                            final api = getIt<CallApiService>();
                            await api.endCall(int.tryParse(callId) ?? 0);
                          } catch (_) {}
                        }
                      },
                      icon: const Icon(Icons.call_end, size: 20),
                      label: const Text('رفض'),
                    ),
                    // زر القبول
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      onPressed: () async {
                        _dismissInAppDialog();
                        await FlutterCallkitIncoming.endAllCalls();
                        try {
                          final api = getIt<CallApiService>();
                          await _handleAccept(
                            callId: callId,
                            channelName: channelName,
                            studentName: studentName,
                            studentId: studentId,
                            api: api,
                          );
                        } catch (_) {}
                      },
                      icon: const Icon(Icons.call, size: 20),
                      label: const Text('قبول'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// UUID ثابت وموثوق مشتق من callId باستخدام RFC 4122 v5
  static String callUuid(String callId) {
    if (callId.isEmpty) return '00000000-0000-4000-8000-000000000000';
    return _uuid.v5('6ba7b811-9dad-11d1-80b4-00c04fd430c8', 'wartil-call-$callId');
  }

  Future<void> _showIncomingCall({
    required String callId,
    required String studentName,
    required String channelName,
    int? studentId,
  }) async {
    _lastIncomingCallTime = DateTime.now();

    // 1. إظهار نافذة الرنين داخل التطبيق للمعلم إذا كان التطبيق مفتوحاً
    _showInAppCallDialog(
      callId: callId,
      studentName: studentName,
      channelName: channelName,
      studentId: studentId,
    );

    // 2. إظهار شاشة رنين CallKit للنظام
    final String uuid = callUuid(callId);
    final params = CallKitParams(
      id: uuid,
      nameCaller: studentName,
      appName: 'Wartil',
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
        if (studentId != null && studentId > 0) 'student_id': studentId,
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
      ios: const IOSParams(
        handleType: 'generic',
        supportsVideo: false,
        maximumCallGroups: 1,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'videoChat',
        audioSessionActive: false, // لا تفعل جلسة الصوت أثناء الرنين لتفادي رفض CoreAudio في المحاكي
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: false,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(params);
    
    // التحقق من أن المكالمة تم تسجيلها بالفعل في CallKit
    try {
      final activeCalls = await FlutterCallkitIncoming.activeCalls();
      if (activeCalls.isNotEmpty) {
        debugPrint('✅ [CALLKIT] تم إظهار شاشة رنّ المكالمة بنجاح (UUID: $uuid) | النشطة: ${activeCalls.length}');
      } else {
        debugPrint('⚠️ [CALLKIT] showCallkitIncoming تم استدعاؤه ولكن لا توجد مكالمة نشطة (طبيعي على أجهزة Simulator)');
      }
    } catch (_) {}
  }

  // ───────────────── 4. الاستماع لقرار المعلم ────────────
  static StreamSubscription<CallEvent?>? _callKitSub;
  static String? _lastAcceptedCallId;
  static DateTime? _lastAcceptTime;

  /// يُستدعى في HomeLayout (وآمن ضد التكرار)
  static void listenToCallEvents(CallApiService api) {
    _callKitSub?.cancel();
    _callKitSub = FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
      if (event == null) return;

      debugPrint('🔔 [CALLKIT EVENT] class: ${event.runtimeType} | name: ${event.eventName} | details: $event');

      switch (event) {
        // ✅ المعلم ضغط "قبول"
        case CallEventActionCallAccept(:final callKitParams):
          final String callId =
              (callKitParams.extra?['call_id'] ?? callKitParams.id).toString();
          final String studentName = callKitParams.nameCaller ?? '';
          final String channelName =
              (callKitParams.extra?['channel_name'] ?? '').toString();
          final int studentId = int.tryParse(
                  (callKitParams.extra?['student_id'] ?? '').toString()) ??
              0;

          debugPrint(
              '✅ [CALLKIT] قبول المكالمة: $callId | الطالب: $studentName | قناة: $channelName | studentId: $studentId');
          _dismissInAppDialog();
          await _handleAccept(
            callId: callId,
            channelName: channelName,
            studentName: studentName,
            studentId: studentId,
            api: api,
          );
          break;

        // ❌ المعلم ضغط "رفض" أو انتهى وقت الرنين
        case CallEventActionCallDecline(:final callKitParams):
          final String callId =
              (callKitParams.extra?['call_id'] ?? callKitParams.id).toString();

          // إذا تم قبول هذه المكالمة للتو (مثلاً عبر الديالوج داخل التطبيق ثم استُدعي endAllCalls)،
          // فلا نرسل endCall للخادم حتى لا تُرفض المكالمة عند الطالب!
          if (_lastAcceptedCallId == callId &&
              _lastAcceptTime != null &&
              DateTime.now().difference(_lastAcceptTime!).inSeconds < 15) {
            debugPrint(
                '⚠️ [CALLKIT] تم تجاهل حدث الرفض لأن المكالمة $callId قُبلت للتو');
            return;
          }

          // حماية من الإغلاق التلقائي الخاطئ (مثل خطأ عتاد الصوت في Simulator):
          // لو جاء حدث الرفض خلال أقل من 1.5 ثانية من ظهور المكالمة، فهو صادر عن النظام وليس المعلم
          final elapsed = _lastIncomingCallTime != null
              ? DateTime.now().difference(_lastIncomingCallTime!).inMilliseconds
              : 99999;
          if (elapsed < 1500) {
            debugPrint(
                '⚠️ [CALLKIT] تم تجاهل رفض المكالمة التلقائي (خلال $elapsed ms — إغلاق من النظام أو محاكي)');
            return;
          }

          debugPrint('❌ [CALLKIT] المعلم ضغط رفض: $callId');
          _dismissInAppDialog();
          if (callId.isNotEmpty) {
            await api.endCall(int.tryParse(callId) ?? 0);
          }
          break;

        case CallEventActionCallTimeout(:final id):
          if (_lastAcceptedCallId != null &&
              _lastAcceptTime != null &&
              DateTime.now().difference(_lastAcceptTime!).inSeconds < 15 &&
              (id == _lastAcceptedCallId || id == callUuid(_lastAcceptedCallId!))) {
            debugPrint('⚠️ [CALLKIT] تم تجاهل انتهاء الوقت لأن المكالمة قُبلت للتو');
            return;
          }
          debugPrint('❌ [CALLKIT] انتهاء وقت المكالمة: $id');
          _dismissInAppDialog();
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
    int? studentId,
    required CallApiService api,
  }) async {
    final now = DateTime.now();
    if (_lastAcceptedCallId == callId &&
        _lastAcceptTime != null &&
        now.difference(_lastAcceptTime!).inSeconds < 5) {
      debugPrint('⚠️ [CALLKIT] تجاهل قبول مكرر للمكالمة: $callId');
      return;
    }
    _lastAcceptedCallId = callId;
    _lastAcceptTime = now;

    _dismissInAppDialog();
    await FlutterCallkitIncoming.endAllCalls();
    // مهلة قصيرة للسماح لنظام iOS بتحرير AVAudioSession بعد إغلاق CallKit
    await Future.delayed(const Duration(milliseconds: 300));

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
        'studentId': studentId,
        'hasPreloadedToken': true,
        'reportableType': 'call',
      },
    );
  }

  // ───────────────── 6. قطع الاتصال عند الخروج ────────────
  Future<void> dispose() async {
    // ── إيقاف Foreground Service ──
    await CallKeepaliveService.stop();

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

import 'package:flutter/foundation.dart';
import 'package:waratel_app/core/networking/api_constants.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

/// خدمة Agora المشتركة للمكالمات وغرف المقرأة
class AgoraService {
  RtcEngine? _engine;

  RtcEngine get engine {
    assert(_engine != null, 'AgoraService: call initialize() first');
    return _engine!;
  }

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  bool _isInitializing = false;

  // Callbacks
  void Function(int uid)? onUserJoined;
  void Function(int uid)? onUserLeft;
  void Function(String error)? onError;

  /// تهيئة المحرك مرة واحدة فقط بشكل آمن ضد الاستدعاء المتزامن
  Future<void> initialize() async {
    if (_isInitialized && _engine != null) return;
    if (_isInitializing) {
      while (_isInitializing) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      return;
    }
    _isInitializing = true;

    try {
      _engine = createAgoraRtcEngine();

      await _engine!.initialize(RtcEngineContext(
        appId: ApiConstants.agoraAppId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
        audioScenario: AudioScenarioType.audioScenarioDefault,
      ));

      debugPrint('🔵 [AGORA] تم تهيئة المحرك بنجاح');

      // ضبط الدور كمذيع ليتمكن من الإرسال
      await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

      // تفعيل الصوت والفيديو
      await _engine!.enableAudio();
      await _engine!.enableVideo();

      // ضبط إعدادات الفيديو لتحسين الأداء وتقليل التقطيع (Stuttering/Distortion)
      await _engine!.setVideoEncoderConfiguration(
        const VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 320, height: 240),
          frameRate: 15,
          bitrate: 200,
        ),
      );

      // تسجيل الأحداث
      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (connection, elapsed) {
            debugPrint('✅ [AGORA] Joined channel successfully');
          },
          onUserJoined: (connection, uid, elapsed) {
            debugPrint('👥 [AGORA] Remote user joined: $uid');
            onUserJoined?.call(uid);
          },
          onUserOffline: (connection, uid, reason) {
            debugPrint('👥 [AGORA] Remote user left: $uid | Reason: $reason');
            onUserLeft?.call(uid);
          },
          onRemoteVideoStateChanged:
              (connection, remoteUid, state, reason, elapsed) {
            debugPrint(
                '📹 [AGORA] Remote video state changed for $remoteUid: $state');
            if (state == RemoteVideoState.remoteVideoStateStarting ||
                state == RemoteVideoState.remoteVideoStateDecoding) {
              onUserJoined?.call(remoteUid);
            }
          },
          onError: (err, msg) {
            debugPrint('❌ [AGORA ERROR] $err: $msg');
            onError?.call(msg);
          },
        ),
      );

      _isInitialized = true;
    } catch (e) {
      debugPrint('❌ [AGORA] خطأ أثناء تهيئة المحرك: $e');
    } finally {
      _isInitializing = false;
    }
  }

  /// الانضمام لقناة — الكاميرا مُغلقة بالافتراضي ويمكن تفعيلها أثناء المكالمة
  Future<void> joinChannel({
    required String token,
    required String channelName,
    required int uid,
  }) async {
    await initialize();
    if (_engine == null) return;
    await _engine!.joinChannel(
      token: token,
      channelId: channelName,
      uid: uid,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        publishCameraTrack: false, // الكاميرا مغلقة افتراضياً لمنع كراش المحاكي وتوفير البيانات
        publishMicrophoneTrack: true,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
      ),
    );
  }

  /// الانضمام لقناة صوت فقط (للمقرأة الصوتية)
  Future<void> joinAudioChannel({
    required String token,
    required String channelName,
    required int uid,
  }) async {
    await initialize();
    if (_engine == null) return;
    await _engine!.disableVideo();
    await _engine!.joinChannel(
      token: token,
      channelId: channelName,
      uid: uid,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        publishCameraTrack: false,
        publishMicrophoneTrack: true,
        autoSubscribeAudio: true,
        autoSubscribeVideo: false,
      ),
    );
  }

  /// مغادرة القناة
  Future<void> leaveChannel() async {
    if (_isInitialized && _engine != null) {
      try {
        await _engine!.leaveChannel();
      } catch (e) {
        debugPrint('⚠️ [AGORA] leaveChannel error: $e');
      }
    }
  }

  /// كتم/فتح الميكروفون المحلي
  Future<void> muteLocalMic(bool mute) async {
    if (_engine != null) {
      await _engine!.muteLocalAudioStream(mute);
    }
  }

  /// تفعيل/إيقاف الكاميرا المحلية وتحديث مسار الفيديو في القناة ديناميكياً
  Future<void> enableLocalVideo(bool enable) async {
    if (_engine == null) return;
    try {
      if (enable) {
        await _engine!.enableLocalVideo(true);
        await _engine!.updateChannelMediaOptions(
          const ChannelMediaOptions(publishCameraTrack: true),
        );
      } else {
        await _engine!.enableLocalVideo(false);
        await _engine!.updateChannelMediaOptions(
          const ChannelMediaOptions(publishCameraTrack: false),
        );
      }
    } catch (e) {
      debugPrint('⚠️ [AGORA] enableLocalVideo error: $e');
    }
  }

  /// تبديل سماعة الهاتف (Speaker vs Earpiece)
  Future<void> setEnableSpeakerphone(bool enable) async {
    if (!_isInitialized || _engine == null) return;
    try {
      await _engine!.setEnableSpeakerphone(enable);
    } catch (e) {
      // Ignore if engine is not in a state that supports this call
    }
  }

  /// تدمير المحرك بالكامل عند الخروج
  Future<void> dispose() async {
    if (_isInitialized) {
      onUserJoined = null;
      onUserLeft = null;
      onError = null;
      await _engine!.leaveChannel();
      await _engine!.release();
      _isInitialized = false;
      _engine = null;
    }
  }
}

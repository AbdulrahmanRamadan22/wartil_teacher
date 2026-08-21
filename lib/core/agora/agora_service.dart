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

  // Callbacks
  void Function(int uid)? onUserJoined;
  void Function(int uid)? onUserLeft;
  void Function(String error)? onError;

  /// تهيئة المحرك مرة واحدة فقط
  Future<void> initialize() async {
    if (_isInitialized) return;

    _engine = createAgoraRtcEngine();

    await _engine!.initialize(RtcEngineContext(
      appId: ApiConstants.agoraAppId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
      audioScenario: AudioScenarioType.audioScenarioDefault,
    ));

    debugPrint('🔵 [AGORA] تم تهيئة المحرك بنجاح');

    // ضبط الدور كمذيع لليتمكن من الإرسال
    await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

    // تفعيل الفيديو
    await _engine!.enableVideo();
    await _engine!.enableAudio();

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
  }

  /// الانضمام لقناة — الكاميرا مُغلقة بالافتراضي ويمكن تفعيلها أثناء المكالمة
  Future<void> joinChannel({
    required String token,
    required String channelName,
    required int uid,
  }) async {
    await initialize();
    await _engine!.joinChannel(
      token: token,
      channelId: channelName,
      uid: uid,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        publishCameraTrack: true, // ← تم التعديل لضمان عمل الكاميرا عند تفعيلها
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
    if (_isInitialized) {
      await _engine!.leaveChannel();
    }
  }

  /// كتم/فتح الميكروفون المحلي
  Future<void> muteLocalMic(bool mute) async {
    await _engine!.muteLocalAudioStream(mute);
  }

  /// تفعيل/إيقاف الكاميرا المحلية
  Future<void> enableLocalVideo(bool enable) async {
    if (enable) {
      await _engine!.enableLocalVideo(true);
    } else {
      await _engine!.enableLocalVideo(false);
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

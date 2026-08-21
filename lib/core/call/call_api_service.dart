import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:waratel_app/core/networking/api_constants.dart';

/// نموذج بيانات المكالمة المستلمة من الـ API عند الانضمام
class JoinCallData {
  final String channelName;
  final String agoraToken;
  final int uid;

  JoinCallData({
    required this.channelName,
    required this.agoraToken,
    required this.uid,
  });

  factory JoinCallData.fromJson(Map<String, dynamic> json) {
    return JoinCallData(
      channelName: json['channel_name'] as String,
      agoraToken: json['agora_token'] as String,
      uid: json['uid'] as int,
    );
  }
}

/// خدمة API للمكالمات — join و end
class CallApiService {
  final Dio _dio;

  CallApiService(this._dio);

  /// POST /api/teacher/call/{callId}/join
  /// يُعيد توكن Agora + channelName + uid للانضمام لغرفة الصوت/الفيديو
  Future<JoinCallData?> joinCall(int callId) async {
    try {
      final response = await _dio.post(ApiConstants.teacherJoinCall(callId));
      final body = response.data as Map<String, dynamic>;
      if (body['status'] == true) {
        return JoinCallData.fromJson(body['data'] as Map<String, dynamic>);
      }
      debugPrint('❌ joinCall: status=false → ${body['message']}');
      return null;
    } catch (e) {
      debugPrint('❌ joinCall error: $e');
      return null;
    }
  }

  /// POST /api/teacher/call/{callId}/end
  /// ينهي المكالمة ويُعيد مدتها وأرصدة الطالب
  Future<bool> endCall(int callId) async {
    try {
      final response = await _dio.post(ApiConstants.teacherEndCall(callId));
      final body = response.data as Map<String, dynamic>;
      return body['status'] == true;
    } catch (e) {
      debugPrint('❌ endCall error: $e');
      return false;
    }
  }
}

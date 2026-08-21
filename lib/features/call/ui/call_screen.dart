import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waratel_app/core/agora/agora_service.dart';
import 'package:waratel_app/core/di/dependency_injection.dart';
import 'package:waratel_app/features/call/logic/cubit/call_cubit.dart';
import 'package:waratel_app/features/call/logic/cubit/call_state.dart';
import 'package:waratel_app/features/call/ui/widgets/floating_mushaf.dart';
import 'package:waratel_app/features/call/ui/widgets/session_report_dialog.dart';
import 'package:waratel_app/features/localization/data/app_localizations.dart';
import 'package:waratel_app/core/routing/routers.dart';
import 'package:intl/intl.dart';

class CallScreen extends StatefulWidget {
  final String token;
  final String channelName;
  final int uid;
  final String studentName;
  final int? callId;

  const CallScreen({
    super.key,
    required this.token,
    required this.channelName,
    required this.uid,
    this.studentName = '',
    this.callId,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final AgoraService _agoraService = getIt<AgoraService>();
  String? _callStartTime;

  @override
  void initState() {
    super.initState();
    _callStartTime = DateFormat.jm().format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<CallCubit>()..joinAndStartCall(widget.callId ?? 0),
      child: BlocConsumer<CallCubit, CallState>(
        listener: (context, state) {
          if (state is CallError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red),
            );
            Navigator.pop(context);
          } else if (state is CallRemoteUserLeft) {
            // Auto end the call when student leaves
            final cubit = context.read<CallCubit>();
            cubit.endCall();
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) => SessionReportDialog(
                studentName: widget.studentName.isEmpty
                    ? 'student'.tr(context)
                    : widget.studentName,
                trackName: 'memorization_track'.tr(context),
                startTime: _callStartTime,
                duration: cubit.currentDurationString,
                sessionId: widget.callId,
                onSuccess: () {
                  Navigator.pop(dialogContext);
                  Navigator.pop(context);
                },
              ),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<CallCubit>();

          return PopScope(
            // منع الخروج العرضي من المكالمة بزر الرجوع
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop) {
                // إنهاء المكالمة فوراً عند الرغبة في الخروج
                cubit.endCall();
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (dialogContext) => SessionReportDialog(
                    studentName: widget.studentName.isEmpty
                        ? 'student'.tr(context)
                        : widget.studentName,
                    trackName: 'memorization_track'.tr(context),
                    startTime: _callStartTime,
                    duration: cubit.currentDurationString,
                    sessionId: widget.callId,
                    onSuccess: () {
                      Navigator.pop(dialogContext); // Close dialog
                      Navigator.pop(context); // Close CallScreen
                    },
                  ),
                );
              }
            },
            child: Scaffold(
              backgroundColor: const Color(0xFF1E1E1E),
              body: Stack(
                children: [
                  // 1. Remote Video (Full Screen)
                  _buildRemoteVideo(context, cubit),

                  // 2. Local Preview (Small Overlay)
                  _buildLocalPreview(context, cubit),

                  // 3. Top Bar (Student Info & Timer)
                  _buildTopBar(context, cubit),

                  // 4. Bottom Controls
                  _buildBottomControls(context, cubit),

                  // 5. Floating Mushaf Overlay
                  if (cubit.isMushafOpen)
                    FloatingMushaf(onClose: () => cubit.toggleMushaf()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRemoteVideo(BuildContext context, CallCubit cubit) {
    if (!_agoraService.isInitialized || cubit.remoteUid == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50.r,
              backgroundColor: Colors.blue.withValues(alpha: 0.2),
              child: Icon(Icons.person, size: 60.sp, color: Colors.white54),
            ),
            SizedBox(height: 20.h),
            Text(
              !_agoraService.isInitialized
                  ? 'initializing_call'.tr(context)
                  : 'waiting_for_student'.tr(context),
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
            ),
          ],
        ),
      );
    }

    return RepaintBoundary(
      child: AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _agoraService.engine,
          canvas: VideoCanvas(uid: cubit.remoteUid),
          connection: RtcConnection(channelId: widget.channelName),
        ),
      ),
    );
  }

  Widget _buildLocalPreview(BuildContext context, CallCubit cubit) {
    if (!cubit.isCamOn || !_agoraService.isInitialized) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 100.h,
      right: 20.w,
      child: RepaintBoundary(
        child: Container(
          width: 120.w,
          height: 180.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(color: Colors.white, width: 2),
            color: Colors.black,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13.r),
            child: AgoraVideoView(
              controller: VideoViewController(
                rtcEngine: _agoraService.engine,
                canvas: const VideoCanvas(uid: 0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, CallCubit cubit) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding:
            EdgeInsets.only(top: 50.h, bottom: 20.h, left: 20.w, right: 20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.studentName.isEmpty
                      ? 'student'.tr(context)
                      : widget.studentName,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold),
                ),
                BlocBuilder<CallCubit, CallState>(
                  buildWhen: (previous, current) => current is CallTimerUpdated,
                  builder: (context, state) {
                    String time =
                        (state is CallTimerUpdated) ? state.duration : '00:00';
                    return RepaintBoundary(
                      child: Text(
                        time,
                        style:
                            TextStyle(color: Colors.white70, fontSize: 14.sp),
                      ),
                    );
                  },
                ),
              ],
            ),
            // مؤقت المكالمة يُعرض في الـ Timer widget أعلاه
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context, CallCubit cubit) {
    return Positioned(
      bottom: 30.h,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _controlCircle(
            icon: cubit.isMicOn ? Icons.mic : Icons.mic_off,
            onTap: () => cubit.toggleMic(),
            color: cubit.isMicOn ? Colors.white24 : Colors.red,
          ),
          _controlCircle(
            icon: cubit.isCamOn ? Icons.videocam : Icons.videocam_off,
            onTap: () => cubit.toggleCam(),
            color: cubit.isCamOn ? Colors.white24 : Colors.red,
          ),
          _controlCircle(
            icon: cubit.isSpeakerOn ? Icons.volume_up : Icons.volume_off,
            onTap: () => cubit.toggleSpeaker(),
            color: cubit.isSpeakerOn ? Colors.blue : Colors.white24,
          ),
          _controlCircle(
            icon: Icons.menu_book,
            onTap: () => Navigator.pushNamed(context, Routes.quran),
            color: Colors.white24,
          ),
          _controlCircle(
            icon: Icons.call_end,
            onTap: () {
              // إنهاء المكالمة فوراً
              cubit.endCall();
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => SessionReportDialog(
                  studentName: widget.studentName.isEmpty
                      ? 'student'.tr(context)
                      : widget.studentName,
                  trackName: 'memorization_track'.tr(context),
                  startTime: _callStartTime,
                  duration: cubit.currentDurationString,
                  sessionId: widget.callId,
                  onSuccess: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Close CallScreen
                  },
                ),
              );
            },
            color: Colors.red,
            size: 65.r,
          ),
        ],
      ),
    );
  }

  Widget _controlCircle({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    double? size,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size ?? 55.r,
        height: size ?? 55.r,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 28.sp),
      ),
    );
  }
}

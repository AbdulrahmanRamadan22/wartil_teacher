import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waratel_app/core/theming/colors.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:waratel_app/core/agora/agora_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waratel_app/core/di/dependency_injection.dart';
import 'package:waratel_app/features/ratings/logic/cubit/ratings_state.dart';
import 'package:waratel_app/features/ratings/logic/cubit/ratings_cubit.dart';
import 'package:waratel_app/features/ratings/data/models/session_model.dart';
import 'package:waratel_app/features/localization/data/app_localizations.dart';
import 'package:waratel_app/features/ratings/ui/widgets/maqraa_attendance_dialog.dart';
import 'package:waratel_app/core/routing/routers.dart';

class MaqraaRoomScreen extends StatefulWidget {
  final SessionItem session;
  final StartSessionData agoraData;

  const MaqraaRoomScreen(
      {super.key, required this.session, required this.agoraData});

  @override
  State<MaqraaRoomScreen> createState() => _MaqraaRoomScreenState();
}

class _MaqraaRoomScreenState extends State<MaqraaRoomScreen> {
  late Timer _timer;
  Duration _timeLeft = Duration.zero;
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isSpeakerOn = true;

  final List<int> _remoteUsers = [];
  final AgoraService _agoraService = getIt<AgoraService>();

  AttendanceResponse? _attendanceData;

  @override
  void initState() {
    super.initState();
    _calculateTimeLeft();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateTimeLeft();
    });

    // Set initial camera state - simple check for video based on title
    if (!widget.session.title.contains('فيديو')) {
      _isCameraOff = true;
    }

    _setupAgoraHandlers();

    // Initial attendance load
    context.read<RatingsCubit>().loadAttendance(widget.session.id);
  }

  void _setupAgoraHandlers() {
    if (_agoraService.isInitialized) {
      // Already initialized, set speaker immediately
      _setSpeakerSafe(true);
    }
    _agoraService.onUserJoined = (uid) {
      if (!mounted) return;
      setState(() {
        _remoteUsers.add(uid);
      });
      // Reload attendance when someone joins to get their name
      context.read<RatingsCubit>().loadAttendance(widget.session.id);
    };

    _agoraService.onUserLeft = (uid) {
      if (!mounted) return;
      setState(() {
        _remoteUsers.remove(uid);
      });
      // Auto-end session if all students leave
      if (_remoteUsers.isEmpty) {
        _showEndSessionDialog(context);
      }
    };
  }

  void _setSpeakerSafe(bool enable) {
    try {
      _agoraService.setEnableSpeakerphone(enable);
    } catch (e) {
      // ignore if engine not ready
    }
  }

  void _calculateTimeLeft() {
    final now = DateTime.now();
    final difference = widget.session.endTime.difference(now);
    if (difference.isNegative) {
      setState(() {
        _timeLeft = Duration.zero;
      });
    } else {
      setState(() {
        _timeLeft = difference;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _agoraService.onUserJoined = null;
    _agoraService.onUserLeft = null;
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RatingsCubit, RatingsState>(
      listener: (context, state) {
        if (state is RatingsAttendanceLoaded) {
          setState(() {
            _attendanceData = state.attendance;
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1E1E1E),
        endDrawer: _buildAttendanceDrawer(context),
        body: Stack(
          children: [
            // Full-screen attendees grid
            Positioned.fill(
              child: GridView.builder(
                padding: EdgeInsets.only(
                    top: 100.h, left: 10.w, right: 10.w, bottom: 100.h),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 10.h,
                ),
                itemCount: _remoteUsers.length + 1, // +1 for local teacher
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Local Teacher
                    return _buildLocalUserTile(context);
                  }
                  // Remote Students
                  final remoteUid = _remoteUsers[index - 1];
                  return _buildRemoteUserTile(context, remoteUid);
                },
              ),
            ),

            // Top overlay - Session info
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                    top: 40.h, bottom: 16.h, left: 16.w, right: 16.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.black.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context)),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            widget.session.title,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (widget.agoraData.isRecording) ...[
                                Container(
                                  width: 8.w,
                                  height: 8.w,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'REC',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                              ],
                              Text(
                                _formatDuration(_timeLeft),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: _timeLeft.inMinutes < 5
                                      ? Colors.red
                                      : Colors.white70,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.people, color: Colors.white),
                        onPressed: () => Scaffold.of(context).openEndDrawer(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom overlay - Controls
            Positioned(
              bottom: 30.h,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 10.w),
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlBtn(
                      icon: _isMuted ? Icons.mic_off : Icons.mic,
                      color: Colors.white,
                      bgColor: _isMuted
                          ? Colors.red
                          : Colors.white.withValues(alpha: 0.2),
                      onTap: () {
                        setState(() => _isMuted = !_isMuted);
                        context.read<RatingsCubit>().toggleMic(_isMuted);
                      },
                    ),
                    _buildControlBtn(
                      icon: Icons.menu_book,
                      color: Colors.white,
                      bgColor: Colors.white.withValues(alpha: 0.2),
                      onTap: () {
                        Navigator.pushNamed(context, Routes.quran);
                      },
                    ),
                    _buildControlBtn(
                      icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                      color: Colors.white,
                      bgColor: _isSpeakerOn
                          ? Colors.green
                          : Colors.white.withValues(alpha: 0.2),
                      onTap: () {
                        setState(() => _isSpeakerOn = !_isSpeakerOn);
                        _setSpeakerSafe(_isSpeakerOn);
                      },
                    ),
                    _buildControlBtn(
                      icon: Icons.call_end,
                      color: Colors.white,
                      bgColor: Colors.red,
                      size: 28.sp,
                      onTap: () {
                        _showEndSessionDialog(context);
                      },
                    ),
                    _buildControlBtn(
                      icon: Icons.exit_to_app,
                      color: Colors.white,
                      bgColor: Colors.grey.withValues(alpha: 0.5),
                      onTap: () {
                        _showExitConfirmation(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceDrawer(BuildContext context) {
    return Drawer(
      width: 250.w,
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
                top: 50.h, bottom: 20.h, left: 16.w, right: 16.w),
            color: ColorsManager.primaryColor,
            width: double.infinity,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: () => context
                          .read<RatingsCubit>()
                          .loadAttendance(widget.session.id),
                    ),
                    const Icon(Icons.people, color: Colors.white, size: 40),
                    SizedBox(width: 48.w), // Spacer for balance
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  'attendance_list'.tr(context),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          if (_attendanceData == null)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_attendanceData!.data.isEmpty && _remoteUsers.isEmpty)
            Expanded(
                child: Center(
                    child: Text('no_attendance_now'.tr(context),
                        style: TextStyle(color: Colors.grey, fontSize: 14.sp))))
          else
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  ..._attendanceData!.data.map((student) {
                    bool isOnline = _remoteUsers.contains(student.id);
                    String name = student.name ??
                        '${'student_label'.tr(context)} ${student.id}';
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isOnline
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1),
                        child: Text(
                            name.isNotEmpty ? name.characters.first : '؟',
                            style: TextStyle(
                                color: isOnline ? Colors.green : Colors.grey)),
                      ),
                      title: Text(name,
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: isOnline
                                  ? FontWeight.bold
                                  : FontWeight.normal)),
                      trailing: Icon(
                          isOnline
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: isOnline ? Colors.green : Colors.grey,
                          size: 20.sp),
                    );
                  }),
                  // Show Agora users who are not in the registered list
                  ..._remoteUsers
                      .where((uid) =>
                          !_attendanceData!.data.any((s) => s.id == uid))
                      .map((uid) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.withValues(alpha: 0.1),
                        child: const Text('؟',
                            style: TextStyle(color: Colors.green)),
                      ),
                      title: Text(
                          '${'student_label'.tr(context)} $uid (${'unregistered'.tr(context)})',
                          style: TextStyle(
                              fontSize: 14.sp, fontWeight: FontWeight.bold)),
                      trailing: Icon(Icons.check_circle,
                          color: Colors.green, size: 20.sp),
                    );
                  }),
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              '${'total_registered'.tr(context)} ${_attendanceData?.summary.totalStudents ?? 0}',
              style: TextStyle(color: Colors.grey, fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('exit_room'.tr(context)),
        content: Text('exit_room_confirm'.tr(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('cancel'.tr(context)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _agoraService.leaveChannel();
              if (context.mounted) Navigator.pop(context);
            },
            child: Text('exit'.tr(context),
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEndSessionDialog(BuildContext context) {
    // If we have API data, use it.
    // If not, use the current online Agora users to build a list.
    List<AttendanceStudent> studentsToTakeAttendance = [];

    if (_attendanceData != null && _attendanceData!.data.isNotEmpty) {
      studentsToTakeAttendance = _attendanceData!.data;
    } else {
      // Create temporary list from current online users
      studentsToTakeAttendance = _remoteUsers
          .map((uid) => AttendanceStudent(
              id: uid, name: '${'student_label'.tr(context)} $uid'))
          .toList();
    }

    if (studentsToTakeAttendance.isEmpty) {
      _showSimpleEndDialog(context);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => MaqraaAttendanceDialog(
        students: studentsToTakeAttendance,
        sessionTitle: widget.session.title,
        onSave: (attendance, notes) {
          Navigator.pop(dialogContext);
          Navigator.pop(context); // Close screen immediately
          context.read<RatingsCubit>().endMaqraaWithReport(
                attendance: attendance,
                notes: notes,
              );
        },
      ),
    );
  }

  void _showSimpleEndDialog(BuildContext context) {
    final ratingsCubit = context.read<RatingsCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('end_maqraa'.tr(context)),
        content: Text('end_session_only_confirm'.tr(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('cancel'.tr(context)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context); // Close screen immediately
              ratingsCubit.endMaqraa();
            },
            child: Text('end_session'.tr(context),
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(text, style: TextStyle(color: Colors.white, fontSize: 12.sp)),
    );
  }

  Widget _buildLocalUserTile(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: ColorsManager.primaryColor, width: 2),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15.r),
            child: !_isCameraOff
                ? AgoraVideoView(
                    controller: VideoViewController(
                      rtcEngine: _agoraService.engine,
                      canvas: const VideoCanvas(uid: 0),
                    ),
                  )
                : Center(
                    child: CircleAvatar(
                      radius: 30.r,
                      backgroundColor: Colors.blue,
                      child: Text('you'.tr(context),
                          style:
                              TextStyle(color: Colors.white, fontSize: 18.sp)),
                    ),
                  ),
          ),
          Positioned(
            bottom: 10.h,
            left: 10.w,
            child: _badge('you_teacher'.tr(context)),
          ),
          if (_isMuted)
            Positioned(
              top: 10.h,
              right: 10.w,
              child: Icon(Icons.mic_off, color: Colors.red, size: 20.sp),
            ),
        ],
      ),
    );
  }

  Widget _buildRemoteUserTile(BuildContext context, int uid) {
    // Attempt to match the UID with a real name from attendance if possible
    String studentName = '${'student_label'.tr(context)} $uid';
    if (_attendanceData != null) {
      try {
        final student = _attendanceData!.data.firstWhere((s) => s.id == uid);
        studentName = student.name ?? studentName;
      } catch (_) {
        // Fallback to generic name if no match found
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15.r),
            child: AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: _agoraService.engine,
                canvas: VideoCanvas(uid: uid),
                connection:
                    RtcConnection(channelId: widget.agoraData.channelName),
              ),
            ),
          ),
          Positioned(
            bottom: 10.h,
            left: 10.w,
            child: _badge(studentName),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBtn({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
    double? size,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: size ?? 24.sp),
      ),
    );
  }
}

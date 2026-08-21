class BookingStudent {
  final int id;
  final String name;
  final String? photo;

  const BookingStudent({
    required this.id,
    required this.name,
    this.photo,
  });

  factory BookingStudent.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const BookingStudent(id: 0, name: '');
    return BookingStudent(
      id: (json['id'] is int)
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: (json['name'] ?? '').toString(),
      photo: json['photo']?.toString(),
    );
  }
}

class BookingCallDetails {
  final int id;
  final String status;
  final String channelName;
  final bool? canStart; // from bookings list
  final bool? canStartNow; // from soon endpoint
  final int duration;

  const BookingCallDetails({
    required this.id,
    required this.status,
    required this.channelName,
    this.canStart,
    this.canStartNow,
    this.duration = 0,
  });

  factory BookingCallDetails.fromJson(Map<String, dynamic> json) {
    return BookingCallDetails(
      id: (json['id'] is int)
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      status: (json['status'] ?? '').toString(),
      channelName: (json['channel_name'] ?? '').toString(),
      canStart: json['can_start'] == true,
      canStartNow: json['can_start_now'] == true,
      duration: (json['duration'] is int)
          ? json['duration']
          : int.tryParse(json['duration'].toString()) ?? 0,
    );
  }
}

class BookingModel {
  final int? bookingId;
  final int slotId;
  final String date;
  final String startTime;
  final String endTime;
  final String bookingStatus;
  final BookingStudent student;
  final BookingCallDetails? callDetails;
  final dynamic rating;
  final bool isPast;

  const BookingModel({
    this.bookingId,
    required this.slotId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.bookingStatus,
    required this.student,
    this.callDetails,
    this.rating,
    this.isPast = false,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      bookingId: (json['booking_id'] != null)
          ? (json['booking_id'] is int ? json['booking_id'] : int.tryParse(json['booking_id'].toString()))
          : (json['id'] != null ? (json['id'] is int ? json['id'] : int.tryParse(json['id'].toString())) : null),
      slotId: (json['slot_id'] is int)
          ? json['slot_id']
          : int.tryParse(json['slot_id'].toString()) ?? 0,
      date: (json['date'] ?? '').toString(),
      startTime: (json['start_time'] ?? '').toString(),
      endTime: (json['end_time'] ?? '').toString(),
      bookingStatus:
          (json['status'] ?? json['booking_status'] ?? '').toString(),
      isPast: json['is_past'] == true,
      student:
          BookingStudent.fromJson(json['student'] as Map<String, dynamic>?),
      callDetails:
          (json['call_details'] != null || json['call_session'] != null)
              ? BookingCallDetails.fromJson((json['call_details'] ??
                  json['call_session']) as Map<String, dynamic>)
              : null,
      rating: json['rating'],
    );
  }

  bool get canStart =>
      callDetails?.canStart == true ||
      callDetails?.canStartNow == true ||
      isWithinJoinWindow;

  DateTime get startDateTime {
    try {
      return DateTime.parse('$date $startTime');
    } catch (_) {
      return DateTime.now();
    }
  }

  DateTime get endDateTime {
    try {
      return DateTime.parse('$date $endTime');
    } catch (_) {
      return DateTime.now();
    }
  }

  bool get isExpiredMidway {
    if (bookingStatus != 'scheduled') return false;

    final now = DateTime.now();
    final midwayPoint = startDateTime.add(
      Duration(minutes: endDateTime.difference(startDateTime).inMinutes ~/ 2),
    );

    return now.isAfter(midwayPoint);
  }

  bool get isWithinJoinWindow {
    if (bookingStatus == 'ongoing') return true;
    if (bookingStatus != 'scheduled') return false;

    final now = DateTime.now();
    final difference = startDateTime.difference(now).inMinutes;
    return difference <= 10 && !isExpiredMidway;
  }
}

class BookingsPagination {
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;
  final String? nextPageUrl;

  const BookingsPagination({
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
    this.nextPageUrl,
  });

  factory BookingsPagination.fromJson(Map<String, dynamic> json) {
    return BookingsPagination(
      currentPage: int.tryParse(json['current_page'].toString()) ?? 1,
      lastPage:
          int.tryParse(json['total_pages'] ?? json['last_page']?.toString()) ??
              1,
      total: int.tryParse(json['total'].toString()) ?? 0,
      perPage: int.tryParse(json['per_page'].toString()) ?? 15,
      nextPageUrl: json['next_page_url']?.toString(),
    );
  }
}

class BookingsResponse {
  final bool status;
  final String message;
  final List<BookingModel> upcoming;
  final List<BookingModel> history;
  final BookingsPagination? pagination;

  const BookingsResponse({
    required this.status,
    required this.message,
    required this.upcoming,
    required this.history,
    this.pagination,
  });

  factory BookingsResponse.fromJson(Map<String, dynamic> json) {
    final bool status = json['status'] == true;
    final String message = (json['message'] ?? '').toString();

    List<BookingModel> upcoming = [];
    List<BookingModel> history = [];
    BookingsPagination? pagination;

    final data = json['data'];
    if (data is Map<String, dynamic>) {
      if (data['upcoming'] is List) {
        upcoming = (data['upcoming'] as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => BookingModel.fromJson(e))
            .toList();
      }
      if (data['history'] is List) {
        history = (data['history'] as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => BookingModel.fromJson(e))
            .toList();
      }
      if (data['pagination'] != null) {
        pagination = BookingsPagination.fromJson(data['pagination']);
      }

      // Auto-move expired upcoming bookings to history
      final now = DateTime.now();
      final expiredUpcoming =
          upcoming.where((b) => !b.endDateTime.isAfter(now)).toList();
      if (expiredUpcoming.isNotEmpty) {
        upcoming = upcoming.where((b) => b.endDateTime.isAfter(now)).toList();
        history = [...expiredUpcoming, ...history];
      }
    }

    return BookingsResponse(
      status: status,
      message: message,
      upcoming: upcoming,
      history: history,
      pagination: pagination,
    );
  }
}

class SoonResponse {
  final bool status;
  final BookingModel? booking;

  const SoonResponse({required this.status, this.booking});

  factory SoonResponse.fromJson(Map<String, dynamic> json) {
    return SoonResponse(
      status: json['status'] == true,
      booking: json['data'] != null && json['data'] is Map<String, dynamic>
          ? BookingModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class StartCallResponse {
  final bool status;
  final String token;
  final String channel;
  final int uid;
  final bool isRecording;

  const StartCallResponse({
    required this.status,
    required this.token,
    required this.channel,
    required this.uid,
    required this.isRecording,
  });

  factory StartCallResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return StartCallResponse(
      status: json['status'] == true,
      token: (data['token'] ?? '').toString(),
      channel: (data['channel'] ?? '').toString(),
      uid: (data['uid'] is int)
          ? data['uid']
          : int.tryParse(data['uid'].toString()) ?? 0,
      isRecording: data['is_recording'] == true,
    );
  }
}

class CancelSlotResponse {
  final bool status;
  final String message;

  const CancelSlotResponse({required this.status, required this.message});

  factory CancelSlotResponse.fromJson(Map<String, dynamic> json) {
    return CancelSlotResponse(
      status: json['status'] == true,
      message: (json['message'] ?? '').toString(),
    );
  }
}

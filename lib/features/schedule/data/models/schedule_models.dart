class SlotModel {
  final int id;
  final int teacherId;
  final String date;
  final String startTime;
  final String endTime;
  final bool isBooked;
  final String createdAt;
  final String updatedAt;

  const SlotModel({
    required this.id,
    required this.teacherId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isBooked,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      id: (json['id'] is int)
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      teacherId: (json['teacher_id'] is int)
          ? json['teacher_id']
          : int.tryParse(json['teacher_id'].toString()) ?? 0,
      date: (json['date'] ?? '').toString(),
      startTime: (json['start_time'] ?? '').toString(),
      endTime: (json['end_time'] ?? '').toString(),
      isBooked: json['is_booked'] == 1 || json['is_booked'] == true,
      createdAt: (json['created_at'] ?? '').toString(),
      updatedAt: (json['updated_at'] ?? '').toString(),
    );
  }

  bool get isPast {
    try {
      // Ensure time has seconds for consistent DateTime parsing if it only has hour:minute
      final timeParts = endTime.split(':');
      final timeStr = timeParts.length == 2 ? '$endTime:00' : endTime;
      final endDateTime = DateTime.parse('$date $timeStr');
      return DateTime.now().isAfter(endDateTime);
    } catch (e) {
      return false; // fallback
    }
  }
}

class MySlotsResponse {
  final bool status;
  final String message;
  final MySlotsData? data;

  const MySlotsResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory MySlotsResponse.fromJson(Map<String, dynamic> json) {
    return MySlotsResponse(
      status: json['status'] == true,
      message: (json['message'] ?? '').toString(),
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? MySlotsData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class MySlotsData {
  final Map<String, List<SlotModel>> calendar;
  final SlotsPagination? pagination;

  const MySlotsData({
    required this.calendar,
    this.pagination,
  });

  factory MySlotsData.fromJson(Map<String, dynamic> json) {
    final calendar = <String, List<SlotModel>>{};

    final calendarRaw = json['calendar'];
    if (calendarRaw != null && calendarRaw is Map<String, dynamic>) {
      calendarRaw.forEach((date, slots) {
        if (slots is List) {
          calendar[date] = slots
              .whereType<Map<String, dynamic>>()
              .map((s) => SlotModel.fromJson(s))
              .toList();
        }
      });
    }

    SlotsPagination? pagination;
    if (json['pagination'] != null &&
        json['pagination'] is Map<String, dynamic>) {
      pagination =
          SlotsPagination.fromJson(json['pagination'] as Map<String, dynamic>);
    }

    return MySlotsData(
      calendar: calendar,
      pagination: pagination,
    );
  }
}

class SlotsPagination {
  final int total;
  final int count;
  final int perPage;
  final int currentPage;
  final int totalPages;

  const SlotsPagination({
    required this.total,
    required this.count,
    required this.perPage,
    required this.currentPage,
    required this.totalPages,
  });

  factory SlotsPagination.fromJson(Map<String, dynamic> json) {
    return SlotsPagination(
      total: int.tryParse(json['total'].toString()) ?? 0,
      count: int.tryParse(json['count'].toString()) ?? 0,
      perPage: int.tryParse(json['per_page'].toString()) ?? 10,
      currentPage: int.tryParse(json['current_page'].toString()) ?? 1,
      totalPages: int.tryParse(json['total_pages'].toString()) ?? 1,
    );
  }
}

class AddSlotsData {
  final int addedCount;
  final String date;

  const AddSlotsData({required this.addedCount, required this.date});

  factory AddSlotsData.fromJson(Map<String, dynamic> json) {
    return AddSlotsData(
      addedCount: int.tryParse(json['added_count'].toString()) ?? 0,
      date: (json['date'] ?? '').toString(),
    );
  }
}

class AddSlotsResponse {
  final bool status;
  final String message;
  final AddSlotsData? data;

  const AddSlotsResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory AddSlotsResponse.fromJson(Map<String, dynamic> json) {
    return AddSlotsResponse(
      status: json['status'] == true,
      message: (json['message'] ?? '').toString(),
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? AddSlotsData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class DeleteSlotResponse {
  final bool status;
  final String message;

  const DeleteSlotResponse({
    required this.status,
    required this.message,
  });

  factory DeleteSlotResponse.fromJson(Map<String, dynamic> json) {
    return DeleteSlotResponse(
      status: json['status'] == true,
      message: (json['message'] ?? '').toString(),
    );
  }
}

class DeleteSlotsByDayData {
  final int deletedCount;
  final String date;

  const DeleteSlotsByDayData({required this.deletedCount, required this.date});

  factory DeleteSlotsByDayData.fromJson(Map<String, dynamic> json) {
    return DeleteSlotsByDayData(
      deletedCount: int.tryParse(json['deleted_count'].toString()) ?? 0,
      date: (json['date'] ?? '').toString(),
    );
  }
}

class DeleteSlotsByDayResponse {
  final bool status;
  final String message;
  final DeleteSlotsByDayData? data;

  const DeleteSlotsByDayResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory DeleteSlotsByDayResponse.fromJson(Map<String, dynamic> json) {
    return DeleteSlotsByDayResponse(
      status: json['status'] == true,
      message: (json['message'] ?? '').toString(),
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? DeleteSlotsByDayData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

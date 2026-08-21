class RatingResponse {
  final bool status;
  final RatingData data;

  RatingResponse({required this.status, required this.data});

  factory RatingResponse.fromJson(Map<String, dynamic> json) {
    return RatingResponse(
      status: json['status'] == true,
      data: RatingData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class RatingData {
  final RatingSummary summary;
  final String filterApplied;
  final ReviewsData reviews;

  RatingData({
    required this.summary,
    required this.filterApplied,
    required this.reviews,
  });

  RatingData copyWith({
    RatingSummary? summary,
    String? filterApplied,
    ReviewsData? reviews,
  }) {
    return RatingData(
      summary: summary ?? this.summary,
      filterApplied: filterApplied ?? this.filterApplied,
      reviews: reviews ?? this.reviews,
    );
  }

  factory RatingData.fromJson(Map<String, dynamic> json) {
    return RatingData(
      summary: RatingSummary.fromJson(json['summary'] as Map<String, dynamic>),
      filterApplied: (json['filter_applied'] ?? '').toString(),
      reviews: ReviewsData.fromJson(json['reviews'] as Map<String, dynamic>),
    );
  }
}

class RatingSummary {
  final num averageRating;
  final int totalReviews;
  final Map<String, int> breakdown;

  RatingSummary({
    required this.averageRating,
    required this.totalReviews,
    required this.breakdown,
  });

  RatingSummary copyWith({
    num? averageRating,
    int? totalReviews,
    Map<String, int>? breakdown,
  }) {
    return RatingSummary(
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      breakdown: breakdown ?? this.breakdown,
    );
  }

  factory RatingSummary.fromJson(Map<String, dynamic> json) {
    Map<String, int> breakdownMap = {};
    if (json['breakdown'] != null) {
      (json['breakdown'] as Map<String, dynamic>).forEach((key, value) {
        breakdownMap[key] = int.tryParse(value.toString()) ?? 0;
      });
    }
    return RatingSummary(
      averageRating: num.tryParse(json['average_rating'].toString()) ?? 0,
      totalReviews: int.tryParse(json['total_reviews'].toString()) ?? 0,
      breakdown: breakdownMap,
    );
  }
}

class ReviewsData {
  final int currentPage;
  final List<ReviewItem> data;
  final int lastPage;
  final int total;
  final String? nextPageUrl;

  ReviewsData({
    required this.currentPage,
    required this.data,
    required this.lastPage,
    required this.total,
    this.nextPageUrl,
  });

  factory ReviewsData.fromJson(Map<String, dynamic> json) {
    return ReviewsData(
      currentPage: int.tryParse(json['current_page'].toString()) ?? 1,
      data: (json['data'] as List? ?? [])
          .map((e) => ReviewItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastPage: int.tryParse(json['last_page'].toString()) ?? 1,
      total: int.tryParse(json['total'].toString()) ?? 0,
      nextPageUrl: json['next_page_url']?.toString(),
    );
  }
}

class ReviewItem {
  final int id;
  final num rating;
  final String? comment;
  final String studentName;
  final String? studentPhoto;
  final String date;

  ReviewItem({
    required this.id,
    required this.rating,
    this.comment,
    required this.studentName,
    this.studentPhoto,
    required this.date,
  });

  factory ReviewItem.fromJson(Map<String, dynamic> json) {
    // Review structure might vary based on student object nesting
    // Assuming student object for name and photo based on bookings API
    final student = json['student'] as Map<String, dynamic>?;

    return ReviewItem(
      id: int.tryParse(json['id'].toString()) ?? 0,
      rating: num.tryParse(json['rating'].toString()) ?? 0,
      comment: json['comment']?.toString(),
      studentName: student != null
          ? (student['name'] ?? '').toString()
          : (json['student_name'] ?? 'طالب').toString(),
      studentPhoto: student != null
          ? student['photo']?.toString()
          : json['student_photo']?.toString(),
      date: (json['created_at'] ?? json['date'] ?? '').toString(),
    );
  }
}

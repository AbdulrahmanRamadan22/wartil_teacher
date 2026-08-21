class AdsResponse {
  final bool status;
  final String message;
  final AdsData data;

  const AdsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory AdsResponse.fromJson(Map<String, dynamic> json) {
    return AdsResponse(
      status: json['status'] is bool
          ? json['status'] as bool
          : (json['status']?.toString() == 'true'),
      message: json['message']?.toString() ?? '',
      data: json['data'] != null
          ? AdsData.fromJson(json['data'] as Map<String, dynamic>)
          : const AdsData(
              currentPage: 1, data: [], lastPage: 1, perPage: 10, total: 0),
    );
  }
}

class AdsData {
  final int currentPage;
  final List<Advertisement> data;
  final int lastPage;
  final int perPage;
  final int total;

  const AdsData({
    required this.currentPage,
    required this.data,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory AdsData.fromJson(Map<String, dynamic> json) {
    return AdsData(
      currentPage: int.tryParse(json['current_page']?.toString() ?? '') ?? 1,
      data: json['data'] is List
          ? (json['data'] as List<dynamic>)
              .map((e) => Advertisement.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      lastPage: int.tryParse(json['last_page']?.toString() ?? '') ?? 1,
      perPage: int.tryParse(json['per_page']?.toString() ?? '') ?? 10,
      total: int.tryParse(json['total']?.toString() ?? '') ?? 0,
    );
  }
}

class Advertisement {
  final int id;
  final String? imageUrl;
  final String? link;

  const Advertisement({
    required this.id,
    this.imageUrl,
    this.link,
  });

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    return Advertisement(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      imageUrl: json['image_url']?.toString(),
      link: json['link']?.toString(),
    );
  }
}

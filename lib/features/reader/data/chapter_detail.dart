class ChapterDetail {
  List<String> imageUrls;

  ChapterDetail({required this.imageUrls});

  factory ChapterDetail.fromJson(Map<String, dynamic> json) {
    final List<dynamic> images = json['data'] ?? [];
    return ChapterDetail(imageUrls: List<String>.from(images));
  }
}

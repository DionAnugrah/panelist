class Chapter {
  final String id;
  final String comicId;
  final double chapterNumber;
  final String title;
  final List<String> imageUrls; // List URL gambar untuk chapternya

  Chapter({
    required this.id,
    required this.comicId,
    required this.chapterNumber,
    required this.title,
    required this.imageUrls,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'],
      comicId: json['comic_id'],
      chapterNumber: json['chapter_number']?.toDouble() ?? 0.0,
      title: json['title'] ?? '',
      // untuk URL gambar disimpan dalam format array/list di database supabase
      imageUrls: List<String>.from(json['image_urls'] ?? []),
    );
  }
}

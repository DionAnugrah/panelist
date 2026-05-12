import 'package:panelist/data/models/chapter.dart';

class ComicDetail {
  final String title;
  final String thumbnailUrl;
  final List<String> genre;
  final String synopsis;
  final List<Chapter> chapters;

  ComicDetail({
    required this.title,
    required this.thumbnailUrl,
    required this.genre,
    required this.synopsis,
    required this.chapters,
  });

  factory ComicDetail.fromJson(Map<String, dynamic> json) {
    final List<dynamic> chapterList = json['chapters'] ?? [];

    return ComicDetail(
      title: json['title'] ?? '',
      thumbnailUrl: json['thumbnail'] ?? '',
      genre: List<String>.from(json['genre'] ?? []),
      synopsis: json['synopsis'] ?? '',
      chapters: chapterList
          .map((chapterJson) => Chapter.fromJson(chapterJson))
          .toList(),
    );
  }
}

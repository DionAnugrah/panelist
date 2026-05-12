import 'package:panelist/data/models/comic.dart';

class ComicRespone {
  final List<Comic> comics;
  final int? nextPage;
  final int? prevPage;

  ComicRespone({required this.comics, this.nextPage, this.prevPage});

  factory ComicRespone.fromJson(Map<String, dynamic> json) {
    final List<dynamic> data = json['data'];

    return ComicRespone(
      comics: data.map((comicJson) => Comic.fromJson(comicJson)).toList(),

      nextPage: _extractPage(json['next_page']),
      prevPage: _extractPage(json['prev_page']),
    );
  }

  static int? _extractPage(dynamic url) {
    if (url == null) return null;

    final uri = Uri.parse(url.toString());

    final page = uri.queryParameters['page'];

    return int.tryParse(page ?? '');
  }
}

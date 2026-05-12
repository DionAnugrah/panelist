import 'package:panelist/data/models/comic_detail.dart';
import 'package:panelist/data/models/comic_respone.dart';
import 'package:panelist/features/reader/data/chapter_detail.dart';

abstract class ComicRepository {
  Future<ComicRespone> fetchComics({int page = 1});
  Future<ComicDetail> fetchComicDetail(String title);
  Future<ComicRespone> fetchComicsByGenres(String genre, {int page = 1});
  Future<ComicRespone> fetchComicsByStatus(String status, {int page = 1});
  Future<ComicRespone> fetchComicsByType(String type, {int page = 1});
  Future<ComicRespone> searchComics({
    String? query,
    String? genre,
    String? type,
    String? status,
  });
  Future<ChapterDetail> fetchChapterDetail(String chapterParam);
  // Future<Comic> fetchComicDetail(String id);
}

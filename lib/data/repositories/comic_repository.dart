import '../models/comic.dart';

abstract class ComicRepository {
  Future<List<Comic>> fetchComics();
  Future<List<Comic>> fetchComicsByGenres(String genre);
  Future<List<Comic>> fetchComicsByStatus(String status);
  Future<List<Comic>> fetchComicsByType(String type);
  Future<List<Comic>> searchComics({
    String? query,
    String? genre,
    String? type,
    String? status,
  });
  // Future<Comic> fetchComicDetail(String id);
}

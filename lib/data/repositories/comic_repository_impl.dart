import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:panelist/core/network/api_client_config.dart';
import 'package:panelist/data/models/comic_detail.dart';
import 'package:panelist/data/models/comic_respone.dart';
import 'package:panelist/data/repositories/comic_repository.dart';
import 'package:panelist/features/reader/data/chapter_detail.dart';

class ComicRepositoryImpl implements ComicRepository {
  final Dio _dio;

  ComicRepositoryImpl({ApiClient? apiClient})
    : _dio = apiClient?.dio ?? ApiClient().dio;

  @override
  Future<ComicRespone> fetchComics({int page = 1}) async {
    try {
      final response = await _dio.get('/', queryParameters: {'page': page});

      return ComicRespone.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint("Dio Error: ${e.message}");
      rethrow;
    } catch (e) {
      debugPrint("Error Fetching Comics: $e");
      rethrow;
    }
  }

  @override
  Future<ComicRespone> fetchComicsByGenres(String genre, {int page = 1}) async {
    try {
      final response = await _dio.get(
        '/',
        queryParameters: {'genre': genre, 'page': page},
      );

      return ComicRespone.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint("Dio Error: ${e.message}");
      rethrow;
    }
  }

  @override
  Future<ComicRespone> fetchComicsByType(String type, {int page = 1}) async {
    try {
      final response = await _dio.get(
        '/',
        queryParameters: {'tipe': type, 'page': page},
      );

      return ComicRespone.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint("Dio Error: ${e.message}");
      rethrow;
    }
  }

  @override
  Future<ComicRespone> fetchComicsByStatus(
    String status, {
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        '/',
        queryParameters: {'status': status, 'page': page},
      );

      return ComicRespone.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint("Dio Error: ${e.message}");
      rethrow;
    }
  }

  @override
  Future<ComicRespone> searchComics({
    String? query,
    String? genre,
    String? type,
    String? status,
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        '/',
        queryParameters: {
          if (page > 1) 'page': page,
          if (query != null && query.isNotEmpty) 's': query,
          if (genre != null && genre != 'All Genres')
            'genre': genre.toLowerCase(),
          if (type != null && type != 'All Types') 'tipe': type.toLowerCase(),
          if (status != null && status != 'All Status')
            'status': status.toLowerCase(),
        },
      );

      return ComicRespone.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint("Dio Error: ${e.message}");
      rethrow;
    }
  }

  @override
  Future<ComicDetail> fetchComicDetail(String title) async {
    try {
      final response = await _dio.get('/$title');

      return ComicDetail.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint("Dio Error: ${e.message}");
      rethrow;
    } catch (e) {
      debugPrint("Error Fetching Comics: $e");
      rethrow;
    }
  }

  @override
  Future<ChapterDetail> fetchChapterDetail(String chapterParam) async {
    try {
      final response = await _dio.get('/chapter/$chapterParam');

      return ChapterDetail.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint("Dio Error: ${e.message}");
      rethrow;
    } catch (e) {
      debugPrint("Error Fetching Chapter Detail: $e");
      rethrow;
    }
  }
}

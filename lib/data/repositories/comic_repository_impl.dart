import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:panelist/core/network/api_client_config.dart';
import 'package:panelist/data/models/comic.dart';
import 'package:panelist/data/repositories/comic_repository.dart';

class ComicRepositoryImpl implements ComicRepository {
  final Dio _dio;

  ComicRepositoryImpl({ApiClient? apiClient})
    : _dio = apiClient?.dio ?? ApiClient().dio;

  @override
  Future<List<Comic>> fetchComics() async {
    try {
      final response = await _dio.get('/');

      final List<dynamic> data = response.data['data'];

      return data.map((json) => Comic.fromJson(json)).toList();
    } on DioException catch (e) {
      debugPrint("Dio Error: ${e.message}");
      rethrow;
    } catch (e) {
      debugPrint("Error Fetching Comics: $e");
      rethrow;
    }
  }

  @override
  Future<List<Comic>> fetchComicsByGenres(String genre) async {
    try {
      final response = await _dio.get('/', queryParameters: {'genre': genre});

      final List<dynamic> data = response.data['data'];

      return data.map((json) => Comic.fromJson(json)).toList();
    } on DioException catch (e) {
      debugPrint("Dio Error: ${e.message}");
      rethrow;
    }
  }

  @override
  Future<List<Comic>> fetchComicsByType(String type) async {
    try {
      final response = await _dio.get('/', queryParameters: {'tipe': type});

      final List<dynamic> data = response.data['data'];

      return data.map((json) => Comic.fromJson(json)).toList();
    } on DioException catch (e) {
      debugPrint("Dio Error: ${e.message}");
      rethrow;
    }
  }

  @override
  Future<List<Comic>> fetchComicsByStatus(String status) async {
    try {
      final response = await _dio.get('/', queryParameters: {'status': status});

      final List<dynamic> data = response.data['data'];

      return data.map((json) => Comic.fromJson(json)).toList();
    } on DioException catch (e) {
      debugPrint("Dio Error: ${e.message}");
      rethrow;
    }
  }

  @override
  Future<List<Comic>> searchComics({
    String? query,
    String? genre,
    String? type,
    String? status,
  }) async {
    try {
      final response = await _dio.get(
        '/',
        queryParameters: {
          if (query != null && query.isNotEmpty) 'search': query,
          if (genre != null && genre != 'All Genres')
            'genre': genre.toLowerCase(),
          if (type != null && type != 'All Types') 'tipe': type.toLowerCase(),
          if (status != null && status != 'All Status')
            'status': status.toLowerCase(),
        },
      );

      final List<dynamic> data = response.data['data'];
      return data.map((json) => Comic.fromJson(json)).toList();
    } on DioException catch (e) {
      debugPrint("Dio Error: ${e.message}");
      rethrow;
    }
  }
}

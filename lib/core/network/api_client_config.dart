import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://weeb-scraper.onrender.com/api/komiku',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Getter agar dio bisa diakses tapi konfigurasinya tetap aman
  Dio get dio => _dio;

  // Kamu bisa tambah fungsi custom di sini jika perlu
}

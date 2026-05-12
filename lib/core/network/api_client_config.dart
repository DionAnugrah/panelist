import 'package:dio/dio.dart';
import 'package:panelist/core/constants/env.dart';

class ApiClient {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Env.apiUrl,
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

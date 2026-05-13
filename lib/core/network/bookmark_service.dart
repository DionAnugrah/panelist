import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/comic.dart';

class BookmarkService {
  final _supabase = Supabase.instance.client;

  // Fungsi buat ngambil ID user yang lagi login saat ini
  String? get userId => _supabase.auth.currentUser?.id;

  // Tarik data bookmark KHUSUS buat user yang login
  Future<List<Comic>> fetchBookmarks() async {
    if (userId == null) return []; // Kalau belum login, kosongin aja

    try {
      final response = await _supabase
          .from('bookmarks')
          .select()
          .eq(
            'user_id',
            userId!,
          ); // Ini filter biar cuma narik punya user tersebut

      return response.map((data) => Comic.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error ambil data: $e');
      return [];
    }
  }

  // Tambah komik beserta ID user-nya
  Future<void> addBookmark(Comic comic) async {
    if (userId == null) return;

    try {
      // Gabungin data komik dengan ID user yang login
      final dataToSave = comic.toJson();
      dataToSave['user_id'] = userId;

      await _supabase.from('bookmarks').insert(dataToSave);
    } catch (e) {
      debugPrint('Error tambah bookmark: $e');
    }
  }

  // Hapus komik KHUSUS punya user yang login
  Future<void> removeBookmark(String paramUrl) async {
    if (userId == null) return;

    try {
      await _supabase
          .from('bookmarks')
          .delete()
          .eq('param', paramUrl)
          .eq('user_id', userId!); // Pastikan cuma hapus kepunyaan dia
    } catch (e) {
      print('Error hapus bookmark: $e');
    }
  }
}

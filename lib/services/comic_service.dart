import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chapter.dart';

class ComicService {
  final _supabase = Supabase.instance.client;

  // Fungsi untuk mengambil daftar chapter berdasarkan ID komik
  Future<List<Chapter>> getChaptersByComicId(int comicId) async {
    try {
      final response = await _supabase
          .from('chapters') // Sesuaikan dengan nama tabel di Supabase kamu
          .select()
          .eq('comic_id', comicId)
          .order('chapter_number', ascending: true);

      return (response as List).map((data) => Chapter.fromJson(data)).toList();
    } catch (e) {
      print('Error fetching chapters: $e');
      return []; // Return list kosong jika gagal
    }
  }
}

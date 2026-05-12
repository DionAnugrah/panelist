import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chapter.dart';

class ComicService {
  final _supabase = Supabase.instance.client;

  Future<List<Chapter>> getChaptersByComicId(int comicId) async {
    try {
      final response = await _supabase
          .from(
            'chapters',
          ) // harus di ganti dengan nama tabel di database supabase, tempat nyimpan URL atau gambar komiknya
          .select()
          .eq('comic_id', comicId)
          .order('chapter_number', ascending: true);

      return (response as List).map((data) => Chapter.fromJson(data)).toList();
    } catch (e) {
      print('Error fetching chapters: $e');
      return [];
    }
  }
}

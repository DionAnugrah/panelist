import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistoryService {
  final _supabase = Supabase.instance.client;
  String? get userId => _supabase.auth.currentUser?.id;

  Future<int> countHistory() async {
    final res = await _supabase
        .from('history')
        .select('param')
        .eq('user_id', userId!);
    return res.length;
  }

  Future<void> saveHistory({
    required String param,
    required String title,
    required String thumbnail,
    required String lastChapter,
  }) async {
    if (userId == null) return;

    try {
      await _supabase.from('history').upsert({
        'param': param,
        'user_id': userId,
        'title': title,
        'thumbnail': thumbnail,
        'last_chapter': lastChapter,
        'last_read_at': DateTime.now().toIso8601String(),
      });
      debugPrint('Riwayat tersimpan: $lastChapter');
    } catch (e) {
      debugPrint('Error simpan riwayat: $e');
    }
  }

  Future<List<dynamic>> fetchHistory() async {
    if (userId == null) return [];
    final response = await _supabase
        .from('history')
        .select()
        .eq('user_id', userId!)
        .order('last_read_at', ascending: false); // Yang terbaru di atas
    return response;
  }
}
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
      final existingChapters = await fetchHistoryBasedOnParams(param);

      final updatedChapters = Set<String>.from(existingChapters);
      updatedChapters.add(lastChapter);

      await _supabase.from('history').upsert({
        'user_id': userId,
        'param': param,
        'title': title,
        'thumbnail': thumbnail,
        'latest_chapter': lastChapter,
        'already_read': updatedChapters.toList(),
        'last_read_at': DateTime.now().toIso8601String(),
      }, onConflict: 'param');

      debugPrint('Riwayat berhasil di-upsert: $lastChapter');
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
        .order('last_read_at', ascending: false);
    return response;
  }

  Future<List<String>> fetchHistoryBasedOnParams(String params) async {
    if (userId == null) return [];
    final response = await _supabase
        .from('history')
        .select()
        .eq('user_id', userId!)
        .eq('param', params)
        .maybeSingle();
    List<String> readChapters = [];
    if (response != null) {
      readChapters = List<String>.from(response['already_read'] ?? []);
    }
    return readChapters;
  }
}

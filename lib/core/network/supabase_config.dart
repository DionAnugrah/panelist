import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/env.dart';

class SupabaseConfig {
  static const String supabaseUrl = Env.supabaseUrl;

  static const String supabaseAnonKey = Env.supabaseAnonKey;

  static Future<void> init() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }
}

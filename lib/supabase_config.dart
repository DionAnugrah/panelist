import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl =
      'https://wrbshtvkaumgqymhwjxz.supabase.co';

  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndyYnNodHZrYXVtZ3F5bWh3anh6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg1MDQ2MjgsImV4cCI6MjA5NDA4MDYyOH0.QoWPAA3_senY7e77LKpn35VwuXAgSCvNH2eb5wU4Unw';
  
  static SupabaseClient get client =>
    Supabase.instance.client;
  
  static Future<void> init() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}
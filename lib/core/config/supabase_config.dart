import 'package:event_go/core/config/app_env.dart';

class SupabaseConfig {
  static String get url => AppEnv.get('SUPABASE_URL');
  static String get anonKey => AppEnv.get('SUPABASE_ANON_KEY');
}
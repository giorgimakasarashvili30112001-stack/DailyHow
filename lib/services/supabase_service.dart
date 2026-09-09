import 'package:supabase_flutter/supabase_flutter.dart';

/// Fill these in, or better: pass them with --dart-define at build time
/// (see README_BUILD.md) so you don't hardcode secrets into source control.
///
///   flutter build apk \
///     --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///     --dart-define=SUPABASE_ANON_KEY=eyJ...
///
/// The anon key is safe to ship in a client app — it only grants what your
/// Row Level Security policies allow.
class SupabaseConfig {
  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ktnayycclukcwfupsdiz.supabase.co',
  );
  static const anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt0bmF5eWNjbHVrY3dmdXBzZGl6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ0NzQwMzUsImV4cCI6MjEwMDA1MDAzNX0.cPYAA3l9iOa7zU_NUMji9npCeBS1IuIXlXDV-GOeIL0',
  );
}

class SupabaseService {
  static Future<void> init() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => client.auth;
  static User? get currentUser => client.auth.currentUser;
  static bool get isSignedIn => currentUser != null;
}

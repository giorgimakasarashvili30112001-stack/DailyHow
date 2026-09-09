import '../models/fact.dart';
import 'supabase_service.dart';

/// Favorites are safe to read/write directly from the client (no edge
/// function needed) because the `favorites` table's Row Level Security
/// policies already restrict every operation to `auth.uid() = user_id`.
/// This mirrors what the original app did with its per-request,
/// user-scoped Supabase client.
class FavoritesService {
  static final _client = SupabaseService.client;

  static Future<bool> isSaved(String factId) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return false;
    final row = await _client
        .from('favorites')
        .select('fact_id')
        .eq('fact_id', factId)
        .maybeSingle();
    return row != null;
  }

  static Future<bool> toggle(String factId) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) throw Exception('Not signed in');

    final existing = await _client
        .from('favorites')
        .select('fact_id')
        .eq('fact_id', factId)
        .maybeSingle();

    if (existing != null) {
      await _client.from('favorites').delete().eq('fact_id', factId);
      return false;
    } else {
      await _client.from('favorites').insert({'user_id': userId, 'fact_id': factId});
      return true;
    }
  }

  static Future<List<SavedFact>> getSavedFacts() async {
    final rows = await _client
        .from('favorites')
        .select('created_at, facts:fact_id(id, title, slug, category, hook, intro, steps, surprising_detail)')
        .order('created_at', ascending: false);

    return (rows as List<dynamic>)
        .where((r) => r['facts'] != null)
        .map((r) => SavedFact(
              createdAt: r['created_at'] as String,
              fact: Fact.fromJson(r['facts'] as Map<String, dynamic>),
            ))
        .toList();
  }
}

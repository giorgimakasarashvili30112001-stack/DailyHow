import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/fact.dart';
import '../models/profile.dart';
import 'supabase_service.dart';

/// Thin wrapper around the three Supabase Edge Functions that hold the
/// server-only logic (daily fact selection + AI generation, quiz
/// generation/grading, streak & coin settlement). See
/// supabase_functions/ in this project for their source.
///
/// supabase.functions.invoke automatically attaches the signed-in user's
/// JWT when there's an active session, and falls back to the anon key
/// otherwise — mirroring the original app's "logged out users can still
/// preview/grade a quiz, logged in users get it persisted" behavior.
class Api {
  static final _fn = SupabaseService.client.functions;

  static Future<T> _invoke<T>(
    String function, {
    Map<String, dynamic>? body,
    HttpMethod method = HttpMethod.get,
    Map<String, String>? queryParams,
  }) async {
    final res = await _fn.invoke(
      function,
      method: method,
      body: body,
      queryParameters: queryParams,
    );
    if (res.status >= 400) {
      throw ApiException(res.data is Map ? (res.data['error']?.toString() ?? 'Request failed') : 'Request failed');
    }
    return res.data as T;
  }

  // ---- facts ----

  static Future<Fact> getTodayFact() async {
    final data = await _invoke<Map<String, dynamic>>('facts', queryParams: {'action': 'today'});
    return Fact.fromJson(data['fact'] as Map<String, dynamic>);
  }

  static Future<List<ArchiveEntry>> getArchive() async {
    final data = await _invoke<Map<String, dynamic>>('facts', queryParams: {'action': 'archive'});
    return (data['entries'] as List<dynamic>)
        .map((e) => ArchiveEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<Fact?> getFactBySlug(String slug) async {
    final data = await _invoke<Map<String, dynamic>>(
      'facts',
      queryParams: {'action': 'by-slug', 'slug': slug},
    );
    if (data['fact'] == null) return null;
    return Fact.fromJson(data['fact'] as Map<String, dynamic>);
  }

  // ---- quiz ----

  static Future<DailyQuiz?> getDailyQuiz() async {
    final data = await _invoke<Map<String, dynamic>>('quiz', queryParams: {'action': 'daily'});
    if (data['quiz'] == null) return null;
    return DailyQuiz.fromJson(data['quiz'] as Map<String, dynamic>);
  }

  static Future<QuizQuestion?> getQuizQuestion(String factId, int questionIndex) async {
    final data = await _invoke<Map<String, dynamic>>('quiz', queryParams: {
      'action': 'question',
      'factId': factId,
      'questionIndex': '$questionIndex',
    });
    if (data['question'] == null) return null;
    return QuizQuestion.fromJson(data['question'] as Map<String, dynamic>);
  }

  static Future<QuizResult> answerQuiz({
    required String factId,
    required int questionIndex,
    required int selectedIndex,
  }) async {
    final data = await _invoke<Map<String, dynamic>>(
      'quiz',
      method: HttpMethod.post,
      body: {
        'action': 'answer',
        'factId': factId,
        'questionIndex': questionIndex,
        'selectedIndex': selectedIndex,
      },
    );
    return QuizResult.fromJson(data);
  }

  static Future<QuizResult?> getTodayAttempt(String factId) async {
    final data = await _invoke<Map<String, dynamic>>('quiz', queryParams: {
      'action': 'attempt',
      'factId': factId,
    });
    if (data['attempt'] == null) return null;
    return QuizResult.fromJson(data['attempt'] as Map<String, dynamic>);
  }

  static Future<Map<String, List<String>>> getStreakCalendar(String month) async {
    final data = await _invoke<Map<String, dynamic>>('quiz', queryParams: {
      'action': 'calendar',
      'month': month,
    });
    return {
      'correct': (data['correct'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      'saved': (data['saved'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
    };
  }

  static Future<Map<String, dynamic>> getQuizStats() async {
    return _invoke<Map<String, dynamic>>('quiz', queryParams: {'action': 'stats'});
  }

  // ---- profile ----

  static Future<ProfileState> getProfile() async {
    final data = await _invoke<Map<String, dynamic>>('profile', method: HttpMethod.get);
    return ProfileState.fromJson(data);
  }

  static Future<void> updateDisplayName(String name) async {
    await _invoke<Map<String, dynamic>>(
      'profile',
      method: HttpMethod.post,
      body: {'displayName': name},
    );
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

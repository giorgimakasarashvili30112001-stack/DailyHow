import 'package:flutter/material.dart';
import '../models/fact.dart';
import '../models/profile.dart';
import '../services/api.dart';
import '../services/favorites_service.dart';
import '../services/supabase_service.dart';
import '../widgets/daily_quiz_card.dart';
import '../widgets/fact_card.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  Fact? _fact;
  bool _factSaved = false;
  DailyQuiz? _quiz;
  QuizResult? _quizResult;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final fact = await Api.getTodayFact();
      bool saved = false;
      if (SupabaseService.isSignedIn) {
        saved = await FavoritesService.isSaved(fact.id);
      }

      DailyQuiz? quiz;
      QuizResult? result;
      try {
        quiz = await Api.getDailyQuiz();
        if (quiz != null && SupabaseService.isSignedIn) {
          result = await Api.getTodayAttempt(quiz.factId);
        }
      } catch (_) {
        // Quiz is optional (no quiz on day 1, or none generated yet).
      }

      if (!mounted) return;
      setState(() {
        _fact = fact;
        _factSaved = saved;
        _quiz = quiz;
        _quizResult = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Today')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(
                    children: [
                      const SizedBox(height: 80),
                      Center(child: Text('Couldn\'t load today\'s fact.\n$_error', textAlign: TextAlign.center)),
                      const SizedBox(height: 16),
                      Center(child: OutlinedButton(onPressed: _load, child: const Text('Retry'))),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (_fact != null) FactCard(fact: _fact!, initiallySaved: _factSaved),
                      if (_quiz != null) ...[
                        const SizedBox(height: 16),
                        DailyQuizCard(
                          quiz: _quiz!,
                          existingResult: _quizResult,
                          onAnswered: () {},
                        ),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
      ),
    );
  }
}

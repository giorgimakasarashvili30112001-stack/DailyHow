class ProfileState {
  final String id;
  final String? displayName;
  final int streakCount;
  final int longestStreak;
  final int coins;
  final String? lastSeenDate;
  final List<String> savedDays;
  final int savedCount;

  ProfileState({
    required this.id,
    required this.displayName,
    required this.streakCount,
    required this.longestStreak,
    required this.coins,
    required this.lastSeenDate,
    required this.savedDays,
    required this.savedCount,
  });

  factory ProfileState.fromJson(Map<String, dynamic> json) {
    return ProfileState(
      id: json['id'] as String,
      displayName: json['display_name'] as String?,
      streakCount: json['streak_count'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      coins: json['coins'] as int? ?? 0,
      lastSeenDate: json['last_seen_date'] as String?,
      savedDays: (json['saved_days'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      savedCount: json['saved_count'] as int? ?? 0,
    );
  }
}

class QuizQuestion {
  final String id;
  final int questionIndex;
  final String prompt;
  final List<String> options;

  QuizQuestion({
    required this.id,
    required this.questionIndex,
    required this.prompt,
    required this.options,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String,
      questionIndex: json['question_index'] as int? ?? 0,
      prompt: json['prompt'] as String,
      options: (json['options'] as List<dynamic>).map((e) => e.toString()).toList(),
    );
  }
}

class DailyQuiz {
  final String factId;
  final String factTitle;
  final QuizQuestion question;

  DailyQuiz({required this.factId, required this.factTitle, required this.question});

  factory DailyQuiz.fromJson(Map<String, dynamic> json) {
    return DailyQuiz(
      factId: json['fact_id'] as String,
      factTitle: json['fact_title'] as String? ?? '',
      question: QuizQuestion.fromJson(json['question'] as Map<String, dynamic>),
    );
  }
}

class QuizResult {
  final bool isCorrect;
  final int correctIndex;
  final String explanation;
  final int? coinsAwarded;
  final int? newStreak;

  QuizResult({
    required this.isCorrect,
    required this.correctIndex,
    required this.explanation,
    this.coinsAwarded,
    this.newStreak,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      isCorrect: json['is_correct'] as bool,
      correctIndex: json['correct_index'] as int,
      explanation: json['explanation'] as String? ?? '',
      coinsAwarded: json['coins_awarded'] as int?,
      newStreak: json['new_streak'] as int?,
    );
  }
}

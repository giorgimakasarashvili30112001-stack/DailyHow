import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../services/api.dart';
import '../services/notification_service.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

class DailyQuizCard extends StatefulWidget {
  final DailyQuiz quiz;
  final QuizResult? existingResult;
  final VoidCallback? onAnswered;

  const DailyQuizCard({super.key, required this.quiz, this.existingResult, this.onAnswered});

  @override
  State<DailyQuizCard> createState() => _DailyQuizCardState();
}

class _DailyQuizCardState extends State<DailyQuizCard> {
  int? _selected;
  QuizResult? _result;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _result = widget.existingResult;
  }

  Future<void> _submit(int index) async {
    if (_result != null || _submitting) return;
    setState(() {
      _selected = index;
      _submitting = true;
    });
    try {
      final result = await Api.answerQuiz(
        factId: widget.quiz.factId,
        questionIndex: widget.quiz.question.questionIndex,
        selectedIndex: index,
      );
      setState(() => _result = result);
      if (SupabaseService.isSignedIn) {
        await NotificationService.cancelTodayReminders();
      }
      widget.onAnswered?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final q = widget.quiz.question;
    final answered = _result != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.quiz_outlined, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text('Yesterday\'s recall', style: textTheme.labelLarge?.copyWith(color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 10),
            Text(q.prompt, style: textTheme.titleMedium),
            const SizedBox(height: 16),
            ...q.options.asMap().entries.map((entry) {
              final i = entry.key;
              final text = entry.value;
              final isSelected = _selected == i;
              final isCorrect = answered && _result!.correctIndex == i;
              final isWrongPick = answered && isSelected && !_result!.isCorrect;

              Color borderColor = AppColors.border;
              Color? bg;
              if (answered) {
                if (isCorrect) {
                  borderColor = AppColors.success;
                  bg = AppColors.success.withValues(alpha: 0.12);
                } else if (isWrongPick) {
                  borderColor = AppColors.destructive;
                  bg = AppColors.destructive.withValues(alpha: 0.12);
                }
              } else if (isSelected) {
                borderColor = AppColors.primary;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: answered || _submitting ? null : () => _submit(i),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: bg ?? AppColors.muted,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(text, style: textTheme.bodyMedium)),
                        if (isCorrect) const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                        if (isWrongPick) const Icon(Icons.cancel, color: AppColors.destructive, size: 18),
                      ],
                    ),
                  ),
                ),
              );
            }),
            if (answered) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.muted,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(_result!.explanation, style: textTheme.bodyMedium),
              ),
              if (_result!.coinsAwarded != null && _result!.coinsAwarded! > 0) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.monetization_on, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text('+${_result!.coinsAwarded} coins', style: textTheme.bodyMedium),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

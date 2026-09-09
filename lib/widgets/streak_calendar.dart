import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api.dart';
import '../theme/app_theme.dart';

class StreakCalendar extends StatefulWidget {
  const StreakCalendar({super.key});

  @override
  State<StreakCalendar> createState() => _StreakCalendarState();
}

class _StreakCalendarState extends State<StreakCalendar> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  Map<String, List<String>>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final monthKey = DateFormat('yyyy-MM').format(_month);
    final data = await Api.getStreakCalendar(monthKey);
    if (mounted) setState(() {
      _data = data;
      _loading = false;
    });
  }

  void _changeMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final firstDay = DateTime(_month.year, _month.month, 1);
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final leadingBlanks = firstDay.weekday % 7; // Sun=0

    final correct = (_data?['correct'] ?? []).toSet();
    final saved = (_data?['saved'] ?? []).toSet();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: () => _changeMonth(-1), icon: const Icon(Icons.chevron_left)),
                Text(DateFormat('MMMM yyyy').format(_month), style: textTheme.titleMedium),
                IconButton(onPressed: () => _changeMonth(1), icon: const Icon(Icons.chevron_right)),
              ],
            ),
            const SizedBox(height: 8),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              )
            else
              GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (int i = 0; i < leadingBlanks; i++) const SizedBox.shrink(),
                  for (int d = 1; d <= daysInMonth; d++)
                    _buildDay(d, correct, saved, textTheme),
                ],
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legend(AppColors.success, 'Answered correctly'),
                const SizedBox(width: 16),
                _legend(AppColors.primary, 'Saved a fact'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDay(int day, Set<String> correct, Set<String> saved, TextTheme textTheme) {
    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime(_month.year, _month.month, day));
    final isCorrect = correct.contains(dateStr);
    final isSaved = saved.contains(dateStr);

    Color bg = Colors.transparent;
    if (isCorrect) bg = AppColors.success.withValues(alpha: 0.25);

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: isSaved ? Border.all(color: AppColors.primary, width: 1.5) : null,
      ),
      alignment: Alignment.center,
      child: Text('$day', style: textTheme.bodySmall),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/fact.dart';
import '../services/favorites_service.dart';
import '../theme/app_theme.dart';

class FactCard extends StatefulWidget {
  final Fact fact;
  final bool initiallySaved;

  const FactCard({super.key, required this.fact, this.initiallySaved = false});

  @override
  State<FactCard> createState() => _FactCardState();
}

class _FactCardState extends State<FactCard> {
  late bool _saved = widget.initiallySaved;
  bool _busy = false;

  Future<void> _toggleSave() async {
    setState(() => _busy = true);
    try {
      final saved = await FavoritesService.toggle(widget.fact.id);
      if (mounted) setState(() => _saved = saved);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in to save facts')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fact = widget.fact;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    fact.category.toUpperCase(),
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.accentForeground,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _busy ? null : _toggleSave,
                  icon: Icon(
                    _saved ? Icons.bookmark : Icons.bookmark_border,
                    color: _saved ? AppColors.primary : AppColors.mutedForeground,
                  ),
                ),
                IconButton(
                  onPressed: () => Share.share('${fact.title}\n\n${fact.hook}'),
                  icon: const Icon(Icons.share_outlined, color: AppColors.mutedForeground),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(fact.title, style: textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(fact.hook, style: textTheme.bodyLarge?.copyWith(color: AppColors.mutedForeground)),
            const SizedBox(height: 16),
            Text(fact.intro, style: textTheme.bodyMedium),
            if (fact.steps.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...fact.steps.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: AppColors.muted,
                              shape: BoxShape.circle,
                            ),
                            child: Text('${e.key + 1}', style: textTheme.bodySmall),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(e.value, style: textTheme.bodyMedium)),
                        ],
                      ),
                    ),
                  ),
            ],
            if (fact.surprisingDetail.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.muted,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.auto_awesome, size: 18, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(fact.surprisingDetail, style: textTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

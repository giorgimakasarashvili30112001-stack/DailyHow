import 'package:flutter/material.dart';
import '../models/fact.dart';
import '../services/favorites_service.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/sign_in_prompt.dart';
import 'fact_detail_screen.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  List<SavedFact> _saved = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!SupabaseService.isSignedIn) {
      setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    final saved = await FavoritesService.getSavedFacts();
    if (!mounted) return;
    setState(() {
      _saved = saved;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved')),
      body: !SupabaseService.isSignedIn
          ? const SignInPrompt(message: 'Sign in to save and revisit facts.')
          : _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _saved.isEmpty
                  ? ListView(children: const [
                      SizedBox(height: 80),
                      Center(child: Text('Nothing saved yet — tap the bookmark on a fact to keep it here.')),
                    ])
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _saved.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final item = _saved[i];
                        return Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            title: Text(item.fact.title),
                            subtitle: Text(
                              item.fact.hook,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppColors.mutedForeground),
                            ),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => FactDetailScreen(slug: item.fact.slug)),
                              );
                              _load();
                            },
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

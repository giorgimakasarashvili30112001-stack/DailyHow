import 'package:flutter/material.dart';
import '../models/fact.dart';
import '../services/api.dart';
import '../services/favorites_service.dart';
import '../services/supabase_service.dart';
import '../widgets/fact_card.dart';

class FactDetailScreen extends StatefulWidget {
  final String slug;
  const FactDetailScreen({super.key, required this.slug});

  @override
  State<FactDetailScreen> createState() => _FactDetailScreenState();
}

class _FactDetailScreenState extends State<FactDetailScreen> {
  Fact? _fact;
  bool _saved = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final fact = await Api.getFactBySlug(widget.slug);
    bool saved = false;
    if (fact != null && SupabaseService.isSignedIn) {
      saved = await FavoritesService.isSaved(fact.id);
    }
    if (!mounted) return;
    setState(() {
      _fact = fact;
      _saved = saved;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_fact?.title ?? 'Fact')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _fact == null
              ? const Center(child: Text('Fact not found.'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [FactCard(fact: _fact!, initiallySaved: _saved)],
                ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/fact.dart';
import '../services/api.dart';
import '../theme/app_theme.dart';
import 'fact_detail_screen.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  List<ArchiveEntry> _entries = [];
  bool _loading = true;
  String? _error;
  String _category = 'All';

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
      final entries = await Api.getArchive();
      if (!mounted) return;
      setState(() {
        _entries = entries;
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
    final categories = ['All', ...{for (final e in _entries) e.fact.category}];
    final filtered = _category == 'All'
        ? _entries
        : _entries.where((e) => e.fact.category == _category).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Archive')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('$_error'))
              : Column(
                  children: [
                    SizedBox(
                      height: 48,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final cat = categories[i];
                          final selected = cat == _category;
                          return ChoiceChip(
                            label: Text(cat),
                            selected: selected,
                            onSelected: (_) => setState(() => _category = cat),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _load,
                        child: filtered.isEmpty
                            ? ListView(children: const [
                                SizedBox(height: 80),
                                Center(child: Text('No facts here yet.')),
                              ])
                            : ListView.separated(
                                padding: const EdgeInsets.all(16),
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 10),
                                itemBuilder: (context, i) {
                                  final entry = filtered[i];
                                  return Card(
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      title: Text(entry.fact.title),
                                      subtitle: Text(
                                        entry.fact.hook,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: AppColors.mutedForeground),
                                      ),
                                      trailing: Text(entry.pickDate, style: const TextStyle(fontSize: 12)),
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => FactDetailScreen(slug: entry.fact.slug)),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

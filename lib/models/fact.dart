/// Some fact rows (especially older ones created by the original app) can
/// store a text field as a structured object instead of a plain string —
/// e.g. `{"body": "..."}` or `{"text": "..."}` — rather than `"..."`.
/// This pulls the readable text out of either shape so the UI never shows
/// a raw Dart/JSON map like "{body: ...}".
String _asText(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  if (value is Map) {
    for (final key in ['body', 'text', 'content', 'value']) {
      final v = value[key];
      if (v is String && v.isNotEmpty) return v;
    }
    // Fall back to joining any string-ish values found in the object.
    final parts = value.values.whereType<String>();
    if (parts.isNotEmpty) return parts.join(' ');
  }
  return value.toString();
}

class Fact {
  final String id;
  final String title;
  final String slug;
  final String category;
  final String hook;
  final String intro;
  final List<String> steps;
  final String surprisingDetail;

  Fact({
    required this.id,
    required this.title,
    required this.slug,
    required this.category,
    required this.hook,
    required this.intro,
    required this.steps,
    required this.surprisingDetail,
  });

  factory Fact.fromJson(Map<String, dynamic> json) {
    return Fact(
      id: json['id'] as String,
      title: _asText(json['title']),
      slug: json['slug'] as String,
      category: _asText(json['category']).isEmpty ? 'General' : _asText(json['category']),
      hook: _asText(json['hook']),
      intro: _asText(json['intro']),
      steps: (json['steps'] as List<dynamic>? ?? []).map(_asText).toList(),
      surprisingDetail: _asText(json['surprising_detail']),
    );
  }
}

class ArchiveEntry {
  final String pickDate; // YYYY-MM-DD
  final Fact fact;

  ArchiveEntry({required this.pickDate, required this.fact});

  factory ArchiveEntry.fromJson(Map<String, dynamic> json) {
    return ArchiveEntry(
      pickDate: json['pick_date'] as String,
      fact: Fact.fromJson(json['fact'] as Map<String, dynamic>? ?? json),
    );
  }
}

class SavedFact {
  final String createdAt;
  final Fact fact;

  SavedFact({required this.createdAt, required this.fact});
}
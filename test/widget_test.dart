import 'package:flutter_test/flutter_test.dart';
import 'package:daily_how/models/fact.dart';

void main() {
  test('parses a fact payload', () {
    final fact = Fact.fromJson({
      'id': 'fact-1',
      'title': 'How rainbows form',
      'slug': 'how-rainbows-form',
      'category': 'Science',
      'hook': 'Light does something beautiful.',
      'intro': 'Sunlight enters a raindrop.',
      'steps': ['Refraction', 'Reflection'],
      'surprising_detail': 'Every rainbow is unique.',
    });

    expect(fact.title, 'How rainbows form');
    expect(fact.steps, ['Refraction', 'Reflection']);
  });
}

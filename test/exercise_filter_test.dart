import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/data/database.dart';
import 'package:gym_tracker/features/exercises/exercise_browser.dart';

CatalogEntry _entry(String name, String equipment, List<String> targets) =>
    CatalogEntry(
      Exercise(
        id: name.hashCode,
        name: name,
        equipment: equipment,
        category: 'strength',
        isCustom: false,
        musclesVerified: true,
      ),
      targets,
    );

void main() {
  final all = [
    _entry('Bench Press', 'barbell', ['chest']),
    _entry('Dumbbell Bench Press', 'dumbbell', ['chest']),
    _entry('Dumbbell Curl', 'dumbbell', ['biceps']),
    // A fine muscle counts as its coarse group.
    _entry('Incline Press', 'dumbbell', [
      'clavicular_head_of_pectoralis_major',
    ]),
  ];
  List<String> names(ExerciseFilter f) => [
    for (final c in all.where(f.matches)) c.exercise.name,
  ];

  test('options OR-ed within a facet, facets AND-ed, words searched', () {
    const none = ExerciseFilter();
    expect(names(none), hasLength(4));
    final chest = none.toggle(Facet.muscle, 'chest');
    expect(names(chest), [
      'Bench Press',
      'Dumbbell Bench Press',
      'Incline Press',
    ]);
    expect(names(chest.toggle(Facet.muscle, 'biceps')), hasLength(4));
    final chestDumbbell = chest.toggle(Facet.equipment, 'dumbbell');
    expect(names(chestDumbbell), ['Dumbbell Bench Press', 'Incline Press']);
    expect(names(chestDumbbell.withQuery('inc')), ['Incline Press']);
    expect(chestDumbbell.count, 2);
    expect(names(chestDumbbell.clear(Facet.equipment)), names(chest));
    expect(chestDumbbell.clear().count, 0);
  });

  test('counts: each option with the other facets applied', () {
    final dumbbell = const ExerciseFilter().toggle(Facet.equipment, 'dumbbell');
    expect(dumbbell.counts(Facet.muscle, all), {'biceps': 1, 'chest': 2});
    // Its own facet is left out, so other equipment still shows a count.
    final chest = const ExerciseFilter().toggle(Facet.muscle, 'chest');
    expect(chest.counts(Facet.equipment, all), {'barbell': 1, 'dumbbell': 2});
    expect(chest.withQuery('curl').counts(Facet.equipment, all), {
      'barbell': 0,
      'dumbbell': 0,
    });
  });
}

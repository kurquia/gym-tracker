// The muscles of the 3D model: their names and the app's coarse muscle group
// of each.

/// Muscles of the 3D body model (the part ids written by
/// tool/build_body_model.py, from Z-Anatomy's names) and the app's coarse
/// muscle group of each one (the free-exercise-db ids in the Muscles table).
/// Muscles not listed here (face, throat, hands, feet, deep spine …) have no
/// exercise data yet and stay neutral grey.
///
/// An exercise's muscles can be coarse groups (free-exercise-db's guess) or
/// these part ids ("fine" muscles, hand-checked: assets/data/curated_muscles.json).
/// This table is the fallback for the exercises that only know coarse groups,
/// and tells which coarse group a fine muscle belongs to.
const muscleGroups = <String, String>{
  // Quadriceps
  'rectus_femoris': 'quadriceps',
  'vastus_lateralis': 'quadriceps',
  'vastus_medialis': 'quadriceps',
  'vastus_intermedius': 'quadriceps',
  // Hamstrings
  'long_head_of_biceps_femoris': 'hamstrings',
  'short_head_of_biceps_femoris': 'hamstrings',
  'semitendinosus': 'hamstrings',
  'semimembranosus': 'hamstrings',
  // Adductors
  'adductor_longus': 'adductors',
  'adductor_brevis': 'adductors',
  'adductor_magnus': 'adductors',
  'adductor_minimus': 'adductors',
  'gracilis': 'adductors',
  'pectineus': 'adductors',
  // Abductors
  'gluteus_medius': 'abductors',
  'gluteus_minimus': 'abductors',
  'tensor_fasciae_latae': 'abductors',
  // Glutes
  'gluteus_maximus': 'glutes',
  // Calves
  'medial_head_of_gastrocnemius': 'calves',
  'lateral_head_of_gastrocnemius': 'calves',
  'soleus': 'calves',
  'plantaris': 'calves',
  // Chest
  'clavicular_head_of_pectoralis_major': 'chest',
  'sternocostal_head_of_pectoralis_major': 'chest',
  'abdominal_part_of_pectoralis_major': 'chest',
  'pectoralis_minor': 'chest',
  // Abdominals
  'rectus_abdominis': 'abdominals',
  'external_abdominal_oblique': 'abdominals',
  'internal_abdominal_oblique': 'abdominals',
  'transversus_abdominis': 'abdominals',
  'pyramidalis': 'abdominals',
  // Lats
  'latissimus_dorsi': 'lats',
  'teres_major': 'lats',
  // Traps
  'trapezius_upper': 'traps',
  // Middle back
  'trapezius_middle': 'middle back',
  'trapezius_lower': 'middle back',
  'rhomboid_major': 'middle back',
  'rhomboid_minor': 'middle back',
  // Lower back
  'iliocostalis_lumborum': 'lower back',
  'iliocostalis_thoracis': 'lower back',
  'longissimus_thoracis': 'lower back',
  'spinalis_thoracis': 'lower back',
  'multifidus_lumborum': 'lower back',
  'multifidus_thoracis': 'lower back',
  'quadratus_lumborum': 'lower back',
  // Shoulders
  'clavicular_part_of_deltoid': 'shoulders',
  'acromial_part_of_deltoid': 'shoulders',
  'scapular_spinal_part_of_deltoid': 'shoulders',
  'supraspinatus': 'shoulders',
  'infraspinatus': 'shoulders',
  'teres_minor': 'shoulders',
  'subscapularis': 'shoulders',
  // Biceps
  'long_head_of_biceps_brachii': 'biceps',
  'short_head_of_biceps_brachii': 'biceps',
  'brachialis': 'biceps',
  // Triceps
  'long_head_of_triceps_brachii': 'triceps',
  'lateral_head_of_triceps_brachii': 'triceps',
  'medial_head_of_triceps_brachii': 'triceps',
  'anconeus': 'triceps',
  // Forearms
  'brachioradialis': 'forearms',
  'flexor_carpi_radialis': 'forearms',
  'humeral_head_of_flexor_carpi_ulnaris': 'forearms',
  'ulnar_head_of_flexor_carpi_ulnaris': 'forearms',
  'palmaris_longus': 'forearms',
  'humero_ulnar_head_of_flexor_digitorum_superficialis': 'forearms',
  'radial_head_of_flexor_digitorum_superficialis': 'forearms',
  'flexor_digitorum_profundus': 'forearms',
  'flexor_pollicis_longus': 'forearms',
  'superficial_head_of_pronator_teres': 'forearms',
  'deep_head_of_pronator_teres': 'forearms',
  'pronator_quadratus': 'forearms',
  'supinator': 'forearms',
  'extensor_carpi_radialis_longus': 'forearms',
  'extensor_carpi_radialis_brevis': 'forearms',
  'humeral_head_of_extensor_carpi_ulnaris': 'forearms',
  'ulnar_head_of_extensor_carpi_ulnaris': 'forearms',
  'extensor_digitorum': 'forearms',
  'extensor_digiti_minimi': 'forearms',
  'extensor_indicis': 'forearms',
  'abductor_pollicis_longus': 'forearms',
  'extensor_pollicis_longus': 'forearms',
  'extensor_pollicis_brevis': 'forearms',
  // Neck
  'sternocleidomastoid': 'neck',
  'splenius_capitis': 'neck',
  'splenius_colli': 'neck',
  'levator_scapulae': 'neck',
  'scalenus_anterior': 'neck',
  'scalenus_medius': 'neck',
  'scalenus_posterior': 'neck',
};

/// Parts of the model that no coarse group covers: an exercise can point at
/// them, but a coarse group never lights them.
const ungroupedParts = {
  'serratus_anterior',
  'coracobrachialis',
  'iliacus',
  'psoas_major',
  'sartorius',
  'piriformis',
};

/// Whether [id] is a muscle part of the model (a fine muscle) and not a coarse
/// group.
bool isFineMuscle(String id) =>
    muscleGroups.containsKey(id) || ungroupedParts.contains(id);

/// The coarse group of a muscle id: itself when it already is one, or null for
/// a fine muscle that no group covers.
String? coarseGroupOf(String id) =>
    muscleGroups[id] ?? (ungroupedParts.contains(id) ? null : id);

/// Text-only groups for fine muscles that no coarse group covers on the model:
/// the coracobrachialis moves the shoulder (flexion, adduction), the iliopsoas
/// and sartorius flex the hip, the piriformis sits under the glutes.
const _textGroups = {
  'coracobrachialis': 'shoulders',
  'iliacus': 'hip flexors',
  'psoas_major': 'hip flexors',
  'sartorius': 'hip flexors',
  'piriformis': 'glutes',
};

/// The distinct group names of [ids] in order, by [names] (muscle id → name),
/// as named in text ("Main: chest"); a muscle without a group keeps its own
/// name.
List<String> groupNames(Iterable<String> ids, Map<String, String> names) => {
  for (final id in ids)
    switch (_textGroups[id] ?? coarseGroupOf(id)) {
      final g? => names[g] ?? muscleName(g),
      null => names[id] ?? muscleName(id),
    },
}.toList();

/// A part id as text: "long_head_of_biceps_brachii" → "Long head of biceps
/// brachii".
String muscleName(String id) {
  final words = id.replaceAll('_', ' ');
  return words[0].toUpperCase() + words.substring(1);
}

/// The coarse groups that have at least one muscle on the model.
final Set<String> modelGroups = muscleGroups.values.toSet();

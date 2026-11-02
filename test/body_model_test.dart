import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/features/exercises/body_model/body_model.dart';
import 'package:gym_tracker/features/exercises/body_model/muscle_map.dart';

void main() {
  final model = BodyModel.parse(
    ByteData.sublistView(File(bodyModelAsset).readAsBytesSync()),
  );

  test('every muscle in the muscle map is on the 3D model', () {
    expect(model.partIds.toSet().containsAll(muscleGroups.keys), isTrue);
    expect(
      model.partIds,
      containsAll(['bone', 'tendon', 'skin', 'latissimus_dorsi']),
    );
  });

  test('the muscle map covers all 17 coarse muscle groups', () {
    final json = jsonDecode(
      File('assets/data/exercises.json').readAsStringSync(),
    );
    final coarse = {
      for (final e in json['exercises'] as List)
        ...[...e['primary'] as List, ...e['secondary'] as List].cast<String>(),
    };
    expect(coarse, hasLength(17));
    expect(modelGroups, coarse);
  });

  test('model geometry is consistent', () {
    expect(model.triangleCount, greaterThan(10000));
    expect(model.indices.every((i) => i < model.vertexCount), isTrue);
    for (var i = 0; i < model.normals.length; i += 3) {
      final n = model.normals;
      final l = math.sqrt(
        n[i] * n[i] + n[i + 1] * n[i + 1] + n[i + 2] * n[i + 2],
      );
      expect(l, closeTo(1, 1e-3));
    }
    expect(model.positions.every((x) => x.abs() <= 1.0001), isTrue);
  });
}

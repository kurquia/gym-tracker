import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/features/routines/routine_drop.dart';

/// Writes a list as letters, supersets in brackets: "A [B C] D".
String _show(List<int> order, List<bool> superset) {
  final out = StringBuffer();
  for (var i = 0; i < order.length; i++) {
    final name = String.fromCharCode(0x41 + order[i]);
    final first = !superset[i];
    final last = i + 1 == order.length || !superset[i + 1];
    if (i > 0) out.write(' ');
    if (first && !last) out.write('[');
    out.write(name);
    if (!first && last) out.write(']');
  }
  return out.toString();
}

/// Parses the same notation into flags (letters must be A, B, C … in order).
List<bool> _flags(String list) {
  final flags = <bool>[];
  var inBlock = false;
  for (final token in list.split(' ')) {
    final opens = token.startsWith('[');
    flags.add(inBlock && !opens);
    if (opens) inBlock = true;
    if (token.endsWith(']')) inBlock = false;
  }
  return flags;
}

String? _drop(String list, DragSource source, DropTarget target) {
  final result = applyDrop(_flags(list), source, target);
  return result == null ? null : _show(result.order, result.superset);
}

void main() {
  group('plain moves between rows', () {
    test('a lone exercise moves down and up', () {
      expect(
        _drop('A B C D', const DragExercise(0), const DropBetween(3)),
        'B C A D',
      );
      expect(
        _drop('A B C D', const DragExercise(3), const DropBetween(0)),
        'D A B C',
      );
      expect(
        _drop('A B C D', const DragExercise(1), const DropBetween(4)),
        'A C D B',
      );
    });

    test('dropping where it already is changes nothing', () {
      expect(_drop('A B C', const DragExercise(1), const DropBetween(1)), null);
      expect(_drop('A B C', const DragExercise(1), const DropBetween(2)), null);
    });

    test('a lone exercise moves past a block, not into it', () {
      expect(
        _drop('A [B C] D', const DragExercise(0), const DropBetween(3)),
        '[B C] A D',
      );
      expect(
        _drop('A [B C] D', const DragExercise(3), const DropBetween(1)),
        'A D [B C]',
      );
    });
  });

  group('dragging a member out leaves the superset', () {
    test('just below its block', () {
      expect(
        _drop('A [B C] D', const DragExercise(2), const DropBetween(3)),
        'A B C D',
      );
      expect(
        _drop('[A B C] D', const DragExercise(2), const DropBetween(3)),
        '[A B] C D',
      );
    });

    test('just above its block', () {
      expect(
        _drop('A [B C] D', const DragExercise(1), const DropBetween(1)),
        'A B C D',
      );
      expect(
        _drop('A [B C D]', const DragExercise(2), const DropBetween(1)),
        'A C [B D]',
      );
    });

    test('far away', () {
      expect(
        _drop('[A B] C D', const DragExercise(0), const DropBetween(4)),
        'B C D A',
      );
    });
  });

  group('dropping onto an exercise makes a superset', () {
    test('with a lone exercise, placed after it', () {
      expect(
        _drop('A B C D', const DragExercise(0), const DropOnto(2)),
        'B [C A] D',
      );
      expect(
        _drop('A B C D', const DragExercise(3), const DropOnto(0)),
        '[A D] B C',
      );
    });

    test('with a member: joins its block after that member', () {
      expect(
        _drop('A [B C] D', const DragExercise(3), const DropOnto(1)),
        'A [B D C]',
      );
      expect(
        _drop('A [B C] D', const DragExercise(0), const DropOnto(2)),
        '[B C A] D',
      );
    });

    test('a member onto an exercise elsewhere moves over', () {
      expect(
        _drop('[A B] C', const DragExercise(0), const DropOnto(2)),
        'B [C A]',
      );
      expect(
        _drop('[A B C] D', const DragExercise(1), const DropOnto(3)),
        '[A C] [D B]',
      );
    });

    test('within its own block it reorders', () {
      expect(
        _drop('[A B C]', const DragExercise(0), const DropOnto(2)),
        '[B C A]',
      );
    });

    test('onto itself changes nothing', () {
      expect(_drop('A B', const DragExercise(1), const DropOnto(1)), null);
    });
  });

  group('dropping onto a block header joins at its end', () {
    test('a lone exercise', () {
      expect(
        _drop('A [B C] D', const DragExercise(0), const DropOntoBlock(1)),
        '[B C A] D',
      );
      expect(
        _drop('A [B C] D', const DragExercise(3), const DropOntoBlock(1)),
        'A [B C D]',
      );
    });
  });

  group('between two members joins the block there', () {
    test('from outside', () {
      expect(
        _drop('A [B C] D', const DragExercise(3), const DropBetween(2)),
        'A [B D C]',
      );
      expect(
        _drop('A [B C] D', const DragExercise(0), const DropBetween(2)),
        '[B A C] D',
      );
    });

    test('within the block it reorders', () {
      expect(
        _drop('[A B C]', const DragExercise(0), const DropBetween(2)),
        '[B A C]',
      );
      expect(
        _drop('[A B C]', const DragExercise(2), const DropBetween(1)),
        '[A C B]',
      );
    });

    test('next to its own place changes nothing', () {
      expect(
        _drop('[A B C]', const DragExercise(1), const DropBetween(1)),
        null,
      );
      expect(
        _drop('[A B C]', const DragExercise(1), const DropBetween(2)),
        null,
      );
    });
  });

  group('a whole block', () {
    test('moves between rows as one', () {
      expect(
        _drop('A [B C] D', const DragBlock(1), const DropBetween(0)),
        '[B C] A D',
      );
      expect(
        _drop('A [B C] D', const DragBlock(1), const DropBetween(4)),
        'A D [B C]',
      );
      expect(
        _drop('A [B C] D', const DragBlock(1), const DropBetween(1)),
        null,
      );
      expect(
        _drop('A [B C] D', const DragBlock(1), const DropBetween(3)),
        null,
      );
    });

    test('dropped onto an exercise merges with it', () {
      expect(
        _drop('A [B C] D', const DragBlock(1), const DropOnto(0)),
        '[A B C] D',
      );
      expect(
        _drop('[A B] C [D E]', const DragBlock(0), const DropOnto(3)),
        'C [D A B E]',
      );
    });

    test('dropped onto another block merges at its end', () {
      expect(
        _drop('[A B] C [D E]', const DragBlock(0), const DropOntoBlock(3)),
        'C [D E A B]',
      );
    });

    test('dropped between members of another block merges there', () {
      expect(
        _drop('[A B] [C D]', const DragBlock(0), const DropBetween(3)),
        '[C A B D]',
      );
    });

    test("can't go onto or into itself", () {
      expect(_drop('[A B C]', const DragBlock(0), const DropOnto(1)), null);
      expect(
        _drop('[A B C]', const DragBlock(0), const DropOntoBlock(0)),
        null,
      );
      expect(_drop('[A B C]', const DragBlock(0), const DropBetween(2)), null);
    });
  });

  test('insideBlock', () {
    final flags = _flags('A [B C] D');
    expect(
      [for (var g = 0; g <= 4; g++) insideBlock(flags, g)],
      [false, false, true, false, false],
    );
  });
}

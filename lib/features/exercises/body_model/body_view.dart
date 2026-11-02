import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/database.dart';
import '../../../shared/theme.dart';
import 'body_model.dart';
import 'muscle_map.dart';

/// Colours of the 3D body. Kept apart from the app's (monochrome) theme.
abstract final class BodyColors {
  // Target red and synergist orange from the first 3D build (Material Red 600,
  // Orange A400); fixator yellow is matplotlib's autumn(0.8), the user's pick
  // (2026-10-23).
  static const target = Color(0xFFE53935);
  static const secondary = Color(0xFFFF9100);
  static const fixator = Color(0xFFFFCC00);
  static const muscle = Color(0xFF5E5E5E);
  static const bone = Color(0xFFB8B4AA);
  static const skin = muscle; // the head: the user's pick (2026-10-21)
}

/// The colours of a highlight, as the legend lists them.
enum BodyKey { target, secondary, fixator }

/// Which muscles (coarse groups or single parts) to colour as targets,
/// secondaries (synergists) and fixators.
class BodyHighlight {
  const BodyHighlight(
    this.targets,
    this.secondaries, [
    this.fixators = const {},
  ]);

  /// Muscle ids by role (one exercise, or a whole workout); the stabilizer
  /// roles are fixators, and a muscle under several roles takes the
  /// strongest. Every body figure is coloured through here.
  factory BodyHighlight.fromRoles(Map<MuscleRole, Iterable<String>> muscles) {
    Set<String> ids(bool Function(MuscleRole) where) => {
      for (final MapEntry(:key, :value) in muscles.entries)
        if (where(key)) ...value,
    };
    final targets = ids((r) => r == MuscleRole.target);
    final synergists = ids((r) => r == MuscleRole.synergist)
        .difference(targets);
    final fixators = ids(
      (r) => r != MuscleRole.target && r != MuscleRole.synergist,
    ).difference(targets).difference(synergists);
    return BodyHighlight(targets, synergists, fixators);
  }

  /// An exercise's muscles by role, as its page lists them.
  factory BodyHighlight.ofExercise(Map<MuscleRole, List<Muscle>> muscles) =>
      BodyHighlight.fromRoles({
        for (final MapEntry(:key, :value) in muscles.entries)
          key: [for (final m in value) m.id],
      });

  final Set<String> targets;
  final Set<String> secondaries;
  final Set<String> fixators;

  /// Only the [shown] colours; the other muscles turn plain grey.
  BodyHighlight showing(Set<BodyKey> shown) => BodyHighlight(
    shown.contains(BodyKey.target) ? targets : const {},
    shown.contains(BodyKey.secondary) ? secondaries : const {},
    shown.contains(BodyKey.fixator) ? fixators : const {},
  );

  /// Whether any highlighted muscle is on the model.
  bool get onModel =>
      targets.any(_onModel) ||
      secondaries.any(_onModel) ||
      fixators.any(_onModel);

  static bool _onModel(String id) =>
      modelGroups.contains(id) || isFineMuscle(id);

  /// Muscles are highlighted as coarse groups or as single parts (fine
  /// muscles); a part counts when it or its group is highlighted.
  Color _colorOf(String id) {
    if (id == 'bone' || id == 'tendon') return BodyColors.bone;
    if (id == 'skin') return BodyColors.skin;
    final group = muscleGroups[id];
    bool hit(Set<String> ids) =>
        ids.contains(id) || (group != null && ids.contains(group));
    if (hit(targets)) return BodyColors.target;
    if (hit(secondaries)) return BodyColors.secondary;
    if (hit(fixators)) return BodyColors.fixator;
    return BodyColors.muscle;
  }

  /// ARGB base colour per part of [model].
  Int32List partColors(BodyModel model) => Int32List.fromList([
    for (final id in model.partIds) _colorOf(id).toARGB32(),
  ]);
}

/// Yaw (radians about the vertical axis) of the two standard views.
const frontYaw = 0.0;
const backYaw = math.pi;
const _defaultPitch = 0.08;

/// Shows [builder]'s widget once the shared model is loaded. While loading
/// it shows nothing (no spinner, so widget tests can settle).
class WithBodyModel extends ConsumerWidget {
  const WithBodyModel(this.builder, {super.key});

  final Widget Function(BodyModel model) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(bodyModelProvider)) {
      AsyncData(:final value) => builder(value),
      AsyncError(:final error) => Center(
        child: Text('Could not load the 3D model.\n$error'),
      ),
      _ => const SizedBox.expand(),
    };
  }
}

/// One renderer per model for all static figures: they paint one at a time
/// and keep nothing from the last paint.
final _sharedRenderers = Expando<BodyRenderer>();

/// Front and back view side by side, drawn once (no animation, no
/// gestures). Tapping one opens [route], the 3D page, on that view.
class BodyFigures extends StatelessWidget {
  const BodyFigures({super.key, required this.highlight, required this.route});

  final BodyHighlight highlight;
  final String route;

  @override
  Widget build(BuildContext context) {
    return WithBodyModel((model) {
      final renderer = _sharedRenderers[model] ??= BodyRenderer(model);
      final colors = highlight.partColors(model);
      Widget figure(double yaw, String label) => Expanded(
        child: Semantics(
          button: true,
          label: '$label view of the muscles, open in 3D',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.push(
              '$route?view=${yaw == backYaw ? 'back' : 'front'}',
            ),
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _BodyPainter(renderer, _Camera(yaw), colors),
                size: Size.infinite,
              ),
            ),
          ),
        ),
      );
      return Row(
        children: [figure(frontYaw, 'Front'), figure(backYaw, 'Back')],
      );
    });
  }
}

class _Camera extends ChangeNotifier {
  _Camera(this.yaw);

  double yaw;
  double pitch = _defaultPitch;
  double zoom = 1;
  Offset pan = Offset.zero;

  void changed() => notifyListeners();
}

/// The interactive 3D body: drag to rotate, pinch or scroll to zoom, two
/// fingers to pan, tap a muscle to see its name. Starts at [initialYaw].
class BodyView extends StatefulWidget {
  const BodyView({
    super.key,
    required this.model,
    required this.highlight,
    required this.initialYaw,
  });

  final BodyModel model;
  final BodyHighlight highlight;
  final double initialYaw;

  @override
  State<BodyView> createState() => _BodyViewState();
}

class _BodyViewState extends State<BodyView>
    with SingleTickerProviderStateMixin {
  late final _camera = _Camera(widget.initialYaw);
  // Its own renderer: picking reads what this view drew last.
  late final _renderer = BodyRenderer(widget.model);
  late final _move = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..addListener(_onMove);
  late ({double yaw, double pitch, double zoom, Offset pan}) _from;
  double _toYaw = 0;
  double _startZoom = 1;
  Offset _downAt = Offset.zero, _lastFocal = Offset.zero;
  bool _moved = false;
  int? _picked;

  @override
  void dispose() {
    _move.dispose();
    _camera.dispose();
    super.dispose();
  }

  void _onMove() {
    final t = Curves.easeInOut.transform(_move.value);
    double mix(double a, double b) => a + (b - a) * t;
    _camera
      ..yaw = mix(_from.yaw, _toYaw)
      ..pitch = mix(_from.pitch, _defaultPitch)
      ..zoom = mix(_from.zoom, 1)
      ..pan = Offset.lerp(_from.pan, Offset.zero, t)!
      ..changed();
  }

  void _animateTo(double yaw) {
    final c = _camera;
    _from = (yaw: c.yaw, pitch: c.pitch, zoom: c.zoom, pan: c.pan);
    _toYaw = yaw;
    _move.forward(from: 0);
  }

  /// Nearest yaw (from the current one) that shows the front, or the back.
  double _nearest(double view) {
    final turns = ((_camera.yaw - view) / (2 * math.pi)).roundToDouble();
    return view + turns * 2 * math.pi;
  }

  /// Back to the view this page opened with.
  void _reset() => _animateTo(_nearest(widget.initialYaw));

  /// Half a turn: front <-> back.
  void _turnAround() {
    final front = _nearest(frontYaw);
    final showsFront = (_camera.yaw - front).abs() < math.pi / 2;
    _animateTo(showsFront ? _nearest(backYaw) : front);
  }

  void _onScaleStart(ScaleStartDetails d) {
    _move.stop();
    _startZoom = _camera.zoom;
    _downAt = _lastFocal = d.localFocalPoint;
    _moved = false;
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    _lastFocal = d.localFocalPoint;
    if ((d.localFocalPoint - _downAt).distance > kTouchSlop ||
        d.pointerCount > 1) {
      _moved = true;
    }
    final c = _camera;
    if (d.pointerCount > 1) {
      c.zoom = (_startZoom * d.scale).clamp(1.0, 5.0);
      c.pan += d.focalPointDelta;
    } else {
      c.yaw += d.focalPointDelta.dx * 0.012;
      c.pitch = (c.pitch + d.focalPointDelta.dy * 0.008).clamp(-1.2, 1.2);
    }
    c.changed();
  }

  void _onScaleEnd(ScaleEndDetails d) {
    if (_moved) return;
    final part = _renderer.pick(_lastFocal);
    setState(() => _picked = part == _picked ? null : part);
  }

  void _onScroll(PointerSignalEvent e) {
    if (e is PointerScrollEvent) {
      _camera
        ..zoom = (_camera.zoom * math.exp(-e.scrollDelta.dy / 400)).clamp(
          1.0,
          5.0,
        )
        ..changed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final picked = _picked;
    final pickedId = picked == null ? null : widget.model.partIds[picked];
    final label = switch (pickedId) {
      null => null,
      'bone' => 'Bone',
      'tendon' => 'Tendon',
      'skin' => 'Head',
      final id => [muscleName(id), ?muscleGroups[id]].join(' · '),
    };
    return Stack(
      children: [
        Positioned.fill(
          child: Listener(
            onPointerSignal: _onScroll,
            child: GestureDetector(
              onScaleStart: _onScaleStart,
              onScaleUpdate: _onScaleUpdate,
              onScaleEnd: _onScaleEnd,
              child: CustomPaint(
                painter: _BodyPainter(
                  _renderer,
                  _camera,
                  widget.highlight.partColors(widget.model),
                ),
              ),
            ),
          ),
        ),
        if (label != null)
          Positioned(
            left: 0,
            top: 0,
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Column(
            children: [
              IconButton(
                tooltip: 'Turn around',
                icon: const Icon(Icons.flip_camera_android_outlined),
                onPressed: _turnAround,
              ),
              IconButton(
                tooltip: 'Reset view',
                icon: const Icon(Icons.center_focus_strong_outlined),
                onPressed: _reset,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

final _paint = Paint()..color = const Color(0xFFFFFFFF);

class _BodyPainter extends CustomPainter {
  _BodyPainter(this.renderer, this.camera, this.colors)
    : super(repaint: camera);

  final BodyRenderer renderer;
  final _Camera camera;
  final Int32List colors;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    final vertices = renderer.build(
      yaw: camera.yaw,
      pitch: camera.pitch,
      scale: size.height / 2 * 0.95 * camera.zoom,
      center: size.center(camera.pan),
      partColors: colors,
    );
    // Modulate with white = the vertex colours as they are.
    canvas.drawVertices(vertices, BlendMode.modulate, _paint);
    vertices.dispose();
  }

  @override
  bool shouldRepaint(_BodyPainter old) =>
      old.camera.yaw != camera.yaw || !listEquals(old.colors, colors);
}

/// Keeps which legend keys are hidden: [builder] gets [highlight] without
/// them and the legend that toggles them, with [hint] after the keys.
class BodyKeyFilter extends StatefulWidget {
  const BodyKeyFilter({
    super.key,
    required this.highlight,
    required this.hint,
    required this.builder,
  });

  final BodyHighlight highlight;
  final String hint;
  final Widget Function(
    BuildContext context,
    BodyHighlight shown,
    Widget legend,
  )
  builder;

  @override
  State<BodyKeyFilter> createState() => _BodyKeyFilterState();
}

class _BodyKeyFilterState extends State<BodyKeyFilter> {
  final _hidden = <BodyKey>{};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dim = theme.colorScheme.onSurface.withValues(alpha: 0.38);
    // A hidden key: grey dot, dimmed label (user's pick, 2026-10-26).
    Widget key(BodyKey k, Color color, String label) {
      final off = _hidden.contains(k);
      return Semantics(
        toggled: !off,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => setState(() {
            if (!_hidden.remove(k)) _hidden.add(k);
          }),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: off ? dim : color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(label, style: off ? TextStyle(color: dim) : null),
              ],
            ),
          ),
        ),
      );
    }

    final h = widget.highlight;
    return widget.builder(
      context,
      h.showing(BodyKey.values.toSet().difference(_hidden)),
      Wrap(
        spacing: 16,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          key(BodyKey.target, BodyColors.target, 'Target'),
          if (h.fixators.isNotEmpty) ...[
            key(BodyKey.secondary, BodyColors.secondary, 'Synergist'),
            key(BodyKey.fixator, BodyColors.fixator, 'Fixator'),
          ] else
            key(BodyKey.secondary, BodyColors.secondary, 'Secondary'),
          Text(widget.hint, style: theme.textTheme.bodySmall.faint),
        ],
      ),
    );
  }
}

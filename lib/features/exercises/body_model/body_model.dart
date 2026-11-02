import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const bodyModelAsset = 'assets/models/body.bin';

/// The 3D body from assets/models/body.bin (written by
/// tool/build_body_model.py): one triangle mesh, split into parts that are
/// each a muscle id (see muscle_map.dart), "bone", "tendon" or "skin" (the
/// head).
///
/// Coordinates: Y up, the body faces +Z, everything inside [-1, 1].
class BodyModel {
  BodyModel._(
    this.partIds,
    this.positions,
    this.normals,
    this.indices,
    this.vertexPart,
  );

  /// Part id per part index.
  final List<String> partIds;

  /// x, y, z per vertex.
  final Float32List positions;

  /// Unit vertex normals (x, y, z), pointing out of the surface.
  final Float32List normals;

  /// Three vertex indices per triangle.
  final Uint16List indices;

  /// Part index per vertex.
  final Uint8List vertexPart;

  int get vertexCount => vertexPart.length;
  int get triangleCount => indices.length ~/ 3;

  static Future<BodyModel> load() async =>
      parse(await rootBundle.load(bodyModelAsset));

  static BodyModel parse(ByteData data) {
    var o = 0;
    int u8() => data.getUint8(o++);
    int u16() {
      final v = data.getUint16(o, Endian.little);
      o += 2;
      return v;
    }

    int u32() {
      final v = data.getUint32(o, Endian.little);
      o += 4;
      return v;
    }

    double f32() {
      final v = data.getFloat32(o, Endian.little);
      o += 4;
      return v;
    }

    final magic = String.fromCharCodes([u8(), u8(), u8(), u8()]);
    if (magic != 'GTBM') throw const FormatException('Not a body model');
    final version = u16();
    if (version != 1) throw FormatException('Unknown body model v$version');
    final partCount = u16();
    final lo = [f32(), f32(), f32()];
    final ext = [f32(), f32(), f32()];

    final ids = <String>[];
    final vCounts = <int>[];
    final tCounts = <int>[];
    for (var p = 0; p < partCount; p++) {
      final len = u8();
      ids.add(
        String.fromCharCodes(
          data.buffer.asUint8List(data.offsetInBytes + o, len),
        ),
      );
      o += len;
      vCounts.add(u32());
      tCounts.add(u32());
    }
    final nv = vCounts.fold(0, (a, b) => a + b);
    final nt = tCounts.fold(0, (a, b) => a + b);
    if (nv > 65536) throw const FormatException('Too many vertices');

    final pos = Float32List(nv * 3);
    final idx = Uint16List(nt * 3);
    final vPart = Uint8List(nv);
    var v0 = 0;
    var t0 = 0;
    for (var p = 0; p < partCount; p++) {
      for (var i = 0; i < vCounts[p]; i++) {
        for (var k = 0; k < 3; k++) {
          pos[(v0 + i) * 3 + k] = lo[k] + u16() / 65535 * ext[k];
        }
        vPart[v0 + i] = p;
      }
      for (var i = 0; i < tCounts[p] * 3; i++) {
        idx[t0 * 3 + i] = v0 + u16();
      }
      v0 += vCounts[p];
      t0 += tCounts[p];
    }
    return BodyModel._(ids, pos, _vertexNormals(pos, idx), idx, vPart);
  }

  /// Area-weighted average of the face normals around each vertex.
  static Float32List _vertexNormals(Float32List p, Uint16List idx) {
    final n = Float32List(p.length);
    for (var t = 0; t < idx.length; t += 3) {
      final a = idx[t] * 3, b = idx[t + 1] * 3, c = idx[t + 2] * 3;
      final ux = p[b] - p[a],
          uy = p[b + 1] - p[a + 1],
          uz = p[b + 2] - p[a + 2];
      final vx = p[c] - p[a],
          vy = p[c + 1] - p[a + 1],
          vz = p[c + 2] - p[a + 2];
      final nx = uy * vz - uz * vy;
      final ny = uz * vx - ux * vz;
      final nz = ux * vy - uy * vx;
      for (final i in [a, b, c]) {
        n[i] += nx;
        n[i + 1] += ny;
        n[i + 2] += nz;
      }
    }
    for (var i = 0; i < n.length; i += 3) {
      final l = math.sqrt(
        n[i] * n[i] + n[i + 1] * n[i + 1] + n[i + 2] * n[i + 2],
      );
      if (l > 0) {
        n[i] /= l;
        n[i + 1] /= l;
        n[i + 2] /= l;
      } else {
        n[i + 2] = 1; // only on zero-area slivers; any direction will do
      }
    }
    return n;
  }
}

/// Loaded once and kept for the app's lifetime (about 0.8 MB).
final bodyModelProvider = FutureProvider<BodyModel>((ref) => BodyModel.load());

/// Turns the model into a flat-shaded [ui.Vertices] for one view: rotate,
/// project (orthographic), drop back faces, sort the rest back to front
/// (painter's algorithm) and light each vertex. Reuses its buffers, so one
/// renderer per view and no allocations per frame besides the Vertices.
class BodyRenderer {
  BodyRenderer(this.model)
    : _screen = Float32List(model.vertexCount * 2),
      _depth = Float32List(model.vertexCount),
      _colors = Int32List(model.vertexCount),
      _triBucket = Int32List(model.triangleCount),
      _visible = Int32List(model.triangleCount),
      _order = Int32List(model.triangleCount),
      _sorted = Uint16List(model.indices.length);

  final BodyModel model;
  final Float32List _screen;
  final Float32List _depth;
  final Int32List _colors;
  final Int32List _triBucket;
  final Int32List _visible;
  final Int32List _order;
  final Uint16List _sorted;
  static const _buckets = 4096;
  final Int32List _bucketStart = Int32List(_buckets + 1);
  int _sortedCount = 0;

  // Light direction in view space (from the upper left, towards the model).
  static final _light = _unit(-0.4, 0.5, 0.77);
  static final _half = _unit(-0.4, 0.5, 1.77);

  static List<double> _unit(double x, double y, double z) {
    final l = math.sqrt(x * x + y * y + z * z);
    return [x / l, y / l, z / l];
  }

  /// [partColors] holds the ARGB base colour per part index.
  ui.Vertices build({
    required double yaw,
    required double pitch,
    required double scale,
    required ui.Offset center,
    required Int32List partColors,
  }) {
    final m = model;
    final p = m.positions, n = m.normals;
    final cy = math.cos(yaw), sy = math.sin(yaw);
    final cp = math.cos(pitch), sp = math.sin(pitch);
    final lx = _light[0], ly = _light[1], lz = _light[2];
    final hx = _half[0], hy = _half[1], hz = _half[2];

    for (var v = 0, i = 0; v < m.vertexCount; v++, i += 3) {
      // Yaw about Y, then pitch about X.
      final x1 = cy * p[i] + sy * p[i + 2];
      final z1 = -sy * p[i] + cy * p[i + 2];
      final y2 = cp * p[i + 1] - sp * z1;
      _depth[v] = sp * p[i + 1] + cp * z1;
      _screen[v * 2] = center.dx + scale * x1;
      _screen[v * 2 + 1] = center.dy - scale * y2;

      final nx = cy * n[i] + sy * n[i + 2];
      final nz1 = -sy * n[i] + cy * n[i + 2];
      final ny = cp * n[i + 1] - sp * nz1;
      final nz = sp * n[i + 1] + cp * nz1;
      var diffuse = nx * lx + ny * ly + nz * lz;
      if (diffuse < 0) diffuse = 0;
      var spec = nx * hx + ny * hy + nz * hz;
      if (spec <= 0) {
        spec = 0;
      } else {
        final s2 = spec * spec, s4 = s2 * s2, s8 = s4 * s4;
        spec = s8 * s8 * s8 * 60; // spec^24
      }
      final shade = 0.3 + 0.75 * diffuse;
      final c = partColors[m.vertexPart[v]];
      var r = ((c >> 16) & 0xff) * shade + spec;
      var g = ((c >> 8) & 0xff) * shade + spec;
      var b = (c & 0xff) * shade + spec;
      if (r > 255) r = 255;
      if (g > 255) g = 255;
      if (b > 255) b = 255;
      _colors[v] = 0xff000000 | r.toInt() << 16 | g.toInt() << 8 | b.toInt();
    }

    // Keep front faces, bucket them by depth (far to near).
    final idx = m.indices;
    final counts = _bucketStart..fillRange(0, _buckets + 1, 0);
    var visible = 0;
    for (var t = 0, i = 0; t < m.triangleCount; t++, i += 3) {
      final a = idx[i], b = idx[i + 1], c = idx[i + 2];
      final ax = _screen[a * 2], ay = _screen[a * 2 + 1];
      final cross =
          (_screen[b * 2] - ax) * (_screen[c * 2 + 1] - ay) -
          (_screen[b * 2 + 1] - ay) * (_screen[c * 2] - ax);
      if (cross >= 0) continue; // back face (screen Y points down)
      final d = _depth[a] + _depth[b] + _depth[c]; // within ±3√3
      var bucket = ((d + 5.2) * (_buckets / 10.4)).toInt();
      if (bucket < 0) bucket = 0;
      if (bucket >= _buckets) bucket = _buckets - 1;
      _visible[visible] = t;
      _triBucket[visible] = bucket;
      counts[bucket + 1]++;
      visible++;
    }
    for (var k = 1; k <= _buckets; k++) {
      counts[k] += counts[k - 1];
    }
    for (var j = 0; j < visible; j++) {
      _order[counts[_triBucket[j]]++] = _visible[j];
    }
    for (var j = 0; j < visible; j++) {
      final s = _order[j] * 3;
      _sorted[j * 3] = idx[s];
      _sorted[j * 3 + 1] = idx[s + 1];
      _sorted[j * 3 + 2] = idx[s + 2];
    }
    _sortedCount = visible;

    return ui.Vertices.raw(
      ui.VertexMode.triangles,
      _screen,
      colors: _colors,
      indices: Uint16List.sublistView(_sorted, 0, visible * 3),
    );
  }

  /// Index of the part drawn on top at [point] in the last [build], if any.
  int? pick(ui.Offset point) {
    final s = _screen;
    for (var j = _sortedCount - 1; j >= 0; j--) {
      final a = _sorted[j * 3] * 2;
      final b = _sorted[j * 3 + 1] * 2;
      final c = _sorted[j * 3 + 2] * 2;
      double side(int i, int k) =>
          (s[k] - s[i]) * (point.dy - s[i + 1]) -
          (s[k + 1] - s[i + 1]) * (point.dx - s[i]);
      final d1 = side(a, b), d2 = side(b, c), d3 = side(c, a);
      if ((d1 <= 0 && d2 <= 0 && d3 <= 0) || (d1 >= 0 && d2 >= 0 && d3 >= 0)) {
        return model.vertexPart[_sorted[j * 3]];
      }
    }
    return null;
  }
}

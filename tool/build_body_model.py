# /// script
# requires-python = ">=3.10"
# dependencies = ["numpy>=1.26", "fast_simplification>=0.1.7"]
# ///
"""Builds assets/models/body.bin, the 3D body shown on the exercise detail page
and the workout cards, from Z-Anatomy (CC BY-SA 4.0, itself built on
BodyParts3D by DBCLS). Pinned to one commit of the Z-Anatomy repo and checked
by SHA-256.

What it does:
  1. downloads the pinned Z-Anatomy.zip into WORKDIR (skipped if present),
  2. runs Blender headless on its Startup.blend with tool/export_zanatomy.py
     to export the skeletal and muscular layers as triangle meshes, cached
     as WORKDIR/zanatomy.npz (skipped if present; Blender is then not needed),
  3. keeps the bones (minus tiny inner ones), every muscle from the neck
     down and the visible tendons; drops fascia, bursae, sheaths and other
     connective tissue; covers the head with a smooth skin (see
     tool/export_zanatomy.py) and drops the skull and the face, jaw and eye
     muscles under it,
  4. welds and decimates each mesh (quadric decimation) to a triangle budget,
     shared by visible surface: a muscle you never see from outside (looked
     at from 24 directions) keeps only a rough shape,
  5. writes one small binary: per part an id ("latissimus_dorsi", "bone",
     "tendon", ...), quantized positions and triangle indices. The left and
     right muscle share one part.
The muscle -> app muscle group table lives in Dart
(lib/features/exercises/body_model/muscle_map.dart).

Blender: the Flatpak (flatpak install --user flathub org.blender.Blender), or
set BLENDER to another command. Run from the project root:
  uv run tool/build_body_model.py ~/.cache/gym_tracker/zanatomy
"""

import collections
import hashlib
import io
import os
import re
import shlex
import struct
import subprocess
import sys
import urllib.request
import zipfile

import fast_simplification
import numpy as np

COMMIT = "bb293be456f6d2245191f37752d14ec76894740d"  # 2024-06-07
ZIP_URL = f"https://raw.githubusercontent.com/Z-Anatomy/Models-of-human-anatomy/{COMMIT}/Z-Anatomy.zip"
ZIP_SHA = "e029688545627bd0214b269e1063143abb580aad72b2c2445d6d8a9a0d9da736"
EXPORTER = os.path.join(os.path.dirname(os.path.abspath(__file__)), "export_zanatomy.py")
OUT = "assets/models/body.bin"

# Total triangle budget, split by surface area times density. Bones get a
# lower density since they only give the silhouette, the head skin a higher
# one; hidden
# surface gets HIDDEN_DENSITY of a visible one. The app draws the whole body
# with 16-bit indices (at most 65536 vertices), and drawing time grows with
# the triangle count.
BUDGET = 55000
BONE_DENSITY = 0.45
SKIN_DENSITY = 3.0  # faces are where people notice facets
HIDDEN_DENSITY = 0.06
MIN_TRIS = 16

# Bones too small or hidden to matter at phone size (laryngeal and nasal
# cartilages, ear ossicles, sinuses, the inside of the skull).
SKIP_BONES = (
    r"incus|malleus|stapes|sesamoid|ethmoid|vomer|concha|palatine|lacrimal"
    r"|sinus|arytenoid|corniculate|cricoid|thyroid cartilage|septal cartilage"
)
# Connective tissue in the muscular layer: sheets over the muscles that would
# hide their colours, and small pads and sheaths.
SKIP_TISSUE = (
    r"\bfascia\b|septum|bursa|sheath|retinacul|aponeurosis|transverse metac"
    r"|transverse metatars|iliopectineal arch|tendinous arch|tendinous ring"
    r"|tarsus|trochlea|cruciform"
)
# Under the head's skin: no exercise works them, and so close under the skin
# they would poke through it (the renderer has no depth buffer).
HEAD_BONES = (
    r"frontal bone|parietal|occipital bone|temporal bone|sphenoid|zygomatic|maxilla"
    r"|mandible|nasal bone|tooth|molar|premolar|incisor|canine|alar cartilage|nasal septal"
)
HEAD_MUSCLES = (
    r"frontalis|occipitalis|temporoparietalis|procerus|nasalis|septi nasi|orbicularis"
    r"|corrugator|levator palpebrae|levator labii|levator nasolabialis|levator anguli"
    r"|zygomaticus|risorius|bucinator|depressor anguli|depressor labii|mentalis|masseter"
    r"|temporalis|pterygoid|genioglossus|hyoglossus"
    r"|^(superior|inferior|medial|lateral) rectus|^(superior|inferior) oblique muscle"
)
# Tendons and bands you can see on the body; drawn like bone.
TENDONS = r"tendon|tract|linea alba|inguinal ligament"
# Z-Anatomy swaps the trapezius labels: its "ascending part" is the upper
# one (neck to shoulder) and its "descending part" the lower one, the reverse
# of Terminologia Anatomica. Named by position instead.
RENAME = {
    "ascending_part_of_trapezius": "trapezius_upper",
    "transverse_part_of_trapezius": "trapezius_middle",
    "descending_part_of_trapezius": "trapezius_lower",
}


def download(workdir):
    os.makedirs(workdir, exist_ok=True)
    path = os.path.join(workdir, "Z-Anatomy.zip")
    if not os.path.exists(path):
        print("downloading Z-Anatomy.zip")
        urllib.request.urlretrieve(ZIP_URL, path)
    with open(path, "rb") as fh:
        h = hashlib.sha256(fh.read()).hexdigest()
    if h != ZIP_SHA:
        sys.exit(f"Z-Anatomy.zip: sha256 {h} != pinned {ZIP_SHA}")
    return path


def export(workdir, zip_path):
    npz = os.path.join(workdir, "zanatomy.npz")
    if not os.path.exists(npz):
        blend = os.path.join(workdir, "Startup.blend")
        with zipfile.ZipFile(zip_path) as z, open(blend, "wb") as out:
            out.write(z.read("Z-Anatomy/Startup.blend"))
        tool = os.path.dirname(EXPORTER)
        blender = shlex.split(os.environ.get("BLENDER", "")) or [
            "flatpak", "run", f"--filesystem={workdir}", f"--filesystem={tool}:ro",
            "org.blender.Blender",
        ]  # fmt: skip
        subprocess.run([*blender, "-b", blend, "--python", EXPORTER, "--", npz], check=True)
        os.remove(blend)  # 300 MB, only needed for the export
    return np.load(npz)


def part_of(name, layer):
    """Part id for a Z-Anatomy object, or None to leave it out."""
    if name.endswith(".g"):  # group placeholders
        return None
    base = re.sub(r"\.[lr]$", "", name)
    low = base.lower()
    if layer == "skin":
        return "skin"
    if layer == "bone":
        return None if re.search(f"{SKIP_BONES}|{HEAD_BONES}", low) else "bone"
    if re.search(f"{SKIP_TISSUE}|{HEAD_MUSCLES}", low):
        return None
    if re.search(TENDONS, low):
        return "tendon"
    words = re.sub(r"[()]", "", low).replace("-", " ").split()
    part = "_".join(w for w in words if w not in ("muscle", "muscles"))
    return RENAME.get(part, part)


def weld(v, f):
    """Merges duplicate vertices so decimation and smooth normals see one surface."""
    q = np.round(v * 1000).astype(np.int64)
    _, first, inverse = np.unique(q, axis=0, return_index=True, return_inverse=True)
    f = inverse.reshape(-1)[f]
    f = f[(f[:, 0] != f[:, 1]) & (f[:, 1] != f[:, 2]) & (f[:, 0] != f[:, 2])]
    return v[first], f


def area(v, f):
    return 0.5 * np.linalg.norm(np.cross(v[f[:, 1]] - v[f[:, 0]], v[f[:, 2]] - v[f[:, 0]]), axis=1).sum()


def orient_outward(v, f):
    """Flips a mesh whose triangles wind inwards (negative signed volume), so
    normals point out of the muscle and back faces can be culled."""
    a, b, c = v[f[:, 0]], v[f[:, 1]], v[f[:, 2]]
    volume = np.einsum("ij,ij->i", a, np.cross(b, c)).sum() / 6
    return f[:, ::-1] if volume < 0 else f


def visible_fraction(meshes):
    """Per mesh, the share of its area seen from outside: from 12 directions
    around the body and 12 from above and below, a triangle counts as seen
    when its centre is the nearest thing in its depth-buffer pixel (~3 mm)."""
    cs, areas, owner, normals = [], [], [], []
    for k, (_, v, f, _) in enumerate(meshes):
        a, b, c = v[f[:, 0]], v[f[:, 1]], v[f[:, 2]]
        n = np.cross(b - a, c - a)
        cs.append((a + b + c) / 3)
        areas.append(0.5 * np.linalg.norm(n, axis=1))
        normals.append(n)
        owner.append(np.full(len(f), k))
    c, area_, owner, n = map(np.concatenate, (cs, areas, owner, normals))
    seen = np.zeros(len(c), bool)
    pixel = (c[:, 2].max() - c[:, 2].min()) / 600
    for pitch in (0.0, 0.6, -0.6):
        for yaw in np.linspace(0, 2 * np.pi, 12 if pitch == 0 else 6, endpoint=False):
            # View direction: towards the body from (yaw, pitch); Z is up.
            d = -np.array([np.cos(pitch) * np.sin(yaw), np.cos(pitch) * np.cos(yaw), np.sin(pitch)])
            right = np.cross(d, [0, 0, 1.0])
            right /= np.linalg.norm(right)
            up = np.cross(right, d)
            depth = c @ d
            ix = np.floor((c @ right) / pixel).astype(np.int64)
            iy = np.floor((c @ up) / pixel).astype(np.int64)
            ix -= ix.min()
            iy -= iy.min()
            key = iy * (ix.max() + 1) + ix
            zbuf = np.full(key.max() + 1, np.inf)
            np.minimum.at(zbuf, key, depth)
            seen |= (depth <= zbuf[key] + 3.0) & (n @ d < 0)
    total = np.bincount(owner, area_, len(meshes))
    shown = np.bincount(owner, area_ * seen, len(meshes))
    return shown / np.maximum(total, 1e-9)


def compact(v, f):
    used = np.unique(f)
    remap = np.full(len(v), -1, np.int64)
    remap[used] = np.arange(len(used))
    return v[used], remap[f]


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    workdir = os.path.abspath(os.path.expanduser(sys.argv[1]))
    data = export(workdir, download(workdir))

    meshes = []  # (part id, vertices in mm, faces, density)
    i = 0
    while f"name_{i}" in data:
        name, layer = str(data[f"name_{i}"]), str(data[f"layer_{i}"])
        part = part_of(name, layer)
        v, f = data[f"v_{i}"].astype(np.float64) * 1000, data[f"f_{i}"].astype(np.int64)
        i += 1
        if part is None or len(f) == 0:
            continue
        v, f = compact(*weld(v, f))
        if len(f):
            density = {"bone": BONE_DENSITY, "skin": SKIN_DENSITY}.get(part, 1.0)
            meshes.append((part, v, f, density))

    # Visibility on a first, uniform decimation (4x the budget) to keep it fast.
    total_area = sum(area(v, f) for _, v, f, _ in meshes)
    rough = []
    for part, v, f, d in meshes:
        target = max(MIN_TRIS, int(4 * BUDGET * area(v, f) / total_area))
        if len(f) > target:
            v, f = fast_simplification.simplify(
                v.astype(np.float32), f.astype(np.int32), target_reduction=1 - target / len(f)
            )
            v, f = compact(v.astype(np.float64), f.astype(np.int64))
        rough.append((part, v, f, d))
    seen = visible_fraction(rough)
    weights = [
        area(v, f) * d * (HIDDEN_DENSITY + (1 - HIDDEN_DENSITY) * s)
        for (_, v, f, d), s in zip(meshes, seen)
    ]
    total = sum(weights)
    parts = collections.defaultdict(lambda: ([], []))
    found = collections.Counter()
    for (part, v, f, _), w in zip(meshes, weights):
        target = max(MIN_TRIS, int(BUDGET * w / total))
        if len(f) > target:
            v, f = fast_simplification.simplify(
                v.astype(np.float32), f.astype(np.int32), target_reduction=1 - target / len(f)
            )
            v, f = compact(v.astype(np.float64), f.astype(np.int64))
        if len(f) == 0:
            continue
        if part != "skin":  # an open shell; Blender already made its normals consistent
            f = orient_outward(v, f)
        # Z-Anatomy: Z up, the body faces -Y, its right side is -X.
        # App: Y up, the body faces +Z (towards the viewer).
        v = np.stack([v[:, 0], v[:, 2], -v[:, 1]], axis=1)
        vs, fs = parts[part]
        offset = sum(len(x) for x in vs)
        vs.append(v)
        fs.append(f + offset)
        found[part] += 1

    fixed = ("bone", "tendon", "skin")
    order = [*fixed, *sorted(p for p in parts if p not in fixed)]
    allv = np.concatenate([np.concatenate(parts[p][0]) for p in order])
    if len(allv) > 65536:
        sys.exit(f"{len(allv)} vertices: over 65536, lower BUDGET")
    lo, hi = allv.min(axis=0), allv.max(axis=0)
    centre = (lo + hi) / 2
    scale = (hi - lo).max() / 2  # model coordinates in [-1, 1]
    lo_n = (lo - centre) / scale
    ext_n = (hi - lo) / scale

    out = io.BytesIO()
    out.write(b"GTBM")
    out.write(struct.pack("<HH", 1, len(order)))
    out.write(struct.pack("<6f", *lo_n, *ext_n))
    body = io.BytesIO()
    ntris = 0
    for p in order:
        v = (np.concatenate(parts[p][0]) - centre) / scale
        f = np.concatenate(parts[p][1])
        q = np.round((v - lo_n) / ext_n * 65535).clip(0, 65535).astype("<u2")
        bid = p.encode()
        out.write(struct.pack("<B", len(bid)) + bid + struct.pack("<II", len(v), len(f)))
        body.write(q.tobytes())
        body.write(f.astype("<u2").tobytes())
        ntris += len(f)
    out.write(body.getvalue())
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "wb") as fh:
        fh.write(out.getvalue())
    print(f"{len(order)} parts ({found['bone']} bones), {len(allv)} vertices, {ntris} triangles, "
          f"{len(out.getvalue()) / 1024:.0f} KiB -> {OUT}")


if __name__ == "__main__":
    main()

"""Runs inside Blender (called by tool/build_body_model.py): exports the bones,
the muscles and a skin for the head of Z-Anatomy's Startup.blend as
world-space triangle meshes. The head skin ("Head skin") is the head's skin
patches (with the ones under the chin, without hair) and the eyeballs, joined
into one surface and smoothed by subdivision.

  blender -b Startup.blend --python tool/export_zanatomy.py -- out.npz

Writes an .npz with, per mesh object i: name_i (object name, e.g.
"Latissimus dorsi muscle.l"), layer_i ("bone", "muscle" or "skin"), v_i (float32
vertices, metres) and f_i (int32 triangles). Modifiers are applied, except
subdivision (the build decimates anyway). Objects without faces (Z-Anatomy's
label and group placeholders) are skipped.
"""

import re
import sys

import bmesh
import bpy
import numpy as np

LAYERS = {"1: Skeletal system": "bone", "4: Muscular system": "muscle"}
# Head skin: the patches of "9: Regions of human body" that are also in these
# collections. ("Head" alone also holds the brain, eyes and inner ear of other
# layers; the inner ear and some others are non-commercial, never take them.)
SKIN = "9: Regions of human body"
SKIN_PARTS = ("Head", "Suprahyoid region")
EYES = ("Sclera.l", "Sclera.r", "Cornea.l", "Cornea.r")


def main():
    out = sys.argv[sys.argv.index("--") + 1]
    for o in bpy.data.objects:
        for m in o.modifiers:
            if m.type == "SUBSURF":
                m.show_viewport = False
    skin = {o.name for o in bpy.data.collections[SKIN].all_objects}
    head = {
        o
        for c in SKIN_PARTS
        for o in bpy.data.collections[c].all_objects
        if o.name in skin and o.type == "MESH" and not re.search(r"hair|eyelash", o.name.lower())
    }
    head |= {bpy.data.objects[n] for n in EYES}
    for o in head:
        for m in o.modifiers:  # one thin surface, not thickened patches
            if m.type == "SOLIDIFY":
                m.show_viewport = False
    depsgraph = bpy.context.evaluated_depsgraph_get()

    bm = bmesh.new()
    for o in sorted(head, key=lambda o: o.name):
        mesh = o.evaluated_get(depsgraph).to_mesh()
        mesh.transform(o.matrix_world)
        bm.from_mesh(mesh)
        o.evaluated_get(depsgraph).to_mesh_clear()
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-4)
    # Gaps up to 30 edges (where the left-out hair sat, ear canals, the lips);
    # the eye openings (filled by the eyeballs) and the neck are larger.
    bmesh.ops.holes_fill(bm, edges=bm.edges, sides=30)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    mesh = bpy.data.meshes.new("Head skin")
    bm.to_mesh(mesh)
    skin_object = bpy.data.objects.new("Head skin", mesh)
    bpy.context.scene.collection.objects.link(skin_object)
    skin_object.modifiers.new("smooth", "SUBSURF").levels = 2
    depsgraph = bpy.context.evaluated_depsgraph_get()

    groups = [(bpy.data.collections[c].all_objects, layer) for c, layer in LAYERS.items()]
    groups.append(([skin_object], "skin"))
    arrays = {}
    done = set()
    i = 0
    for objects, layer in groups:
        for o in objects:
            if o.type != "MESH" or not o.data.polygons or o.name in done:
                continue
            done.add(o.name)
            ev = o.evaluated_get(depsgraph)
            mesh = ev.to_mesh()
            mesh.calc_loop_triangles()
            v = np.empty(len(mesh.vertices) * 3, np.float32)
            mesh.vertices.foreach_get("co", v)
            v = v.reshape(-1, 3)
            f = np.empty(len(mesh.loop_triangles) * 3, np.int32)
            mesh.loop_triangles.foreach_get("vertices", f)
            mw = np.array(ev.matrix_world, np.float64)
            v = (v @ mw[:3, :3].T + mw[:3, 3]).astype(np.float32)
            ev.to_mesh_clear()
            arrays[f"name_{i}"] = o.name
            arrays[f"layer_{i}"] = layer
            arrays[f"v_{i}"] = v
            arrays[f"f_{i}"] = f.reshape(-1, 3)
            i += 1
    np.savez_compressed(out, **arrays)
    print(f"exported {i} meshes -> {out}")


main()

# /// script
# requires-python = ">=3.11"
# ///
"""Writes docs/code-map.html, the interactive map of the code: run by
tool/check.sh, or by hand after a change.

  uv run tool/code_map.py

Files, imports, screens, tables and providers are read from the source on every
run. tool/code_map_render.py writes the page, tool/code_map_template.html holds
its styles and the script for clicks; the hand-written, deliberately general text
(glossary, where to look) is in tool/code_map_notes.toml.

What a file does comes from the code: a plain `//` comment standing alone at the
top or after the imports, else the `///` doc comment of the class named after
the file (or of its only class); [files] in the notes overrides both. Warnings name files with no description, and paths in the
notes that no longer exist. There is no date in the output, so the same code
gives the same bytes and the file only changes when the code does.
"""

import ast
import os
import re
import tomllib
from collections import Counter, defaultdict
from pathlib import Path, PurePosixPath

from code_map_render import LAYERS, Page

ROOT = Path(__file__).resolve().parent.parent
LIB = ROOT / "lib"
OUT = ROOT / "docs" / "code-map.html"
TEMPLATE = ROOT / "tool" / "code_map_template.html"
NOTES = ROOT / "tool" / "code_map_notes.toml"

COLUMN_TYPES = {"Int": "int", "Text": "text", "Real": "real", "Bool": "bool", "DateTime": "date", "Blob": "blob"}
DECLARATION = re.compile(r"^(?:abstract |sealed |final |base |mixin )*(class|enum|mixin|extension|typedef) (\w+)")
FUNCTION = re.compile(r"^[A-Za-z][\w<>?,\[\](){} ]*? ([a-z]\w*)\(")
METHOD = re.compile(r"^  [A-Z][\w<>?,() ]*? ([a-z]\w*)\(")
PROVIDER = re.compile(r"^final (\w+Provider)\s*=\s*(\w+)", re.M)
DIRECTIVE = re.compile(r"^(import|export|part|library)\b")
IMPORT = re.compile(r"""^(?:import|export)\s+['"]([^'"]+)['"]""", re.M)


def line_count(path):
    with open(path, "rb") as f:
        return sum(1 for _ in f)


def first_paragraph(comment_lines):
    """The text up to the first empty comment line, [dartdoc] names as `code`."""
    words = []
    for line in comment_lines:
        if not line and words:
            break
        words.append(line)
    return re.sub(r"\[([\w.]+)\]", r"`\1`", " ".join(w for w in words if w))


def doc_above(lines, index):
    """The `///` comment above line `index`, skipping annotations."""
    i = index - 1
    while i >= 0 and lines[i].strip() and not lines[i].strip().startswith("///") and not lines[i].endswith((";", "}")):
        i -= 1
    doc = []
    while i >= 0 and lines[i].strip().startswith("///"):
        doc.append(lines[i].strip()[3:].strip())
        i -= 1
    return first_paragraph(doc[::-1])


def comment_block(lines, i):
    """The `//` block from line `i`, if a blank line follows it."""
    block = []
    while i < len(lines) and lines[i].startswith("//") and not lines[i].startswith("///"):
        block.append(lines[i][2:].strip())
        i += 1
    alone = i >= len(lines) or not lines[i].strip()
    return first_paragraph(block) if block and alone and not block[0].startswith("ignore") else ""


def file_comment(lines):
    """A `//` block standing alone at the top or after the imports, or a `///`
    block on `library;`."""
    for i, line in enumerate(lines):
        if line.strip() == "library;":
            return doc_above(lines, i)
    if top := comment_block(lines, 0):
        return top
    i = directive_end = 0
    while i < len(lines):
        if DIRECTIVE.match(lines[i]):
            while ";" not in lines[i]:
                i += 1
            directive_end = i + 1
        i += 1
    i = directive_end
    while i < len(lines) and not lines[i].strip():
        i += 1
    return comment_block(lines, i)


def declarations(lines, is_dao):
    """Public names of a file: classes and so on, functions, DAO methods."""
    found = []
    for i, line in enumerate(lines):
        if m := DECLARATION.match(line):
            if not m[2].startswith("_"):
                found.append({"kind": m[1], "name": m[2], "about": doc_above(lines, i)})
        elif line and line[0].isalpha() and not DIRECTIVE.match(line):
            if line.startswith(("return", "final", "const", "var", "late")):
                continue
            if m := FUNCTION.match(line):
                found.append({"kind": "function", "name": m[1], "about": doc_above(lines, i)})
        elif is_dao and (m := METHOD.match(line)):
            found.append({"kind": "method", "name": m[1], "about": doc_above(lines, i)})
    return found


def pascal(stem):
    return "".join(part.capitalize() for part in stem.split("_"))


def describe(rel, lines, defines, overrides):
    if rel in overrides:
        return overrides[rel]
    if comment := file_comment(lines):
        return comment
    classes = [d for d in defines if d["kind"] in ("class", "extension")]
    named = [d for d in classes if d["name"] == pascal(PurePosixPath(rel).stem)]
    if named or len(classes) == 1:
        return (named or classes)[0]["about"]
    return ""


def resolve(importer, uri, files):
    """The lib/ file an import points at, or None for packages and generated files."""
    if uri.startswith("package:gym_tracker/"):
        target = uri.removeprefix("package:gym_tracker/")
    elif ":" in uri:
        return None
    else:
        target = os.path.normpath(PurePosixPath(importer).parent / uri)
    return target if target in files else None


def layer_of(rel):
    first = rel.split("/")[0]
    if "/" not in rel:
        return "start"
    return first if first in LAYERS else None


def group_of(rel):
    parent = str(PurePosixPath(rel).parent)
    return "" if parent == "." else parent + "/"


def box_of(rel):
    """The box a file is drawn in: a feature folder, or its own folder."""
    parts = rel.split("/")
    return f"features/{parts[1]}/" if parts[0] == "features" else group_of(rel)


def cycles(uses):
    """Tarjan's strongly connected components with more than one file."""
    index, low, on_stack, stack, found = {}, {}, set(), [], []

    def visit(v):
        index[v] = low[v] = len(index)
        stack.append(v)
        on_stack.add(v)
        for w in uses[v]:
            if w not in index:
                visit(w)
                low[v] = min(low[v], low[w])
            elif w in on_stack:
                low[v] = min(low[v], index[w])
        if low[v] == index[v]:
            component = []
            while True:
                w = stack.pop()
                on_stack.discard(w)
                component.append(w)
                if w == v:
                    break
            if len(component) > 1:
                found.append(sorted(component))

    for v in sorted(uses):
        if v not in index:
            visit(v)
    return sorted(found)


def matching_close(text, open_at):
    """Index of the bracket closing the one at `open_at`."""
    pairs = {"(": ")", "{": "}", "[": "]"}
    opening, closing = text[open_at], pairs[text[open_at]]
    depth = 0
    for i in range(open_at, len(text)):
        if text[i] == opening:
            depth += 1
        elif text[i] == closing:
            depth -= 1
            if depth == 0:
                return i
    raise ValueError(f"unbalanced {opening} at {open_at}")


def parse_routes(text, class_file):
    """Every GoRoute with its full path, screen class and nesting."""
    spans = []
    for m in re.finditer(r"\bGoRoute\(", text):
        spans.append((m.start(), matching_close(text, m.end() - 1)))
    routes = []
    for start, end in spans:
        inner = [s for s in spans if start < s[0] and s[1] < end]
        own = text[start:end]
        for s, e in sorted(inner, reverse=True):
            own = own[: s - start] + own[e - start :]
        parents = [i for i, s in enumerate(spans) if s[0] < start and end < s[1]]
        parent = routes[parents[-1]] if parents else None
        path = re.search(r"path:\s*'([^']*)'", own)[1]
        screen = re.search(r"builder:.*?=>\s*(?:const\s+)?([A-Z]\w*)", own, re.S)
        routes.append(
            {
                "path": parent["path"].rstrip("/") + "/" + path if parent else path,
                "own": path,
                "screen": screen[1] if screen else "",
                "file": class_file.get(screen[1], "") if screen else "",
                "depth": len(parents),
                "full": "parentNavigatorKey" in own,
            }
        )
    return routes


def snake(name):
    return re.sub(r"(?<!^)([A-Z])", r"_\1", name).lower()


def parse_tables(text):
    lines = text.splitlines()
    tables = []
    for m in re.finditer(r"^class (\w+) extends Table \{", text, re.M):
        end = matching_close(text, m.end() - 1)
        body = text[m.end() : end]
        columns = []
        for c in re.finditer(r"^  (\w+)Column get (\w+) =>(.*?);\n", body, re.M | re.S):
            definition = c[3]
            enum = re.search(r"textEnum<(\w+)>", definition)
            ref = re.search(r"references\(\s*(\w+)", definition)
            at = text.count("\n", 0, m.end() + c.start())
            columns.append(
                {
                    "name": c[2],
                    "type": enum[1] if enum else COLUMN_TYPES.get(c[1], c[1]),
                    "nullable": ".nullable()" in definition,
                    "ref": ref[1] if ref else "",
                    "about": doc_above(lines, at),
                }
            )
        name = re.search(r"tableName => '(\w+)'", body)
        key = re.search(r"primaryKey => \{(.*?)\}", body)
        auto = [c["name"] for c in columns if "autoIncrement" in body and c["name"] == "id"]
        tables.append(
            {
                "class": m[1],
                "name": name[1] if name else snake(m[1]),
                "about": doc_above(lines, text.count("\n", 0, m.start())),
                "key": key[1].replace(" ", "").split(",") if key else auto,
                "columns": columns,
            }
        )
    return tables


def parse_providers(texts):
    """Providers with their kind, description and the files that use them."""
    providers = []
    for rel, text in texts.items():
        lines = text.splitlines()
        for m in PROVIDER.finditer(text):
            name = m[1]
            users = [f for f, t in texts.items() if f != rel and re.search(rf"\b{name}\b", t)]
            at = text.count("\n", 0, m.start())
            providers.append(
                {"name": name, "kind": m[2], "file": rel, "users": users, "about": doc_above(lines, at)}
            )
    return providers


def tests(files):
    rows, tested_by = [], defaultdict(list)
    for path in sorted((ROOT / "test").glob("*.dart")):
        text = path.read_text()
        for uri in IMPORT.findall(text):
            if uri.startswith("package:gym_tracker/") and (target := resolve("", uri, files)):
                tested_by[target].append(path.name)
        rows.append(
            {
                "name": path.name,
                "lines": line_count(path),
                "tests": len(re.findall(r"^\s*(?:test|testWidgets)\(", text, re.M)),
            }
        )
    return rows, tested_by


def tool_description(path):
    text = path.read_text()
    if path.suffix == ".py":
        doc = ast.get_docstring(ast.parse(text)) or ""
        return " ".join(doc.split("\n\n")[0].split())
    if path.suffix == ".html":
        m = re.search(r"<!--(.*?)-->", text, re.S)
        return " ".join(m[1].split()) if m else ""
    block = []
    for line in text.splitlines():
        if line.startswith("#!"):
            continue
        if not line.startswith("#"):
            break
        block.append(line[1:].strip())
    return first_paragraph(block)


def tools():
    rows = []
    for path in sorted((ROOT / "tool").iterdir()):
        if path.is_file():
            rows.append({"name": path.name, "lines": line_count(path), "about": tool_description(path)})
    return rows


def assets(notes):
    rows = []
    for path in sorted((ROOT / "assets").rglob("*")):
        if path.is_file():
            rel = path.relative_to(ROOT / "assets").as_posix()
            rows.append({"name": rel, "bytes": path.stat().st_size, "about": notes.get(rel, "")})
    return rows


def dependencies(texts):
    section = re.search(r"^dependencies:\n((?:(?:  .*)?\n)*)", (ROOT / "pubspec.yaml").read_text(), re.M)
    names = re.findall(r"^  ([a-z_]+):", section[1], re.M)
    rows = []
    for name in names:
        used = sum(f"package:{name}/" in text or f"'{name}'" in text for text in texts.values())
        rows.append({"name": name, "files": used})
    return sorted(rows, key=lambda row: (-row["files"], row["name"]))


def check_notes(notes, warnings):
    """Every path written in backticks in the notes must still exist."""

    def strings(value):
        if isinstance(value, str):
            yield value
        elif isinstance(value, dict):
            for v in value.values():
                yield from strings(v)
        elif isinstance(value, list):
            for v in value:
                yield from strings(v)

    for text in strings(notes):
        for token in re.findall(r"`([^`]+)`", text):
            if not re.fullmatch(r"[\w./-]+", token) or token.startswith("/"):
                continue
            if "/" not in token and not re.search(r"\.(dart|py|sh|toml|json|html)$", token):
                continue
            if token.endswith(".g.dart") or token.startswith(("ref.", "db.")):
                continue
            if not (ROOT / token).exists() and not (LIB / token).exists():
                warnings.append(f"the notes name `{token}`, which does not exist")


def main():
    notes = tomllib.loads(NOTES.read_text())
    warnings = []
    check_notes(notes, warnings)

    paths = sorted(LIB.rglob("*.dart"))
    generated = [p for p in paths if p.name.endswith(".g.dart")]
    sources = [p for p in paths if not p.name.endswith(".g.dart")]
    texts = {p.relative_to(LIB).as_posix(): p.read_text() for p in sources}
    names = set(texts)

    uses = {}
    for rel, text in texts.items():
        uses[rel] = sorted({t for u in IMPORT.findall(text) if (t := resolve(rel, u, names))})
    used_by = defaultdict(list)
    for rel, targets in uses.items():
        for target in targets:
            used_by[target].append(rel)
    tested_rows, tested_by = tests(names)

    overrides = notes.get("files", {})
    files, class_file = {}, {}
    for rel, text in texts.items():
        lines = text.splitlines()
        defines = declarations(lines, rel.startswith("data/daos/"))
        about = describe(rel, lines, defines, overrides)
        if not about:
            warnings.append(f"lib/{rel} has no description")
        if layer_of(rel) is None:
            warnings.append(f"lib/{rel} is in no layer")
        for d in defines:
            class_file.setdefault(d["name"], rel)
        files[rel] = {
            "lines": len(lines),
            "about": about,
            "defines": [{"kind": d["kind"], "name": d["name"]} for d in defines],
            "packages": sorted(set(re.findall(r"^(?:import|export)\s+'package:(\w+)/", text, re.M)) - {"gym_tracker"}),
            "uses": uses[rel],
            "usedBy": sorted(used_by[rel]),
            "tests": sorted(tested_by[rel]),
            "box": box_of(rel),
            "group": group_of(rel),
            "layer": layer_of(rel) or "shared",
        }

    router = texts["router.dart"]
    routes = parse_routes(router, class_file)
    initial = re.search(r"initialLocation:\s*'([^']*)'", router)
    for route in routes:
        if route["file"]:
            files[route["file"]].setdefault("routes", []).append(route["path"])
    if not routes:
        warnings.append("no routes found in lib/router.dart")
    tables = parse_tables(texts["data/tables.dart"])
    if not tables:
        warnings.append("no tables found in lib/data/tables.dart")

    # Feature folders in tab order, then any others.
    tab_order = [f"features{r['path']}/" for r in routes if r["depth"] == 0]
    boxes = defaultdict(lambda: {"files": 0, "lines": 0})
    for rel, f in files.items():
        boxes[f["box"]]["files"] += 1
        boxes[f["box"]]["lines"] += f["lines"]
        boxes[f["box"]]["layer"] = f["layer"]

    def box_rank(box):
        rank = tab_order.index(box) if box in tab_order else len(tab_order)
        return (LAYERS.index(boxes[box]["layer"]), rank, box)

    groups = defaultdict(list)
    for rel in sorted(files):
        groups[files[rel]["group"]].append(rel)

    def group_rank(group):
        return (*box_rank(box_of(group + "x.dart")), group)

    between, across, upward = Counter(), Counter(), []
    for rel, targets in uses.items():
        for target in targets:
            a, b = files[rel], files[target]
            between[f"{a['layer']}>{b['layer']}"] += 1
            if a["layer"] == b["layer"] == "features" and a["box"] != b["box"]:
                across[(a["box"], b["box"])] += 1
            if LAYERS.index(b["layer"]) < LAYERS.index(a["layer"]):
                upward.append([rel, target])

    data = {
        "stats": {
            "files": len(files),
            "lines": sum(f["lines"] for f in files.values()),
            "generatedFiles": len(generated),
            "generatedLines": sum(line_count(p) for p in generated),
            "imports": sum(len(u) for u in uses.values()),
            "schema": int(re.search(r"schemaVersion => (\d+)", texts["data/database.dart"])[1]),
            "tests": sum(row["tests"] for row in tested_rows),
        },
        "files": files,
        "groups": [{"name": g, "files": groups[g]} for g in sorted(groups, key=group_rank)],
        "boxes": [{"name": b, **boxes[b]} for b in sorted(boxes, key=box_rank)],
        "between": dict(sorted(between.items())),
        "across": [{"from": a, "to": b, "count": n} for (a, b), n in sorted(across.items())],
        "upward": upward,
        "cycles": cycles(uses),
        "routes": routes,
        "initialRoute": initial[1] if initial else "",
        "tables": tables,
        "providers": parse_providers(texts),
        "testFiles": tested_rows,
        "tools": tools(),
        "assets": assets(notes.get("assets", {})),
        "packages": dependencies(texts),
        "notes": {k: v for k, v in notes.items() if k not in ("files", "assets")},
    }

    body = Page(data).body()
    html = re.sub(r"<main>.*?</main>", lambda _: f"<main>{body}</main>", TEMPLATE.read_text(), flags=re.S)
    OUT.parent.mkdir(exist_ok=True)
    changed = not OUT.exists() or OUT.read_text() != html
    if changed:
        OUT.write_text(html)
    state = "updated" if changed else "unchanged"
    print(
        f"{OUT.relative_to(ROOT)} {state}: {len(files)} files, {len(routes)} addresses, "
        f"{len(tables)} tables, {len(warnings)} warnings"
    )
    for warning in warnings:
        print(f"  {warning}")


if __name__ == "__main__":
    main()

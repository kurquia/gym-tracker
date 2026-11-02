"""Turns the facts gathered by tool/code_map.py into the HTML of the map. All of
the page is written here, diagrams included, so it reads in viewers that don't
run scripts; the script in the template only adds clicks and search.
"""

import html
import re

LAYERS = ["start", "features", "shared", "data"]
FLOW_SVG = """<svg viewBox="0 0 900 250" role="img" aria-label="A widget calls a DAO, the database stream emits, the provider passes it on, the widget redraws">{defs}
<rect class="box" x="20" y="90" width="210" height="64"/><text x="125" y="117" text-anchor="middle">a screen's widget</text><text x="125" y="138" text-anchor="middle" class="note">lib/features/</text>
<rect class="box dark" x="620" y="90" width="260" height="64"/><text x="750" y="117" text-anchor="middle" class="inv">a DAO, then SQLite</text><text x="750" y="138" text-anchor="middle" class="note inv">lib/data/daos/</text>
<rect class="box" x="345" y="178" width="210" height="64"/><text x="450" y="205" text-anchor="middle">a provider</text><text x="450" y="226" text-anchor="middle" class="note">lib/data/providers.dart</text>
<path class="edge" d="M230,104 C380,40 520,40 620,104" marker-end="url(#ah2)"/>
<text x="425" y="32" text-anchor="middle">1 · you tap → a method call</text><text x="425" y="52" text-anchor="middle" class="note">writes to the tables</text>
<path class="edge" d="M720,154 C700,205 620,210 557,210" marker-end="url(#ah2)"/><text x="690" y="210" class="note">2 · the stream emits</text><text x="690" y="226" class="note">    the new rows</text>
<path class="edge" d="M345,210 C280,210 200,205 160,156" marker-end="url(#ah2)"/><text x="20" y="200" class="note">3 · ref.watch gets them,</text><text x="20" y="216" class="note">    the widget redraws</text></svg>"""


def esc(text):
    return html.escape(str(text))


def num(n):
    return f"{n:,}"


def plural(n, word):
    return f"{num(n)} {word}{'' if n == 1 else 's'}"


def px(x):
    """A coordinate without floating-point noise."""
    return f"{x:.1f}".removesuffix(".0")


def arrow_defs(name):
    return (
        f'<defs><marker id="{name}" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" '
        'orient="auto-start-reverse"><path class="head" d="M0,0 L10,5 L0,10 z"/></marker></defs>'
    )


def section(key, eyebrow, title, body):
    return f'<section id="{key}"><div class="eyebrow">{eyebrow}</div><h2>{esc(title)}</h2>{body}</section>'


class Page:
    def __init__(self, data):
        self.d = data
        self.files = data["files"]
        self.notes = data["notes"]

    def file_of(self, token):
        name = token.removeprefix("lib/")
        return name if name in self.files else None

    def md(self, text):
        """Notes markup: `code` (a link when it names a lib/ file) and **bold**."""

        def code(m):
            token = m[1]
            target = self.file_of(html.unescape(token))
            return f'<code class="link" data-file="{esc(target)}">{token}</code>' if target else f"<code>{token}</code>"

        return re.sub(r"\*\*([^*]+)\*\*", r"<b>\1</b>", re.sub(r"`([^`]+)`", code, esc(text)))

    def file_link(self, rel):
        return f'<span class="link" data-file="{esc(rel)}">{esc(rel)}</span>'

    # 1 · Layers

    def layers_svg(self):
        width, left, box_h = 900, 92, 54
        usable = width - left
        files, between = self.files, self.d["between"]

        def place(items):
            gap = 14
            w = (usable - gap * (len(items) - 1)) / len(items)
            return [{**b, "x": left + i * (w + gap), "w": w} for i, b in enumerate(items)]

        def in_start(rel):
            return [u for u in files[rel]["usedBy"] if "/" not in u]

        def chain(rel):
            return 1 + max(map(chain, in_start(rel))) if in_start(rel) else 0

        def boxes(layer):
            return [b for b in self.d["boxes"] if b["layer"] == layer]

        # Start files in import order: main → app → router.
        roots = next(g for g in self.d["groups"] if g["name"] == "")["files"]
        start = sorted(roots, key=chain)
        rows = {
            "start": place([{"name": f, "files": 1, "lines": files[f]["lines"], "isFile": True} for f in start]),
            "features": place(boxes("features")),
            "shared": place(boxes("shared")),
            "data": place([*boxes("data"), {"name": "SQLite file", "external": True}]),
        }
        biggest = max(b["lines"] for b in self.d["boxes"])

        def centre(b):
            return b["x"] + b["w"] / 2

        feature = {b["name"]: i for i, b in enumerate(rows["features"])}
        arcs = [dict(e) for e in self.d["across"] if e["from"] in feature and e["to"] in feature]
        max_span = max([abs(feature[e["from"]] - feature[e["to"]]) for e in arcs], default=1)
        arc_space = 30 + 16 * max_span if arcs else 0
        step = box_h + 58
        top = {"start": 8}
        top["features"] = top["start"] + step
        top["shared"] = top["features"] + box_h + arc_space + 44
        top["data"] = top["shared"] + step
        height = top["data"] + box_h + 8

        out = [f'<svg viewBox="0 0 {width} {height}" role="img" aria-label="Layer diagram">', arrow_defs("ah")]
        for layer in LAYERS:
            out.append(f'<text x="0" y="{top[layer] + 31}" class="note">{layer.upper()}</text>')
        for layer in LAYERS:
            for b in rows[layer]:
                y, external, is_file = top[layer], b.get("external"), b.get("isFile")
                dark = not external and not is_file and b["lines"] == biggest
                short = b["name"].removeprefix("features/")
                if external:
                    sub = "on the device"
                elif is_file:
                    sub = f"{num(b['lines'])} lines"
                else:
                    sub = f"{plural(b['files'], 'file')} · {num(b['lines'])}"
                attributes = "" if external else f' class="node" data-box="{esc(b["name"])}"'
                x, cx, inv = px(b["x"]), px(centre(b)), " inv" if dark else ""
                out.append(
                    f'<g{attributes}><rect class="box{" dark" if dark else ""}{" dash" if external else ""}" '
                    f'x="{x}" y="{y}" width="{px(b["w"])}" height="{box_h}"/>'
                    f'<text x="{cx}" y="{y + 23}" text-anchor="middle" class="{inv.strip()}">{esc(short)}</text>'
                    f'<text x="{cx}" y="{y + 42}" text-anchor="middle" class="note{inv}">{sub}</text></g>'
                )
        for a, b in zip(rows["start"], rows["start"][1:]):
            if b["name"] in files[a["name"]]["uses"]:
                y = top["start"] + box_h / 2
                out.append(
                    f'<line class="edge" x1="{px(a["x"] + a["w"])}" y1="{px(y)}" x2="{px(b["x"] - 2)}" y2="{px(y)}" '
                    'marker-end="url(#ah)"/>'
                )
        # Imports arriving at each layer, one arrow per layer, counted.
        for i, layer in enumerate(LAYERS[1:]):
            counts = [(between.get(f"{a}>{layer}", 0), a) for a in LAYERS[: i + 1]]
            words = " · ".join(f"{n} from {a}" for n, a in sorted(counts, key=lambda c: -c[0]) if n)
            x, y2 = left + usable / 2, top[layer] - 2
            y1 = y2 - 30
            out.append(
                f'<line class="edge" x1="{px(x)}" y1="{y1}" x2="{px(x)}" y2="{y2}" marker-end="url(#ah)"/>'
                f'<text x="{px(x + 10)}" y="{y1 + 19}" class="note">imports: {words}</text>'
            )
        # Features borrowing from each other: arcs under the row. Each arc gets its
        # own port on a box, in the order of the far ends, so that arcs nest.
        base = top["features"] + box_h
        by_name = {b["name"]: b for b in rows["features"]}
        for e in arcs:
            e["left"] = feature[e["to"]] < feature[e["from"]]
        for box in rows["features"]:
            near = centre(box)
            ends = []
            for e in arcs:
                if e["from"] == box["name"]:
                    ends.append((e, "x1", centre(by_name[e["to"]])))
                if e["to"] == box["name"]:
                    ends.append((e, "x2", centre(by_name[e["from"]])))
            ends.sort(key=lambda p: (p[2], -p[0]["left"] if near < p[2] else p[0]["left"]))
            for i, (e, end, _) in enumerate(ends):
                e[end] = near + (i - (len(ends) - 1) / 2) * min(26, box["w"] * 0.7 / len(ends))
        for e in arcs:
            span = abs(feature[e["from"]] - feature[e["to"]])
            h = 14 + 13 * span + (16 if e["left"] else 0)
            x1, x2 = px(e["x1"]), px(e["x2"])
            out.append(
                f'<path class="edge dash" d="M{x1},{base + 1} C{x1},{base + h} {x2},{base + h} {x2},{base + 3}" '
                f'marker-end="url(#ah)"><title>{esc(e["from"])} imports {esc(e["to"])} {e["count"]}×</title></path>'
                f'<text x="{px((e["x1"] + e["x2"]) / 2)}" y="{px(base + h * 0.75 - 4)}" text-anchor="middle" '
                f'class="note">{e["count"]}</text>'
            )
        out.append("</svg>")
        return "".join(out)

    def big_picture(self):
        upward, cycles = self.d["upward"], self.d["cycles"]
        title = f"Four layers, {plural(len(upward), 'import')} pointing up" if upward else "Four layers, imports only point down"
        extra = ""
        if upward:
            pairs = ", ".join(f"{self.file_link(a)} → {self.file_link(b)}" for a, b in upward)
            extra += f'<p class="prose">Pointing up: {pairs}.</p>'
        if cycles:
            listed = "; ".join(
                f"{plural(len(c), 'file')} ({', '.join(f.split('/')[-1] for f in c)})" for c in cycles
            )
            extra += (
                f'<p class="prose">{self.md(self.notes["big_picture"]["cycle"])}</p>'
                f'<p class="prose small muted">Now: {esc(listed)}.</p>'
            )
        return section(
            "layers",
            "1 · The big picture",
            title,
            f'<p class="prose">{self.md(self.notes["big_picture"]["text"])}</p>'
            f'<figure class="figure">{self.layers_svg()}</figure>'
            '<p class="small muted">Solid arrow = imports arriving at that layer. Dashed = one feature borrowing from '
            'another, with the count. Filled = the biggest part.<span class="js-only"> Click a box to jump to its '
            f"files.</span></p>{extra}",
        )

    # 2 · Every file

    def chips(self, title, items):
        if not items:
            return ""
        return (
            f'<div><div class="eyebrow">{title} ({len(items)})</div>'
            f'<div class="chips">{" · ".join(esc(i) for i in items)}</div></div>'
        )

    def file_list(self, title, items):
        rows = "".join(f"<li>{self.file_link(i)}</li>" for i in items)
        body = f"<ul>{rows}</ul>" if items else '<div class="chips muted">nothing</div>'
        return f'<div><div class="eyebrow">{title} ({len(items)})</div>{body}</div>'

    def file_info(self, rel):
        f = self.files[rel]
        about = self.md(f["about"]) if f["about"] else '<span class="muted">No description yet: give the file a comment.</span>'
        methods = [d["name"] for d in f["defines"] if d["kind"] == "method"]
        names = [d["name"] for d in f["defines"] if d["kind"] != "method"]
        return (
            f'<h3>lib/{esc(rel)}</h3><div class="eyebrow">{num(f["lines"])} lines</div><p>{about}</p>'
            + self.chips("Address", f.get("routes", []))
            + self.chips("Defines", names)
            + self.chips("Queries and actions", methods)
            + self.file_list("Imports", f["uses"])
            + self.file_list("Imported by", f["usedBy"])
            + self.chips("Packages", f["packages"])
            + self.chips("Imported by tests", f["tests"])
        )

    def explorer(self):
        folders = []
        for group in self.d["groups"]:
            name = group["name"]
            rows = []
            for rel in group["files"]:
                f = self.files[rel]
                short = rel[len(name) : -len(".dart")]
                rows.append(
                    f'<details data-pick="{esc(rel)}" data-uses="{esc(" ".join(f["uses"]))}" '
                    f'data-usedby="{esc(" ".join(f["usedBy"]))}"><summary class="file"><span>{esc(short)}</span>'
                    f'<span>{f["lines"]}</span></summary><div class="info">{self.file_info(rel)}</div></details>'
                )
            heading = f"lib/{esc(name)}{'' if name else ' (start)'}"
            folders.append(f'<div class="folder" data-group="{esc(name)}"><h3>{heading}</h3>{"".join(rows)}</div>')
        stats = self.d["stats"]
        most_imported = max(sorted(self.files), key=lambda rel: len(self.files[rel]["usedBy"]))
        return section(
            "files",
            "2 · Every file",
            "Click a file to see what it does and what it touches",
            '<div class="bar js-only"><input id="search" type="search" placeholder="Search files and names…" '
            'aria-label="Search files and names"><div class="legend"><span><i class="swatch s"></i>selected</span>'
            '<span><i class="swatch"></i>imports these</span><span><i class="swatch d"></i>imported by these</span>'
            "<span>numbers = lines</span></div></div>"
            f'<div class="explorer" data-start="{esc(most_imported)}"><div class="folders">{"".join(folders)}</div>'
            '<aside class="panel js-only" id="panel" aria-live="polite"></aside></div>'
            f'<p class="muted small">Not shown: {plural(stats["generatedFiles"], "generated file")} (<code>*.g.dart</code>, '
            f"{num(stats['generatedLines'])} lines) written by <code>build_runner</code>. Never edit those; regenerate them.</p>",
        )

    # 3 · Screens

    def screens(self):
        tabs = []
        for route in self.d["routes"]:
            if route["depth"] == 0:
                tabs.append([])
            tabs[-1].append(route)
        cards = []
        for tab in tabs:
            root = tab[0]
            rows = []
            for r in tab:
                short_screen = r["screen"].removesuffix("Screen")
                label = esc(r["own"] if r["depth"] else r["screen"])
                side = (esc(short_screen) + (" · full" if r["full"] else "")) if r["depth"] else "tab"
                rows.append(
                    f'<button class="file route" style="--depth:{r["depth"]}" type="button" data-file="{esc(r["file"])}" '
                    f'title="{esc(r["path"])}"><span>{label}</span><span>{side}</span></button>'
                )
            start = " (start tab)" if root["path"] == self.d["initialRoute"] else ""
            cards.append(f'<div class="folder"><h3>{esc(root["path"])}{start}</h3>{"".join(rows)}</div>')
        return section(
            "screens",
            "3 · Screens",
            f"{len(self.d['routes'])} addresses in {len(tabs)} tabs",
            f'<p class="prose">{self.md(self.notes["screens"]["text"])}</p><div class="cards">{"".join(cards)}</div>',
        )

    # 4 · Data flow

    def flow(self):
        providers = sorted(self.d["providers"], key=lambda p: -len(p["users"]))
        rows = []
        for p in providers:
            about = f'<span class="about">{self.md(p["about"])}</span>' if p["about"] else ""
            rows.append(
                f'<div><span class="name">{esc(p["name"])}</span><span class="num">{plural(len(p["users"]), "file")}</span>{about}</div>'
            )
        half = (len(rows) + 1) // 2
        notes = self.notes["flow"]
        return section(
            "flow",
            "4 · Data flow",
            "What happens when you tap something",
            f'<p class="prose">{self.md(notes["text"])}</p>'
            f'<figure class="figure">{FLOW_SVG.format(defs=arrow_defs("ah2"))}</figure>'
            f'<pre>{esc(notes["code"].strip())}</pre><p class="prose">{self.md(notes["after"])}</p>'
            f"<h3>{plural(len(providers), 'provider')}, most used first</h3>"
            f'<div class="cols"><div class="rows">{"".join(rows[:half])}</div>'
            f'<div class="rows">{"".join(rows[half:])}</div></div>',
        )

    # 5 · Database. Layered by foreign keys: a table sits below everything it points
    # at. An arrow skipping a row passes through it as a thin invisible node, which
    # keeps a gap open for it instead of running behind another table.

    def database_svg(self):
        tables = self.d["tables"]
        by_class = {t["class"]: t for t in tables}

        def refs(t):
            return sorted({c["ref"] for c in t["columns"] if c["ref"] in by_class}, key=list(by_class).index)

        rank = {}

        def rank_of(t):
            if t["class"] not in rank:
                rank[t["class"]] = 1 + max(map(rank_of, (by_class[r] for r in refs(t)))) if refs(t) else 0
            return rank[t["class"]]

        for t in tables:
            rank_of(t)
        rows = [[] for _ in range(max(rank.values()) + 1)]
        up, down, edges = {}, {}, []

        def add(node, row):
            rows[row].append(node)
            up[node], down[node] = [], []

        for t in tables:
            add(t["class"], rank[t["class"]])
        for t in tables:
            for r in refs(t):
                path = [t["class"]]
                for k in range(rank[t["class"]] - 1, rank[r], -1):
                    node = f"{t['class']}>{r}@{k}"
                    add(node, k)
                    path.append(node)
                path.append(r)
                for a, b in zip(path, path[1:]):
                    up[a].append(b)
                    down[b].append(a)
                optional = any(c["ref"] == r and c["nullable"] for c in t["columns"])
                edges.append({"path": path, "optional": optional})

        # A few sweeps of the barycentre heuristic: order each row by its neighbours.
        pos = {}

        def set_positions():
            for row in rows:
                for i, node in enumerate(row):
                    pos[node] = (i + 0.5) / len(row)

        set_positions()
        for sweep in range(12):
            near = down if sweep % 2 else up
            for row in reversed(rows) if sweep % 2 else rows:
                score = {n: sum(pos[m] for m in near[n]) / len(near[n]) if near[n] else pos[n] for n in row}
                row.sort(key=score.get)
                set_positions()

        box_w, box_h, thin, gap_x, gap_y = 148, 50, 16, 20, 62

        def node_width(node):
            return box_w if node in by_class else thin

        def row_width(row):
            return sum(node_width(n) + gap_x for n in row) - gap_x

        width = max(map(row_width, rows))
        height = len(rows) * box_h + (len(rows) - 1) * gap_y + 4
        at = {}
        for k, row in enumerate(rows):
            x = (width - row_width(row)) / 2
            for node in row:
                at[node] = {"x": x, "y": 2 + k * (box_h + gap_y), "cx": x + node_width(node) / 2}
                x += node_width(node) + gap_x

        # Arrows leave and arrive side by side, sorted by where they come from.
        def spread(nodes, x):
            ordered = sorted(nodes, key=lambda n: at[n]["cx"])
            return {n: x + (i - (len(ordered) - 1) / 2) * 16 for i, n in enumerate(ordered)}

        leave = {n: spread(up[n], at[n]["cx"]) for n in at}
        arrive = {n: spread(down[n], at[n]["cx"]) for n in at}
        out = [
            f'<svg viewBox="0 0 {px(width)} {height}" role="img" aria-label="Database tables and how they reference '
            'each other" style="min-width:560px">',
            arrow_defs("ah3"),
        ]
        for edge in edges:
            path, d = edge["path"], ""
            for i, (a, b) in enumerate(zip(path, path[1:])):
                x1 = leave[a][b] if a in by_class else at[a]["cx"]
                x2 = arrive[b][a] if b in by_class else at[b]["cx"]
                y1, y2 = at[a]["y"], at[b]["y"] + box_h + (2 if b in by_class else 0)
                bend = (y1 - y2) * 0.5
                if i == 0:
                    d += f"M{px(x1)},{y1}"
                d += f" C{px(x1)},{px(y1 - bend)} {px(x2)},{px(y2 + bend)} {px(x2)},{y2}"
                if b not in by_class:
                    d += f" L{px(x2)},{at[b]['y']}"
            out.append(f'<path class="edge{" dash" if edge["optional"] else ""}" d="{d}" marker-end="url(#ah3)"/>')
        for t in tables:
            x, y = at[t["class"]]["x"], at[t["class"]]["y"]
            cx = px(x + box_w / 2)
            out.append(
                f'<g class="node" data-table="{esc(t["class"])}"><rect class="box" x="{px(x)}" y="{y}" width="{box_w}" '
                f'height="{box_h}"/><text x="{cx}" y="{y + 22}" text-anchor="middle" class="mono">{esc(t["name"])}</text>'
                f'<text x="{cx}" y="{y + 39}" text-anchor="middle" class="note">{plural(len(t["columns"]), "column")}</text></g>'
            )
        out.append("</svg>")
        return "".join(out)

    def table_info(self, t):
        names = {x["class"]: x["name"] for x in self.d["tables"]}
        rows = []
        for c in t["columns"]:
            key = " (key)" if c["name"] in t["key"] else ""
            ref = ""
            if c["ref"] in names:
                ref = f' → <span class="link" data-goto="{esc(c["ref"])}">{esc(names[c["ref"]])}</span>'
            about = f'<span class="about">{self.md(c["about"])}</span>' if c["about"] else ""
            kind = esc(c["type"]) + ("?" if c["nullable"] else "")
            rows.append(f'<div><span class="name">{esc(c["name"])}{key}{ref}</span><span class="num">{kind}</span>{about}</div>')
        about = f'<p>{self.md(t["about"])}</p>' if t["about"] else ""
        return f'<h3>{esc(t["name"])}</h3>{about}<div class="rows">{"".join(rows)}</div>'

    def database(self):
        tables = self.d["tables"]
        entries = "".join(
            f'<details data-table-info="{esc(t["class"])}"><summary class="file"><span>{esc(t["name"])}</span>'
            f'<span>{len(t["columns"])}</span></summary><div class="info">{self.table_info(t)}</div></details>'
            for t in tables
        )
        widest = max(tables, key=lambda t: len(t["columns"]))
        return section(
            "database",
            "5 · The database",
            f"{plural(len(tables), 'table')}, schema v{self.d['stats']['schema']}",
            f'<p class="prose">{self.md(self.notes["database"]["text"])}</p>'
            f'<div class="explorer" data-start-table="{esc(widest["class"])}"><figure class="figure">{self.database_svg()}</figure>'
            f'<aside class="panel js-only" id="table-panel" aria-live="polite"></aside></div>'
            f'<div class="tablelist">{entries}</div>'
            '<p class="small muted">Dashed arrow = optional: the column may be empty.</p>',
        )

    # 6 · Where to look

    def where(self):
        rows = "".join(f"<tr><td>{self.md(w['change'])}</td><td>{self.md(w['start'])}</td></tr>" for w in self.notes["where"])
        return section(
            "where",
            "6 · Where to look",
            "If you want to change…",
            f'<div class="tablewrap"><table><thead><tr><th>Change</th><th>Start in</th></tr></thead><tbody>{rows}</tbody></table></div>',
        )

    # 7 · Outside lib/

    def row(self, name, number, about=""):
        text = f'<span class="about">{self.md(about)}</span>' if about else ""
        return f'<div><span class="name">{esc(name)}</span><span class="num">{number}</span>{text}</div>'

    def outside(self):
        def size(b):
            if b >= 1e6:
                return f"{b / 1e6:.1f} MB"
            return f"{round(b / 1e3)} kB" if b >= 1e3 else f"{b} B"

        d = self.d
        tests = "".join(self.row(t["name"], f"{plural(t['tests'], 'block')} · {num(t['lines'])}") for t in d["testFiles"])
        tools = "".join(self.row(t["name"], num(t["lines"]), t["about"]) for t in d["tools"])
        assets = "".join(self.row(a["name"], size(a["bytes"]), a["about"]) for a in d["assets"])
        packages = "".join(self.row(p["name"], plural(p["files"], "file")) for p in d["packages"])
        folders = "".join(self.row(f["name"], "", f["about"]) for f in self.notes["folders"])
        below = ' style="margin-top:20px"'
        return section(
            "outside",
            "7 · Outside lib/",
            "Tests, tools, assets and packages",
            f'<div class="cols"><div><h3>tool/ · {plural(len(d["tools"]), "file")}</h3><div class="rows">{tools}</div></div>'
            f'<div><h3>test/ · {plural(d["stats"]["tests"], "test block")}</h3><div class="rows">{tests}</div>'
            f'<h3{below}>assets/</h3><div class="rows">{assets}</div>'
            f'<h3{below}>Packages the app uses</h3><div class="rows">{packages}</div>'
            f'<h3{below}>Other folders</h3><div class="rows">{folders}</div></div></div>',
        )

    # 8 · Glossary

    def glossary(self):
        rows = "".join(f"<dt>{esc(g['term'])}</dt><dd>{self.md(g['meaning'])}</dd>" for g in self.notes["glossary"])
        return section("glossary", "8 · Words you'll meet in the code", "A small glossary", f"<dl>{rows}</dl>")

    def header(self):
        s, d = self.d["stats"], self.d
        toc = "".join(
            f'<a href="#{key}">{name}</a>'
            for key, name in [
                ("layers", "Big picture"),
                ("files", "Files"),
                ("screens", "Screens"),
                ("flow", "Data flow"),
                ("database", "Database"),
                ("where", "Where to look"),
                ("outside", "Outside lib/"),
                ("glossary", "Glossary"),
            ]
        )
        cycles = len(d["cycles"])
        stats = "".join(
            f"<span>{text}</span>"
            for text in [
                f"<b>{s['files']}</b> source files",
                f"<b>{num(s['lines'])}</b> lines",
                f"<b>{s['imports']}</b> imports between them",
                f"<b>{cycles}</b> import {'cycle' if cycles == 1 else 'cycles'}",
                f"<b>{len(d['routes'])}</b> addresses",
                f"schema <b>v{s['schema']}</b>",
                f"<b>{s['tests']}</b> test blocks",
            ]
        )
        return (
            '<header><div class="eyebrow">kurquia/gym-tracker · written by tool/code_map.py<span id="updated"></span></div>'
            "<h1>Gym Tracker code map</h1><p class=\"lede prose\">How the app's code fits together: which file does what, "
            "who imports whom, and how a tap reaches the database and comes back to the screen.</p>"
            f'<div class="stats">{stats}</div><nav class="toc" aria-label="Contents">{toc}</nav></header>'
        )

    def body(self):
        return "".join(
            [
                self.header(),
                self.big_picture(),
                self.explorer(),
                self.screens(),
                self.flow(),
                self.database(),
                self.where(),
                self.outside(),
                self.glossary(),
            ]
        )

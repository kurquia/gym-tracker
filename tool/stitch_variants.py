# /// script
# requires-python = ">=3.11"
# dependencies = ["pillow"]
# ///
"""Puts same-named screenshots of several layout variants side by side, each
column labelled with its variant (the folder name), 40 px grey gaps.

  uv run tool/stitch_variants.py --out DIR [--crop X,Y,W,H] [--only a,b] VARIANT_DIR…

Writes DIR/<name>.png for every PNG name in the first variant folder (or only
the names given with --only, without .png). --crop cuts the same box from every
shot first, in PNG pixels (the screenshot test renders at 2×: 824 × 1784).
Called by tool/variants.sh.
"""

import argparse
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

GAP = 40
GREY = (128, 128, 128)
LABEL_HEIGHT = 56


def stitch(paths, labels, crop):
    shots = [Image.open(p).convert("RGB") for p in paths]
    if crop:
        x, y, w, h = crop
        shots = [s.crop((x, y, x + w, y + h)) for s in shots]
    width = sum(s.width for s in shots) + GAP * (len(shots) + 1)
    height = max(s.height for s in shots) + LABEL_HEIGHT + GAP
    sheet = Image.new("RGB", (width, height), GREY)
    draw = ImageDraw.Draw(sheet)
    font = ImageFont.load_default(size=32)
    x = GAP
    for shot, label in zip(shots, labels):
        draw.text((x, 10), label, fill=(0, 0, 0), font=font)
        sheet.paste(shot, (x, LABEL_HEIGHT))
        x += shot.width + GAP
    return sheet


def main():
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument("--out", required=True, type=Path)
    parser.add_argument("--crop", help="X,Y,W,H in PNG pixels")
    parser.add_argument("--only", help="comma-separated shot names")
    parser.add_argument("variants", nargs="+", type=Path)
    args = parser.parse_args()

    crop = tuple(int(v) for v in args.crop.split(",")) if args.crop else None
    if crop and len(crop) != 4:
        sys.exit("--crop takes X,Y,W,H")
    names = (
        args.only.split(",")
        if args.only
        else sorted(p.stem for p in args.variants[0].glob("*.png"))
    )
    if not names:
        sys.exit(f"no PNGs in {args.variants[0]}")
    args.out.mkdir(parents=True, exist_ok=True)
    labels = [v.name for v in args.variants]
    for name in names:
        paths = [v / f"{name}.png" for v in args.variants]
        missing = [str(p) for p in paths if not p.exists()]
        if missing:
            print(f"skipped {name}: missing {', '.join(missing)}")
            continue
        out = args.out / f"{name}.png"
        stitch(paths, labels, crop).save(out)
        print(out)


if __name__ == "__main__":
    main()

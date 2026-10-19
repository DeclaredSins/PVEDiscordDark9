#!/usr/bin/env python3
"""Create light-coloured copies of Proxmox's black SVG icons.

Proxmox ships some icons with hard-coded black fills. The stock dark theme tries to
lighten them with a CSS `invert()` filter, which also inverts neighbouring text.
We ship recoloured copies instead.

Usage: recolor-icons.py <pve-manager/www/images> <proxmox-widget-toolkit/src/images> <out-dir>
(the two inputs are checkouts of git.proxmox.com/git/pve-manager.git and
proxmox-widget-toolkit.git). Output files are named dd_<original>.svg.
"""
import re
import sys
from pathlib import Path

LIGHT = "#e6e7ea"  # keep in sync with $icon-color in src/scss/abstracts/_variables.scss
PVE = ["icon-cpu", "icon-memory", "icon-cd-drive", "icon-pci", "icon-serial", "icon-die"]
PWT = ["icon-ram"]

def recolor(svg: str) -> str:
    return re.sub(r"(?i)(?<![\w-])(#000000|#000|black)(?![\w-])", LIGHT, svg)

def main(pve_dir, pwt_dir, out_dir):
    out = Path(out_dir)
    out.mkdir(parents=True, exist_ok=True)
    for src_dir, names in ((Path(pve_dir), PVE), (Path(pwt_dir), PWT)):
        for name in names:
            svg = recolor((src_dir / f"{name}.svg").read_text())
            if re.search(r"(?i)#000\b|black", svg):
                sys.exit(f"{name}: black fill left after recolouring")
            (out / f"dd_{name}.svg").write_text(svg)
            print("wrote", out / f"dd_{name}.svg")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        sys.exit(__doc__)
    main(*sys.argv[1:])

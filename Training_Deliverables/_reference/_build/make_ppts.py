#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Build one .pptx per module into Training_Deliverables/1_PPTS/."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from slides_data import MODULES
import deck

OUT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "1_PPTS"))

def main(only=None):
    os.makedirs(OUT, exist_ok=True)
    for n, m in sorted(MODULES.items()):
        if only is not None and n != only: continue
        if not m["beats"]:
            print(f"  {n:02d}  (no slides authored yet)"); continue
        specs = [dict(layout="title", kicker=f"Module {n:02d}",
                      title=m["title"], sub=m["sub"])] + m["beats"]
        name = f"Module_{n:02d}_{m['title'].replace(' ','_').replace(',','').replace('—','-')}.pptx"
        made = deck.build(n, specs, os.path.join(OUT, name))
        print(f"  {n:02d}  {made:>3} slides -> {name}")

if __name__ == "__main__":
    main(int(sys.argv[1]) if len(sys.argv) > 1 else None)

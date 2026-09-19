#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Build one video per module from the EXPORTED DECK SLIDES.

The frames are the .pptx slides themselves (exported via Keynote), so the video and
the deck can never disagree. One slide per narration beat; the beat's own text is
burned in as a caption in the band the slide reserves for it.

Real app screen recordings are cut in for the beats that describe the app running.
Clips carry a playhead across consecutive segments, so a clip never snaps back to
its first frame mid-scene (the old build's visible "glitch").

    python3 make_videos.py          # all modules
    python3 make_videos.py 1        # just module 01
"""

import glob
import os
import subprocess
import sys
import textwrap

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import design as D

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    sys.exit("pip install pillow")

BASE = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
REF = os.path.join(BASE, "_reference")
SLIDES_PNG = os.path.join(REF, "slides_png")
NARR = os.path.join(REF, "narration")
FOOT = os.path.join(REF, "footage")
OUT = os.path.join(BASE, "2_VIDEOS")

W, H, FPS, WPM, MIN_SEG = 1920, 1080, 30, 150, 2.5
CAP_TOP = int(H * D.CAPTION_TOP_FRAC)

# Beats that show the app actually running get real screen-recording footage
# instead of a slide. Key: module -> {1-based beat index: clip filename}.
# (clip, start_seconds) — most recordings open on the iOS home screen while the app
# launches, so each entry starts where the app is actually on screen.
FOOTAGE = {
    0:  {9:  ("01_app_montage.mov", 3)},
    1:  {25: ("shot_1.6_ctrl_drag.mov", 0), 26: ("04_table_scrolling.mov", 3)},
    2:  {24: ("03_search_and_sort.mov", 4)},
    4:  {16: ("05_reviews_local_vs_online.mov", 4)},
    5:  {16: ("06_bookings_persisted.mov", 3), 17: ("06_bookings_persisted.mov", 3),
         18: ("10_profile_auth.mov", 10)},
    6:  {18: ("00_booking_flow_full.mov", 4)},
    7:  {18: ("07_map_and_pins.mov", 3)},
    8:  {12: ("00_booking_flow_full.mov", 4), 15: ("08_concert_quantity.mov", 17)},
    9:  {13: ("01_app_montage.mov", 3)},
    10: {8:  ("09_settings_changelog.mov", 20)},
}

_LEN, _HEAD = {}, {}


def font(sz, bold=True):
    p = ("/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold
         else "/System/Library/Fonts/Supplemental/Arial.ttf")
    try:
        return ImageFont.truetype(p, sz)
    except Exception:
        return ImageFont.load_default()


def run(cmd):
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode:
        raise RuntimeError(" ".join(cmd[:8]) + "\n" + r.stderr[-900:])


def clip_len(path):
    if path not in _LEN:
        r = subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration",
                            "-of", "csv=p=0", path], capture_output=True, text=True)
        try:
            _LEN[path] = float(r.stdout.strip())
        except ValueError:
            _LEN[path] = 0.0
    return _LEN[path]


def take(path, dur, start0=0.0):
    """Consume `dur` seconds of a clip, continuing where the last segment stopped."""
    start = _HEAD.get(path, start0)
    total = clip_len(path)
    if total <= 0:
        return 0.0, False
    if start >= total - 0.2:
        start = start0
    _HEAD[path] = start + dur
    return start, (start + dur) > total


def caption_png(text, out):
    """Caption drawn into the band the slide reserves — never over its content."""
    img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    f = font(31, False)
    lines = textwrap.wrap(text, 92)[:3]
    lh = 44
    top = CAP_TOP + (H - CAP_TOP - (lh * len(lines) + 30)) // 2
    d.rectangle([0, CAP_TOP, W, H], fill=(*D.BG, 235))
    d.rectangle([0, CAP_TOP, W, CAP_TOP + 3], fill=(*D.RED, 255))
    d.rectangle([96, top - 4, 101, top + lh * len(lines) + 8], fill=(*D.GOLD, 255))
    y = top
    for ln in lines:
        d.text((126, y), ln, font=f, fill=(*D.TEXT, 255))
        y += lh
    img.save(out)
    return out


def segment(visual, kind, dur, cap_png, out, start0=0.0):
    scale = (f"scale={W}:{H}:force_original_aspect_ratio=decrease,"
             f"pad={W}:{H}:(ow-iw)/2:(oh-ih)/2:color=0x{D.hexs(D.BG)},setsar=1,fps={FPS}")
    d = f"{dur:.3f}"
    cmd = ["ffmpeg", "-y"]
    tail = ""
    if kind == "img":
        cmd += ["-loop", "1", "-t", d, "-i", visual]
    else:
        start, hold = take(visual, dur, start0)
        cmd += ["-ss", f"{start:.3f}", "-t", d, "-i", visual]
        if hold:
            tail = f",tpad=stop_mode=clone:stop_duration={d}"
    cmd += ["-loop", "1", "-t", d, "-i", cap_png,
            "-f", "lavfi", "-t", d, "-i", "anullsrc=channel_layout=stereo:sample_rate=44100",
            "-filter_complex",
            f"[0:v]{scale}{tail}[bg];[bg][1:v]overlay=0:0:format=auto,format=yuv420p[v]",
            "-map", "[v]", "-map", "2:a:0",
            "-c:v", "libx264", "-preset", "veryfast", "-crf", "22",
            "-c:a", "aac", "-b:a", "96k", "-shortest", out]
    run(cmd)


def srt_t(s):
    ms = int(round(s * 1000))
    h, ms = divmod(ms, 3600000)
    m, ms = divmod(ms, 60000)
    sec, ms = divmod(ms, 1000)
    return f"{h:02d}:{m:02d}:{sec:02d},{ms:03d}"


def build(num, deck_dir, beats, specs):
    slides = sorted(glob.glob(os.path.join(SLIDES_PNG, deck_dir, "*.png")))
    # a spec of None produces no slide (that beat is real footage), so the deck has
    # one slide per non-None beat, plus the title slide
    expect = 1 + sum(1 for sp in specs if sp is not None)
    if len(slides) != expect:
        print(f"  {num:02d}: {len(slides)} slides, expected {expect} — skipped")
        return None
    tmp = f"/tmp/vid_{num:02d}"
    os.makedirs(tmp, exist_ok=True)
    for old in glob.glob(os.path.join(tmp, "*")):
        os.remove(old)

    parts, srt, t, n = [], [], 0.0, 1
    blank = caption_png("", os.path.join(tmp, "cap_blank.png"))
    seg0 = os.path.join(tmp, "s000.mp4")
    segment(slides[0], "img", 3.0, blank, seg0)
    parts.append(seg0)
    t += 3.0

    si = 1
    for i, text in enumerate(beats, 1):
        dur = max(MIN_SEG, len(text.split()) / WPM * 60.0)
        spec = specs[i - 1] if i - 1 < len(specs) else None
        ent = FOOTAGE.get(num, {}).get(i)
        clip, start0 = (ent if isinstance(ent, tuple) else (ent, 0.0)) if ent else (None, 0.0)
        slide = slides[si] if spec is not None else None
        if spec is not None:
            si += 1                      # the deck slide index only advances for real slides
        if clip and os.path.exists(os.path.join(FOOT, clip)):
            vis, kind = os.path.join(FOOT, clip), "vid"
        elif slide:
            vis, kind = slide, "img"
        else:
            print(f"\n  {num:02d} beat {i}: no slide and no footage — using title card")
            vis, kind = slides[0], "img"
        cap = caption_png(text, os.path.join(tmp, f"cap{i:03d}.png"))
        seg = os.path.join(tmp, f"s{i:03d}.mp4")
        segment(vis, kind, dur, cap, seg, start0)
        parts.append(seg)
        srt += [str(n), f"{srt_t(t)} --> {srt_t(t + dur)}",
                "\n".join(textwrap.wrap(text, 92)[:3]), ""]
        n += 1
        t += dur
        print(f"    beat {i}/{len(beats)}", end="\r", flush=True)

    lst = os.path.join(tmp, "list.txt")
    with open(lst, "w") as fh:
        for p in parts:
            fh.write(f"file '{p}'\n")
    os.makedirs(OUT, exist_ok=True)
    out = os.path.join(OUT, f"{deck_dir}.mp4")
    run(["ffmpeg", "-y", "-f", "concat", "-safe", "0", "-i", lst, "-c", "copy", out])
    with open(os.path.join(OUT, f"{deck_dir}.srt"), "w") as fh:
        fh.write("\n".join(srt))
    return out, t


def main(only=None):
    from slides_data import MODULES
    for num, m in sorted(MODULES.items()):
        if only is not None and num != only:
            continue
        deck = [d for d in os.listdir(SLIDES_PNG)
                if d.startswith(f"Module_{num:02d}_")]
        if not deck:
            print(f"  {num:02d}: no exported slides"); continue
        f = os.path.join(NARR, f"NARRATION_video_{num:02d}.txt")
        beats = [x.strip() for x in open(f).read().split("\n\n") if x.strip()]
        _HEAD.clear()
        r = build(num, deck[0], beats, m["beats"])
        if r:
            out, t = r
            print(f"  {num:02d}: {len(beats)} beats · {int(t//60)}:{int(t%60):02d} · "
                  f"{os.path.getsize(out)//1_000_000} MB")


if __name__ == "__main__":
    main(int(sys.argv[1]) if len(sys.argv) > 1 else None)

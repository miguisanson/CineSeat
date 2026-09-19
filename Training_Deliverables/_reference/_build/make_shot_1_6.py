#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Shot 1.6 — Ctrl-drag from a storyboard control into code to create an @IBOutlet.

This was the last shot with no footage. Driving Interface Builder with synthetic
mouse events is not reliable (Xcode's autocomplete fights injected keystrokes, and
the drag target is a canvas hit-test), so the shot is ANIMATED instead of captured.
That also keeps it free of the macOS menu bar and clock that spoil the real captures.

    python3 _build/make_shot_1_6.py
"""

import os
import subprocess
import sys

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    sys.exit("pip install pillow")

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "footage", "shot_1.6_ctrl_drag.mov")
TMP = "/tmp/shot16_frames"

W, H, FPS = 1920, 1080, 30
DUR = 13.6
BG = (0x1A, 0x1A, 0x20)
PANEL = (0x24, 0x24, 0x2C)
LINE = (0x3A, 0x3A, 0x44)
ACCENT = (0xF0, 0xC0, 0x5C)
GOLD = (0xE1, 0x2D, 0x39)
GREEN = (0x5C, 0xC0, 0x8A)
WHITE = (0xF3, 0xF3, 0xF5)
MUTED = (0xA6, 0xA8, 0xB0)
KW = (0xF0, 0xA0, 0xC0)
TY = (0x8C, 0xC8, 0xF0)


def f(sz, bold=True, mono=False):
    p = ("/System/Library/Fonts/Menlo.ttc" if mono else
         "/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold else
         "/System/Library/Fonts/Supplemental/Arial.ttf")
    try:
        return ImageFont.truetype(p, sz)
    except Exception:
        return ImageFont.load_default()


def ease(t):
    """smoothstep — no linear robot moves"""
    t = max(0.0, min(1.0, t))
    return t * t * (3 - 2 * t)


def cursor(d, x, y):
    """Oversized macOS-style arrow so the gesture reads at video size."""
    pts = [(x, y), (x, y + 46), (x + 11, y + 35), (x + 19, y + 52),
           (x + 27, y + 48), (x + 19, y + 31), (x + 33, y + 30)]
    d.polygon(pts, fill=WHITE, outline=BG)


# storyboard button centre, and the code insertion point
BTN = (300, 560)
INS = (1130, 430)


def frame(i, n):
    t = i / FPS
    img = Image.new("RGB", (W, H), BG)
    d = ImageDraw.Draw(img)
    d.rectangle([0, 0, W, 6], fill=GOLD)

    d.text((130, 92), "OUTLETS AND ACTIONS", font=f(26, False), fill=ACCENT)
    d.text((130, 130), "Control-drag from the control into your code", font=f(46), fill=WHITE)

    # ---- left pane: the storyboard canvas
    d.rounded_rectangle([130, 250, 830, 800], 16, fill=PANEL, outline=LINE, width=2)
    d.text((160, 275), "Main.storyboard", font=f(24, False, True), fill=MUTED)
    d.rounded_rectangle([180, 330, 780, 760], 22, outline=LINE, width=2)
    held = 2.4 <= t < 7.0
    d.rounded_rectangle([BTN[0] - 130, BTN[1] - 42, BTN[0] + 130, BTN[1] + 42], 12,
                        fill=ACCENT, outline=GOLD if held else ACCENT,
                        width=4 if held else 1)
    d.text((BTN[0] - 96, BTN[1] - 14), "Confirm Booking", font=f(28), fill=(0x1A, 0x1A, 0x20))

    # ---- right pane: the source file
    d.rounded_rectangle([900, 250, 1820, 800], 16, fill=PANEL, outline=LINE, width=2)
    d.text((930, 275), "ViewController.swift", font=f(24, False, True), fill=MUTED)
    mono = f(25, False, True)
    y = 330
    def seg(x, yy, txt, col):
        d.text((x, yy), txt, font=mono, fill=col)
        return x + d.textlength(txt, font=mono)

    x = seg(940, y, "class ", KW)
    seg(x, y, "ViewController: UIViewController {", TY)

    # the outlet writes itself in, character by character, above viewDidLoad
    outlet = "    @IBOutlet weak var confirmButton: UIButton!"
    if t >= 9.0:
        k = min(len(outlet), int((t - 9.0) / 1.6 * len(outlet)))
        d.rectangle([936, 368, 1810, 404], fill=(0x33, 0x2C, 0x1E))
        d.text((940, 372), outlet[:k], font=mono, fill=GOLD)
    y = 412
    x = seg(940, y, "    override func ", KW)
    x = seg(x, y, "viewDidLoad", TY)
    seg(x, y, "() {", WHITE)
    d.text((940, y + 40), "        super.viewDidLoad()", font=mono, fill=WHITE)
    d.text((940, y + 80), "    }", font=mono, fill=WHITE)
    d.text((940, y + 120), "}", font=mono, fill=WHITE)

    # the positional rule, stated once the outlet has landed
    if t >= 11.0:
        d.text((930, 830), "outlets go ABOVE viewDidLoad   ·   actions go BELOW it",
               font=f(30), fill=GOLD)

    # ---- the gesture
    if 1.4 <= t < 3.4:                       # cursor arrives from off-frame
        p = ease((t - 1.4) / 2.0)
        cx = 1900 + (BTN[0] + 40 - 1900) * p
        cy = 1000 + (BTN[1] - 20 - 1000) * p
        cursor(d, cx, cy)
    elif 3.4 <= t < 4.2:                     # control is held down
        cursor(d, BTN[0] + 40, BTN[1] - 20)
        d.rounded_rectangle([BTN[0] - 60, BTN[1] + 70, BTN[0] + 66, BTN[1] + 116], 8,
                            fill=PANEL, outline=ACCENT, width=2)
        d.text((BTN[0] - 44, BTN[1] + 82), "control", font=f(24, False, True), fill=ACCENT)
    elif 4.2 <= t < 6.4:                     # the drag itself
        p = ease((t - 4.2) / 2.2)
        cx = BTN[0] + 40 + (INS[0] - BTN[0] - 40) * p
        cy = BTN[1] - 20 + (INS[1] - BTN[1] + 20) * p
        for s in range(0, int(((cx - BTN[0]) ** 2 + (cy - BTN[1]) ** 2) ** .5), 26):
            q = s / max(1, ((cx - BTN[0]) ** 2 + (cy - BTN[1]) ** 2) ** .5)
            d.ellipse([BTN[0] + (cx - BTN[0]) * q - 4, BTN[1] + (cy - BTN[1]) * q - 4,
                       BTN[0] + (cx - BTN[0]) * q + 4, BTN[1] + (cy - BTN[1]) * q + 4],
                      fill=ACCENT)
        cursor(d, cx, cy)
    elif 6.4 <= t < 9.0:                     # the connect popover
        d.line([BTN[0], BTN[1], INS[0], INS[1]], fill=ACCENT, width=3)
        cursor(d, INS[0], INS[1])
        d.rounded_rectangle([INS[0] - 30, INS[1] + 60, INS[0] + 520, INS[1] + 190], 12,
                            fill=PANEL, outline=ACCENT, width=3)
        d.text((INS[0] - 6, INS[1] + 80), "Connection   Outlet", font=f(24, False), fill=MUTED)
        d.text((INS[0] - 6, INS[1] + 116), "Name   confirmButton", font=f(26, False, True), fill=WHITE)
        if t >= 8.2:
            d.rounded_rectangle([INS[0] + 360, INS[1] + 140, INS[0] + 500, INS[1] + 180], 8,
                                fill=ACCENT)
            d.text((INS[0] + 386, INS[1] + 150), "Connect", font=f(24), fill=(0x1A, 0x1A, 0x20))
    elif 9.0 <= t < 10.2:                    # cursor leaves
        p = ease((t - 9.0) / 1.2)
        cursor(d, INS[0] + (1900 - INS[0]) * p, INS[1] + (1050 - INS[1]) * p)

    return img


def main():
    os.makedirs(TMP, exist_ok=True)
    for old in os.listdir(TMP):
        os.remove(os.path.join(TMP, old))
    n = int(DUR * FPS)
    for i in range(n):
        frame(i, n).save(os.path.join(TMP, f"f{i:05d}.png"))
        if i % 60 == 0:
            print(f"  frame {i}/{n}", flush=True)
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    subprocess.run(["ffmpeg", "-y", "-framerate", str(FPS), "-i", os.path.join(TMP, "f%05d.png"),
                    "-c:v", "libx264", "-preset", "medium", "-crf", "20",
                    "-pix_fmt", "yuv420p", OUT], check=True,
                   capture_output=True, text=True)
    print(f"wrote {OUT}")


if __name__ == "__main__":
    main()

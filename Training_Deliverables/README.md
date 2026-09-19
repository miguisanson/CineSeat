# iOS Development Training — deliverables

Three folders. Everything else is reference material you don't need to open.

| Folder | What's in it |
|---|---|
| **`1_PPTS/`** | 11 PowerPoint decks, one per module (246 slides) |
| **`2_VIDEOS/`** | 11 MP4s with burned-in captions, plus `.srt` files |
| **`3_SCRIPTS/`** | 13 paste-ready ElevenLabs files + `_PASTE_ORDER.txt` |
| `_reference/` | Narration source, app footage, exported slide PNGs, build scripts, the 3 old HyperFrames videos |

## How the three stay consistent

One spec file drives everything, and the videos are cut from the **exported deck slides
themselves** — so a video can never show something the deck doesn't.

```
_reference/_build/slides_data.py    236 beats, one per narration paragraph
        │
        ├── deck.py ─────────► 1_PPTS/*.pptx
        │                          │
        │                    export_slides.sh (Keynote)
        │                          ▼
        │                    _reference/slides_png/
        │                          │
        └── make_videos.py ◄───────┘ + narration captions + app footage
                    └──────────► 2_VIDEOS/*.mp4
```

The ElevenLabs scripts come from the same narration files the captions do, so what the
voice says and what the caption reads are identical.

## Rebuilding

```bash
cd _reference/_build
python3 make_ppts.py          # decks      -> 1_PPTS/
./export_slides.sh            # slides     -> _reference/slides_png/  (drives Keynote)
python3 make_videos.py        # videos     -> 2_VIDEOS/
```

## Design

Lifted from `TicketPlease_PresentationFinalv2.pptx`: near-black `#1A1A20`, gold `#F0C05C`
as the single accent, red `#E12D39` for warnings and the top rule, `#F3F3F5` text. Every
slide is uppercase kicker → gold tick → title → content. Bullets carry a bold gold lead-in.
Screenshots sit in gold device frames.

## The ElevenLabs budget

**41,772 characters against ~42,000 credits — 228 spare.** That is not enough to
re-generate anything, so `3_SCRIPTS/_PASTE_ORDER.txt` lists the files in teaching
priority with a running total. The course introduction is last: if you run short, it is
the least damaging thing to be missing.

Acronyms are pre-spaced (`M V V M`, `U I Kit`, `T M D B`) so the voice says them correctly
first time. A re-do costs far more than those few characters.

## Audio

The videos have **no voiceover yet**. Segments are timed at 150 wpm, matching the `.srt`
files, so ElevenLabs audio drops onto these timings without a re-cut.

## Notes

- **Shot 1.6 (Ctrl-drag)** is animated, not captured. Driving Interface Builder with
  synthetic mouse events is unreliable, and it keeps the macOS menu bar and clock out of
  frame. Source: `_reference/_build/make_shot_1_6.py`.
- **Real app footage** is cut in for the beats that describe the app running (module →
  beat map at the top of `make_videos.py`). Clips carry a playhead across consecutive
  segments so a clip never snaps back to its first frame mid-scene.
- **Narration is verbatim** from `_reference/narration/`. Editing it changes both the
  captions and the ElevenLabs budget — rebuild both after any change.

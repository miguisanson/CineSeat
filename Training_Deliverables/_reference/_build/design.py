# -*- coding: utf-8 -*-
"""
Shared design tokens, lifted from TicketPlease_PresentationFinalv2.pptx.

One source of truth for BOTH renderers:
  · deck.py   -> the .pptx a human opens
  · frames.py -> the .png frames the video is cut from

There is no pptx->image converter on this Mac (no LibreOffice; Keynote needs an
Automation permission that is denied), so the two renderers share this file instead
of one converting the other. Same tokens, same content, same result.
"""

# ---- palette (measured from the reference deck) --------------------------------
BG       = (0x1A, 0x1A, 0x20)   # near-black ground
PANEL    = (0x24, 0x24, 0x2C)   # raised panel
PANEL_2  = (0x2E, 0x2E, 0x38)   # alternating row
GOLD     = (0xF0, 0xC0, 0x5C)   # dominant accent
RED      = (0xE1, 0x2D, 0x39)   # emphasis / warning
TEXT     = (0xF3, 0xF3, 0xF5)   # primary text
MUTED    = (0xA6, 0xA8, 0xB0)   # secondary text
RULE     = (0x76, 0x78, 0x82)   # hairlines
GREEN    = (0x5C, 0xC0, 0x8A)   # "correct" (not in the reference; needed for compares)

# code syntax colours, tuned to sit on PANEL
C_KW     = (0xF0, 0xA0, 0xC0)
C_TYPE   = (0x8C, 0xC8, 0xF0)
C_STR    = (0xF0, 0xA8, 0x80)
C_COMMENT= (0x76, 0x78, 0x82)

# ---- geometry -------------------------------------------------------------------
SLIDE_W_IN, SLIDE_H_IN = 13.333, 7.5     # 16:9, matches the reference deck
PX_W, PX_H = 1920, 1080

MARGIN_IN = 0.9
# The video letterboxes the slide ABOVE a caption strip rather than overlaying it,
# so a slide may use nearly its whole height. This is just the bottom safe margin.
CAPTION_TOP_FRAC = 0.82

FONT_TITLE = "Arial"
FONT_BODY = "Arial"
FONT_MONO = "Menlo"


def hexs(rgb):
    return "%02X%02X%02X" % rgb

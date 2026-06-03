"""Build the TBag-fufu logo PNGs from the source artwork (Test.jpeg).

The icon is AI-generated art: a white bunny walking away down a moonlit path
to a castle, wearing a purple star-charm satchel, in a gold filigree frame.
This script just converts it to lossless PNG and emits the sizes we use
(1024 master for CurseForge upload, plus 512/256 for previews/README).
"""
from PIL import Image, ImageDraw
import os

here = os.path.dirname(os.path.abspath(__file__))
src = Image.open(os.path.join(here, "Test.jpeg")).convert("RGB")

RADIUS_FRAC = 0.05   # corner radius as a fraction of the (square) image side
SS = 4               # supersample the mask for smooth, anti-aliased corners

def round_corners(img):
    w, h = img.size
    mask = Image.new("L", (w * SS, h * SS), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, w * SS - 1, h * SS - 1],
        radius=int(min(w, h) * SS * RADIUS_FRAC), fill=255)
    mask = mask.resize((w, h), Image.LANCZOS)
    out = img.convert("RGBA")
    out.putalpha(mask)
    return out

# Master (native 1024) plus downscales; round each at its own size for crisp corners.
round_corners(src).save(os.path.join(here, "tbag-fufu-logo-1024.png"))
for sz in (512, 256):
    round_corners(src.resize((sz, sz), Image.LANCZOS)).save(
        os.path.join(here, f"tbag-fufu-logo-{sz}.png"))

print("wrote tbag-fufu-logo-{1024,512,256}.png (rounded corners) from Test.jpeg")

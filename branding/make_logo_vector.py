"""TBag-fufu logo: a bunny seen from BEHIND, walking away with a backpack on.
Back-facing lavender ears (splayed side-by-side, no overlap) rise above a gold
backpack with a WoW-default-style fold-over flap + central buckle strap, two
shoulder straps draping over the top edge, and little feet peeking out the bottom.
Midnight-violet badge. Pillow, SS supersample + LANCZOS downscale.
"""
from PIL import Image, ImageDraw, ImageFilter, ImageChops

SS = 3            # supersample factor
U = 1024          # design units (final master is 1024)
W = U * SS

def u(v):
    return int(round(v * SS))

# --- Midnight palette ---------------------------------------------------------
BG_TOP    = (40, 26, 70)
BG_BOT    = (98, 60, 176)
BORDER    = (170, 140, 225, 180)
EAR       = (208, 190, 242)
EAR_CREASE= (180, 160, 216)
EAR_SHADOW= (150, 132, 196)
BODY      = (233, 185, 76)
BODY_DK   = (212, 162, 60)
FLAP      = (214, 162, 60)
FLAP_EDGE = (168, 122, 42)
SEAM      = (176, 128, 44)
STRAP     = (198, 148, 52)
STRAP_EDGE= (158, 116, 40)
BUCKLE    = (58, 38, 94)
PIN       = (150, 130, 190, 255)
FOOT      = (208, 190, 242)
FOOT_PAD  = (180, 160, 216)

base = Image.new("RGBA", (W, W), (0, 0, 0, 0))

# --- badge: vertical gradient clipped to a rounded square --------------------
grad = Image.new("RGB", (W, W), BG_TOP)
gd = ImageDraw.Draw(grad)
for y in range(W):
    t = y / (W - 1)
    c = tuple(int(BG_TOP[i] + (BG_BOT[i] - BG_TOP[i]) * t) for i in range(3))
    gd.line([(0, y), (W, y)], fill=c)

mask = Image.new("L", (W, W), 0)
ImageDraw.Draw(mask).rounded_rectangle(
    [u(48), u(48), u(976), u(976)], radius=u(200), fill=255)
base.paste(grad, (0, 0), mask)

sheen = Image.new("RGBA", (W, W), (0, 0, 0, 0))
ImageDraw.Draw(sheen).ellipse([u(110), u(40), u(914), u(560)], fill=(255, 255, 255, 30))
sheen.putalpha(ImageChops.multiply(sheen.split()[3], mask))
base = Image.alpha_composite(base, sheen)

ImageDraw.Draw(base).rounded_rectangle(
    [u(48), u(48), u(976), u(976)], radius=u(200), outline=BORDER, width=u(6))

def paste_center(img, cx, cy):
    base.alpha_composite(img, (int(cx - img.width / 2), int(cy - img.height / 2)))

def composite(img):
    global base
    base = Image.alpha_composite(base, img)

# --- back-facing bunny ears: splayed V, side by side, no overlap -------------
def make_ear():
    tw, th = u(150), u(366)
    tile = Image.new("RGBA", (tw, th), (0, 0, 0, 0))
    d = ImageDraw.Draw(tile)
    d.ellipse([0, 0, tw, th], fill=EAR)
    d.ellipse([u(12), int(th * 0.56), tw - u(12), th], fill=EAR_SHADOW)   # base shading
    d.ellipse([int(tw * 0.42), int(th * 0.10), int(tw * 0.58), int(th * 0.82)],
              fill=EAR_CREASE)                                            # fold crease
    return tile

ear = make_ear()
paste_center(ear.rotate(17,  expand=True, resample=Image.BICUBIC), u(430), u(304))
paste_center(ear.rotate(-17, expand=True, resample=Image.BICUBIC), u(594), u(304))

# --- shoulder straps: behind-the-bag portion (cresting above the top edge) ----
# Drawn now (behind the body) so the top loop reads as going OVER the top edge;
# the front tongue is drawn again on top of the body further down.
def make_strap(w, h, buckle_at=None):
    tile = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(tile)
    d.rounded_rectangle([0, 0, w, h], radius=int(w / 2), fill=STRAP)
    d.rounded_rectangle([0, 0, w, h], radius=int(w / 2), outline=STRAP_EDGE, width=u(4))
    if buckle_at is not None:
        by = int(h * buckle_at)
        d.rounded_rectangle([u(5), by, w - u(5), by + u(30)], radius=u(8), fill=BUCKLE)
    return tile

strap = make_strap(u(58), u(300), buckle_at=0.62)
left_strap  = strap.rotate(14,  expand=True, resample=Image.BICUBIC)
right_strap = strap.rotate(-14, expand=True, resample=Image.BICUBIC)
paste_center(left_strap,  u(372), u(446))
paste_center(right_strap, u(652), u(446))

# --- little feet peeking out the bottom (behind body) ------------------------
def foot(cx, cy):
    f = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    d = ImageDraw.Draw(f)
    d.ellipse([cx - u(50), cy - u(34), cx + u(50), cy + u(34)], fill=FOOT)
    d.ellipse([cx - u(26), cy - u(16), cx + u(26), cy + u(20)], fill=FOOT_PAD)
    return f

composite(foot(u(450), u(812)))
composite(foot(u(574), u(812)))

# --- backpack body -----------------------------------------------------------
draw = ImageDraw.Draw(base)
draw.rounded_rectangle([u(298), u(414), u(726), u(800)], radius=u(78), fill=BODY)

# lower-body shading (clipped to body)
low = Image.new("RGBA", (W, W), (0, 0, 0, 0))
ImageDraw.Draw(low).rounded_rectangle([u(298), u(600), u(726), u(800)], radius=u(78),
                                      fill=(*BODY_DK, 120))
lm = Image.new("L", (W, W), 0)
ImageDraw.Draw(lm).rounded_rectangle([u(298), u(414), u(726), u(800)], radius=u(78), fill=255)
low.putalpha(ImageChops.multiply(low.split()[3], lm))
composite(low)

# --- shoulder straps: front tongue over the top edge (on top of the body) ----
# A short segment of each strap sits on the bag front just below the top edge,
# so the strap visibly crosses the top edge (loop above + tongue below).
draw = ImageDraw.Draw(base)
for x0 in (u(346), u(622)):
    draw.rounded_rectangle([x0, u(420), x0 + u(56), u(560)], radius=u(28), fill=STRAP)
    draw.rounded_rectangle([x0, u(420), x0 + u(56), u(560)], radius=u(28),
                           outline=STRAP_EDGE, width=u(4))
    draw.rounded_rectangle([x0 + u(8), u(496), x0 + u(48), u(528)], radius=u(8), fill=BUCKLE)

# --- fold-over flap (WoW-default-style) --------------------------------------
draw.rounded_rectangle([u(338), u(404), u(686), u(580)], radius=u(64), fill=FLAP)
draw.rounded_rectangle([u(338), u(404), u(686), u(580)], radius=u(64),
                       outline=FLAP_EDGE, width=u(5))
# fold highlight near the top of the flap
draw.line([u(360), u(440), u(664), u(440)], fill=(248, 214, 130), width=u(4))

# --- central buckle strap over the flap --------------------------------------
draw.rounded_rectangle([u(482), u(408), u(542), u(640)], radius=u(16), fill=STRAP)
draw.rounded_rectangle([u(482), u(408), u(542), u(640)], radius=u(16),
                       outline=STRAP_EDGE, width=u(4))
# square buckle at the flap's bottom edge
draw.rounded_rectangle([u(470), u(548), u(554), u(624)], radius=u(16), fill=BUCKLE)
draw.rounded_rectangle([u(486), u(566), u(538), u(606)], radius=u(8), outline=PIN, width=u(4))

# --- export ------------------------------------------------------------------
import os
here = os.path.dirname(os.path.abspath(__file__))
for sz in (1024, 512, 256):
    base.resize((sz, sz), Image.LANCZOS).save(
        os.path.join(here, f"tbag-fufu-logo-{sz}.png"))
print("wrote tbag-fufu-logo-{1024,512,256}.png to", here)

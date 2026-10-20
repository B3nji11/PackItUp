"""Build every FriesGame icon and marketing image from code.

Diner Sticker style: flat fills, ink-brown outline, white sticker border,
solid ink-brown shadow offset down-right.

Usage (Python 3.9+, needs: pip install cairosvg pillow numpy scipy):
    python art/source/build_art.py

Writes:
    art/source/icons/<name>.svg   editable vector art (no sticker effect)
    art/icons/<name>.png          final 256x256 transparent icons, names per art/README.md
    art/marketing/game-icon.png   512x512; thumbnail-1..3.png 1920x1080
Fonts: Luckiest Guy must be installed (or set LUCKIEST_GUY_TTF) for the
marketing text and the "$" glyphs.
"""
import io
import math
import os

import cairosvg
import numpy as np
from PIL import Image, ImageDraw, ImageFont
from scipy import ndimage

HERE = os.path.dirname(os.path.abspath(__file__))
ART = os.path.dirname(HERE)
SRC_ICONS = os.path.join(HERE, "icons")
OUT_ICONS = os.path.join(ART, "icons")
OUT_MKT = os.path.join(ART, "marketing")

# ---- palette (README: Diner Sticker) ----
KETCHUP = "#e63946"
MUSTARD = "#ffb703"
TEAL = "#2a9d8f"
CREAM = "#fff4dc"
INK = "#3d1f1f"
WHITE = "#ffffff"
ORANGE = "#f77f00"
GRAPE = "#7b2cbf"
BLUEBERRY = "#1d6fd8"
TAN = "#b8a58c"
GOLD = "#e09f00"
FRY = "#ffd166"
FRY_DARK = "#f4a83a"
KRAFT = "#d9a066"
KRAFT_DARK = "#b98049"

SW = 9  # ink outline width in the 256 viewBox
S = f'stroke="{INK}" stroke-width="{SW}" stroke-linejoin="round" stroke-linecap="round"'


def svg(body):
    return (
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" '
        'width="256" height="256">' + body + "</svg>"
    )


def dollar(x, y, size, fill=CREAM):
    # outline drawn as a wide stroke under the fill so it reads at small sizes
    t = (f'<text x="{x}" y="{y}" font-family="Luckiest Guy" font-size="{size}" '
         f'text-anchor="middle" dominant-baseline="central"')
    return (t + f' fill="{INK}" stroke="{INK}" stroke-width="{size*0.16:.1f}" '
            f'stroke-linejoin="round">$</text>' + t + f' fill="{fill}">$</text>')


def coin(cx, cy, r):
    return (
        f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="{MUSTARD}" {S}/>'
        f'<circle cx="{cx}" cy="{cy}" r="{r*0.74:.1f}" fill="{GOLD}" opacity="0.35"/>'
        f'<circle cx="{cx}" cy="{cy}" r="{r*0.74:.1f}" fill="none" stroke="{GOLD}" stroke-width="{r*0.07:.1f}"/>'
        f'<path d="M{cx-r*0.62:.1f},{cy-r*0.25:.1f} A{r*0.66:.1f},{r*0.66:.1f} 0 0 1 {cx-r*0.2:.1f},{cy-r*0.64:.1f}" '
        f'fill="none" stroke="{WHITE}" stroke-width="{r*0.11:.1f}" stroke-linecap="round" opacity="0.8"/>'
        + dollar(cx, cy + r * 0.04, r * 1.05)
    )


def fry(x, y, w, h, rot=0, face=False):
    cx, cy = x + w / 2, y + h / 2
    s = (f'<g transform="rotate({rot} {cx} {cy})">'
         f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{w*0.28:.1f}" fill="{FRY}" {S}/>'
         f'<rect x="{x+w*0.62:.1f}" y="{y+h*0.08:.1f}" width="{w*0.18:.1f}" height="{h*0.84:.1f}" rx="{w*0.09:.1f}" fill="{FRY_DARK}" opacity="0.55"/>')
    if face:
        ey = y + h * 0.34
        s += (f'<circle cx="{cx-w*0.17:.1f}" cy="{ey:.1f}" r="{w*0.08:.1f}" fill="{INK}"/>'
              f'<circle cx="{cx+w*0.17:.1f}" cy="{ey:.1f}" r="{w*0.08:.1f}" fill="{INK}"/>'
              f'<path d="M{cx-w*0.16:.1f},{ey+w*0.2:.1f} Q{cx},{ey+w*0.38:.1f} {cx+w*0.16:.1f},{ey+w*0.2:.1f}" '
              f'fill="none" stroke="{INK}" stroke-width="{max(3, w*0.07):.1f}" stroke-linecap="round"/>')
    return s + "</g>"


def fries_carton():
    fries = "".join([
        fry(70, 50, 30, 110, -12),
        fry(150, 46, 30, 110, 12),
        fry(96, 30, 30, 120, -4),
        fry(126, 34, 30, 118, 5),
        fry(110, 58, 30, 100, 0),
    ])
    carton = (
        f'<path d="M52,112 Q128,136 204,112 L184,222 Q128,236 72,222 Z" fill="{KETCHUP}" {S}/>'
        f'<path d="M66,140 Q128,160 190,140" fill="none" stroke="{CREAM}" stroke-width="10" stroke-linecap="round"/>'
        f'<path d="M78,206 Q128,218 178,206" fill="none" stroke="#b5222e" stroke-width="8" stroke-linecap="round" opacity="0.6"/>'
        f'<circle cx="128" cy="180" r="17" fill="{MUSTARD}" {S}/>'
    )
    return fries + carton


def paper_bag(x=52, y=88, w=152, h=136, fries_out=True, tag=True):
    r = x + w
    b = y + h
    zig = " ".join(f"L{x + i * w / 8:.1f},{y + (0 if i % 2 == 0 else 10)}" for i in range(9))
    s = ""
    if fries_out:
        s += fry(x + w * 0.22, y - 52, 26, 84, -14) + fry(x + w * 0.5, y - 62, 26, 92, 6) + fry(x + w * 0.66, y - 44, 26, 80, 18)
    s += (f'<path d="M{x},{y} {zig} L{r},{b-12} Q{r},{b} {r-12},{b} L{x+12},{b} Q{x},{b} {x},{b-12} Z" fill="{KRAFT}" {S}/>'
          f'<path d="M{x+w*0.06:.1f},{y+24} L{r-w*0.06:.1f},{y+24}" stroke="{KRAFT_DARK}" stroke-width="6" stroke-linecap="round" stroke-dasharray="2 14"/>'
          f'<rect x="{r-w*0.2:.1f}" y="{y+22}" width="{w*0.08:.1f}" height="{h-36}" rx="5" fill="{KRAFT_DARK}" opacity="0.5"/>')
    if tag:
        cx, cy = x + w * 0.44, y + h * 0.6
        s += f'<circle cx="{cx:.1f}" cy="{cy:.1f}" r="34" fill="{TEAL}" {S}/>' + dollar(cx, cy + 2, 46)
    return s


def gear_path(cx, cy, teeth=8, ro=96, ri=74):
    pts = []
    step = 2 * math.pi / teeth
    for i in range(teeth):
        a = i * step
        for da, r in ((-0.30, ri), (-0.17, ro), (0.17, ro), (0.30, ri)):
            ang = a + da * step * 1.6
            pts.append((cx + r * math.cos(ang), cy + r * math.sin(ang)))
    return "M" + " L".join(f"{px:.1f},{py:.1f}" for px, py in pts) + " Z"


def arc_arrow(cx, cy, r, a0, a1, color, width=34):
    p0 = (cx + r * math.cos(math.radians(a0)), cy + r * math.sin(math.radians(a0)))
    p1 = (cx + r * math.cos(math.radians(a1)), cy + r * math.sin(math.radians(a1)))
    large = 1 if (a1 - a0) % 360 > 180 else 0
    d = f"M{p0[0]:.1f},{p0[1]:.1f} A{r},{r} 0 {large} 1 {p1[0]:.1f},{p1[1]:.1f}"
    t = (-math.sin(math.radians(a1)), math.cos(math.radians(a1)))
    n = (math.cos(math.radians(a1)), math.sin(math.radians(a1)))
    hb = width * 0.95
    head = [
        (p1[0] + n[0] * hb, p1[1] + n[1] * hb),
        (p1[0] + t[0] * width * 1.25, p1[1] + t[1] * width * 1.25),
        (p1[0] - n[0] * hb, p1[1] - n[1] * hb),
    ]
    hp = "M" + " L".join(f"{x:.1f},{y:.1f}" for x, y in head) + " Z"
    under = f'<path d="{d}" fill="none" stroke="{INK}" stroke-width="{width+2*SW}"/>'
    arrow = f'<path d="{hp}" fill="{color}" {S}/>'
    over = f'<path d="{d}" fill="none" stroke="{color}" stroke-width="{width}"/>'
    return under, arrow, over


def star_path(cx, cy, ro, ri, points=5, rot=-90):
    pts = []
    for i in range(points * 2):
        r = ro if i % 2 == 0 else ri
        a = math.radians(rot + i * 180 / points)
        pts.append((cx + r * math.cos(a), cy + r * math.sin(a)))
    return "M" + " L".join(f"{x:.1f},{y:.1f}" for x, y in pts) + " Z"


def sparkle_path(cx, cy, r, k=0.22):
    # four-point sparkle with concave sides
    return (f"M{cx},{cy-r} Q{cx+r*k},{cy-r*k} {cx+r},{cy} Q{cx+r*k},{cy+r*k} {cx},{cy+r} "
            f"Q{cx-r*k},{cy+r*k} {cx-r},{cy} Q{cx-r*k},{cy-r*k} {cx},{cy-r} Z")


def thick_line(d, color, width=30):
    return (f'<path d="{d}" fill="none" stroke="{INK}" stroke-width="{width+2*SW}" stroke-linecap="round" stroke-linejoin="round"/>'
            f'<path d="{d}" fill="none" stroke="{color}" stroke-width="{width}" stroke-linecap="round" stroke-linejoin="round"/>')


# ---------------- icons ----------------
ICONS = {}

ICONS["currency_cash"] = coin(128, 128, 96)

ICONS["currency_gem"] = (
    f'<path d="M60,96 L98,52 L158,52 L196,96 L128,212 Z" fill="#9d4edd" {S}/>'
    f'<path d="M60,96 L196,96" fill="none" {S}/>'
    f'<path d="M98,52 L112,96 L128,212 L144,96 L158,52" fill="none" stroke="{INK}" stroke-width="5" stroke-linejoin="round" opacity="0.55"/>'
    f'<path d="M98,52 L112,96 L64,96 Z" fill="#c77dff"/>'
    f'<path d="M112,96 L144,96 L128,58 Z" fill="#e0aaff"/>'
    f'<path d="M144,96 L196,96 L128,212 Z" fill="{GRAPE}" opacity="0.85"/>'
    f'<path d="M60,96 L98,52 L158,52 L196,96 L128,212 Z" fill="none" {S}/>'
    f'<path d="M86,110 L114,170" stroke="{WHITE}" stroke-width="9" stroke-linecap="round" opacity="0.75"/>'
)

ICONS["action_pack"] = fries_carton()
ICONS["action_sell"] = paper_bag()

ICONS["menu_upgrades"] = (
    f'<path d="M128,28 L216,122 L164,122 L164,222 L92,222 L92,122 L40,122 Z" fill="{ORANGE}" {S}/>'
    f'<path d="M106,132 L106,206" stroke="#ffb15c" stroke-width="12" stroke-linecap="round"/>'
    f'<path d="M80,106 L126,56" stroke="#ffb15c" stroke-width="12" stroke-linecap="round"/>'
)

_u1, _a1, _o1 = arc_arrow(128, 128, 74, 195, 325, GRAPE)
_u2, _a2, _o2 = arc_arrow(128, 128, 74, 15, 145, GRAPE)
ICONS["menu_rebirth"] = (
    _u1 + _u2 + _a1 + _a2 + _o1 + _o2
    + f'<path d="{sparkle_path(128, 128, 30)}" fill="{MUSTARD}" {S}/>'
)

_caps = "".join(
    f'<circle cx="{x}" cy="{y}" r="15" fill="{c}" stroke="{INK}" stroke-width="5"/>'
    f'<path d="M{x-15},{y} L{x+15},{y}" stroke="{INK}" stroke-width="4"/>'
    for x, y, c in [(96, 108, KETCHUP), (128, 116, MUSTARD), (160, 106, BLUEBERRY),
                    (110, 82, GRAPE), (146, 80, TEAL), (126, 56, KETCHUP)]
)
ICONS["menu_spin"] = (
    f'<rect x="112" y="18" width="32" height="20" rx="6" fill="{KETCHUP}" {S}/>'
    f'<circle cx="128" cy="96" r="64" fill="#e6f6ff"/>'
    + _caps
    + f'<circle cx="128" cy="96" r="64" fill="none" {S}/>'
    f'<path d="M92,64 A44,44 0 0 1 120,46" fill="none" stroke="{WHITE}" stroke-width="10" stroke-linecap="round"/>'
    f'<rect x="56" y="132" width="144" height="92" rx="18" fill="{TEAL}" {S}/>'
    f'<rect x="56" y="132" width="144" height="16" fill="{INK}" opacity="0.18"/>'
    f'<circle cx="128" cy="172" r="21" fill="{MUSTARD}" {S}/>'
    f'<path d="M116,172 L140,172" stroke="{INK}" stroke-width="7" stroke-linecap="round"/>'
    f'<rect x="102" y="200" width="52" height="14" rx="7" fill="{INK}"/>'
)

ICONS["menu_pets"] = "".join(
    f'<ellipse cx="{x}" cy="{y}" rx="{rx}" ry="{ry}" transform="rotate({r} {x} {y})" fill="{BLUEBERRY}" {S}/>'
    f'<ellipse cx="{x-rx*0.3:.1f}" cy="{y-ry*0.35:.1f}" rx="{rx*0.25:.1f}" ry="{ry*0.2:.1f}" transform="rotate({r} {x} {y})" fill="{WHITE}" opacity="0.6"/>'
    for x, y, rx, ry, r in [(62, 112, 22, 30, -25), (102, 66, 24, 32, -8), (154, 66, 24, 32, 8), (194, 112, 22, 30, 25)]
) + (
    f'<path d="M128,124 C168,124 202,170 196,198 C190,226 158,214 128,214 C98,214 66,226 60,198 C54,170 88,124 128,124 Z" fill="{BLUEBERRY}" {S}/>'
    f'<path d="M96,158 Q110,140 128,138" fill="none" stroke="{WHITE}" stroke-width="10" stroke-linecap="round" opacity="0.6"/>'
)

ICONS["menu_settings"] = (
    f'<path d="{gear_path(128, 128)}" fill="{TAN}" {S}/>'
    f'<circle cx="128" cy="128" r="56" fill="none" stroke="#a08a6c" stroke-width="10"/>'
    f'<circle cx="128" cy="128" r="30" fill="{CREAM}" {S}/>'
    f'<path d="M78,98 A58,58 0 0 1 106,74" fill="none" stroke="{WHITE}" stroke-width="10" stroke-linecap="round" opacity="0.7"/>'
)

ICONS["menu_home"] = (
    f'<rect x="160" y="50" width="24" height="44" rx="4" fill="{KETCHUP}" {S}/>'
    f'<rect x="58" y="108" width="140" height="112" rx="10" fill="{CREAM}" {S}/>'
    f'<path d="M108,220 L108,176 A20,20 0 0 1 148,176 L148,220 Z" fill="{MUSTARD}" {S}/>'
    f'<path d="M36,122 L128,40 L220,122 Z" fill="{KETCHUP}" {S}/>'
    f'<path d="M70,112 L128,62" stroke="#ff7b86" stroke-width="10" stroke-linecap="round"/>'
)

_cursor = [(0, 0), (0, 92), (24, 70), (40, 104), (58, 96), (42, 64), (74, 62)]
_cpts = " L".join(f"{126 + x},{104 + y}" for x, y in _cursor)
ICONS["upgrade_fries_per_click"] = (
    fry(66, 30, 46, 156, -22)
    + f'<path d="M{_cpts} Z" fill="{WHITE}" {S}/>'
    + "".join(f'<path d="M{x1},{y1} L{x2},{y2}" stroke="{INK}" stroke-width="10" stroke-linecap="round"/>'
              for x1, y1, x2, y2 in [(134, 86, 138, 68), (150, 96, 164, 86), (118, 84, 112, 70)])
    + f'<path d="M182,40 L182,84 M160,62 L204,62" stroke="{INK}" stroke-width="30" stroke-linecap="round"/>'
    f'<path d="M182,40 L182,84 M160,62 L204,62" stroke="{MUSTARD}" stroke-width="14" stroke-linecap="round"/>'
)

ICONS["upgrade_money_per_fry"] = fry(56, 26, 52, 172, -14) + coin(164, 162, 62)

ICONS["upgrade_bag_capacity"] = (
    paper_bag(40, 70, 140, 152, fries_out=True, tag=False)
    + "".join(f'<path d="M66,{y} L150,{y}" stroke="{KRAFT_DARK}" stroke-width="7" stroke-linecap="round" stroke-dasharray="1 16"/>'
              for y in (150, 180))
    + f'<circle cx="186" cy="90" r="40" fill="{TEAL}" {S}/>'
    f'<path d="M186,70 L186,110 M166,90 L206,90" stroke="{WHITE}" stroke-width="13" stroke-linecap="round"/>'
)

ICONS["badge_close"] = (
    f'<circle cx="128" cy="128" r="98" fill="{KETCHUP}" {S}/>'
    + thick_line("M90,90 L166,166 M166,90 L90,166", WHITE, 30)
)

ICONS["badge_equipped"] = (
    f'<circle cx="128" cy="128" r="98" fill="{TEAL}" {S}/>'
    + thick_line("M80,132 L114,166 L178,94", WHITE, 30)
)

ICONS["badge_golden"] = (
    f'<path d="{sparkle_path(116, 136, 96, 0.2)}" fill="{MUSTARD}" {S}/>'
    f'<path d="{sparkle_path(116, 136, 46, 0.2)}" fill="{WHITE}" opacity="0.55"/>'
    f'<path d="{sparkle_path(196, 60, 36, 0.22)}" fill="{MUSTARD}" {S}/>'
    f'<circle cx="200" cy="192" r="14" fill="{MUSTARD}" {S}/>'
)

# White fill on purpose: tint it per rarity in Roblox with ImageColor3.
ICONS["badge_rarity_star"] = (
    f'<path d="{star_path(128, 134, 104, 48)}" fill="{WHITE}" {S}/>'
    f'<path d="M92,118 L112,104" stroke="#d9d0c4" stroke-width="9" stroke-linecap="round"/>'
)


# ---------------- sticker compositing ----------------
def hex_rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def render_svg(body_svg, px):
    png = cairosvg.svg2png(bytestring=body_svg.encode(), output_width=px, output_height=px)
    return Image.open(io.BytesIO(png)).convert("RGBA")


def sticker(art, size, border, shadow, margin):
    """Fit art into size x size with a white border and an ink shadow."""
    bbox = art.getbbox()
    art = art.crop(bbox)
    avail = size - 2 * (border + margin) - shadow
    scale = min(avail / art.width, avail / art.height)
    art = art.resize((max(1, round(art.width * scale)), max(1, round(art.height * scale))), Image.LANCZOS)
    layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    ox = (size - art.width - shadow) // 2
    oy = (size - art.height - shadow) // 2
    layer.alpha_composite(art, (ox, oy))
    a = np.array(layer.split()[3]) > 8
    dist = ndimage.distance_transform_edt(~a)
    halo = np.clip(border + 1.0 - dist, 0, 1)  # anti-aliased dilation
    halo_a = Image.fromarray((halo * 255).astype(np.uint8))
    out = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    shadow_img = Image.new("RGBA", (size, size), hex_rgb(INK) + (0,))
    shadow_img.putalpha(halo_a)
    out.alpha_composite(shadow_img, (shadow, shadow))
    white = Image.new("RGBA", (size, size), (255, 255, 255, 0))
    white.putalpha(halo_a)
    out.alpha_composite(white)
    out.alpha_composite(layer)
    return out


# Final file names, exactly as listed in art/README.md
FILE_NAMES = {
    "currency_cash": "cash", "currency_gem": "gem",
    "action_pack": "fries", "action_sell": "bag",
    "menu_upgrades": "upgrades", "menu_rebirth": "rebirth", "menu_spin": "spin",
    "menu_pets": "pets", "menu_settings": "settings", "menu_home": "home",
    "upgrade_fries_per_click": "upgrade-fries-per-click",
    "upgrade_money_per_fry": "upgrade-money-per-fry",
    "upgrade_bag_capacity": "upgrade-bag-capacity",
    "badge_close": "close", "badge_equipped": "check",
    "badge_golden": "sparkle", "badge_rarity_star": "star",
}


def icon_image(name, size=256):
    hi = size * 4
    art = render_svg(svg(ICONS[name]), hi)
    # README: keep 16 px (at 256) of empty margin outside the sticker border and shadow
    big = sticker(art, hi, border=round(hi * 0.022), shadow=round(hi * 0.028), margin=round(hi * 19 / 256))
    return big.resize((size, size), Image.LANCZOS)


# ---------------- marketing ----------------
def font_path():
    env = os.environ.get("LUCKIEST_GUY_TTF")
    if env:
        return env
    for d in [os.path.expanduser("~/.fonts"), "/usr/share/fonts", os.path.expanduser("~/Library/Fonts"),
              "C:/Windows/Fonts"]:
        for root, _, files in os.walk(d):
            for f in files:
                if f.lower().startswith("luckiestguy") and f.lower().endswith(".ttf"):
                    return os.path.join(root, f)
    raise SystemExit("Luckiest Guy TTF not found; set LUCKIEST_GUY_TTF")


def burst_bg(w, h, c1, c2, cx, cy, rays=24):
    img = Image.new("RGBA", (w, h), hex_rgb(c1) + (255,))
    d = ImageDraw.Draw(img)
    R = math.hypot(w, h)
    for i in range(rays):
        if i % 2:
            continue
        a0 = 2 * math.pi * i / rays
        a1 = 2 * math.pi * (i + 1) / rays
        d.polygon([(cx, cy), (cx + R * math.cos(a0), cy + R * math.sin(a0)),
                   (cx + R * math.cos(a1), cy + R * math.sin(a1))], fill=hex_rgb(c2) + (255,))
    return img


def checker(img, y, cell, c1=KETCHUP, c2=CREAM, rows=2):
    d = ImageDraw.Draw(img)
    for r in range(rows):
        for i in range(img.width // cell + 1):
            c = c1 if (i + r) % 2 == 0 else c2
            d.rectangle([i * cell, y + r * cell, (i + 1) * cell, y + (r + 1) * cell], fill=hex_rgb(c))
    d.rectangle([0, y - 6, img.width, y], fill=hex_rgb(INK))
    d.rectangle([0, y + rows * cell, img.width, y + rows * cell + 6], fill=hex_rgb(INK))


def sticker_text(img, xy, text, size, fill=WHITE, anchor="la", rot=0):
    f = ImageFont.truetype(font_path(), size)
    pad = size
    tmp_d = ImageDraw.Draw(Image.new("RGBA", (1, 1)))
    l, t, r, b = tmp_d.textbbox((0, 0), text, font=f, stroke_width=round(size * 0.1))
    layer = Image.new("RGBA", (r - l + 2 * pad, b - t + 2 * pad), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    sh = round(size * 0.09)
    sw = round(size * 0.1)
    d.text((pad - l + sh, pad - t + sh), text, font=f, fill=hex_rgb(INK), stroke_width=sw, stroke_fill=hex_rgb(INK))
    d.text((pad - l, pad - t), text, font=f, fill=hex_rgb(fill), stroke_width=sw, stroke_fill=hex_rgb(INK))
    if rot:
        layer = layer.rotate(rot, resample=Image.BICUBIC, expand=True)
    w, h = layer.size
    x, y = xy
    if anchor == "mm":
        x, y = x - w // 2, y - h // 2
    else:
        x, y = x - pad, y - pad
    img.alpha_composite(layer, (int(x), int(y)))


def place(img, name_or_svg, size, cx, cy, rot=0):
    if name_or_svg in ICONS:
        body = ICONS[name_or_svg]
    else:
        body = name_or_svg
    hi = size * 2
    art = render_svg(svg(body), hi)
    st = sticker(art, hi, border=round(hi * 0.022), shadow=round(hi * 0.028), margin=round(hi * 0.01))
    st = st.resize((size, size), Image.LANCZOS)
    if rot:
        st = st.rotate(rot, resample=Image.BICUBIC, expand=True)
    img.alpha_composite(st, (int(cx - st.width / 2), int(cy - st.height / 2)))


FRY_BUDDY = fry(88, 28, 80, 200, 0, face=True)
FRY_BUDDY_TILT = fry(88, 28, 80, 200, -10, face=True)
BAG_FULL = paper_bag(46, 92, 164, 132, fries_out=True, tag=True)


def game_icon():
    W = 512
    img = burst_bg(W, W, KETCHUP, "#ef5a64", W / 2, W / 2)
    place(img, BAG_FULL, 380, 256, 300)
    place(img, "action_pack", 200, 140, 150, rot=18)
    place(img, "currency_cash", 130, 400, 120, rot=-12)
    place(img, "badge_golden", 90, 410, 420)
    return img.convert("RGB")


def thumb_title():
    W, H = 1920, 1080
    img = burst_bg(W, H, KETCHUP, "#ef5a64", 1380, 560, rays=32)
    checker(img, H - 120, 60)
    sticker_text(img, (110, 150), "PUT THE", 150, CREAM, rot=3)
    sticker_text(img, (110, 330), "FRIES", 260, MUSTARD, rot=3)
    sticker_text(img, (110, 600), "IN THE BAG!", 170, CREAM, rot=3)
    place(img, BAG_FULL, 620, 1420, 600)
    place(img, "action_pack", 360, 1120, 300, rot=16)
    place(img, FRY_BUDDY_TILT, 300, 1760, 330, rot=-8)
    for x, y, s, r in [(1060, 880, 180, -10), (1800, 790, 160, 14), (1250, 930, 120, 6)]:
        place(img, "currency_cash", s, x, y, rot=r)
    return img.convert("RGB")


def thumb_pets():
    W, H = 1920, 1080
    img = burst_bg(W, H, TEAL, "#36b3a4", 560, 560, rays=32)
    checker(img, H - 120, 60, TEAL, CREAM)
    place(img, "menu_spin", 640, 560, 520)
    sticker_text(img, (1050, 170), "SPIN FOR", 160, CREAM, rot=-3)
    sticker_text(img, (1050, 360), "PETS!", 300, MUSTARD, rot=-3)
    place(img, FRY_BUDDY, 250, 1230, 850, rot=8)
    place(img, FRY_BUDDY_TILT, 250, 1500, 850, rot=-6)
    place(img, "badge_golden", 170, 1770, 840)
    for x, y, r in [(170, 200, 8), (950, 170, -10)]:
        place(img, "badge_rarity_star", 120, x, y, rot=r)
    place(img, "menu_pets", 160, 1010, 870, rot=12)
    return img.convert("RGB")


def thumb_rebirth():
    W, H = 1920, 1080
    img = burst_bg(W, H, GRAPE, "#8f3fd6", 1400, 520, rays=32)
    checker(img, H - 120, 60, GRAPE, CREAM)
    sticker_text(img, (110, 160), "REBIRTH", 230, CREAM, rot=2)
    sticker_text(img, (110, 420), "FOR GEMS!", 190, MUSTARD, rot=2)
    sticker_text(img, (120, 660), "UPGRADE FOREVER", 100, CREAM, rot=2)
    place(img, "menu_rebirth", 560, 1400, 500)
    for x, y, s, r in [(1080, 820, 200, -12), (1760, 800, 220, 10), (1700, 220, 160, 14), (1120, 230, 140, -16)]:
        place(img, "currency_gem", s, x, y, rot=r)
    place(img, "menu_upgrades", 220, 1420, 880)
    return img.convert("RGB")


def main():
    for d in (SRC_ICONS, OUT_ICONS, OUT_MKT):
        os.makedirs(d, exist_ok=True)
    for name, body in ICONS.items():
        out = FILE_NAMES[name]
        with open(os.path.join(SRC_ICONS, out + ".svg"), "w", encoding="utf-8") as f:
            f.write(svg(body))
        icon_image(name).save(os.path.join(OUT_ICONS, out + ".png"), optimize=True)
        print("icon", out)
    game_icon().save(os.path.join(OUT_MKT, "game-icon.png"), optimize=True)
    thumb_title().save(os.path.join(OUT_MKT, "thumbnail-1.png"), optimize=True)
    thumb_pets().save(os.path.join(OUT_MKT, "thumbnail-2.png"), optimize=True)
    thumb_rebirth().save(os.path.join(OUT_MKT, "thumbnail-3.png"), optimize=True)
    print("marketing done")


if __name__ == "__main__":
    main()

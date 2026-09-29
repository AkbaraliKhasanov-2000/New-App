#!/usr/bin/env python3
"""Generates the Scanlet app icon (light, dark and tinted variants).

Usage: python3 tools/make_icon.py   (requires Pillow)
"""
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

SIZE = 1024
OUT = Path(__file__).resolve().parent.parent / "Scanlet/Resources/Assets.xcassets/AppIcon.appiconset"


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def gradient(top, bottom):
    img = Image.new("RGB", (SIZE, SIZE))
    px = img.load()
    for y in range(SIZE):
        for x in range(SIZE):
            t = (x * 0.35 + y * 0.65) / SIZE
            px[x, y] = lerp(top, bottom, min(1, max(0, t)))
    return img


def make(top, bottom, beam_color, paper=(255, 255, 255), line=(186, 196, 236), fold=(205, 214, 255), glow=True):
    background = gradient(top, bottom)
    img = background.convert("RGBA")

    if glow:
        layer = Image.new("RGBA", (SIZE, SIZE), (255, 255, 255, 0))
        ImageDraw.Draw(layer).ellipse((180, 120, 860, 800), fill=(255, 255, 255, 55))
        img = Image.alpha_composite(img, layer.filter(ImageFilter.GaussianBlur(120)))

    # Paper shadow.
    shadow = Image.new("RGBA", (SIZE, SIZE), (10, 10, 60, 0))
    ImageDraw.Draw(shadow).rounded_rectangle((300, 248, 724, 828), radius=44, fill=(10, 10, 60, 110))
    img = Image.alpha_composite(img, shadow.filter(ImageFilter.GaussianBlur(30)))

    # Paper with a folded top-right corner.
    x0, y0, x1, y1, f = 300, 210, 724, 790, 110
    backdrop = img.copy()
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle((x0, y0, x1, y1), radius=40, fill=paper + (255,))
    mask = Image.new("L", (SIZE, SIZE), 0)
    ImageDraw.Draw(mask).polygon([(x1 - f, y0 - 2), (x1 + 3, y0 - 2), (x1 + 3, y0 + f)], fill=255)
    img.paste(backdrop, (0, 0), mask)
    draw = ImageDraw.Draw(img)
    draw.polygon([(x1 - f, y0), (x1 - f, y0 + f - 16), (x1 - f + 16, y0 + f), (x1, y0 + f)], fill=fold + (255,))

    # Text lines.
    for yy, w in zip([330, 400, 470, 540, 610, 680], [250, 330, 300, 330, 220, 280]):
        draw.rounded_rectangle((x0 + 60, yy, x0 + 60 + w, yy + 26), radius=13, fill=line + (255,))

    # Scan beam with a colored glow (transparent pixels share the beam color to avoid gray halos).
    beam = Image.new("RGBA", (SIZE, SIZE), beam_color + (0,))
    ImageDraw.Draw(beam).rounded_rectangle((230, 500, 794, 528), radius=14, fill=beam_color + (255,))
    halo = Image.new("RGBA", (SIZE, SIZE), beam_color + (0,))
    ImageDraw.Draw(halo).rounded_rectangle((230, 490, 794, 538), radius=24, fill=beam_color + (150,))
    img = Image.alpha_composite(img, halo.filter(ImageFilter.GaussianBlur(24)))
    img = Image.alpha_composite(img, beam)

    # Viewfinder brackets.
    draw = ImageDraw.Draw(img)
    thickness, length, margin, radius = 34, 120, 150, 17
    for cx, cy, sx, sy in [(margin, margin, 1, 1), (SIZE - margin, margin, -1, 1),
                           (margin, SIZE - margin, 1, -1), (SIZE - margin, SIZE - margin, -1, -1)]:
        draw.rounded_rectangle((min(cx, cx + sx * length), cy if sy > 0 else cy - thickness,
                                max(cx, cx + sx * length), cy + thickness if sy > 0 else cy), radius=radius, fill="white")
        draw.rounded_rectangle((cx if sx > 0 else cx - thickness, min(cy, cy + sy * length),
                                cx + thickness if sx > 0 else cx, max(cy, cy + sy * length)), radius=radius, fill="white")
    return img.convert("RGB")


if __name__ == "__main__":
    OUT.mkdir(parents=True, exist_ok=True)
    make((92, 120, 255), (40, 36, 190), (80, 230, 255)).save(OUT / "AppIcon.png")
    make((38, 44, 104), (12, 12, 40), (80, 230, 255), paper=(236, 238, 250), glow=False).save(OUT / "AppIcon-Dark.png")
    tinted = make((70, 70, 70), (20, 20, 20), (235, 235, 235), paper=(235, 235, 235), line=(150, 150, 150), fold=(190, 190, 190), glow=False)
    tinted.convert("L").convert("RGB").save(OUT / "AppIcon-Tinted.png")
    print("Icons written to", OUT)

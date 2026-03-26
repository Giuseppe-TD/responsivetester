#!/usr/bin/env python3
"""
Genera AppIcon.appiconset per DevicePreviewer.
Design: sfondo blu scuro, tre sagome di telefoni bianchi in prospettiva.
"""
import os, json, math
from PIL import Image, ImageDraw, ImageFilter

SIZES = [16, 32, 64, 128, 256, 512, 1024]

OUT = "DevicePreviewer/Assets.xcassets/AppIcon.appiconset"
os.makedirs(OUT, exist_ok=True)


def draw_phone_shape(draw, cx, cy, w, h, fill, alpha=255, corner_frac=0.18):
    r = max(2, int(w * corner_frac))
    x0, y0 = int(cx - w / 2), int(cy - h / 2)
    x1, y1 = int(cx + w / 2), int(cy + h / 2)
    color = fill + (alpha,) if len(fill) == 3 else fill
    draw.rounded_rectangle([x0, y0, x1, y1], radius=r, fill=color)
    # schermo
    m  = max(1, int(w * 0.13))
    mt = max(1, int(h * 0.12))
    mb = max(1, int(h * 0.08))
    sr = max(1, int(r * 0.45))
    screen_color = (15, 20, 50, 255)
    draw.rounded_rectangle([x0+m, y0+mt, x1-m, y1-mb], radius=sr, fill=screen_color)
    # dynamic island
    if w > 18:
        pw = max(2, int(w * 0.28))
        ph = max(1, int(h * 0.025))
        px = cx
        py = y0 + mt - ph * 2
        if py > y0 + 2:
            draw.rounded_rectangle(
                [int(px - pw/2), py, int(px + pw/2), py + ph],
                radius=ph // 2, fill=(5, 8, 20, 255)
            )


def create_icon(size: int) -> Image.Image:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))

    # ── Sfondo gradiente navy ──────────────────────────────────────
    bg = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    bg_draw = ImageDraw.Draw(bg)
    for y in range(size):
        t   = y / size
        col = (
            int(10  + t * 6),
            int(16  + t * 14),
            int(42  + t * 28),
            255,
        )
        bg_draw.line([(0, y), (size - 1, y)], fill=col)

    # Arrotonda angoli sfondo
    mask = Image.new("L", (size, size), 0)
    md   = ImageDraw.Draw(mask)
    cr   = int(size * 0.225)
    md.rounded_rectangle([0, 0, size - 1, size - 1], radius=cr, fill=255)
    bg.putalpha(mask)
    img.paste(bg, mask=bg)

    draw = ImageDraw.Draw(img)

    s  = size
    cx = s // 2
    cy = int(s * 0.52)

    # ── Telefono centrale ──────────────────────────────────────────
    pw_c = int(s * 0.30)
    ph_c = int(s * 0.56)
    draw_phone_shape(draw, cx, cy, pw_c, ph_c, (255, 255, 255), alpha=230)

    # ── Telefono sinistro (più piccolo, arretrato) ─────────────────
    pw_l = int(s * 0.21)
    ph_l = int(s * 0.40)
    draw_phone_shape(draw, cx - int(s * 0.24), cy + int(s * 0.05),
                     pw_l, ph_l, (160, 185, 255), alpha=170)

    # ── Telefono destro (medio, arretrato) ────────────────────────
    pw_r = int(s * 0.24)
    ph_r = int(s * 0.46)
    draw_phone_shape(draw, cx + int(s * 0.25), cy + int(s * 0.03),
                     pw_r, ph_r, (180, 200, 255), alpha=180)

    # ── Lieve vignetta sui bordi ──────────────────────────────────
    vignette = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    vd = ImageDraw.Draw(vignette)
    vd.rounded_rectangle([0, 0, s-1, s-1], radius=cr,
                          fill=(0, 0, 0, 0), outline=(0, 0, 0, 60), width=int(s * 0.06))
    img = Image.alpha_composite(img, vignette)

    return img


# ── Genera tutte le dimensioni ─────────────────────────────────────
contents_images = []

mappings = {
    16:   [("mac", "1x", "16x16")],
    32:   [("mac", "2x", "16x16"), ("mac", "1x", "32x32")],
    64:   [("mac", "2x", "32x32")],
    128:  [("mac", "1x", "128x128")],
    256:  [("mac", "2x", "128x128"), ("mac", "1x", "256x256")],
    512:  [("mac", "2x", "256x256"), ("mac", "1x", "512x512")],
    1024: [("mac", "2x", "512x512")],
}

for sz in SIZES:
    icon = create_icon(sz)
    fname = f"icon_{sz}.png"
    icon.save(os.path.join(OUT, fname))
    for idiom, scale, size_str in mappings.get(sz, []):
        contents_images.append({
            "filename": fname,
            "idiom":    idiom,
            "scale":    scale,
            "size":     size_str,
        })

contents = {
    "images": contents_images,
    "info":   {"author": "xcode", "version": 1},
}
with open(os.path.join(OUT, "Contents.json"), "w") as f:
    json.dump(contents, f, indent=2)

print(f"✓ AppIcon generata in {OUT}  ({len(SIZES)} dimensioni)")

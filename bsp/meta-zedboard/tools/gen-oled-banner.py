#!/usr/bin/env python3
"""Generate the ZedBoard OLED banner (512-byte SSD1306 frame).

The panel mirrors the image horizontally, so the bitmap is pre-flipped.
Requires Pillow; run on the build host:

    python3 gen-oled-banner.py line1 line2 > oled-banner.bin
"""
import sys
from PIL import Image, ImageDraw, ImageFont

W, H = 128, 32
FONT = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"


def pack(img):
    buf = bytearray()
    px = img.load()
    for page in range(4):
        for x in range(W):
            v = 0
            for r in range(8):
                if px[x, page * 8 + r]:
                    v |= 1 << r
            buf.append(v)
    return bytes(buf)


def render(line1, line2, size=16):
    img = Image.new("1", (W, H), 0)
    d = ImageDraw.Draw(img)
    font = ImageFont.truetype(FONT, size)
    for txt, (y0, y1) in zip((line1, line2), ((0, 16), (16, 32))):
        bb = d.textbbox((0, 0), txt, font=font)
        w, h = bb[2] - bb[0], bb[3] - bb[1]
        d.text(((W - w) // 2 - bb[0], y0 + (y1 - y0 - h) // 2 - bb[1]),
               txt, fill=1, font=font)
    return img.transpose(Image.FLIP_LEFT_RIGHT)


if __name__ == "__main__":
    l1 = sys.argv[1] if len(sys.argv) > 1 else "openEuler"
    l2 = sys.argv[2] if len(sys.argv) > 2 else "Embedded"
    sys.stdout.buffer.write(pack(render(l1, l2)))
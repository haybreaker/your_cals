#!/usr/bin/env python3
"""
Thicken dark linework in an icon PNG.

Uses Pillow morphological operations to isolate dark lines,
dilate them, then composite back onto the original.
"""

import argparse
import sys
from pathlib import Path
from PIL import Image, ImageFilter


def thickened(input_path: str, output_path: str, thickness: float = 1.5):
    img = Image.open(input_path).convert("RGBA")
    w, h = img.size

    # 1. Extract the alpha channel and luminance
    r, g, b, a = img.split()
    gray = img.convert("L")

    # 2. Threshold to isolate dark linework (dark pixels become white in mask)
    #    Lines are the darkest elements — threshold at ~30% luminance
    threshold = 80
    mask = gray.point(lambda p: 255 if p < threshold else 0, mode="1")

    # 3. Dilate the mask to thicken the lines
    #    Use max filter (morphological dilation for binary images)
    dilate_radius = max(1, int(thickness))
    for _ in range(dilate_radius):
        mask = mask.filter(ImageFilter.MaxFilter(3))

    # 4. Smooth the dilated mask slightly to avoid jagged edges
    mask = mask.filter(ImageFilter.SMOOTH)

    # 5. Create a version with thicker dark lines:
    #    - For pixels where the mask is active (thickened area),
    #      use the original dark line color
    #    - For pixels where mask is inactive, keep original
    result = img.copy()

    # Get pixel data for processing
    img_pixels = img.load()
    mask_pixels = mask.load()
    result_pixels = result.load()

    # Find the dominant dark color (the line color)
    # Sample from known dark pixels in the original
    dark_colors = []
    for y in range(h):
        for x in range(w):
            if mask_pixels[x, y] > 128:
                # This is a dark pixel area
                p = img_pixels[x, y]
                if p[3] > 100:  # Non-transparent
                    dark_colors.append(p[:3])

    if not dark_colors:
        print("No dark linework found — saving unchanged.")
        img.save(output_path)
        return

    # Use median of dark colors as the line color
    dark_colors.sort(key=lambda c: sum(c))
    line_color = dark_colors[len(dark_colors) // 2]

    # 6. Composite: for thickened mask areas that weren't originally dark,
    #    paint with the line color (preserving alpha from original where possible)
    for y in range(h):
        for x in range(w):
            if mask_pixels[x, y] > 128:
                orig = img_pixels[x, y]
                was_already_dark = (orig[0] < threshold and orig[1] < threshold and orig[2] < threshold)
                if not was_already_dark and orig[3] > 20:
                    # This is a newly thickened area — paint with line color
                    # Keep original alpha
                    result_pixels[x, y] = (*line_color, orig[3])

    result.save(output_path)
    print(f"Saved thickened icon to {output_path}")
    print(f"  Input:  {input_path} ({w}x{h})")
    print(f"  Line color (median dark): {line_color}")
    print(f"  Thickness dilation: {dilate_radius}px")


def main():
    parser = argparse.ArgumentParser(description="Thicken dark linework in icon PNG")
    parser.add_argument("input", help="Input PNG path")
    parser.add_argument("-o", "--output", help="Output PNG path (default: input_thickened.png)")
    parser.add_argument("-t", "--thickness", type=float, default=1.5,
                        help="Extra thickness in pixels (default: 1.5)")
    args = parser.parse_args()

    input_path = Path(args.input)
    if not input_path.exists():
        print(f"Error: {input_path} not found", file=sys.stderr)
        sys.exit(1)

    output_path = args.output or str(input_path.with_stem(input_path.stem + "_thickened"))
    thickened(str(input_path), output_path, args.thickness)


if __name__ == "__main__":
    main()

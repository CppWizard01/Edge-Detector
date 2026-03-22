import numpy as np
import cv2
import sys

pixels = []

try:
    with open('output_image.hex', 'r') as f:
        for line in f:
            clean_line = line.strip()
            if clean_line:
                pixels.append(int(clean_line, 16))
except FileNotFoundError:
    print("Error: output_image.hex not found. Run the Icarus simulation first.")
    sys.exit(1)

expected_pixels = 124 * 124

if len(pixels) != expected_pixels:
    print(f"CRITICAL ERROR: Found {len(pixels)} pixels. Expected exactly {expected_pixels}.")
    sys.exit(1)

img_array = np.array(pixels, dtype=np.uint8).reshape((124, 124))
cv2.imwrite('edge_output.png', img_array)
print("Success! hardware_edge_output.png saved.")
import numpy as np
import cv2
import sys
import argparse
from pathlib import Path

def read_hex_to_image(hex_path: Path, output_path: Path, size: tuple = (124, 124)):
    if not hex_path.is_file():
        print(f"Error: Hex file '{hex_path}' not found. Run the Icarus simulation first.")
        sys.exit(1)

    pixels = []
    try:
        with open(hex_path, 'r') as f:
            for line in f:
                clean_line = line.strip()
                if clean_line:
                    pixels.append(int(clean_line, 16))
    except IOError as e:
        print(f"Error reading '{hex_path}': {e}")
        sys.exit(1)

    expected_pixels = size[0] * size[1]
    if len(pixels) != expected_pixels:
        print(f"CRITICAL ERROR: Found {len(pixels)} pixels. Expected exactly {expected_pixels} for a {size[0]}x{size[1]} image.")
        sys.exit(1)

    img_array = np.array(pixels, dtype=np.uint8).reshape(size)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    cv2.imwrite(str(output_path), img_array)
    print(f"Success! Hardware output image saved to '{output_path}'.")

def main():
    parser = argparse.ArgumentParser(description="Convert an RTL hex output file back to a PNG image.")
    parser.add_argument("--in_file", type=str, default="output_image.hex", help="Path to the input hex file (default: output_image.hex)")
    parser.add_argument("--out_file", type=str, default="edge_output.png", help="Path to save the output image (default: edge_output.png)")
    parser.add_argument("--size", type=int, default=124, help="Target resolution (default: 124 for 128x128 input dropping 4 pixels total)")

    args = parser.parse_args()

    input_path = Path(args.in_file)
    output_path = Path(args.out_file)

    read_hex_to_image(input_path, output_path, size=(args.size, args.size))

if __name__ == "__main__":
    main()
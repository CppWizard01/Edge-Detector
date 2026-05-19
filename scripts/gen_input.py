import cv2
import sys
import argparse
from pathlib import Path

def generate_hex(image_path: Path, output_dir: Path, size: tuple = (128, 128)):
    if not image_path.is_file():
        print(f"Error: Input file '{image_path}' does not exist.")
        sys.exit(1)

    img = cv2.imread(str(image_path), cv2.IMREAD_GRAYSCALE)
    if img is None:
        print(f"Error: OpenCV could not read '{image_path}'. Check file format.")
        sys.exit(1)

    img_resized = cv2.resize(img, size)

    output_dir.mkdir(parents=True, exist_ok=True)
    hex_filename = output_dir / f"{image_path.stem}.hex"

    try:
        with open(hex_filename, 'w') as f:
            for row in img_resized:
                for pixel in row:
                    f.write(f"{pixel:02X}\n")
        print(f"Success! Generated '{hex_filename}' ({size[0] * size[1]} lines).")
    except IOError as e:
        print(f"Error writing to '{hex_filename}': {e}")
        sys.exit(1)

def main():
    parser = argparse.ArgumentParser(description="Convert an image to a hex file for RTL testbenches.")
    parser.add_argument("input_image", type=str, help="Path to the input image (e.g., data/ip_img1.png)")
    parser.add_argument("--out_dir", type=str, default="data/hex", help="Directory to save the hex file (default: data/hex)")
    parser.add_argument("--size", type=int, default=128, help="Target resolution (default: 128 for 128x128)")

    args = parser.parse_args()

    input_path = Path(args.input_image)
    output_dir = Path(args.out_dir)

    generate_hex(input_path, output_dir, size=(args.size, args.size))

if __name__ == "__main__":
    main()
import cv2
import sys
import os

image_path = 'data/ip_img4.png' 
img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)

if img is None:
    print(f"Error: Could not load {image_path}. Check the file name.")
    sys.exit(1)

img_resized = cv2.resize(img, (128, 128))

# Extract the base name of the file (e.g., 'ip_img4' from 'data/ip_img4.png')
base_name = os.path.splitext(os.path.basename(image_path))[0]
hex_filename = f"{base_name}.hex"

# Write the hex file using the dynamic name
with open(hex_filename, 'w') as f:
    for row in img_resized:
        for pixel in row:
            f.write(f"{pixel:02X}\n")

print(f"Success! {hex_filename} generated from {image_path}. (16384 lines)")
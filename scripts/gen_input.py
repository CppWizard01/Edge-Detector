import cv2
import sys

image_path = 'data/input_image.png' 
img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)

if img is None:
    print(f"Error: Could not load {image_path}. Check the file name.")
    sys.exit(1)

img_resized = cv2.resize(img, (128, 128))

# Save it to the directory
cv2.imwrite('fpga_input_preview.png', img_resized)

# Write the hex file
with open('input_image.hex', 'w') as f:
    for row in img_resized:
        for pixel in row:
            f.write(f"{pixel:02X}\n")

print(f"Success! input_image.hex generated from {image_path}. (16384 lines)")
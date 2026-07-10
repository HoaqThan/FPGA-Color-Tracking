from PIL import Image
import os
import glob

# ==========================================
# Configuration
# ==========================================

WIDTH = 640
HEIGHT = 480

BASE_DIR = "C:/Image_Project"

INPUT_FOLDER = os.path.join(BASE_DIR, "input")
OUTPUT_FOLDER = os.path.join(BASE_DIR, "output")

MASK_FILE = os.path.join(OUTPUT_FOLDER, "threshold_out.txt")
RESULT_FILE = os.path.join(OUTPUT_FOLDER, "result.png")

# ==========================================
# Find Image Automatically
# ==========================================

image_files = (
    glob.glob(os.path.join(INPUT_FOLDER, "*.jpg")) +
    glob.glob(os.path.join(INPUT_FOLDER, "*.jpeg")) +
    glob.glob(os.path.join(INPUT_FOLDER, "*.png"))
)

if len(image_files) == 0:
    print("ERROR: No image found in input folder!")
    exit()

IMAGE_FILE = image_files[0]

print("--------------------------------")
print("Input Image :", IMAGE_FILE)
print("--------------------------------")

# ==========================================
# Load Original Image
# ==========================================

img = Image.open(IMAGE_FILE)

img = img.resize((WIDTH, HEIGHT))

# Chuyển sang ảnh trắng đen
gray_img = img.convert("L")

# ==========================================
# Read Threshold Mask
# ==========================================

with open(MASK_FILE, "r") as f:
    mask = f.readlines()

print("Mask Pixels :", len(mask))

# ==========================================
# Create Result Image
# ==========================================

result = Image.new("RGB", (WIDTH, HEIGHT))

index = 0

for y in range(HEIGHT):
    for x in range(WIDTH):

        if index >= len(mask):
            break

        gray = gray_img.getpixel((x, y))

        value = mask[index].strip()

        if value == "1":

            # Giữ nguyên độ sáng của vật thể
            result.putpixel((x, y), (gray, gray, gray))

        else:

            # Nền tối lại nhưng vẫn nhìn được
            dark = max(int(gray * 0.15), 20)

            result.putpixel((x, y), (dark, dark, dark))

        index += 1

# ==========================================
# Save Result
# ==========================================

os.makedirs(OUTPUT_FOLDER, exist_ok=True)

result.save(RESULT_FILE)

print("--------------------------------")
print("Restore Complete!")
print("Saved :", RESULT_FILE)
print("--------------------------------")
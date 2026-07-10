from PIL import Image
import os
import glob

# ==========================================================
# IMAGE TO RGB565 CONVERTER
# Author : Le Cuong Thinh
# Project : Color Tracking FPGA
# ==========================================================

# Thư mục chứa ảnh
INPUT_FOLDER = "input"
OUTPUT_FOLDER = "output"
# File output cho ModelSim
# Tạo thư mục output nếu chưa có
os.makedirs(OUTPUT_FOLDER, exist_ok=True)

# File output cho ModelSim
OUTPUT_FILE = os.path.join(OUTPUT_FOLDER, "image_rgb.txt")

# ==========================================================
# Tìm ảnh trong thư mục input
# ==========================================================

image_list = []

image_list.extend(glob.glob(os.path.join(INPUT_FOLDER, "*.jpg")))
image_list.extend(glob.glob(os.path.join(INPUT_FOLDER, "*.jpeg")))
image_list.extend(glob.glob(os.path.join(INPUT_FOLDER, "*.png")))

if len(image_list) == 0:
    print("ERROR: Không tìm thấy ảnh!")
    exit()

# Chỉ lấy ảnh đầu tiên
image_path = image_list[0]

print("Đang đọc:", image_path)

# ==========================================================
# Đọc ảnh
# ==========================================================

img = Image.open(image_path).convert("RGB")

# Luôn đưa ảnh về đúng kích thước VGA
img = img.resize((640, 480))

width, height = img.size

print(f"Kích thước: {width} x {height}")

# ==========================================================
# Tạo file output
# ==========================================================

out = open(OUTPUT_FILE, "w")

pixel_count = 0

# ==========================================================
# Đọc từng Pixel
# ==========================================================

for y in range(height):

    for x in range(width):

        r, g, b = img.getpixel((x, y))

        # RGB888 -> RGB565
        r5 = r >> 3
        g6 = g >> 2
        b5 = b >> 3

        rgb565 = (r5 << 11) | (g6 << 5) | b5

        # Ghi HEX 16-bit
        out.write(f"{rgb565:04X}\n")

        pixel_count += 1

out.close()

# ==========================================================
# Kết thúc
# ==========================================================

print("----------------------------------")
print("Convert thành công!")
print(f"Tổng pixel : {pixel_count}")
print(f"Đã tạo file: {OUTPUT_FILE}")
print("----------------------------------")
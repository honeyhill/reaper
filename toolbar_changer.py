import cv2
import numpy as np
import os

# Define the color mappings (BGR format for OpenCV)
color_map = {
    (234, 172, 23): (40, 40, 40),   # #17ACEA → #282828
    (249, 176, 0): (40, 40, 40),    # #00B0F9 → #282828
    (254, 219, 132): (90, 90, 90),  # #84DBFE → #5A5A5A
    (248, 221, 121): (80, 80, 80),  # #79DDF8 → #505050
    (249, 182, 88): (64, 64, 64),   # #58B6F9 → #404040
    (254, 185, 21): (40, 40, 40),   # #15B9FE → #282828
    (197, 160, 76): (56, 56, 56),   # #4CA0C5 → #383838
    (236, 203, 100): (212, 214, 220) # #64CBEC → #D4D6DC
}

# Folder containing PNG files
input_folder = "/Users/honeyhill/Library/CloudStorage/OneDrive-Persönlich/Dokumente/HONEYHILL/03_Business/02_Marketing/2023/Assets/Icons/old icons/"
output_folder = "/Users/honeyhill/Library/CloudStorage/OneDrive-Persönlich/Dokumente/HONEYHILL/03_Business/02_Marketing/2023/Assets/Icons/new icons/"

os.makedirs(output_folder, exist_ok=True)

# Loop through all PNG files
for filename in os.listdir(input_folder):
    if filename.endswith(".png"):
        img_path = os.path.join(input_folder, filename)
        img = cv2.imread(img_path, cv2.IMREAD_UNCHANGED)

        if img is None:
            print(f"Failed to load: {filename}")
            continue

        # Iterate through each pixel
        for old_color, new_color in color_map.items():
            mask = np.all(img[:, :, :3] == old_color, axis=-1)
            img[mask, :3] = new_color

        # Save the modified image
        output_path = os.path.join(output_folder, filename)
        cv2.imwrite(output_path, img)

        print(f"Processed: {filename}")

print("Batch processing completed!")

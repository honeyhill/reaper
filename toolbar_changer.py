import cv2
import numpy as np
import os

# Folder paths
input_folder = "/Users/honeyhill/Library/CloudStorage/OneDrive-Persönlich/Dokumente/HONEYHILL/03_Business/02_Marketing/2023/Assets/Icons/old icons/"
output_folder = "/Users/honeyhill/Library/CloudStorage/OneDrive-Persönlich/Dokumente/HONEYHILL/03_Business/02_Marketing/2023/Assets/Icons/new icons/"
background_on_path = "/Users/honeyhill/Library/CloudStorage/OneDrive-Persönlich/Dokumente/HONEYHILL/03_Business/02_Marketing/2023/Assets/Reaper Assets/background_off.png"
background_off_path = "/Users/honeyhill/Library/CloudStorage/OneDrive-Persönlich/Dokumente/HONEYHILL/03_Business/02_Marketing/2023/Assets/Reaper Assets/background_on.png"

os.makedirs(output_folder, exist_ok=True)

# Color map for first transformation
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

# Function to apply a color mapping transformation
def apply_color_map(image, color_map):
    for old_color, new_color in color_map.items():
        mask = np.all(image[:, :, :3] == old_color, axis=-1)
        image[mask, :3] = new_color
    return image

# Function to invert icon colors
def invert_colors(image):
    inverted = image.copy()
    inverted[:, :, :3] = 255 - inverted[:, :, :3]  # Invert RGB channels only
    return inverted

# Function to overlay an icon onto a background
def overlay_icon(base, overlay):
    h, w, _ = overlay.shape
    base_resized = cv2.resize(base, (w, h), interpolation=cv2.INTER_LINEAR)
    alpha_overlay = overlay[:, :, 3] / 255.0
    alpha_base = 1.0 - alpha_overlay
    
    for c in range(3):
        base_resized[:, :, c] = (alpha_overlay * overlay[:, :, c] +
                                 alpha_base * base_resized[:, :, c])
    return base_resized

# Process toolbar icons
for filename in os.listdir(input_folder):
    if filename.endswith(".png") and not filename.endswith("_on.png") and not filename.endswith("_off.png"):
        base_name = filename[:-4]  # Remove .png extension
        img_path = os.path.join(input_folder, filename)
        img = cv2.imread(img_path, cv2.IMREAD_UNCHANGED)

        if img is None:
            print(f"Failed to load: {filename}")
            continue

        # Apply standard recoloring
        processed_img = apply_color_map(img, color_map)
        output_path = os.path.join(output_folder, filename)
        cv2.imwrite(output_path, processed_img)
        print(f"Processed: {filename}")

        # Check for _on and _off versions
        on_path = os.path.join(input_folder, f"{base_name}_on.png")
        off_path = os.path.join(input_folder, f"{base_name}_off.png")

        if os.path.exists(on_path):
            background_on = cv2.imread(background_on_path, cv2.IMREAD_UNCHANGED)
            inverted_img = invert_colors(processed_img.copy())  # Invert the overlay
            icon_on = overlay_icon(background_on, inverted_img)
            cv2.imwrite(os.path.join(output_folder, f"{base_name}_on.png"), icon_on)
            print(f"Created: {base_name}_on.png")

        if os.path.exists(off_path):
            background_off = cv2.imread(background_off_path, cv2.IMREAD_UNCHANGED)
            icon_off = overlay_icon(background_off, processed_img)  # Use the recolored icon directly
            cv2.imwrite(os.path.join(output_folder, f"{base_name}_off.png"), icon_off)
            print(f"Created: {base_name}_off.png")

print("Batch processing completed!")

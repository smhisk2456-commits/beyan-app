import json
import os
import shutil
from PIL import Image, ImageDraw, ImageFilter

def apply_new_logo():
    new_logo_source = r"C:\Users\smhis\.gemini\antigravity\brain\f2197c74-a7ba-481e-89ab-f76e638c5416\beyan_app_icon_fullbleed_1792044863088.jpg"
    base_dir = r"C:\Users\smhis\.gemini\antigravity\scratch\islamic_app"
    desktop_dir = r"C:\Users\smhis\OneDrive\Masaüstü\claude"

    # Open and ensure 1024x1024 RGBA
    img = Image.open(new_logo_source).convert("RGBA")
    if img.size != (1024, 1024):
        img = img.resize((1024, 1024), Image.Resampling.LANCZOS)

    # 1. assets/images/app_logo.png
    target_app_logo = os.path.join(base_dir, "assets", "images", "app_logo.png")
    img.save(target_app_logo, "PNG")
    print(f"Updated: {target_app_logo}")

    # 2. Marketing real_beyan_logo_1024.png
    target_mkt_logo = os.path.join(base_dir, "assets", "images", "marketing", "authentic_outro", "real_beyan_logo_1024.png")
    img.save(target_mkt_logo, "PNG")
    print(f"Updated: {target_mkt_logo}")

    # 3. Desktop copies
    desktop_1024 = os.path.join(desktop_dir, "real_beyan_logo_1024.png")
    desktop_logo = os.path.join(desktop_dir, "beyan_app_logo.png")
    img.save(desktop_1024, "PNG")
    img.save(desktop_logo, "PNG")
    print(f"Updated desktop files: {desktop_1024}, {desktop_logo}")

    # 4. Squircle version
    squircle = Image.new("RGBA", (1024, 1024), (0, 0, 0, 0))
    mask = Image.new("L", (1024, 1024), 0)
    draw_mask = ImageDraw.Draw(mask)
    draw_mask.rounded_rectangle([0, 0, 1024, 1024], radius=224, fill=255)
    squircle.paste(img, (0, 0), mask)
    
    mkt_squircle = os.path.join(base_dir, "assets", "images", "marketing", "authentic_outro", "overlay_app_icon_squircle.png")
    desktop_squircle = os.path.join(desktop_dir, "overlay_app_icon_squircle.png")
    squircle_336 = squircle.resize((336, 336), Image.Resampling.LANCZOS)
    squircle_336.save(mkt_squircle, "PNG")
    squircle_336.save(desktop_squircle, "PNG")
    print(f"Updated squircle icons: {mkt_squircle}")

    # 5. iOS AppIcon.appiconset
    appicon_dir = os.path.join(base_dir, "ios", "Runner", "Assets.xcassets", "AppIcon.appiconset")
    contents_path = os.path.join(appicon_dir, "Contents.json")
    with open(contents_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    # Note: iOS app store icons must be RGB (no alpha channel)
    img_rgb = img.convert("RGB")

    for item in data.get("images", []):
        filename = item.get("filename")
        if not filename:
            continue
        size_str = item.get("size", "0x0")
        scale_str = item.get("scale", "1x")
        
        base_w, base_h = [float(x) for x in size_str.split("x")]
        scale = float(scale_str.replace("x", ""))
        
        target_w = int(round(base_w * scale))
        target_h = int(round(base_h * scale))
        
        resized = img_rgb.resize((target_w, target_h), Image.Resampling.LANCZOS)
        out_path = os.path.join(appicon_dir, filename)
        resized.save(out_path, "PNG")
        print(f"Generated iOS icon {filename} ({target_w}x{target_h})")

    # 6. Android launcher icons
    android_res_dir = os.path.join(base_dir, "android", "app", "src", "main", "res")
    densities = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }

    for folder, size in densities.items():
        folder_path = os.path.join(android_res_dir, folder)
        os.makedirs(folder_path, exist_ok=True)

        # Standard launcher (square/squircle)
        launcher_path = os.path.join(folder_path, "ic_launcher.png")
        resized_launcher = img.resize((size, size), Image.Resampling.LANCZOS)
        resized_launcher.save(launcher_path, "PNG")

        # Round launcher
        round_path = os.path.join(folder_path, "ic_launcher_round.png")
        round_img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        rmask = Image.new("L", (size, size), 0)
        rdraw = ImageDraw.Draw(rmask)
        rdraw.ellipse([0, 0, size, size], fill=255)
        round_img.paste(resized_launcher, (0, 0), rmask)
        round_img.save(round_path, "PNG")

        # Foreground for adaptive icon (scaled to 72% centered inside 108x108 equivalent)
        fg_path = os.path.join(folder_path, "ic_launcher_foreground.png")
        fg_size = int(size * 108 / 48) if folder == "mipmap-mdpi" else int(size * 1.5)
        fg_img = Image.new("RGBA", (fg_size, fg_size), (0, 0, 0, 0))
        # Center the logo in foreground
        inner_size = int(fg_size * 0.72)
        inner_img = img.resize((inner_size, inner_size), Image.Resampling.LANCZOS)
        offset = (fg_size - inner_size) // 2
        fg_img.paste(inner_img, (offset, offset), inner_img)
        fg_img.save(fg_path, "PNG")

        print(f"Generated Android {folder} icons (size: {size}x{size})")

    print("\nSUCCESS: All iOS, Android, and project icon assets updated with the new Arabic Ba logo!")

if __name__ == "__main__":
    apply_new_logo()

import json
import os
from PIL import Image

def generate_ios_icons():
    base_dir = r"C:\Users\smhis\.gemini\antigravity\scratch\islamic_app"
    source_logo = os.path.join(base_dir, "assets", "images", "app_logo.png")
    appicon_dir = os.path.join(base_dir, "ios", "Runner", "Assets.xcassets", "AppIcon.appiconset")
    contents_path = os.path.join(appicon_dir, "Contents.json")

    with open(contents_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    img = Image.open(source_logo).convert("RGBA")

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
        
        resized = img.resize((target_w, target_h), Image.Resampling.LANCZOS)
        out_path = os.path.join(appicon_dir, filename)
        resized.save(out_path, "PNG")
        print(f"Generated {filename} ({target_w}x{target_h})")

if __name__ == "__main__":
    generate_ios_icons()

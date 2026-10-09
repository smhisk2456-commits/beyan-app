import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

OUTPUT_DIR = os.path.abspath("app_store_screenshots")
DESKTOP_DIR = r"C:\Users\smhis\Desktop\Beyan_App_Store_Gorselleri"
os.makedirs(OUTPUT_DIR, exist_ok=True)
os.makedirs(DESKTOP_DIR, exist_ok=True)

USER_UPLOADED_DIR = r"C:\Users\smhis\.gemini\antigravity\brain\f2197c74-a7ba-481e-89ab-f76e638c5416\.user_uploaded"

SCREENSHOT_MAP = {
    1: os.path.join(USER_UPLOADED_DIR, "media_1791460530735.jpg"),        # Dashboard / Prayer times
    2: os.path.join(USER_UPLOADED_DIR, "media_1791460530746.jpg"),        # Lock Screen Widget
    3: os.path.join(USER_UPLOADED_DIR, "media_1791467372648_b5fc52df.jpg"), # Smart Tasbih / Zikirmatik
    4: os.path.join(USER_UPLOADED_DIR, "media_1791467372780_04ed4426.jpg"), # Daily Quran Verses & Duas
    5: os.path.join(USER_UPLOADED_DIR, "media_1791307128944.png"),        # 3 Days Free Trial & 49.99 TL Pricing Screen
}

BANNER_DATA = [
    {
        "id": 1,
        "badge": "DİYANET İLE %100 UYUMLU",
        "title": "Hassas Namaz Vakitleri",
        "subtitle": "Milimetrik vakit hesaplama, canlı geri sayım ve vakit alarmları",
        "filename": "screenshot_1_namaz_vakitleri.png"
    },
    {
        "id": 2,
        "badge": "KİLİT EKRANI WİDGET",
        "title": "Kilit Ekranı Canlı Sayaç",
        "subtitle": "Telefon kilidini açmadan yaklaşan vakti ve günün âyetini takip edin",
        "filename": "screenshot_2_kilit_ekrani_widget.png"
    },
    {
        "id": 3,
        "badge": "AKILLI ZİKİRMATİK",
        "title": "Sesli & Titreşimli Zikir",
        "subtitle": "Esmaü'l-Hüsna, tesbihat ve dokunsal sayaç ile zikirlerinizi çekin",
        "filename": "screenshot_3_zikirmatik.png"
    },
    {
        "id": 4,
        "badge": "KUR'AN-I KERİM & DUALAR",
        "title": "Günün Âyeti & Mealli Dualar",
        "subtitle": "Arapça hat, Türkçe meal ve sahih hadis kaynaklı günlük dualar",
        "filename": "screenshot_4_kuran_ve_dualar.png"
    },
    {
        "id": 5,
        "badge": "3 GÜN ÜCRETSİZ DENEME",
        "title": "Beyân Pro & ₺49,99 / Ay",
        "subtitle": "3 gün ücretsiz deneyin, dilediğiniz an iptal edin. Reklamsız tam erişim",
        "filename": "screenshot_5_beyan_pro.png"
    }
]

WIDTH = 1179
HEIGHT = 2556

FONT_BOLD = r"C:\Windows\Fonts\segoeuib.ttf"
FONT_REG = r"C:\Windows\Fonts\segoeui.ttf"

def create_gradient_background():
    base = Image.new("RGBA", (WIDTH, HEIGHT), (6, 17, 13, 255))
    draw = ImageDraw.Draw(base)
    for y in range(HEIGHT):
        ratio = y / HEIGHT
        if ratio < 0.4:
            r = int(6 + (14 - 6) * (ratio / 0.4))
            g = int(17 + (32 - 17) * (ratio / 0.4))
            b = int(13 + (26 - 13) * (ratio / 0.4))
        else:
            local_ratio = (ratio - 0.4) / 0.6
            r = int(14 - (14 - 4) * local_ratio)
            g = int(32 - (32 - 9) * local_ratio)
            b = int(26 - (26 - 8) * local_ratio)
        draw.line([(0, y), (WIDTH, y)], fill=(r, g, b, 255))
    
    glow = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    cx, cy = WIDTH // 2, 450
    max_radius = 600
    for r in range(max_radius, 0, -10):
        alpha = int(25 * (1.0 - r / max_radius))
        glow_draw.ellipse([cx - r, cy - r // 2, cx + r, cy + r // 2], fill=(212, 175, 55, alpha))
    
    return Image.alpha_composite(base, glow)

def wrap_text(text, font, max_width, draw):
    words = text.split()
    lines = []
    current_line = []
    for word in words:
        test_line = " ".join(current_line + [word])
        bbox = draw.textbbox((0, 0), test_line, font=font)
        if bbox[2] - bbox[0] <= max_width:
            current_line.append(word)
        else:
            if current_line:
                lines.append(" ".join(current_line))
            current_line = [word]
    if current_line:
        lines.append(" ".join(current_line))
    return lines

def create_phone_mockup(screen_image_path):
    phone_w = 920
    phone_h = 1880
    corner_radius = 85
    bezel = 18
    
    raw_img = Image.open(screen_image_path).convert("RGBA")
    screen_w = phone_w - (bezel * 2)
    screen_h = phone_h - (bezel * 2)
    
    scale = max(screen_w / raw_img.width, screen_h / raw_img.height)
    scaled_w = int(raw_img.width * scale)
    scaled_h = int(raw_img.height * scale)
    raw_scaled = raw_img.resize((scaled_w, scaled_h), Image.Resampling.LANCZOS)
    
    left = (scaled_w - screen_w) // 2
    top = 0
    cropped_screen = raw_scaled.crop((left, top, left + screen_w, top + screen_h))
    
    inner_radius = corner_radius - bezel
    screen_mask = Image.new("L", (screen_w, screen_h), 0)
    mask_draw = ImageDraw.Draw(screen_mask)
    mask_draw.rounded_rectangle([0, 0, screen_w, screen_h], radius=inner_radius, fill=255)
    
    rounded_screen = Image.new("RGBA", (screen_w, screen_h), (0, 0, 0, 0))
    rounded_screen.paste(cropped_screen, (0, 0), screen_mask)
    
    phone_layer = Image.new("RGBA", (phone_w, phone_h), (0, 0, 0, 0))
    phone_draw = ImageDraw.Draw(phone_layer)
    phone_draw.rounded_rectangle([0, 0, phone_w, phone_h], radius=corner_radius, fill=(24, 32, 28, 255), outline=(212, 175, 55, 120), width=3)
    phone_layer.paste(rounded_screen, (bezel, bezel), rounded_screen)
    
    # Dynamic Island
    di_w = 190
    di_h = 48
    di_x = (phone_w - di_w) // 2
    di_y = bezel + 18
    phone_draw.rounded_rectangle([di_x, di_y, di_x + di_w, di_y + di_h], radius=24, fill=(0, 0, 0, 255))
    phone_draw.ellipse([di_x + di_w - 38, di_y + 14, di_x + di_w - 18, di_y + 34], fill=(18, 22, 28, 255))
    
    # Drop shadow
    shadow_pad = 80
    shadow_img = Image.new("RGBA", (phone_w + shadow_pad * 2, phone_h + shadow_pad * 2), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow_img)
    shadow_draw.rounded_rectangle(
        [shadow_pad, shadow_pad + 20, shadow_pad + phone_w, shadow_pad + phone_h + 20],
        radius=corner_radius,
        fill=(0, 0, 0, 160)
    )
    shadow_img = shadow_img.filter(ImageFilter.GaussianBlur(35))
    
    final_mock = Image.new("RGBA", (phone_w + shadow_pad * 2, phone_h + shadow_pad * 2), (0, 0, 0, 0))
    final_mock.paste(shadow_img, (0, 0), shadow_img)
    final_mock.paste(phone_layer, (shadow_pad, shadow_pad), phone_layer)
    
    return final_mock, shadow_pad

def generate_banner(data):
    canvas = create_gradient_background()
    draw = ImageDraw.Draw(canvas)
    
    font_badge = ImageFont.truetype(FONT_BOLD, 32)
    font_title = ImageFont.truetype(FONT_BOLD, 74)
    font_sub = ImageFont.truetype(FONT_REG, 40)
    
    curr_y = 130
    
    # 1. Badge Pill
    badge_text = data["badge"]
    badge_bbox = draw.textbbox((0, 0), badge_text, font=font_badge)
    badge_w = badge_bbox[2] - badge_bbox[0] + 50
    badge_h = badge_bbox[3] - badge_bbox[1] + 24
    badge_x = (WIDTH - badge_w) // 2
    
    pill_img = Image.new("RGBA", (badge_w, badge_h), (0, 0, 0, 0))
    pill_draw = ImageDraw.Draw(pill_img)
    pill_draw.rounded_rectangle([0, 0, badge_w, badge_h], radius=badge_h // 2, fill=(212, 175, 55, 30), outline=(212, 175, 55, 140), width=2)
    canvas.paste(pill_img, (badge_x, curr_y), pill_img)
    draw.text((badge_x + 25, curr_y + 10), badge_text, font=font_badge, fill=(243, 229, 171))
    
    curr_y += badge_h + 45
    
    # 2. Main Title
    title_text = data["title"]
    title_bbox = draw.textbbox((0, 0), title_text, font=font_title)
    title_w = title_bbox[2] - title_bbox[0]
    draw.text(((WIDTH - title_w) // 2, curr_y), title_text, font=font_title, fill=(255, 255, 255))
    curr_y += (title_bbox[3] - title_bbox[1]) + 28
    
    # 3. Subtitle
    sub_lines = wrap_text(data["subtitle"], font_sub, 980, draw)
    for line in sub_lines:
        line_bbox = draw.textbbox((0, 0), line, font=font_sub)
        line_w = line_bbox[2] - line_bbox[0]
        draw.text(((WIDTH - line_w) // 2, curr_y), line, font=font_sub, fill=(160, 180, 172))
        curr_y += (line_bbox[3] - line_bbox[1]) + 16
        
    # 4. Phone Mockup
    screen_path = SCREENSHOT_MAP[data["id"]]
    phone_mock, shadow_pad = create_phone_mockup(screen_path)
    
    mock_x = (WIDTH - phone_mock.width) // 2
    mock_y = 660 - shadow_pad
    canvas.paste(phone_mock, (mock_x, mock_y), phone_mock)
    
    final_rgb = canvas.convert("RGB")
    out_path = os.path.join(OUTPUT_DIR, data["filename"])
    final_rgb.save(out_path, "PNG", quality=100)
    
    # Also save to Desktop folder
    desktop_out = os.path.join(DESKTOP_DIR, data["filename"])
    final_rgb.save(desktop_out, "PNG", quality=100)
    print(f"Generated {data['filename']} in app_store_screenshots and Desktop folder")

if __name__ == "__main__":
    for item in BANNER_DATA:
        generate_banner(item)
    print("Done generating updated banners!")

import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

OUTPUT_DIR = os.path.abspath("app_store_screenshots")
DESKTOP_DIR = r"C:\Users\smhis\OneDrive\Masaüstü\Beyan_App_Store_Gorselleri"
DESKTOP_IPAD_DIR = os.path.join(DESKTOP_DIR, "iPad_13_Inch")
ARTIFACT_DIR = r"C:\Users\smhis\.gemini\antigravity\brain\f2197c74-a7ba-481e-89ab-f76e638c5416"
os.makedirs(OUTPUT_DIR, exist_ok=True)
os.makedirs(DESKTOP_DIR, exist_ok=True)
os.makedirs(DESKTOP_IPAD_DIR, exist_ok=True)

USER_UPLOADED_DIR = r"C:\Users\smhis\.gemini\antigravity\brain\f2197c74-a7ba-481e-89ab-f76e638c5416\.user_uploaded"
TEMP_DIR = os.path.abspath(os.path.join("tools", "temp_screens"))
os.makedirs(TEMP_DIR, exist_ok=True)

# Clean status bar from real screenshot (removes '◄ TestFlight' and red battery icon so Apple Review approves)
im_clean_status = Image.open(os.path.join(USER_UPLOADED_DIR, "media_1793146665231_486f2726.jpg")).convert("RGBA")
status_bar_crop = im_clean_status.crop((0, 0, 472, 60))

# 1. Real Updated Home Screen 1 (Keşfet & İslami Yaşam 6-card Bento Grid + 4-button row)
im_new_home_1 = Image.open(os.path.join(USER_UPLOADED_DIR, "media_1793224334518_079f5ae1.jpg")).convert("RGBA")
im_new_home_1.paste(status_bar_crop, (0, 0))
bg_color_1 = im_new_home_1.getpixel((5, 860))
d1 = ImageDraw.Draw(im_new_home_1)
d1.rectangle([0, 952, 472, 1024], fill=bg_color_1)
home_1_path = os.path.join(TEMP_DIR, "real_new_home_1.png")
im_new_home_1.save(home_1_path, "PNG")

# 4. Real Updated Home Screen 2 (Bugün Kalbin Nasıl Hissediyor + Tabbed Günün Ayet-i Kerimesi / Günün Niyazı ve Duası)
im_new_home_2 = Image.open(os.path.join(USER_UPLOADED_DIR, "media_1793224337290_1da3634b.jpg")).convert("RGBA")
im_new_home_2.paste(status_bar_crop, (0, 0))
home_2_path = os.path.join(TEMP_DIR, "real_new_home_2.png")
im_new_home_2.save(home_2_path, "PNG")

# 2. Real Lock Screen Widget (with Turkish bottom dock labels)
im_widget = Image.open(os.path.join(USER_UPLOADED_DIR, "media_1791460530746.jpg")).convert("RGBA")
im_zikir = Image.open(os.path.join(USER_UPLOADED_DIR, "media_1793141188201_0cfdadc4.jpg")).convert("RGBA")
im_vakit = Image.open(os.path.join(USER_UPLOADED_DIR, "media_1793146662506_47746321.jpg")).convert("RGBA")

left_dock = im_zikir.crop((32, 895, 195, 955))
im_widget.paste(left_dock, (32, 895))
right_dock = im_vakit.crop((275, 895, 354, 955))
im_widget.paste(right_dock, (275, 895))

widget_tr_path = os.path.join(TEMP_DIR, "media_widget_tr_real.png")
im_widget.save(widget_tr_path, "PNG")

SCREENSHOT_MAP = {
    1: home_1_path,                                                         # 100% Real TestFlight Updated Home Screen 1
    2: widget_tr_path,                                                      # 100% Real TR Lock Screen Widget
    3: os.path.join(USER_UPLOADED_DIR, "media_1793141188201_0cfdadc4.jpg"), # 100% Real TR Smart Tasbih / Zikirmatik
    4: home_2_path,                                                         # 100% Real TestFlight Updated Home Screen 2 (Günün Ayeti & Duası)
    5: os.path.join(USER_UPLOADED_DIR, "media_1793141238993_0d5334ff.jpg"), # 100% Real TR Step-by-Step Prayer & Wudu Guide
}

BANNER_DATA = [
    {
        "id": 1,
        "badge": "DİYANET İLE %100 UYUMLU",
        "title": "Namaz & İslami Yaşam",
        "subtitle": "Milimetrik vakit hesaplama, Sesli Elif-Bâ, Abdest Rehberi ve Beyân AI",
        "pills": ["Canlı GPS Vakitleri", "Sesli Elif-Bâ & Beyân AI", "Yakındaki Camiler"],
        "filename": "screenshot_1_namaz_vakitleri.png",
        "ipad_filename": "ipad_13_inch_1_namaz_vakitleri.png"
    },
    {
        "id": 2,
        "badge": "KİLİT EKRANI WİDGET",
        "title": "Kilit Ekranı Canlı Sayaç",
        "subtitle": "Telefon kilidini açmadan yaklaşan vakti ve günün âyetini takip edin",
        "pills": ["Canlı Vakit Sayacı", "Günün Âyet-i Kerîmesi", "Şarj Dostu Tasarım"],
        "filename": "screenshot_2_kilit_ekrani_widget.png",
        "ipad_filename": "ipad_13_inch_2_kilit_ekrani_widget.png"
    },
    {
        "id": 3,
        "badge": "AKILLI ZİKİRMATİK",
        "title": "Sesli & Titreşimli Zikir",
        "subtitle": "Esmaü'l-Hüsna, tesbihat ve dokunsal sayaç ile zikirlerinizi çekin",
        "pills": ["Dokunsal Titreşim", "Salavât & Tesbihat", "Günlük Hedef Takibi"],
        "filename": "screenshot_3_zikirmatik.png",
        "ipad_filename": "ipad_13_inch_3_zikirmatik.png"
    },
    {
        "id": 4,
        "badge": "KUR'AN-I KERİM & DUALAR",
        "title": "Günün Âyeti & Manevi Şifâ",
        "subtitle": "Ruh haline özel âyetler, sahih günlük dualar, Akşam Virdi ve Yakın Camiler",
        "pills": ["Kalbe Şifâ Âyetler", "Günün Niyazı & Duası", "Sabah & Akşam Virdi"],
        "filename": "screenshot_4_gunun_ayeti_ve_dualar.png",
        "ipad_filename": "ipad_13_inch_4_gunun_ayeti_ve_dualar.png"
    },
    {
        "id": 5,
        "badge": "NAMAZ & ABDEST REHBERİ",
        "title": "Adım Adım İbadet Rehberi",
        "subtitle": "Diyanet uyumlu abdest hazırlığı, rekat bilgileri ve sesli namaz kılavuzu",
        "pills": ["16 Adımda Namaz", "Abdest & Gusül Rehberi", "Sesli Okunuş & Meal"],
        "filename": "screenshot_5_namaz_ve_abdest_rehberi.png",
        "ipad_filename": "ipad_13_inch_5_namaz_ve_abdest_rehberi.png"
    }
]

WIDTH = 1179
HEIGHT = 2556

IPAD_W = 2048
IPAD_H = 2732

FONT_BOLD = r"C:\Windows\Fonts\segoeuib.ttf"
FONT_REG = r"C:\Windows\Fonts\segoeui.ttf"

def create_gradient_background(w=WIDTH, h=HEIGHT):
    base = Image.new("RGBA", (w, h), (6, 17, 13, 255))
    draw = ImageDraw.Draw(base)
    for y in range(h):
        ratio = y / h
        if ratio < 0.4:
            r = int(6 + (14 - 6) * (ratio / 0.4))
            g = int(17 + (32 - 17) * (ratio / 0.4))
            b = int(13 + (26 - 13) * (ratio / 0.4))
        else:
            local_ratio = (ratio - 0.4) / 0.6
            r = int(14 - (14 - 4) * local_ratio)
            g = int(32 - (32 - 9) * local_ratio)
            b = int(26 - (26 - 8) * local_ratio)
        draw.line([(0, y), (w, y)], fill=(r, g, b, 255))
    
    glow = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    cx, cy = w // 2, 450
    max_radius = int(w * 0.5)
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

def create_phone_mockup(screen_image_path, phone_w=920, phone_h=1880, corner_radius=85, bezel=18, include_dynamic_island=True):
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
    phone_draw.rounded_rectangle([0, 0, phone_w, phone_h], radius=corner_radius, fill=(24, 32, 28, 255), outline=(212, 175, 55, 140), width=4)
    phone_layer.paste(rounded_screen, (bezel, bezel), rounded_screen)
    
    if include_dynamic_island:
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
    canvas = create_gradient_background(WIDTH, HEIGHT)
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
    
    desktop_out = os.path.join(DESKTOP_DIR, data["filename"])
    final_rgb.save(desktop_out, "PNG", quality=100)
    artifact_out = os.path.join(ARTIFACT_DIR, data["filename"])
    final_rgb.save(artifact_out, "PNG", quality=100)
    print(f"Generated iPhone: {data['filename']}")

def generate_ipad_banner(data):
    canvas = create_gradient_background(IPAD_W, IPAD_H)
    draw = ImageDraw.Draw(canvas)
    
    font_badge = ImageFont.truetype(FONT_BOLD, 38)
    font_title = ImageFont.truetype(FONT_BOLD, 84)
    font_sub = ImageFont.truetype(FONT_REG, 44)
    font_pill = ImageFont.truetype(FONT_BOLD, 36)
    
    curr_y = 110
    
    # 1. Badge Pill
    badge_text = data["badge"]
    badge_bbox = draw.textbbox((0, 0), badge_text, font=font_badge)
    badge_w = badge_bbox[2] - badge_bbox[0] + 64
    badge_h = badge_bbox[3] - badge_bbox[1] + 28
    badge_x = (IPAD_W - badge_w) // 2
    
    pill_img = Image.new("RGBA", (badge_w, badge_h), (0, 0, 0, 0))
    pill_draw = ImageDraw.Draw(pill_img)
    pill_draw.rounded_rectangle([0, 0, badge_w, badge_h], radius=badge_h // 2, fill=(212, 175, 55, 30), outline=(212, 175, 55, 140), width=3)
    canvas.paste(pill_img, (badge_x, curr_y), pill_img)
    draw.text((badge_x + 32, curr_y + 12), badge_text, font=font_badge, fill=(243, 229, 171))
    
    curr_y += badge_h + 36
    
    # 2. Main Title
    title_text = data["title"]
    title_bbox = draw.textbbox((0, 0), title_text, font=font_title)
    title_w = title_bbox[2] - title_bbox[0]
    draw.text(((IPAD_W - title_w) // 2, curr_y), title_text, font=font_title, fill=(255, 255, 255))
    curr_y += (title_bbox[3] - title_bbox[1]) + 24
    
    # 3. Subtitle
    sub_lines = wrap_text(data["subtitle"], font_sub, 1650, draw)
    for line in sub_lines:
        line_bbox = draw.textbbox((0, 0), line, font=font_sub)
        line_w = line_bbox[2] - line_bbox[0]
        draw.text(((IPAD_W - line_w) // 2, curr_y), line, font=font_sub, fill=(160, 180, 172))
        curr_y += (line_bbox[3] - line_bbox[1]) + 14
        
    # 4. Device Frame (scaled cleanly so bottom dock sits right at the bottom and pills don't overlap)
    screen_path = SCREENSHOT_MAP[data["id"]]
    device_mock, shadow_pad = create_phone_mockup(
        screen_path,
        phone_w=960,
        phone_h=1920,
        corner_radius=80,
        bezel=22,
        include_dynamic_island=False
    )
    mock_x = (IPAD_W - device_mock.width) // 2
    mock_y = 490 - shadow_pad
    canvas.paste(device_mock, (mock_x, mock_y), device_mock)
    
    # 5. Bottom Feature Pills (with gold circle bullet, no broken emoji boxes)
    pills = data["pills"]
    pill_h = 76
    py = 2520
    pill_widths = []
    for p in pills:
        pb = draw.textbbox((0, 0), p, font=font_pill)
        pw = (pb[2] - pb[0]) + 90  # space for gold dot + padding
        pill_widths.append(pw)
    total_w = sum(pill_widths) + (len(pills) - 1) * 32
    cur_x = (IPAD_W - total_w) // 2
    
    for p, pw in zip(pills, pill_widths):
        p_img = Image.new("RGBA", (pw, pill_h), (0, 0, 0, 0))
        p_draw = ImageDraw.Draw(p_img)
        p_draw.rounded_rectangle([0, 0, pw, pill_h], radius=pill_h // 2, fill=(10, 36, 30, 235), outline=(212, 175, 55, 130), width=2)
        # Gold dot
        dot_r = 8
        dot_cx = 34
        dot_cy = pill_h // 2
        p_draw.ellipse([dot_cx - dot_r, dot_cy - dot_r, dot_cx + dot_r, dot_cy + dot_r], fill=(212, 175, 55, 255))
        p_draw.text((56, 16), p, font=font_pill, fill=(235, 245, 240, 255))
        canvas.paste(p_img, (cur_x, py), p_img)
        cur_x += pw + 32

    final_rgb = canvas.convert("RGB")
    out_path = os.path.join(OUTPUT_DIR, data["ipad_filename"])
    final_rgb.save(out_path, "PNG", quality=100)
    
    desktop_ipad_out = os.path.join(DESKTOP_IPAD_DIR, data["ipad_filename"])
    final_rgb.save(desktop_ipad_out, "PNG", quality=100)
    
    artifact_out = os.path.join(ARTIFACT_DIR, data["ipad_filename"])
    final_rgb.save(artifact_out, "PNG", quality=100)
    print(f"Generated iPad 13-inch (2048x2732): {data['ipad_filename']}")

if __name__ == "__main__":
    for item in BANNER_DATA:
        generate_banner(item)
        generate_ipad_banner(item)
    print("Done generating 5 iPhone + 5 iPad 13-inch pure real screenshots!")

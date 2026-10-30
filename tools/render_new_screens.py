import os
import subprocess
import base64
from PIL import Image, ImageDraw, ImageFont, ImageFilter

PROJECT_DIR = r"C:\Users\smhis\.gemini\antigravity\scratch\islamic_app"
OUTPUT_DIR = os.path.join(PROJECT_DIR, "app_store_screenshots")
DESKTOP_DIR = r"C:\Users\smhis\Desktop\Beyan_App_Store_Gorselleri"
TEMP_DIR = os.path.join(PROJECT_DIR, "tools", "temp_screens")
USER_UPLOADED_DIR = r"C:\Users\smhis\.gemini\antigravity\brain\f2197c74-a7ba-481e-89ab-f76e638c5416\.user_uploaded"

os.makedirs(OUTPUT_DIR, exist_ok=True)
os.makedirs(DESKTOP_DIR, exist_ok=True)
os.makedirs(TEMP_DIR, exist_ok=True)

CHROME_PATH = r"C:\Program Files\Google\Chrome\Application\chrome.exe"
if not os.path.exists(CHROME_PATH):
    CHROME_PATH = r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

LOGO_PATH = os.path.join(PROJECT_DIR, "assets", "images", "marketing", "authentic_outro", "real_beyan_logo_1024.png")
AMIRI_FONT_PATH = os.path.join(PROJECT_DIR, "assets", "fonts", "Amiri-Regular.ttf").replace("\\", "/")

with open(LOGO_PATH, "rb") as f:
    LOGO_B64 = base64.b64encode(f.read()).decode("utf-8")

COMMON_CSS = f"""
@font-face {{
    font-family: 'AmiriCustom';
    src: url('file:///{AMIRI_FONT_PATH}') format('truetype');
}}
* {{
    box-sizing: border-box;
    margin: 0;
    padding: 0;
    user-select: none;
    -webkit-font-smoothing: antialiased;
}}
body {{
    width: 884px;
    height: 1844px;
    overflow: hidden;
    background: linear-gradient(180deg, #071611 0%, #050F0C 100%);
    font-family: 'Segoe UI', -apple-system, BlinkMacSystemFont, sans-serif;
    color: #FFFFFF;
    position: relative;
}}
.status-bar {{
    height: 96px;
    padding: 34px 48px 0 54px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-size: 30px;
    font-weight: 700;
    letter-spacing: -0.5px;
}}
.status-right {{
    display: flex;
    align-items: center;
    gap: 14px;
}}
.signal-bars {{
    display: flex;
    align-items: flex-end;
    gap: 4px;
    height: 22px;
}}
.signal-bars span {{
    width: 6px;
    background: #FFFFFF;
    border-radius: 2px;
}}
.battery {{
    width: 52px;
    height: 26px;
    border: 2.5px solid rgba(255,255,255,0.45);
    border-radius: 8px;
    padding: 3px;
    display: flex;
    align-items: center;
    position: relative;
}}
.battery-fill {{
    width: 82%;
    height: 100%;
    background: #4CD964;
    border-radius: 4px;
}}
.app-header {{
    padding: 16px 36px 20px 36px;
    display: flex;
    justify-content: space-between;
    align-items: center;
}}
.brand-row {{
    display: flex;
    align-items: center;
    gap: 18px;
}}
.brand-logo {{
    width: 64px;
    height: 64px;
    border-radius: 18px;
    border: 2px solid rgba(212, 175, 55, 0.65);
    box-shadow: 0 4px 16px rgba(212, 175, 55, 0.25);
    object-fit: cover;
}}
.brand-title {{
    font-size: 40px;
    font-weight: 800;
    letter-spacing: -0.5px;
    color: #FFFFFF;
}}
.header-actions {{
    display: flex;
    align-items: center;
    gap: 16px;
}}
.lang-pill {{
    background: rgba(212, 175, 55, 0.12);
    border: 1.8px solid rgba(212, 175, 55, 0.45);
    border-radius: 30px;
    padding: 8px 20px;
    font-size: 22px;
    font-weight: 700;
    color: #F3E5AB;
    display: flex;
    align-items: center;
    gap: 8px;
}}
.icon-btn {{
    width: 52px;
    height: 52px;
    border-radius: 16px;
    background: rgba(255,255,255,0.05);
    border: 1.5px solid rgba(212, 175, 55, 0.25);
    display: flex;
    align-items: center;
    justify-content: center;
    color: #D4AF37;
    font-size: 26px;
}}
.bottom-dock {{
    position: absolute;
    bottom: 28px;
    left: 32px;
    right: 32px;
    height: 132px;
    background: rgba(10, 26, 20, 0.96);
    border: 2px solid rgba(212, 175, 55, 0.35);
    border-radius: 66px;
    display: flex;
    justify-content: space-around;
    align-items: center;
    padding: 0 18px;
    box-shadow: 0 16px 40px rgba(0,0,0,0.65);
}}
.dock-item {{
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 6px;
    color: #8CA69B;
    font-size: 20px;
    font-weight: 600;
    padding: 12px 22px;
    border-radius: 40px;
}}
.dock-item.active {{
    background: rgba(212, 175, 55, 0.16);
    border: 1.5px solid rgba(212, 175, 55, 0.45);
    color: #F3E5AB;
}}
.dock-center-orb {{
    width: 118px;
    height: 118px;
    border-radius: 59px;
    background: radial-gradient(circle at 30% 30%, #173F30, #0A2018);
    border: 4px solid #D4AF37;
    box-shadow: 0 0 28px rgba(212, 175, 55, 0.45);
    display: flex;
    align-items: center;
    justify-content: center;
    margin-top: -48px;
    color: #F3E5AB;
    font-size: 44px;
}}
.arabic {{
    font-family: 'AmiriCustom', serif;
    direction: rtl;
}}
"""

STATUS_BAR_HTML = """
<div class="status-bar">
    <div>14:52</div>
    <div class="status-right">
        <div class="signal-bars">
            <span style="height:8px"></span>
            <span style="height:12px"></span>
            <span style="height:17px"></span>
            <span style="height:22px"></span>
        </div>
        <span style="font-size:24px; font-weight:700;">5G</span>
        <div class="battery"><div class="battery-fill"></div></div>
    </div>
</div>
"""

def get_dock_html(active_tab="home"):
    return f"""
    <div class="bottom-dock">
        <div class="dock-item {'active' if active_tab=='home' else ''}">
            <span style="font-size:30px">🧭</span>
            <span>Ana Sayfa</span>
        </div>
        <div class="dock-item {'active' if active_tab=='prayers' else ''}">
            <span style="font-size:30px">🕒</span>
            <span>Vakitler</span>
        </div>
        <div class="dock-center-orb">📖</div>
        <div class="dock-item {'active' if active_tab=='tasbih' else ''}">
            <span style="font-size:30px">📿</span>
            <span>Zikirmatik</span>
        </div>
        <div class="dock-item {'active' if active_tab=='widget' else ''}">
            <span style="font-size:30px">⊞</span>
            <span>Widget</span>
        </div>
    </div>
    """

# ---------------------------------------------------------------------------
# SCREEN 1: NEW DECLUTTERED HOME SCREEN + SPIRITUAL LIFE BENTO HUB (100% TR)
# ---------------------------------------------------------------------------
HTML_SCREEN_1 = f"""<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><style>
{COMMON_CSS}
.content {{ padding: 0 32px; }}
.hero-card {{
    background: linear-gradient(145deg, #0F2920 0%, #081812 100%);
    border: 2px solid rgba(212, 175, 55, 0.38);
    border-radius: 36px;
    padding: 28px 32px;
    box-shadow: 0 16px 36px rgba(0,0,0,0.4);
    margin-bottom: 22px;
}}
.loc-row {{
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 14px;
}}
.loc-text {{
    color: #A2BEB2;
    font-size: 23px;
    font-weight: 600;
}}
.hijri-pill {{
    background: rgba(212, 175, 55, 0.12);
    border: 1.5px solid rgba(212, 175, 55, 0.4);
    color: #F3E5AB;
    padding: 6px 18px;
    border-radius: 22px;
    font-size: 20px;
    font-weight: 700;
}}
.prayer-main {{
    display: flex;
    justify-content: space-between;
    align-items: flex-end;
    margin-bottom: 16px;
}}
.next-label {{
    color: #D4AF37;
    font-size: 22px;
    font-weight: 700;
    margin-bottom: 4px;
}}
.prayer-name {{
    font-size: 64px;
    font-weight: 800;
    line-height: 1.05;
    display: flex;
    align-items: baseline;
    gap: 16px;
}}
.prayer-ar {{
    font-size: 40px;
    color: #A2BEB2;
    font-weight: 400;
}}
.prayer-time {{
    font-size: 74px;
    font-weight: 300;
    letter-spacing: -1px;
}}
.meta-row {{
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 18px;
}}
.rakat-badge {{
    background: rgba(212, 175, 55, 0.14);
    border: 1.5px solid rgba(212, 175, 55, 0.45);
    color: #F3E5AB;
    padding: 8px 20px;
    border-radius: 22px;
    font-size: 21px;
    font-weight: 600;
}}
.countdown-badge {{
    background: rgba(212, 175, 55, 0.18);
    border: 1.5px solid rgba(212, 175, 55, 0.55);
    color: #F3E5AB;
    padding: 8px 22px;
    border-radius: 22px;
    font-size: 22px;
    font-weight: 700;
}}
.prog-bar {{
    height: 12px;
    background: rgba(255,255,255,0.1);
    border-radius: 6px;
    overflow: hidden;
    margin-bottom: 20px;
}}
.prog-fill {{
    width: 64%;
    height: 100%;
    background: linear-gradient(90deg, #D4AF37, #F3E5AB);
    border-radius: 6px;
}}
.times-strip {{
    display: grid;
    grid-template-columns: repeat(5, 1fr);
    gap: 10px;
    padding-top: 14px;
    border-top: 1.5px solid rgba(255,255,255,0.08);
}}
.time-col {{
    text-align: center;
    padding: 12px 6px;
    border-radius: 22px;
}}
.time-col.active {{
    background: rgba(212, 175, 55, 0.18);
    border: 2px solid #D4AF37;
}}
.tc-name {{ font-size: 20px; color: #9CB6AA; margin-bottom: 6px; font-weight: 600; }}
.time-col.active .tc-name {{ color: #F3E5AB; font-weight: 700; }}
.tc-val {{ font-size: 26px; font-weight: 700; color: #FFFFFF; margin-bottom: 6px; }}
.tc-rakat {{
    display: inline-block;
    font-size: 16px;
    padding: 2px 10px;
    border-radius: 10px;
    background: rgba(255,255,255,0.08);
    color: #A2BEB2;
    font-weight: 700;
}}
.time-col.active .tc-rakat {{ background: #D4AF37; color: #071611; }}

/* 4-Item Quick Row */
.quick-row {{
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 14px;
    margin-bottom: 24px;
}}
.q-card {{
    background: rgba(15, 41, 32, 0.85);
    border: 1.5px solid rgba(212, 175, 55, 0.25);
    border-radius: 26px;
    padding: 18px 10px;
    text-align: center;
}}
.q-icon {{
    width: 58px;
    height: 58px;
    border-radius: 29px;
    background: rgba(212, 175, 55, 0.14);
    border: 1.5px solid rgba(212, 175, 55, 0.45);
    margin: 0 auto 10px auto;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 28px;
}}
.q-title {{ font-size: 22px; font-weight: 700; color: #FFFFFF; margin-bottom: 3px; }}
.q-sub {{ font-size: 17px; color: #8CA69B; font-weight: 500; }}

/* Spiritual Life Hub Bento Grid */
.section-header {{
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 14px;
    padding: 0 4px;
}}
.sec-title {{
    font-size: 24px;
    font-weight: 800;
    color: #F3E5AB;
    letter-spacing: 0.5px;
    text-transform: uppercase;
}}
.sec-pill {{
    font-size: 18px;
    color: #D4AF37;
    background: rgba(212, 175, 55, 0.12);
    border: 1px solid rgba(212, 175, 55, 0.35);
    padding: 4px 14px;
    border-radius: 16px;
    font-weight: 700;
}}
.bento-grid {{
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 14px;
}}
.bento-card {{
    background: linear-gradient(135deg, rgba(18, 46, 36, 0.95) 0%, rgba(10, 27, 21, 0.95) 100%);
    border: 1.8px solid rgba(212, 175, 55, 0.32);
    border-radius: 26px;
    padding: 18px 20px;
    display: flex;
    align-items: center;
    gap: 16px;
    position: relative;
}}
.bento-icon {{
    width: 62px;
    height: 62px;
    border-radius: 18px;
    background: rgba(212, 175, 55, 0.15);
    border: 1.5px solid rgba(212, 175, 55, 0.45);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 30px;
    flex-shrink: 0;
}}
.bento-title {{ font-size: 23px; font-weight: 800; color: #FFFFFF; margin-bottom: 4px; }}
.bento-sub {{ font-size: 17px; color: #9CB6AA; font-weight: 500; }}
.new-tag {{
    position: absolute;
    top: 12px;
    right: 12px;
    background: #D4AF37;
    color: #071611;
    font-size: 13px;
    font-weight: 900;
    padding: 2px 8px;
    border-radius: 8px;
}}
</style></head>
<body>
    {STATUS_BAR_HTML}
    <div class="app-header">
        <div class="brand-row">
            <img class="brand-logo" src="data:image/png;base64,{LOGO_B64}">
            <div class="brand-title">Beyân</div>
        </div>
        <div class="header-actions">
            <div class="icon-btn">🎖️</div>
            <div class="icon-btn">🎨</div>
            <div class="lang-pill">🇹🇷 TR</div>
            <div class="icon-btn">🔔</div>
        </div>
    </div>

    <div class="content">
        <div class="hero-card">
            <div class="loc-row">
                <div class="loc-text">📍 İstanbul, Türkiye</div>
                <div class="hijri-pill">16 Cemâziyelevvel • Cuma</div>
            </div>
            <div class="prayer-main">
                <div>
                    <div class="next-label">Sıradaki Namaz</div>
                    <div class="prayer-name">
                        <span>İkindi</span>
                        <span class="prayer-ar arabic">العصر</span>
                    </div>
                </div>
                <div class="prayer-time">16:56</div>
            </div>
            <div class="meta-row">
                <div class="rakat-badge">🕌 8 Rekat (4 Sünnet + 4 Farz)</div>
                <div class="countdown-badge">⏱ 2s 04dk kaldı</div>
            </div>
            <div class="prog-bar"><div class="prog-fill"></div></div>
            <div class="times-strip">
                <div class="time-col">
                    <div class="tc-name">İmsak</div>
                    <div class="tc-val">05:38</div>
                    <div class="tc-rakat">4R</div>
                </div>
                <div class="time-col">
                    <div class="tc-name">Öğle</div>
                    <div class="tc-val">12:58</div>
                    <div class="tc-rakat">10R</div>
                </div>
                <div class="time-col active">
                    <div class="tc-name">İkindi</div>
                    <div class="tc-val">16:56</div>
                    <div class="tc-rakat">8R</div>
                </div>
                <div class="time-col">
                    <div class="tc-name">Akşam</div>
                    <div class="tc-val">18:43</div>
                    <div class="tc-rakat">5R</div>
                </div>
                <div class="time-col">
                    <div class="tc-name">Yatsı</div>
                    <div class="tc-val">20:02</div>
                    <div class="tc-rakat">13R</div>
                </div>
            </div>
        </div>

        <div class="quick-row">
            <div class="q-card">
                <div class="q-icon">🧭</div>
                <div class="q-title">Kıble</div>
                <div class="q-sub">152° GD</div>
            </div>
            <div class="q-card">
                <div class="q-icon">🤲</div>
                <div class="q-title">Dualar</div>
                <div class="q-sub">Kütüphane</div>
            </div>
            <div class="q-card">
                <div class="q-icon">📅</div>
                <div class="q-title">Takvim</div>
                <div class="q-sub">Kandiller</div>
            </div>
            <div class="q-card">
                <div class="q-icon">🌙</div>
                <div class="q-title">Ramazan</div>
                <div class="q-sub">İmsakiye</div>
            </div>
        </div>

        <div class="section-header">
            <div class="sec-title">✨ Manevi Yaşam Merkezi</div>
            <div class="sec-pill">8 Dil Desteği</div>
        </div>

        <div class="bento-grid">
            <div class="bento-card">
                <span class="new-tag">YENİ</span>
                <div class="bento-icon">✨</div>
                <div>
                    <div class="bento-title">Beyân AI</div>
                    <div class="bento-sub">Ayet & Hadis Rehberi</div>
                </div>
            </div>
            <div class="bento-card">
                <span class="new-tag">SESLİ</span>
                <div class="bento-icon">🔤</div>
                <div>
                    <div class="bento-title">Sesli Elif-Bâ</div>
                    <div class="bento-sub">28 Harf & Tecvid</div>
                </div>
            </div>
            <div class="bento-card">
                <span class="new-tag">REHBER</span>
                <div class="bento-icon">💧</div>
                <div>
                    <div class="bento-title">Abdest Rehberi</div>
                    <div class="bento-sub">Adım Adım Sesli</div>
                </div>
            </div>
            <div class="bento-card">
                <div class="bento-icon">🌿</div>
                <div>
                    <div class="bento-title">Tematik Kur'an</div>
                    <div class="bento-sub">Duygu & Konu Fihristi</div>
                </div>
            </div>
            <div class="bento-card">
                <div class="bento-icon">☀️</div>
                <div>
                    <div class="bento-title">Cuma Modu</div>
                    <div class="bento-sub">Kehf & Salavat Sayacı</div>
                </div>
            </div>
            <div class="bento-card">
                <div class="bento-icon">🕌</div>
                <div>
                    <div class="bento-title">Yakın Camiler</div>
                    <div class="bento-sub">Harita & Mesafe</div>
                </div>
            </div>
        </div>
    </div>

    {get_dock_html("home")}
</body>
</html>
"""

# ---------------------------------------------------------------------------
# SCREEN 3: QURAN WORD-BY-WORD + SESLİ ELİF-BA + TEMATİK FİHRİST
# ---------------------------------------------------------------------------
HTML_SCREEN_3 = f"""<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><style>
{COMMON_CSS}
.content {{ padding: 0 32px; }}
.seg-tabs {{
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    background: rgba(15, 41, 32, 0.9);
    border: 1.8px solid rgba(212, 175, 55, 0.35);
    border-radius: 26px;
    padding: 8px;
    margin-bottom: 22px;
}}
.seg-tab {{
    text-align: center;
    padding: 14px 8px;
    font-size: 21px;
    font-weight: 700;
    color: #9CB6AA;
    border-radius: 20px;
}}
.seg-tab.active {{
    background: #D4AF37;
    color: #071611;
}}
.quran-card {{
    background: linear-gradient(145deg, #0F2920 0%, #081812 100%);
    border: 2px solid rgba(212, 175, 55, 0.42);
    border-radius: 34px;
    padding: 26px 28px;
    margin-bottom: 20px;
}}
.surah-head {{
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 16px;
    padding-bottom: 14px;
    border-bottom: 1.5px solid rgba(255,255,255,0.08);
}}
.surah-badge {{
    background: rgba(212, 175, 55, 0.16);
    border: 1.5px solid rgba(212, 175, 55, 0.45);
    color: #F3E5AB;
    padding: 6px 18px;
    border-radius: 20px;
    font-size: 20px;
    font-weight: 700;
}}
.arabic-verse {{
    font-size: 52px;
    text-align: right;
    color: #F3E5AB;
    line-height: 1.65;
    margin-bottom: 18px;
}}
.wbw-row {{
    display: flex;
    flex-direction: row-reverse;
    justify-content: flex-start;
    gap: 12px;
    margin-bottom: 18px;
    flex-wrap: wrap;
}}
.wbw-chip {{
    background: rgba(212, 175, 55, 0.11);
    border: 1.5px solid rgba(212, 175, 55, 0.38);
    border-radius: 18px;
    padding: 10px 18px;
    text-align: center;
}}
.wbw-ar {{ font-size: 32px; color: #F3E5AB; margin-bottom: 4px; }}
.wbw-tr {{ font-size: 18px; color: #FFFFFF; font-weight: 600; }}
.meal-text {{
    font-size: 24px;
    color: #E2ECE8;
    line-height: 1.45;
    font-style: italic;
    margin-bottom: 18px;
}}
.audio-bar {{
    background: rgba(0,0,0,0.32);
    border: 1.5px solid rgba(212, 175, 55, 0.3);
    border-radius: 22px;
    padding: 14px 20px;
    display: flex;
    justify-content: space-between;
    align-items: center;
}}
.play-btn {{
    width: 48px;
    height: 48px;
    border-radius: 24px;
    background: #D4AF37;
    color: #071611;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 24px;
    font-weight: 900;
}}
/* Elif-Ba Section */
.elifba-card {{
    background: linear-gradient(145deg, #102B21 0%, #091913 100%);
    border: 2px solid rgba(212, 175, 55, 0.35);
    border-radius: 32px;
    padding: 22px 26px;
    margin-bottom: 20px;
}}
.eb-header {{
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 16px;
}}
.eb-title {{ font-size: 25px; font-weight: 800; color: #F3E5AB; }}
.eb-sub {{ font-size: 19px; color: #D4AF37; font-weight: 700; }}
.letters-grid {{
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 14px;
    direction: rtl;
}}
.letter-box {{
    background: rgba(212, 175, 55, 0.12);
    border: 2px solid rgba(212, 175, 55, 0.4);
    border-radius: 24px;
    padding: 14px 10px;
    text-align: center;
    position: relative;
}}
.letter-box.playing {{
    background: rgba(212, 175, 55, 0.25);
    border-color: #D4AF37;
    box-shadow: 0 0 20px rgba(212, 175, 55, 0.35);
}}
.l-ar {{ font-size: 50px; color: #F3E5AB; line-height: 1.1; margin-bottom: 6px; }}
.l-name {{ font-size: 20px; font-weight: 800; color: #FFFFFF; }}
.l-sub {{ font-size: 15px; color: #A2BEB2; }}
.spk-badge {{
    position: absolute;
    top: 10px;
    left: 10px;
    font-size: 18px;
}}
/* Thematic chips */
.theme-row {{
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 12px;
}}
.theme-pill {{
    background: rgba(15, 41, 32, 0.9);
    border: 1.5px solid rgba(212, 175, 55, 0.32);
    border-radius: 22px;
    padding: 16px 14px;
    text-align: center;
}}
.tp-title {{ font-size: 20px; font-weight: 800; color: #F3E5AB; margin-bottom: 4px; }}
.tp-sub {{ font-size: 16px; color: #9CB6AA; }}
</style></head>
<body>
    {STATUS_BAR_HTML}
    <div class="app-header">
        <div class="brand-row">
            <img class="brand-logo" src="data:image/png;base64,{LOGO_B64}">
            <div class="brand-title">Kur'an & Elif-Bâ</div>
        </div>
        <div class="header-actions">
            <div class="lang-pill">🔊 Sesli Hatim</div>
        </div>
    </div>

    <div class="content">
        <div class="seg-tabs">
            <div class="seg-tab active">📖 Kelime Meal</div>
            <div class="seg-tab">🔤 Sesli Elif-Bâ</div>
            <div class="seg-tab">🌿 Tematik Fihrist</div>
        </div>

        <div class="quran-card">
            <div class="surah-head">
                <div style="font-size:26px; font-weight:800;">İnşirâh Suresi • Ayet 5-6</div>
                <div class="surah-badge">Kelime Kelime Meal</div>
            </div>
            <div class="arabic-verse arabic">فَإِنَّ مَعَ الْعُسْرِ يُسْرًا ﴿٥﴾ إِنَّ مَعَ الْعُسْرِ يُسْرًا ﴿٦﴾</div>
            <div class="wbw-row">
                <div class="wbw-chip">
                    <div class="wbw-ar arabic">فَإِنَّ</div>
                    <div class="wbw-tr">Şüphesiz</div>
                </div>
                <div class="wbw-chip">
                    <div class="wbw-ar arabic">مَعَ</div>
                    <div class="wbw-tr">Beraber</div>
                </div>
                <div class="wbw-chip">
                    <div class="wbw-ar arabic">الْعُسْرِ</div>
                    <div class="wbw-tr">Zorlukla</div>
                </div>
                <div class="wbw-chip">
                    <div class="wbw-ar arabic">يُسْرًا</div>
                    <div class="wbw-tr">Kolaylık vardır</div>
                </div>
            </div>
            <div class="meal-text">"Şüphesiz her güçlükle beraber bir kolaylık vardır. Gerçekten, her güçlükle beraber bir kolaylık vardır."</div>
            <div class="audio-bar">
                <div style="display:flex; align-items:center; gap:14px;">
                    <div class="play-btn">▶</div>
                    <div>
                        <div style="font-size:21px; font-weight:700; color:#FFF;">Mişari Raşid el-Afasi</div>
                        <div style="font-size:17px; color:#9CB6AA;">Ayet Tekrarlı Sesli Tilavet • 1.0x</div>
                    </div>
                </div>
                <div class="surah-badge">Paylaş 📤</div>
            </div>
        </div>

        <div class="elifba-card">
            <div class="eb-header">
                <div class="eb-title">🔤 Sesli Elif-Bâ & Tecvid Rehberi</div>
                <div class="eb-sub">28 Harf • Dokun & Dinle</div>
            </div>
            <div class="letters-grid">
                <div class="letter-box">
                    <span class="spk-badge">🔊</span>
                    <div class="l-ar arabic">ا</div>
                    <div class="l-name">Elif</div>
                    <div class="l-sub">Boğaz Evveli</div>
                </div>
                <div class="letter-box playing">
                    <span class="spk-badge">🔊</span>
                    <div class="l-ar arabic">ب</div>
                    <div class="l-name">Bâ</div>
                    <div class="l-sub">Dudak Harfi</div>
                </div>
                <div class="letter-box">
                    <span class="spk-badge">🔊</span>
                    <div class="l-ar arabic">ت</div>
                    <div class="l-name">Tâ</div>
                    <div class="l-sub">Dil Ucu</div>
                </div>
                <div class="letter-box">
                    <span class="spk-badge">🔊</span>
                    <div class="l-ar arabic">ث</div>
                    <div class="l-name">Sâ</div>
                    <div class="l-sub">Peltek Harf</div>
                </div>
            </div>
        </div>

        <div class="theme-row">
            <div class="theme-pill">
                <div class="tp-title">💚 Huzur & Şifa</div>
                <div class="tp-sub">24 Seçkin Ayet</div>
            </div>
            <div class="theme-pill">
                <div class="tp-title">🌾 Rızık & Bereket</div>
                <div class="tp-sub">18 Seçkin Ayet</div>
            </div>
            <div class="theme-pill">
                <div class="tp-title">🛡️ Sabır & Tevekkül</div>
                <div class="tp-sub">30 Seçkin Ayet</div>
            </div>
        </div>
    </div>

    {get_dock_html("home")}
</body>
</html>
"""

# ---------------------------------------------------------------------------
# SCREEN 4: ABDEST REHBERİ + CUMA MODU + BEYÂN AI DİNİ REHBER
# ---------------------------------------------------------------------------
HTML_SCREEN_4 = f"""<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><style>
{COMMON_CSS}
.content {{ padding: 0 32px; }}
.wudu-card {{
    background: linear-gradient(145deg, #0F2920 0%, #081812 100%);
    border: 2px solid rgba(212, 175, 55, 0.45);
    border-radius: 34px;
    padding: 26px 28px;
    margin-bottom: 20px;
}}
.card-top {{
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 16px;
}}
.fard-pill {{
    background: #D4AF37;
    color: #071611;
    font-size: 19px;
    font-weight: 900;
    padding: 6px 18px;
    border-radius: 18px;
}}
.step-box {{
    background: rgba(255,255,255,0.04);
    border: 1.5px solid rgba(212, 175, 55, 0.28);
    border-radius: 26px;
    padding: 20px 22px;
    margin-bottom: 16px;
}}
.step-title {{
    font-size: 30px;
    font-weight: 800;
    color: #FFFFFF;
    margin-bottom: 8px;
    display: flex;
    align-items: center;
    gap: 12px;
}}
.step-desc {{
    font-size: 21px;
    color: #B8CEC4;
    line-height: 1.45;
    margin-bottom: 14px;
}}
.dua-strip {{
    background: rgba(212, 175, 55, 0.12);
    border: 1.5px solid rgba(212, 175, 55, 0.38);
    border-radius: 20px;
    padding: 12px 18px;
    display: flex;
    justify-content: space-between;
    align-items: center;
}}
.steps-dots {{
    display: flex;
    gap: 8px;
    align-items: center;
}}
.dot {{
    height: 10px;
    flex: 1;
    border-radius: 5px;
    background: rgba(255,255,255,0.12);
}}
.dot.done {{ background: #D4AF37; }}

/* Friday Mode Card */
.friday-card {{
    background: linear-gradient(135deg, #16382B 0%, #0A1E16 100%);
    border: 2px solid rgba(212, 175, 55, 0.45);
    border-radius: 32px;
    padding: 22px 26px;
    margin-bottom: 20px;
}}
.check-grid {{
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 12px;
    margin-top: 14px;
}}
.check-item {{
    background: rgba(0,0,0,0.28);
    border: 1.5px solid rgba(212, 175, 55, 0.35);
    border-radius: 20px;
    padding: 14px 16px;
    display: flex;
    align-items: center;
    gap: 12px;
    font-size: 20px;
    font-weight: 700;
    color: #F3E5AB;
}}
/* Beyan AI Card */
.ai-card {{
    background: linear-gradient(145deg, #0E261D 0%, #071510 100%);
    border: 2px solid rgba(212, 175, 55, 0.38);
    border-radius: 32px;
    padding: 22px 26px;
}}
.ai-q {{
    background: rgba(212, 175, 55, 0.16);
    border: 1.5px solid rgba(212, 175, 55, 0.4);
    border-radius: 22px 22px 6px 22px;
    padding: 12px 20px;
    font-size: 20px;
    font-weight: 700;
    color: #F3E5AB;
    margin-bottom: 14px;
    align-self: flex-end;
}}
.ai-a {{
    background: rgba(255,255,255,0.05);
    border: 1.5px solid rgba(255,255,255,0.12);
    border-radius: 6px 22px 22px 22px;
    padding: 16px 20px;
    font-size: 20px;
    color: #E2ECE8;
    line-height: 1.45;
}}
</style></head>
<body>
    {STATUS_BAR_HTML}
    <div class="app-header">
        <div class="brand-row">
            <img class="brand-logo" src="data:image/png;base64,{LOGO_B64}">
            <div class="brand-title">İbadet Rehberi</div>
        </div>
        <div class="header-actions">
            <div class="lang-pill">✨ Diyanet Uyumlu</div>
        </div>
    </div>

    <div class="content">
        <div class="wudu-card">
            <div class="card-top">
                <div style="font-size:26px; font-weight:800; color:#F3E5AB;">💧 Adım Adım Abdest Rehberi</div>
                <div class="fard-pill">4 / 11 • FARZ</div>
            </div>
            <div class="step-box">
                <div class="step-title"><span>4. Adım: Yüzü Yıkamak</span></div>
                <div class="step-desc">Alın saç bitiminden çene altına ve iki kulak yumuşağı arasına kadar yüz üç defa eksiksiz yıkanır.</div>
                <div class="dua-strip">
                    <div>
                        <div style="font-size:18px; font-weight:700; color:#F3E5AB;">🔊 Sesli Abdest Duası & Anlatım</div>
                        <div style="font-size:16px; color:#9CB6AA;">"Allah'ım! Yüzlerin ağardığı günde yüzümü ak eyle..."</div>
                    </div>
                    <div class="fard-pill" style="padding:8px 16px;">Dinle ▶</div>
                </div>
            </div>
            <div class="steps-dots">
                <div class="dot done"></div><div class="dot done"></div><div class="dot done"></div><div class="dot done"></div>
                <div class="dot"></div><div class="dot"></div><div class="dot"></div><div class="dot"></div>
            </div>
        </div>

        <div class="friday-card">
            <div style="display:flex; justify-content:space-between; align-items:center;">
                <div style="font-size:26px; font-weight:800; color:#F3E5AB;">🕌 Cuma Modu & Sünnetler</div>
                <div class="lang-pill" style="font-size:18px; padding:4px 14px;">Hayırlı Cumalar</div>
            </div>
            <div class="check-grid">
                <div class="check-item">✅ Kehf Suresi Oku</div>
                <div class="check-item">✅ 100 Salavat (100/100)</div>
                <div class="check-item">✅ Gusül & Misvak</div>
                <div class="check-item">✨ İcabet Saati Duası</div>
            </div>
        </div>

        <div class="ai-card">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px;">
                <div style="font-size:25px; font-weight:800; color:#F3E5AB;">✨ Beyân AI • Dini Rehber</div>
                <div style="font-size:17px; color:#4CD964; font-weight:700;">● Ayet & Hadis Kaynaklı</div>
            </div>
            <div class="ai-q">"İkindi namazının sünneti nasıl kılınır?"</div>
            <div class="ai-a">
                İkindi namazının 4 rekat sünneti <b>gayr-i müekked</b> sünnettir. İlk oturuşta <i>Ettehiyyâtü</i>'den sonra <b>Salli-Bârik</b> duaları okunur; 3. rekata kalkınca <b>Sübhâneke</b> okunup Eûzü-Besmele ile devam edilir.
            </div>
        </div>
    </div>

    {get_dock_html("prayers")}
</body>
</html>
"""

# ---------------------------------------------------------------------------
# SCREEN 5: AKILLI ZİKİRMATİK + DOĞRULANMIŞ DUALAR (RESİM OLARAK İNDİR)
# ---------------------------------------------------------------------------
HTML_SCREEN_5 = f"""<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><style>
{COMMON_CSS}
.content {{ padding: 0 32px; }}
.seg-tabs {{
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    background: rgba(15, 41, 32, 0.9);
    border: 1.8px solid rgba(212, 175, 55, 0.35);
    border-radius: 26px;
    padding: 8px;
    margin-bottom: 20px;
}}
.seg-tab {{
    text-align: center;
    padding: 14px 8px;
    font-size: 22px;
    font-weight: 700;
    color: #9CB6AA;
    border-radius: 20px;
}}
.seg-tab.active {{
    background: #D4AF37;
    color: #071611;
}}
.dhikr-card {{
    background: linear-gradient(145deg, #0F2920 0%, #081812 100%);
    border: 2px solid rgba(212, 175, 55, 0.42);
    border-radius: 34px;
    padding: 24px 28px;
    text-align: center;
    margin-bottom: 22px;
}}
.dhikr-ar {{
    font-size: 64px;
    color: #F3E5AB;
    line-height: 1.3;
    margin-bottom: 6px;
}}
.dhikr-tr {{ font-size: 30px; font-weight: 800; color: #FFFFFF; margin-bottom: 4px; }}
.dhikr-mean {{ font-size: 20px; color: #A2BEB2; font-style: italic; margin-bottom: 22px; }}

.ring-wrap {{
    width: 390px;
    height: 390px;
    border-radius: 195px;
    margin: 0 auto 20px auto;
    background: radial-gradient(circle, rgba(212,175,55,0.14) 0%, rgba(7,22,17,0.95) 72%);
    border: 12px solid #D4AF37;
    box-shadow: 0 0 50px rgba(212, 175, 55, 0.32), inset 0 0 40px rgba(212, 175, 55, 0.18);
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
}}
.ring-num {{ font-size: 108px; font-weight: 900; color: #FFFFFF; line-height: 1; }}
.ring-target {{ font-size: 28px; font-weight: 700; color: #D4AF37; margin-top: 8px; }}
.ring-tap {{ font-size: 19px; letter-spacing: 3px; color: #9CB6AA; margin-top: 8px; font-weight: 700; }}

/* Verified Daily Dua Card with One-Tap Download */
.dua-card {{
    background: linear-gradient(145deg, #102B21 0%, #081812 100%);
    border: 2px solid rgba(212, 175, 55, 0.4);
    border-radius: 32px;
    padding: 24px 28px;
}}
.dua-top {{
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 12px;
}}
.dua-ar {{
    font-size: 40px;
    color: #F3E5AB;
    text-align: right;
    line-height: 1.5;
    margin-bottom: 10px;
}}
.dua-tr {{
    font-size: 21px;
    color: #E2ECE8;
    font-style: italic;
    line-height: 1.4;
    margin-bottom: 16px;
}}
.dua-actions {{
    display: flex;
    justify-content: space-between;
    align-items: center;
}}
.btn-gold {{
    background: #D4AF37;
    color: #071611;
    font-size: 20px;
    font-weight: 800;
    padding: 10px 22px;
    border-radius: 20px;
    display: inline-flex;
    align-items: center;
    gap: 8px;
}}
</style></head>
<body>
    {STATUS_BAR_HTML}
    <div class="app-header">
        <div class="brand-row">
            <img class="brand-logo" src="data:image/png;base64,{LOGO_B64}">
            <div class="brand-title">Zikirmatik & Dua</div>
        </div>
        <div class="header-actions">
            <div class="lang-pill">📿 99 Esmaü'l-Hüsna</div>
        </div>
    </div>

    <div class="content">
        <div class="seg-tabs">
            <div class="seg-tab active">📿 Sesli Zikirmatik</div>
            <div class="seg-tab">📊 İbadet & Kaza Takibi</div>
        </div>

        <div class="dhikr-card">
            <div class="dhikr-ar arabic">سُبْحَانَ اللَّهِ وَبِحَمْدِهِ</div>
            <div class="dhikr-tr">Sübhanallahi ve bi-hamdihi</div>
            <div class="dhikr-mean">"Allah'ı hamd ile tesbih ederim, O her türlü eksiklikten uzaktır"</div>

            <div class="ring-wrap">
                <div class="ring-num">33</div>
                <div class="ring-target">/ 33 Tamamlandı</div>
                <div class="ring-tap">DOKUN & ZİKRET</div>
            </div>
        </div>

        <div class="dua-card">
            <div class="dua-top">
                <div style="font-size:23px; font-weight:800; color:#F3E5AB;">🤲 Günün Sahih Duası</div>
                <div style="font-size:18px; color:#D4AF37; font-weight:700;">Sünen-i İbni Mâce (925)</div>
            </div>
            <div class="dua-ar arabic">اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا، وَرِزْقًا طَيِّبًا، وَعَمَلًا مُتَقَبَّلًا</div>
            <div class="dua-tr">"Allah'ım! Senden faydalı ilim, temiz ve helal rızık ve kabul olunan salih amel dilerim."</div>
            <div class="dua-actions">
                <div class="btn-gold">📥 Resim Olarak İndir</div>
                <div class="lang-pill" style="font-size:19px;">📤 Hikayede Paylaş</div>
            </div>
        </div>
    </div>

    {get_dock_html("tasbih")}
</body>
</html>
"""

def render_html_to_png(html_content, out_png_path):
    html_path = out_png_path.replace(".png", ".html")
    with open(html_path, "w", encoding="utf-8") as f:
        f.write(html_content)
    cmd = [
        CHROME_PATH,
        "--headless=new",
        "--disable-gpu",
        "--hide-scrollbars",
        "--window-size=884,1844",
        "--device-scale-factor=1",
        f"--screenshot={out_png_path}",
        f"file:///{html_path.replace(os.sep, '/')}"
    ]
    subprocess.run(cmd, check=True)
    print(f"Rendered HTML screen -> {out_png_path}")

# Render the 4 new custom screens
s1_path = os.path.join(TEMP_DIR, "screen_1_home.png")
s3_path = os.path.join(TEMP_DIR, "screen_3_quran_elifba.png")
s4_path = os.path.join(TEMP_DIR, "screen_4_wudu_friday_ai.png")
s5_path = os.path.join(TEMP_DIR, "screen_5_tasbih_dua.png")

render_html_to_png(HTML_SCREEN_1, s1_path)
render_html_to_png(HTML_SCREEN_3, s3_path)
render_html_to_png(HTML_SCREEN_4, s4_path)
render_html_to_png(HTML_SCREEN_5, s5_path)

# Existing authentic screens for Lock Screen Widget (#2) and Free Trial Paywall (#6)
s2_path = os.path.join(USER_UPLOADED_DIR, "media_1791460530746.jpg")
s6_path = os.path.join(USER_UPLOADED_DIR, "media_1791307128944.png")

SCREENSHOT_MAP = {
    1: s1_path,
    2: s2_path,
    3: s3_path,
    4: s4_path,
    5: s5_path,
    6: s6_path,
}

BANNER_DATA = [
    {
        "id": 1,
        "badge": "DİYANET İLE %100 UYUMLU",
        "title": "Namaz Vakitleri & Yaşam",
        "subtitle": "Milimetrik vakit hesaplama, canlı geri sayım ve yeni Manevi Yaşam Merkezi",
        "filename": "screenshot_1_namaz_vakitleri.png"
    },
    {
        "id": 2,
        "badge": "KİLİT EKRANI & ANA EKRAN",
        "title": "Kilit Ekranı Canlı Sayaç",
        "subtitle": "Telefon kilidini açmadan yaklaşan vakti ve günün âyetini takip edin",
        "filename": "screenshot_2_kilit_ekrani_widget.png"
    },
    {
        "id": 3,
        "badge": "KUR'AN, MEAL & SESLİ ELİF-BÂ",
        "title": "Kur'an-ı Kerim & Elif-Bâ",
        "subtitle": "Kelime kelime meal, sesli tilavet, 28 harf sesli Elif-Bâ ve Tematik Fihrist",
        "filename": "screenshot_3_kuran_ve_elifba.png"
    },
    {
        "id": 4,
        "badge": "YENİ NESİL İBADET REHBERİ",
        "title": "Abdest, Cuma Modu & AI",
        "subtitle": "Adım adım sesli Abdest Rehberi, Kehf Suresi Cuma Modu ve kaynaklı Beyân AI",
        "filename": "screenshot_4_abdest_cuma_ai.png"
    },
    {
        "id": 5,
        "badge": "AKILLI ZİKİRMATİK & DUALAR",
        "title": "Sesli Zikir & Dualar",
        "subtitle": "Esmaü'l-Hüsna, dokunsal sayaç ve tek tıkla resimli dua kartı indirme",
        "filename": "screenshot_5_zikirmatik_ve_dualar.png"
    },
    {
        "id": 6,
        "badge": "3 GÜN ÜCRETSİZ DENEME",
        "title": "Beyân Pro & ₺49,99 / Ay",
        "subtitle": "3 gün ücretsiz deneyin, dilediğiniz an iptal edin. 8 dil ve reklamsız erişim",
        "filename": "screenshot_6_beyan_pro.png"
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
        alpha = int(28 * (1.0 - r / max_radius))
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
    phone_draw.rounded_rectangle([0, 0, phone_w, phone_h], radius=corner_radius, fill=(24, 32, 28, 255), outline=(212, 175, 55, 130), width=3)
    phone_layer.paste(rounded_screen, (bezel, bezel), rounded_screen)

    # Dynamic Island
    di_w = 190
    di_h = 48
    di_x = (phone_w - di_w) // 2
    di_y = bezel + 18
    phone_draw.rounded_rectangle([di_x, di_y, di_x + di_w, di_y + di_h], radius=24, fill=(0, 0, 0, 255))
    phone_draw.ellipse([di_x + di_w - 38, di_y + 14, di_x + di_w - 18, di_y + 34], fill=(18, 22, 28, 255))

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

# Clean old desktop files first so there is no confusion
for old_f in os.listdir(DESKTOP_DIR):
    if old_f.endswith(".png"):
        try:
            os.remove(os.path.join(DESKTOP_DIR, old_f))
        except Exception:
            pass

for item in BANNER_DATA:
    canvas = create_gradient_background()
    draw = ImageDraw.Draw(canvas)

    font_badge = ImageFont.truetype(FONT_BOLD, 32)
    font_title = ImageFont.truetype(FONT_BOLD, 72)
    font_sub = ImageFont.truetype(FONT_REG, 39)

    curr_y = 125

    badge_text = item["badge"]
    badge_bbox = draw.textbbox((0, 0), badge_text, font=font_badge)
    badge_w = badge_bbox[2] - badge_bbox[0] + 50
    badge_h = badge_bbox[3] - badge_bbox[1] + 24
    badge_x = (WIDTH - badge_w) // 2

    pill_img = Image.new("RGBA", (badge_w, badge_h), (0, 0, 0, 0))
    pill_draw = ImageDraw.Draw(pill_img)
    pill_draw.rounded_rectangle([0, 0, badge_w, badge_h], radius=badge_h // 2, fill=(212, 175, 55, 34), outline=(212, 175, 55, 150), width=2)
    canvas.paste(pill_img, (badge_x, curr_y), pill_img)
    draw.text((badge_x + 25, curr_y + 10), badge_text, font=font_badge, fill=(243, 229, 171))

    curr_y += badge_h + 42

    title_text = item["title"]
    title_bbox = draw.textbbox((0, 0), title_text, font=font_title)
    title_w = title_bbox[2] - title_bbox[0]
    draw.text(((WIDTH - title_w) // 2, curr_y), title_text, font=font_title, fill=(255, 255, 255))
    curr_y += (title_bbox[3] - title_bbox[1]) + 26

    sub_lines = wrap_text(item["subtitle"], font_sub, 990, draw)
    for line in sub_lines:
        line_bbox = draw.textbbox((0, 0), line, font=font_sub)
        line_w = line_bbox[2] - line_bbox[0]
        draw.text(((WIDTH - line_w) // 2, curr_y), line, font=font_sub, fill=(168, 188, 180))
        curr_y += (line_bbox[3] - line_bbox[1]) + 14

    screen_path = SCREENSHOT_MAP[item["id"]]
    phone_mock, shadow_pad = create_phone_mockup(screen_path)

    mock_x = (WIDTH - phone_mock.width) // 2
    mock_y = 655 - shadow_pad
    canvas.paste(phone_mock, (mock_x, mock_y), phone_mock)

    final_rgb = canvas.convert("RGB")
    out_path = os.path.join(OUTPUT_DIR, item["filename"])
    final_rgb.save(out_path, "PNG", quality=100)

    desktop_out = os.path.join(DESKTOP_DIR, item["filename"])
    final_rgb.save(desktop_out, "PNG", quality=100)
    print(f"Saved {item['filename']}")

print("ALL 6 SCREENSHOTS GENERATED SUCCESSFULLY!")

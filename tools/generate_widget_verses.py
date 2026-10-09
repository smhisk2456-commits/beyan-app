"""quran.db'den kilit ekranına sığacak ve kalbe dokunan duygusal/huzur veren kısa ayetleri seçip Swift veri dosyası üretir."""
import sqlite3, re

ROOT = r'C:\Users\smhis\.gemini\antigravity\scratch\islamic_app'
c = sqlite3.connect(ROOT + r'\assets\database\quran.db')
surahs = {sid: name for sid, name in c.execute("select id, name_turkish from surah")}
rows = c.execute(
    "select surah_id, verse_number, turkish_meaning from verse order by surah_id, verse_number"
).fetchall()

# 1. En sevilen, derin ve kalbe dokunan seçkin Kur'an incileri (Duygusal, şefkat, ümit ve teselli ayetleri)
EMOTIONAL_GEMS = [
    ("İnşirâh 94:6", "Şüphesiz her güçlükle beraber bir kolaylık vardır."),
    ("Duhâ 93:3", "Rabbin seni terk etmedi ve sana darılmadı."),
    ("Duhâ 93:5", "Rabbin sana verecek ve sen razı olacaksın."),
    ("Ra'd 13:28", "Bilin ki, kalpler ancak Allah'ı anmakla huzur bulur."),
    ("Yûsuf 12:86", "Ben hüzün ve kederimi ancak Allah'a arz ederim."),
    ("Bakara 2:186", "Kullarım Beni sorarlarsa, şüphesiz Ben onlara çok yakınım."),
    ("Bakara 2:152", "Beni anın ki Ben de sizi anayım; Bana şükredin."),
    ("Bakara 2:153", "Ey iman edenler! Sabır ve namazla yardım dileyin."),
    ("Zümer 39:36", "Allah kuluna kâfi değil midir?"),
    ("Zümer 39:53", "Allah'ın rahmetinden ümidinizi kesmeyin."),
    ("Tevbe 9:40", "Üzülme, çünkü Allah bizimle beraberdir."),
    ("Tâhâ 20:46", "Korkmayın, şüphesiz Ben sizinle beraberim; işitir ve görürüm."),
    ("Tâhâ 20:25-26", "Rabbim! Gönlüme ferahlık ver, işimi bana kolaylaştır."),
    ("Talâk 65:3", "Kim Allah'a tevekkül ederse, O kendisine yeter."),
    ("Mü'min 40:60", "Rabbiniz buyurdu ki: Bana dua edin, size icabet edeyim."),
    ("Hûd 11:90", "Şüphesiz Rabbim merhametlidir, çok sevendir."),
    ("Âl-i İmrân 3:139", "Gevşemeyin, üzülmeyin; inanmışsanız üstün sizsiniz."),
    ("Yûnus 10:62", "İyi bilin ki, Allah'ın dostlarına asla korku ve hüzün yoktur."),
    ("Hûd 11:115", "Sabret; Allah güzel davrananların mükâfatını zayi etmez."),
    ("Nisâ 4:132", "Göklerde ve yerde ne varsa Allah'ındır. Vekil olarak O yeter."),
    ("A'râf 7:55", "Rabbinize gönülden ve gizlice yalvarın."),
    ("Kâf 50:16", "Biz insana şah damarından daha yakınız."),
    ("Âl-i İmrân 3:173", "Allah bize yeter; O ne güzel vekildir."),
    ("İbrâhîm 14:39", "Şüphesiz Rabbim duayı hakkıyla işitendir."),
    ("Bakara 2:286", "Allah hiçbir kimseye gücünün yettiğinden fazlasını yüklemez."),
    ("A'râf 7:56", "Şüphesiz Allah'ın rahmeti iyilik edenlere pek yakındır."),
    ("İsrâ 17:24", "Rabbim! Onlar beni küçükken koruduğu gibi Sen de merhamet et."),
    ("Kehf 18:10", "Rabbimiz! Bize katından bir rahmet ver ve işimizde kolaylık lütfet."),
    ("Şûrâ 42:25", "O, kullarının tövbesini kabul eden, günahları bağışlayandır."),
    ("Âl-i İmrân 3:159", "Şüphesiz Allah, tevekkül edenleri sever."),
    ("Âl-i İmrân 3:146", "Allah sabredenleri sever."),
    ("İbrâhîm 14:40", "Rabbim! Beni ve neslimi namazı dosdoğru kılanlardan eyle."),
    ("Tahrîm 66:8", "Rabbimiz! Nurumuzu tamamla ve bizi bağışla."),
    ("Bakara 2:257", "Allah inananların dostudur; onları karanlıklardan nura çıkarır."),
    ("Fussilet 41:34", "Kötülüğü en güzel olanla sav; düşmanın sımsıcak bir dost oluverir."),
    ("Kalem 68:4", "Şüphesiz sen pek yüce bir ahlak üzerindesin.")
]

POSITIVE = ('rahmet', 'merhamet', 'sabr', 'sabır', 'şükr', 'şükür', 'namaz', 'dua', 'bağışla',
            'affed', 'tevekkül', 'güven', 'kolaylık', 'huzur', 'cennet', 'iyilik', 'rabbimiz', 'sever',
            'yakın', 'mağfiret', 'nimet', 'hidayet', 'zikr', 'anın', 'tövbe', 'müjde', 'yardım',
            'kalp', 'gönül', 'ferah', 'keder', 'hüzün', 'şah damar', 'terk', 'darıl', 'üzülme', 'korkma')
NEGATIVE = ('azab', 'azap', 'cehennem', 'inkâr', 'inkar', 'alay', 'lanet', 'kâfir', 'kafir', 'münafık',
            'yalanla', 'helak', 'ateş', 'zalim', 'buzağı', 'öldür', 'savaş', 'cezas', 'kötü', 'puta',
            'şeytan', 'sapık', 'sapıt', 'gazab', 'yahudi', 'hristiyan', 'firavun', 'mühürle', 'günahkâr')

db_cands = []
seen_texts = {text for _, text in EMOTIONAL_GEMS}

for sid, vn, text in rows:
    t = re.sub(r'\s+', ' ', (text or '')).strip()
    low = t.lower()
    # Kilit ekranında 3-4 satıra tam sığacak (asla kesilmeyecek), anlamı bütün, olumlu kısa ayetler
    if not (20 <= len(t) <= 85) or not t.endswith(('.', '!')):
        continue
    if low.startswith(('ve ', 'ancak', 'yahut', 'veya', 'onlar', 'işte', 'sonra', 'eğer', 'vazgeç', 'ölümünüz', 'ey israiloğulları')):
        continue
    if any(n in low for n in NEGATIVE) or not any(p in low for p in POSITIVE):
        continue
    if t in seen_texts:
        continue
    seen_texts.add(t)
    db_cands.append((f"{surahs[sid]} {sid}:{vn}", t))

# Bütün listeyi birleştir: Önce en duygusal ve seçkin inciler, ardından veritabanındaki zengin ayetler
all_picked = EMOTIONAL_GEMS + db_cands

def esc(s):
    return s.replace('\\', '\\\\').replace('"', '\\"')

lines = [
    '// OTOMATİK ÜRETİLDİ – tools/generate_widget_verses.py',
    '// Kaynak: assets/database/quran.db (Türkçe meal)',
    '// Kilit ekranında asla kesilmeyecek (<= 85 karakter) zengin ve duygusal ayet havuzu',
    '',
    'struct WidgetVerseData {',
    '    static let all: [(ref: String, text: String)] = [',
]
for ref, t in all_picked:
    lines.append(f'        ("{esc(ref)}", "{esc(t)}"),')
lines += ['    ]', '}', '']

out = ROOT + r'\ios\IslamicAppWidget\WidgetVerseData.swift'
with open(out, 'w', encoding='utf-8') as f:
    f.write('\n'.join(lines))
print(f'Gems: {len(EMOTIONAL_GEMS)}, DB Cands: {len(db_cands)}, Total: {len(all_picked)}')

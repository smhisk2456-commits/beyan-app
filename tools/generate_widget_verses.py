"""quran.db'den kilit ekranına sığacak kısa ayetleri seçip Swift veri dosyası üretir."""
import sqlite3, re

ROOT = r'C:\Users\smhis\.gemini\antigravity\scratch\islamic_app'
c = sqlite3.connect(ROOT + r'\assets\database\quran.db')
surahs = {sid: name for sid, name in c.execute("select id, name_turkish from surah")}
rows = c.execute(
    "select surah_id, verse_number, turkish_meaning from verse order by surah_id, verse_number"
).fetchall()

POSITIVE = ('rahmet', 'merhamet', 'sabr', 'sabır', 'şükr', 'şükür', 'namaz', 'dua', 'bağışla',
            'affed', 'tevekkül', 'güven', 'kolaylık', 'huzur', 'cennet', 'iyilik', 'rabbimiz', 'sever',
            'yakın', 'mağfiret', 'nimet', 'hidayet', 'zikr', 'anın', 'tövbe', 'müjde', 'yardım')
NEGATIVE = ('azab', 'azap', 'cehennem', 'inkâr', 'inkar', 'alay', 'lanet', 'kâfir', 'kafir', 'münafık',
            'yalanla', 'helak', 'ateş', 'zalim', 'buzağı', 'öldür', 'savaş', 'cezas', 'kötü', 'puta',
            'şeytan', 'sapık', 'sapıt', 'gazab', 'yahudi', 'hristiyan', 'firavun', 'mühürle', 'günahkâr')

cands = []
for sid, vn, text in rows:
    t = re.sub(r'\s+', ' ', (text or '')).strip()
    low = t.lower()
    # Kilit ekranında 3 satıra sığacak, anlamı tek başına bütün, olumlu kısa ayetler
    if not (40 <= len(t) <= 125) or not t.endswith(('.', '!')):
        continue
    if low.startswith(('ve ', 'ancak', 'yahut', 'veya', 'onlar', 'işte', 'sonra', 'eğer', 'vazgeç', 'ölümünüz', 'ey israiloğulları')):
        continue
    if any(n in low for n in NEGATIVE) or not any(p in low for p in POSITIVE):
        continue
    cands.append((sid, vn, t))

# Tüm Kur'an'a yayılacak şekilde eşit aralıklı en fazla 300 ayet seç
step = max(1, len(cands) // 300)
picked = cands[::step][:300]

def esc(s):
    return s.replace('\\', '\\\\').replace('"', '\\"')

lines = [
    '// OTOMATİK ÜRETİLDİ – tools/generate_widget_verses.py',
    '// Kaynak: assets/database/quran.db (Türkçe meal)',
    '',
    'struct WidgetVerseData {',
    '    static let all: [(ref: String, text: String)] = [',
]
for sid, vn, t in picked:
    lines.append(f'        ("{esc(surahs[sid])} {sid}:{vn}", "{esc(t)}"),')
lines += ['    ]', '}', '']

out = ROOT + r'\ios\IslamicAppWidget\WidgetVerseData.swift'
with open(out, 'w', encoding='utf-8') as f:
    f.write('\n'.join(lines))
print('candidates', len(cands), 'picked', len(picked))

-- ================================================================
-- quran.db şema tanımı
-- Bu dosya referans amaçlıdır; gerçek DB SQLite binary formatındadır.
-- Hazır Kur'an DB'si için: https://github.com/quran/quran-json
-- veya: https://tanzil.net/wiki/Tanzil_Download
-- ================================================================

-- ── Sure Tablosu ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS surah (
    id              INTEGER PRIMARY KEY,        -- 1 ile 114 arasında
    name_arabic     TEXT    NOT NULL,           -- ör: الفاتحة
    name_turkish    TEXT    NOT NULL,           -- ör: Fatiha
    name_english    TEXT    NOT NULL,           -- ör: The Opening
    verse_count     INTEGER NOT NULL,           -- Toplam ayet sayısı
    revelation_type TEXT    NOT NULL            -- 'meccan' veya 'medinan'
);

-- ── Ayet Tablosu ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS verse (
    id               INTEGER PRIMARY KEY AUTOINCREMENT,
    surah_id         INTEGER NOT NULL,
    verse_number     INTEGER NOT NULL,
    arabic_text      TEXT    NOT NULL,          -- Harekeli Arapça metin
    transliteration  TEXT,                      -- Türkçe okunuş (opsiyonel)
    turkish_meaning  TEXT    NOT NULL,          -- Türkçe meal (Diyanet)
    FOREIGN KEY (surah_id) REFERENCES surah(id)
);

-- Performans için index
CREATE INDEX IF NOT EXISTS idx_verse_surah ON verse(surah_id);
CREATE INDEX IF NOT EXISTS idx_verse_number ON verse(surah_id, verse_number);

-- ── Günlük Dua Tablosu ───────────────────────────────────────
CREATE TABLE IF NOT EXISTS daily_dua (
    id               INTEGER PRIMARY KEY AUTOINCREMENT,
    arabic_text      TEXT    NOT NULL,          -- Harekeli Arapça
    transliteration  TEXT,                      -- Okunuş
    turkish_meaning  TEXT    NOT NULL,          -- Türkçe anlamı
    reference        TEXT    NOT NULL           -- Kaynak
);

-- ── Örnek Veri – Fatiha Suresi ───────────────────────────────
INSERT OR IGNORE INTO surah VALUES (
    1, 'الفاتحة', 'Fatiha', 'The Opening', 7, 'meccan'
);

INSERT OR IGNORE INTO verse (surah_id, verse_number, arabic_text, transliteration, turkish_meaning) VALUES
(1, 1, 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
    'Bismillâhirrahmânirrahîm',
    'Rahman ve Rahim olan Allah\'ın adıyla'),
(1, 2, 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
    'Elhamdülillâhi rabbil âlemîn',
    'Hamd, âlemlerin Rabbi Allah\'a mahsustur'),
(1, 3, 'الرَّحْمَنِ الرَّحِيمِ',
    'Errahmânirrahîm',
    'O, Rahman\'dır, Rahim\'dir'),
(1, 4, 'مَالِكِ يَوْمِ الدِّينِ',
    'Mâliki yevmiddîn',
    'Din gününün (hesap gününün) sahibidir'),
(1, 5, 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
    'İyyâke na''budü ve iyyâke nesteîn',
    'Yalnız sana ibadet ederiz ve yalnız senden yardım dileriz'),
(1, 6, 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
    'İhdinas sırâtal müstekîm',
    'Bizi doğru yola ilet'),
(1, 7, 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
    'Sırâtallezîne en''amte aleyhim ğayrilmağdûbi aleyhim veleddâllîn',
    'Nimet verdiğin kimselerin yoluna; gazaba uğramışların ve sapkınların yoluna değil');

-- ── Örnek Günlük Dua ─────────────────────────────────────────
INSERT OR IGNORE INTO daily_dua (arabic_text, transliteration, turkish_meaning, reference) VALUES
(
    'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
    'Rabbenâ âtinâ fiddünyâ haseneten ve fil âhirati haseneten ve kınâ azâbennâr',
    'Rabbimiz! Bize dünyada iyilik, ahirette de iyilik ver ve bizi cehennem azabından koru.',
    'Bakara Suresi, 201. Ayet'
),
(
    'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي',
    'Rabbişrahlî sadrî ve yessirlî emrî',
    'Rabbim! Göğsümü aç, işimi kolaylaştır.',
    'Taha Suresi, 25-26. Ayetler'
),
(
    'لَا إِلَهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
    'Lâ ilâhe illâ ente subhâneke innî küntü minezzâlimîn',
    'Senden başka ilah yoktur. Sen Sübhansın. Şüphesiz ben zalimlerden oldum.',
    'Enbiya Suresi, 87. Ayet'
);

/// Comprehensive Multilingual Localizations for Verified Duas
/// Provides English and Arabic titles, translations, and references for all 46 verified duas.
class DuaTranslationEntry {
  final String titleEn;
  final String titleAr;
  final String meaningEn;
  final String meaningAr;
  final String referenceEn;
  final String referenceAr;

  const DuaTranslationEntry({
    required this.titleEn,
    required this.titleAr,
    required this.meaningEn,
    required this.meaningAr,
    required this.referenceEn,
    required this.referenceAr,
  });
}

const Map<String, DuaTranslationEntry> kDuaTranslations = {
  // ── 1. SABAH DUALARI ──────────────────────────────────────────────────────────
  'sabah_1': DuaTranslationEntry(
    titleEn: 'Morning Remembrance & Praise',
    titleAr: 'أذكار الصباح والحمد',
    meaningEn: 'We have reached the morning and the kingdom belongs to Allah, and all praise is for Allah. There is no deity worthy of worship except Allah alone, without partner; to Him belongs the dominion and to Him belongs the praise, and He is over all things capable.',
    meaningAr: 'أصبحنا وأصبح الملك لله، والحمد لله، لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير.',
    referenceEn: 'Sahih Muslim (2723)',
    referenceAr: 'صحيح مسلم (٢٧٢٣)',
  ),
  'sabah_2': DuaTranslationEntry(
    titleEn: 'Sayyid al-Istighfar (Master Supplication for Forgiveness)',
    titleAr: 'سيد الاستغفار',
    meaningEn: 'O Allah, You are my Lord, none has the right to be worshiped but You. You created me and I am Your slave, and I am faithful to my covenant and my promise to You as much as I can. I seek refuge in You from the evil of what I have done. I acknowledge before You Your blessing upon me, and I confess to You my sin. So forgive me, for none forgives sins except You.',
    meaningAr: 'اللهم أنت ربي لا إله إلا أنت، خلقتني وأنا عبدك، وأنا على عهدك ووعدك ما استطعت، أعوذ بك من شر ما صنعت، أبوء لك بنعمتك علي، وأبوء لك بذنبي فاغفر لي فإنه لا يغفر الذنوب إلا أنت.',
    referenceEn: 'Sahih al-Bukhari (6306)',
    referenceAr: 'صحيح البخاري (٦٣٠٦)',
  ),
  'sabah_3': DuaTranslationEntry(
    titleEn: 'Protection from All Harm',
    titleAr: 'دعاء الحماية من كل ضرر',
    meaningEn: 'In the Name of Allah, with Whose Name nothing can cause harm in the earth nor in the heavens, and He is the All-Hearing, the All-Knowing.',
    meaningAr: 'بسم الله الذي لا يضر مع اسمه شيء في الأرض ولا في السماء وهو السميع العليم.',
    referenceEn: 'Sunan Abi Dawud (5088), Jami` at-Tirmidhi (3388)',
    referenceAr: 'سنن أبي داود (٥٠٨٨)، جامع الترمذي (٣٣٨٨)',
  ),
  'sabah_4': DuaTranslationEntry(
    titleEn: 'Supplication for Health & Well-being',
    titleAr: 'سؤال العافية في الجسد والسمع والبصر',
    meaningEn: 'O Allah, grant soundness to my body. O Allah, grant soundness to my hearing. O Allah, grant soundness to my sight. There is no deity worthy of worship except You.',
    meaningAr: 'اللهم عافني في بدني، اللهم عافني في سمعي، اللهم عافني في بصري، لا إله إلا أنت.',
    referenceEn: 'Sunan Abi Dawud (5090)',
    referenceAr: 'سنن أبي داود (٥٠٩٠)',
  ),
  'sabah_5': DuaTranslationEntry(
    titleEn: 'Beneficial Knowledge, Good Provision & Accepted Deeds',
    titleAr: 'طلب العلم النافع والرزق الطيب والعمل الصالح',
    meaningEn: 'O Allah, I ask You for beneficial knowledge, good provision, and accepted deeds.',
    meaningAr: 'اللهم إني أسألك علماً نافعاً، ورزقاً طيباً، وعملاً متقبلاً.',
    referenceEn: 'Sunan Ibn Majah (925)',
    referenceAr: 'سنن ابن ماجه (٩٢٥)',
  ),

  // ── 2. AKŞAM DUALARI ──────────────────────────────────────────────────────────
  'aksam_1': DuaTranslationEntry(
    titleEn: 'Evening Remembrance & Praise',
    titleAr: 'أذكار المساء والحمد',
    meaningEn: 'We have reached the evening and the dominion belongs to Allah, and all praise is for Allah. There is no deity worthy of worship except Allah alone, without partner; to Him belongs the dominion and to Him belongs the praise, and He is over all things capable.',
    meaningAr: 'أمسينا وأمسى الملك لله، والحمد لله، لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير.',
    referenceEn: 'Sahih Muslim (2723)',
    referenceAr: 'صحيح مسلم (٢٧٢٣)',
  ),
  'aksam_2': DuaTranslationEntry(
    titleEn: 'Protection from the Evil of Creation',
    titleAr: 'الاستعاذة بكلمات الله التامات',
    meaningEn: 'I seek refuge in the perfect words of Allah from the evil of that which He has created.',
    meaningAr: 'أعوذ بكلمات الله التامات من شر ما خلق.',
    referenceEn: 'Sahih Muslim (2709)',
    referenceAr: 'صحيح مسلم (٢٧٠٩)',
  ),
  'aksam_3': DuaTranslationEntry(
    titleEn: 'Amanar-Rasul (Protective Verses of the Night)',
    titleAr: 'آمن الرسول (خواتيم سورة البقرة)',
    meaningEn: 'The Messenger has believed in what was revealed to him from his Lord, and [so have] the believers. All of them have believed in Allah and His angels and His books and His messengers.',
    meaningAr: 'آمَنَ الرَّسُولُ بِمَا أُنْزِلَ إِلَيْهِ مِنْ رَبِّهِ وَالْمُؤْمِنُونَ ۚ كُلٌّ آمَنَ بِاللَّهِ وَمَلَائِكَتِهِ وَكُتُبِهِ وَرُسُلِهِ.',
    referenceEn: 'Surah Al-Baqarah 2:285 / Sahih al-Bukhari (5008)',
    referenceAr: 'سورة البقرة ٢٨٥ / صحيح البخاري (٥٠٠٨)',
  ),
  'aksam_4': DuaTranslationEntry(
    titleEn: 'Evening Al-Mu\'awwidhat (Ikhlas, Falaq, Nas)',
    titleAr: 'قراءة الإخلاص والمعوذتين في المساء',
    meaningEn: 'Say: He is Allah, [who is] One... Say: I seek refuge in the Lord of daybreak... Say: I seek refuge in the Lord of mankind...',
    meaningAr: 'قل هو الله أحد... قل أعوذ برب الفلق... قل أعوذ برب الناس...',
    referenceEn: 'Sunan Abi Dawud (5082), Jami` at-Tirmidhi (3575)',
    referenceAr: 'سنن أبي داود (٥٠٨٢)، جامع الترمذي (٣٥٧٥)',
  ),

  // ── 3. GÜNLÜK YAŞAM DUALARI ──────────────────────────────────────────────────
  'gunluk_1': DuaTranslationEntry(
    titleEn: 'Supplication upon Leaving Home',
    titleAr: 'دعاء الخروج من المنزل',
    meaningEn: 'In the name of Allah; I trust in Allah; there is no power and no strength except by Allah.',
    meaningAr: 'بسم الله، توكلت على الله، ولا حول ولا قوة إلا بالله.',
    referenceEn: 'Sunan Abi Dawud (5095), Jami` at-Tirmidhi (3426)',
    referenceAr: 'سنن أبي داود (٥٠٩٥)، جامع الترمذي (٣٤٢٦)',
  ),
  'gunluk_2': DuaTranslationEntry(
    titleEn: 'Supplication upon Entering Home',
    titleAr: 'دعاء دخول المنزل',
    meaningEn: 'In the name of Allah we enter, and in the name of Allah we leave, and upon Allah our Lord we rely.',
    meaningAr: 'بسم الله ولجنا، وبسم الله خرجنا، وعلى الله ربنا توكلنا.',
    referenceEn: 'Sunan Abi Dawud (5096)',
    referenceAr: 'سنن أبي داود (٥٠٩٦)',
  ),
  'gunluk_3': DuaTranslationEntry(
    titleEn: 'Supplication upon Entering the Mosque',
    titleAr: 'دعاء دخول المسجد',
    meaningEn: 'O Allah, open for me the gates of Your mercy.',
    meaningAr: 'اللهم افتح لي أبواب رحمتك.',
    referenceEn: 'Sahih Muslim (713)',
    referenceAr: 'صحيح مسلم (٧١٣)',
  ),
  'gunluk_4': DuaTranslationEntry(
    titleEn: 'Supplication upon Leaving the Mosque',
    titleAr: 'دعاء الخروج من المسجد',
    meaningEn: 'O Allah, I ask You from Your bounty.',
    meaningAr: 'اللهم إني أسألك من فضلك.',
    referenceEn: 'Sahih Muslim (713)',
    referenceAr: 'صحيح مسلم (٧١٣)',
  ),
  'gunluk_5': DuaTranslationEntry(
    titleEn: 'Supplication after Ablution (Wudu)',
    titleAr: 'الذكر المستحب بعد الوضوء',
    meaningEn: 'I bear witness that there is no deity worthy of worship except Allah alone, without partner; and I bear witness that Muhammad is His slave and Messenger. O Allah, make me among those who repent and make me among those who purify themselves.',
    meaningAr: 'أشهد أن لا إله إلا الله وحده لا شريك له، وأشهد أن محمداً عبده ورسوله، اللهم اجعلني من التوابين واجعلني من المتطهرين.',
    referenceEn: 'Sahih Muslim (234), Jami` at-Tirmidhi (55)',
    referenceAr: 'صحيح مسلم (٢٣٤)، جامع الترمذي (٥٥)',
  ),
  'gunluk_6': DuaTranslationEntry(
    titleEn: 'Supplication when Looking into the Mirror',
    titleAr: 'دعاء النظر في المرآة',
    meaningEn: 'O Allah, as You have made my physical form good, so make my character good.',
    meaningAr: 'اللهم أنت حسنت خلقي فحسن خلقي.',
    referenceEn: 'Musnad Ahmad (1/403)',
    referenceAr: 'مسند أحمد (١/٤٠٣)',
  ),

  // ── 4. YOLCULUK DUALARI ─────────────────────────────────────────────────────
  'yolculuk_1': DuaTranslationEntry(
    titleEn: 'Mounting a Vehicle & Starting a Journey',
    titleAr: 'دعاء ركوب الدابة والسفر',
    meaningEn: 'Glory be to Him Who has subjected this to us, and we could never have achieved it by our own efforts. And indeed, to our Lord we will surely return.',
    meaningAr: 'سبحان الذي سخر لنا هذا وما كنا له مقرنين وإنا إلى ربنا لمنقلبون.',
    referenceEn: 'Surah Az-Zukhruf 43:13-14 / Sahih Muslim (1342)',
    referenceAr: 'سورة الزخرف ١٣-١٤ / صحيح مسلم (١٣٤٢)',
  ),
  'yolculuk_2': DuaTranslationEntry(
    titleEn: 'Righteousness & Piety during Travel',
    titleAr: 'سؤال البر والتقوى في السفر',
    meaningEn: 'O Allah, we ask You in this journey of ours for righteousness and piety, and for deeds that please You.',
    meaningAr: 'اللهم إنا نسألك في سفرنا هذا البر والتقوى، ومن العمل ما ترضى.',
    referenceEn: 'Sahih Muslim (1342)',
    referenceAr: 'صحيح مسلم (١٣٤٢)',
  ),
  'yolculuk_3': DuaTranslationEntry(
    titleEn: 'Returning from a Journey',
    titleAr: 'دعاء الرجوع من السفر',
    meaningEn: 'We return, repenting, worshiping, and praising our Lord.',
    meaningAr: 'آيبون، تائبون، عابدون، لربنا حامدون.',
    referenceEn: 'Sahih al-Bukhari (1797), Sahih Muslim (1342)',
    referenceAr: 'صحيح البخاري (١٧٩٧)، صحيح مسلم (١٣٤٢)',
  ),
  'yolculuk_4': DuaTranslationEntry(
    titleEn: 'Entering a City or Town',
    titleAr: 'دعاء دخول البلدة أو القرية',
    meaningEn: 'O Allah, bless us in it. O Allah, grant us its fruits and make us beloved to its people.',
    meaningAr: 'اللهم بارك لنا فيها، اللهم ارزقنا جناها، وحببنا إلى أهلها.',
    referenceEn: 'At-Tabarani, Al-Mu\'jam al-Awsat (5030)',
    referenceAr: 'المعجم الأوسط للطبراني (٥٠٣٠)',
  ),

  // ── 5. ŞÜKÜR VE SABIR ───────────────────────────────────────────────────────
  'sukur_1': DuaTranslationEntry(
    titleEn: 'Gratitude for Divine Blessings',
    titleAr: 'دعاء الشكر على النعم (سليمان عليه السلام)',
    meaningEn: 'My Lord, enable me to be grateful for Your favor which You have bestowed upon me and upon my parents and to do righteousness of which You approve.',
    meaningAr: 'رب أوزعني أن أشكر نعمتك التي أنعمت علي وعلى والدي وأن أعمل صالحاً ترضاه.',
    referenceEn: 'Surah An-Naml 27:19 / Surah Al-Ahqaf 46:15',
    referenceAr: 'سورة النمل ١٩ / سورة الأحقاف ١٥',
  ),
  'sukur_2': DuaTranslationEntry(
    titleEn: 'Patience & Hope in Affliction',
    titleAr: 'الصبر والاسترجاع عند المصيبة',
    meaningEn: 'Indeed to Allah we belong and to Him we shall return. O Allah, reward me for my affliction and compensate me with what is better than it.',
    meaningAr: 'إنا لله وإنا إليه راجعون، اللهم أجرني في مصيبتي وأخلف لي خيراً منها.',
    referenceEn: 'Sahih Muslim (918)',
    referenceAr: 'صحيح مسلم (٩١٨)',
  ),
  'sukur_3': DuaTranslationEntry(
    titleEn: 'Praising Allah in All Conditions',
    titleAr: 'حمد الله تعالى على كل حال',
    meaningEn: 'Praise be to Allah under all circumstances.',
    meaningAr: 'الحمد لله على كل حال.',
    referenceEn: 'Sunan Ibn Majah (3803)',
    referenceAr: 'سنن ابن ماجه (٣٨٠٣)',
  ),
  'sukur_4': DuaTranslationEntry(
    titleEn: 'Allah Suffices Me (Hasbiyallah)',
    titleAr: 'التوكل وحسبنا الله ونعم الوكيل',
    meaningEn: 'Sufficient for me is Allah; there is no deity worthy of worship except Him. On Him I have relied, and He is the Lord of the Great Throne.',
    meaningAr: 'حسبي الله لا إله إلا هو عليه توكلت وهو رب العرش العظيم.',
    referenceEn: 'Surah At-Tawbah 9:129 / Sunan Abi Dawud (5081)',
    referenceAr: 'سورة التوبة ١٢٩ / سنن أبي داود (٥٠٨١)',
  ),

  // ── 6. SIKINTI VE FERAHLIK ───────────────────────────────────────────────────
  'sikinti_1': DuaTranslationEntry(
    titleEn: 'Supplication of Prophet Yunus (In Distress)',
    titleAr: 'دعاء ذي النون يونس عليه السلام في الكرب',
    meaningEn: 'There is no deity worthy of worship except You; exalted are You. Indeed, I have been of the wrongdoers.',
    meaningAr: 'لا إله إلا أنت سبحانك إني كنت من الظالمين.',
    referenceEn: 'Surah Al-Anbiya 21:87 / Jami` at-Tirmidhi (3505)',
    referenceAr: 'سورة الأنبياء ٨٧ / جامع الترمذي (٣٥٠٥)',
  ),
  'sikinti_2': DuaTranslationEntry(
    titleEn: 'Relief from Anxiety, Debt & Helplessness',
    titleAr: 'الاستعاذة من الهم والحزن وغلبة الدين',
    meaningEn: 'O Allah, I seek refuge in You from anxiety and sorrow, and I seek refuge in You from incapacity and laziness, and I seek refuge in You from cowardice and miserliness, and I seek refuge in You from being overpowered by debt and the oppression of men.',
    meaningAr: 'اللهم إني أعوذ بك من الهم والحزن، وأعوذ بك من العجز والكسل، وأعوذ بك من الجبن والبخل، وأعوذ بك من غلبة الدين وقهر الرجال.',
    referenceEn: 'Sahih al-Bukhari (6369)',
    referenceAr: 'صحيح البخاري (٦٣٦٩)',
  ),
  'sikinti_3': DuaTranslationEntry(
    titleEn: 'Relying Entirely on Allah\'s Mercy',
    titleAr: 'الافتقار إلى رحمة الله وعدم الاتكال على النفس',
    meaningEn: 'O Allah, it is Your mercy that I hope for, so do not leave me to myself even for the blink of an eye, and rectify all my affairs. There is no deity worthy of worship except You.',
    meaningAr: 'اللهم رحمتك أرجو، فلا تكلني إلى نفسي طرفة عين، وأصلح لي شأني كله، لا إله إلا أنت.',
    referenceEn: 'Sunan Abi Dawud (5090)',
    referenceAr: 'سنن أبي داود (٥٠٩٠)',
  ),
  'sikinti_4': DuaTranslationEntry(
    titleEn: 'Treasure of Paradise (La Hawla)',
    titleAr: 'كنز من كنوز الجنة (الحوقلة)',
    meaningEn: 'There is no power and no strength except by Allah, the Most High, the Most Great.',
    meaningAr: 'لا حول ولا قوة إلا بالله العلي العظيم.',
    referenceEn: 'Sahih al-Bukhari (6384), Sahih Muslim (2704)',
    referenceAr: 'صحيح البخاري (٦٣٨٤)، صحيح مسلم (٢٧٠٤)',
  ),

  // ── 7. UYKU ÖNCESİ VE SONRASI ──────────────────────────────────────────────
  'uyku_1': DuaTranslationEntry(
    titleEn: 'Supplication before Sleeping',
    titleAr: 'دعاء النوم عند الاضطجاع',
    meaningEn: 'In Your Name, my Lord, I lay my side down, and by Your grace I raise it up. If You keep my soul, have mercy upon it, and if You send it back, then protect it with that which You protect Your righteous servants.',
    meaningAr: 'باسمك ربي وضعت جنبي وبك أرفعه، إن أمسكت نفسي فارحمها، وإن أرسلتها فاحفظها بما تحفظ به عبادك الصالحين.',
    referenceEn: 'Sahih al-Bukhari (6320), Sahih Muslim (2714)',
    referenceAr: 'صحيح البخاري (٦٣٢٠)، صحيح مسلم (٢٧١٤)',
  ),
  'uyku_2': DuaTranslationEntry(
    titleEn: 'Supplication upon Waking Up',
    titleAr: 'الحمد والشكر عند الاستيقاظ',
    meaningEn: 'Praise be to Allah Who brought us to life after having caused us to die (sleep), and unto Him is the resurrection.',
    meaningAr: 'الحمد لله الذي أحيانا بعد ما أماتنا وإليه النشور.',
    referenceEn: 'Sahih al-Bukhari (6312)',
    referenceAr: 'صحيح البخاري (٦٣١٢)',
  ),
  'uyku_3': DuaTranslationEntry(
    titleEn: 'Ayat al-Kursi before Sleep',
    titleAr: 'آية الكرسي قبل النوم للحفظ',
    meaningEn: 'Allah - there is no deity worthy of worship except Him, the Ever-Living, the Sustainer of all existence. Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens and whatever is on the earth.',
    meaningAr: 'اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ.',
    referenceEn: 'Surah Al-Baqarah 2:255 / Sahih al-Bukhari (2311)',
    referenceAr: 'سورة البقرة ٢٥٥ / صحيح البخاري (٢٣١١)',
  ),
  'uyku_4': DuaTranslationEntry(
    titleEn: 'Surrendering Soul to Allah (Bara\'s Dua)',
    titleAr: 'دعاء الاستسلام لله قبل المنام (حديث البراء)',
    meaningEn: 'O Allah, I have surrendered myself to You, and I have committed my affair to You, and I have turned my face to You, and I have leaned my back against You, out of desire for You and fear of You.',
    meaningAr: 'اللهم أسلمت نفسي إليك، وفوضت أمري إليك، وألجأت ظهري إليك، رغبة ورهبة إليك.',
    referenceEn: 'Sahih al-Bukhari (247), Sahih Muslim (2710)',
    referenceAr: 'صحيح البخاري (٢٤٧)، صحيح مسلم (٢٧١٠)',
  ),

  // ── 8. YEMEK VE NİMET DUALARI ───────────────────────────────────────────────
  'yemek_1': DuaTranslationEntry(
    titleEn: 'Before Beginning a Meal',
    titleAr: 'التسمية والدعاء قبل الأكل',
    meaningEn: 'In the name of Allah and upon the blessings of Allah.',
    meaningAr: 'بسم الله وعلى بركة الله.',
    referenceEn: 'Musnad Ahmad, Sunan Abi Dawud (3767)',
    referenceAr: 'مسند أحمد، سنن أبي داود (٣٧٦٧)',
  ),
  'yemek_2': DuaTranslationEntry(
    titleEn: 'Praise after Finishing a Meal',
    titleAr: 'الحمد والدعاء بعد الفراغ من الطعام',
    meaningEn: 'Praise be to Allah Who has fed us, given us drink, and made us Muslims.',
    meaningAr: 'الحمد لله الذي أطعمنا وسقانا وجعلنا مسلمين.',
    referenceEn: 'Sunan Abi Dawud (3850), Jami` at-Tirmidhi (3457)',
    referenceAr: 'سنن أبي داود (٣٨٥٠)، جامع الترمذي (٣٤٥٧)',
  ),
  'yemek_3': DuaTranslationEntry(
    titleEn: 'Supplication for the Generous Host',
    titleAr: 'دعاء الضيف لمن أطعمه وسقاه',
    meaningEn: 'May fasting people break their fast with you, may the righteous eat your food, and may the angels send blessings upon you.',
    meaningAr: 'أفطر عندكم الصائمون، وأكل طعامكم الأبرار، وصلت عليكم الملائكة.',
    referenceEn: 'Sunan Abi Dawud (3854)',
    referenceAr: 'سنن أبي داود (٣٨٥٤)',
  ),
  'yemek_4': DuaTranslationEntry(
    titleEn: 'Supplication after Drinking Milk',
    titleAr: 'دعاء شرب اللبن وسؤال البركة',
    meaningEn: 'O Allah, bless it for us and increase it for us.',
    meaningAr: 'اللهم بارك لنا فيه وزدنا منه.',
    referenceEn: 'Sunan Abi Dawud (3730), Jami` at-Tirmidhi (3455)',
    referenceAr: 'سنن أبي داود (٣٧٣٠)، جامع الترمذي (٣٤٥٥)',
  ),

  // ── 9. KUR\'AN-I KERİM DUALARI ─────────────────────────────────────────────
  'kuran_1': DuaTranslationEntry(
    titleEn: 'Goodness in This World & Hereafter (Rabbana Atina)',
    titleAr: 'طلب الحسنة في الدنيا والآخرة والنجاة من النار',
    meaningEn: 'Our Lord, give us in this world that which is good and in the Hereafter that which is good, and save us from the punishment of the Fire.',
    meaningAr: 'ربنا آتنا في الدنيا حسنة وفي الآخرة حسنة وقنا عذاب النار.',
    referenceEn: 'Surah Al-Baqarah 2:201',
    referenceAr: 'سورة البقرة ٢٠١',
  ),
  'kuran_2': DuaTranslationEntry(
    titleEn: 'Steadfastness in Faith (Al-Imran)',
    titleAr: 'دعاء الثبات على الهداية بعد الإيمان',
    meaningEn: 'Our Lord, let not our hearts deviate after You have guided us and grant us from Yourself mercy. Indeed, You are the Bestower.',
    meaningAr: 'ربنا لا تزغ قلوبنا بعد إذ هديتنا وهب لنا من لدنك رحمة ۚ إنك أنت الوهاب.',
    referenceEn: 'Surah Ali \'Imran 3:8',
    referenceAr: 'سورة آل عمران ٨',
  ),
  'kuran_3': DuaTranslationEntry(
    titleEn: 'Forgiveness for Parents & Believers',
    titleAr: 'دعاء إبراهيم بالمغفرة للوالدين وللمؤمنين',
    meaningEn: 'Our Lord, forgive me and my parents and the believers the Day the account is established.',
    meaningAr: 'ربنا اغفر لي ولوالدي وللمؤمنين يوم يقوم الحساب.',
    referenceEn: 'Surah Ibrahim 14:41',
    referenceAr: 'سورة إبراهيم ٤١',
  ),
  'kuran_4': DuaTranslationEntry(
    titleEn: 'Righteous Spouses & Offspring',
    titleAr: 'دعاء عباد الرحمن لصلاح الأزواج والذرية',
    meaningEn: 'Our Lord, grant us from among our spouses and offspring comfort to our eyes and make us a leader for the righteous.',
    meaningAr: 'ربنا هب لنا من أزواجنا وذرياتنا قرة أعين واجعلنا للمتقين إماماً.',
    referenceEn: 'Surah Al-Furqan 25:74',
    referenceAr: 'سورة الفرقان ٧٤',
  ),
  'kuran_5': DuaTranslationEntry(
    titleEn: 'Steadfastness in Performing Prayer',
    titleAr: 'دعاء إقامة الصلاة للذرية وقبول الدعاء',
    meaningEn: 'My Lord, make me an establisher of prayer, and [many] from my descendants. Our Lord, and accept my supplication.',
    meaningAr: 'رب اجعلني مقيم الصلاة ومن ذريتي ۚ ربنا وتقبل دعاء.',
    referenceEn: 'Surah Ibrahim 14:40',
    referenceAr: 'سورة إبراهيم ٤٠',
  ),
  'kuran_6': DuaTranslationEntry(
    titleEn: 'Supplication for Increasing Knowledge',
    titleAr: 'طلب الزيادة في العلم والحكمة',
    meaningEn: 'My Lord, increase me in knowledge.',
    meaningAr: 'رب زدني علماً.',
    referenceEn: 'Surah Taha 20:114',
    referenceAr: 'سورة طه ١١٤',
  ),

  // ── 10. PEYGAMBERLERİN DUALARI ─────────────────────────────────────────────
  'peygamber_1': DuaTranslationEntry(
    titleEn: 'Expansion of the Chest & Eloquence (Moses)',
    titleAr: 'دعاء موسى عليه السلام بانشراح الصدر وتيسير الأمر',
    meaningEn: 'My Lord, expand for me my chest, and ease for me my task, and untie the knot from my tongue that they may understand my speech.',
    meaningAr: 'رب اشرح لي صدري ويسر لي أمري واحلل عقدة من لساني يفقهوا قولي.',
    referenceEn: 'Surah Taha 20:25-28',
    referenceAr: 'سورة طه ٢٥-٢٨',
  ),
  'peygamber_2': DuaTranslationEntry(
    titleEn: 'Supplication for Healing (Job / Ayyub)',
    titleAr: 'دعاء أيوب عليه السلام لطلب الشفاء من البلاء',
    meaningEn: 'Indeed, adversity has touched me, and You are the Most Merciful of the merciful.',
    meaningAr: 'أني مسني الضر وأنت أرحم الراحمين.',
    referenceEn: 'Surah Al-Anbiya 21:83',
    referenceAr: 'سورة الأنبياء ٨٣',
  ),
  'peygamber_3': DuaTranslationEntry(
    titleEn: 'Repentance & Forgiveness (Adam & Eve)',
    titleAr: 'توبة آدم وحواء عليهما السلام واعترافهما بالظلم',
    meaningEn: 'Our Lord, we have wronged ourselves, and if You do not forgive us and have mercy upon us, we will surely be among the losers.',
    meaningAr: 'ربنا ظلمنا أنفسنا وإن لم تغفر لنا وترحمنا لنكونن من الخاسرين.',
    referenceEn: 'Surah Al-A\'raf 7:23',
    referenceAr: 'سورة الأعراف ٢٣',
  ),
  'peygamber_4': DuaTranslationEntry(
    titleEn: 'A Righteous Ending in Faith (Joseph / Yusuf)',
    titleAr: 'دعاء يوسف عليه السلام بحسن الختام مع الصالحين',
    meaningEn: 'Cause me to die a Muslim and join me with the righteous.',
    meaningAr: 'توفني مسلماً وألحقني بالصالحين.',
    referenceEn: 'Surah Yusuf 12:101',
    referenceAr: 'سورة يوسف ١٠١',
  ),
  'peygamber_5': DuaTranslationEntry(
    titleEn: 'Supplication for Righteous Progeny (Zechariah)',
    titleAr: 'دعاء زكريا عليه السلام بالذرية الطيبة',
    meaningEn: 'My Lord, grant me from Yourself a good offspring. Indeed, You are the Hearer of supplication.',
    meaningAr: 'رب هب لي من لدنك ذرية طيبة ۖ إنك سميع الدعاء.',
    referenceEn: 'Surah Ali \'Imran 3:38',
    referenceAr: 'سورة آل عمران ٣٨',
  ),
};

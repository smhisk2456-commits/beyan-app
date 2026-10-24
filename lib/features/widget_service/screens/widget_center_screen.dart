import 'package:islamic_app/core/theme/beyan_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/utils/app_constants.dart';
import '../widget_service.dart';
import '../../monetization/providers/premium_provider.dart';
import '../../monetization/widgets/banner_ad_widget.dart';
import '../../notifications/models/id_verse_translations.dart';
import '../../notifications/models/short_verse_notification.dart';

/// Kilit Ekranı Widget Kategorileri
enum WidgetCategoryType {
  quotes, // İslami Sözler, Dua ve Ayet
  dailyVerse, // Günün Ayeti
  prayerTimes, // Namaz Vakitleri
  countdown, // Namaz Geri Sayımı
  hijri, // Hicri Takvim
  sunTimes, // Güneş & Vakit
}

/// Kilit Ekranı Widget Önizleme Söz Modeli
class WidgetPreviewQuote {
  final String referenceTr;
  final String referenceEn;
  final String referenceAr;
  final String arabic;
  final String meaningTr;
  final String meaningEn;
  final String meaningAr;

  const WidgetPreviewQuote({
    required this.referenceTr,
    required this.referenceEn,
    required this.referenceAr,
    required this.arabic,
    required this.meaningTr,
    required this.meaningEn,
    required this.meaningAr,
  });

  String localizedReference(String langCode) {
    if (langCode == 'ar') return referenceAr;
    if (langCode != 'tr') return referenceEn;
    return referenceTr;
  }

  String localizedMeaning(String langCode) {
    if (langCode == 'ar') return meaningAr;
    if (langCode == 'id') {
      return kIndonesianShortVerses[referenceTr] ?? meaningEn;
    }
    if (langCode != 'tr') return meaningEn;
    return meaningTr;
  }

  String getReference(AppLanguage lang) {
    if (lang == AppLanguage.turkish) return referenceTr;
    if (lang == AppLanguage.arabic) return referenceAr;
    return referenceEn;
  }

  String getMeaning(AppLanguage lang) {
    if (lang == AppLanguage.turkish) return meaningTr;
    if (lang == AppLanguage.arabic) return meaningAr;
    if (lang == AppLanguage.indonesian) {
      return kIndonesianShortVerses[referenceTr] ?? meaningEn;
    }
    return meaningEn;
  }
  String formatForViewMode(String viewMode, String langCode) {
    final meal = localizedMeaning(langCode);
    if (viewMode == 'arabic_only' || viewMode == 'Yalnızca Arapça') {
      return arabic;
    }
    if (viewMode == 'arabic_meal' || viewMode == 'Arapça + Meal') {
      return '$arabic\n$meal';
    }
    return meal;
  }
}

const List<WidgetPreviewQuote> _comfortQuotes = [
  WidgetPreviewQuote(
    referenceTr: 'Duhâ 93:3',
    referenceEn: 'Ad-Duhaa 93:3',
    referenceAr: 'الضحى ٩٣:٣',
    arabic: 'مَا وَدَّعَكَ رَبُّكَ وَمَا قَلَىٰ',
    meaningTr: 'Rabbin seni terk etmedi ve sana darılmadı.',
    meaningEn: 'Your Lord has not taken leave of you, nor has He detested you.',
    meaningAr: 'ما ودعك ربك وما قلى',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Duhâ 93:5',
    referenceEn: 'Ad-Duhaa 93:5',
    referenceAr: 'الضحى ٩٣:٥',
    arabic: 'وَلَسَوْفَ يُعْطِيكَ رَبُّكَ فَتَرْضَىٰ',
    meaningTr: 'Rabbin sana yakında öyle verecek ki, gönlün razı olacak.',
    meaningEn: 'And your Lord is going to give you, and you will be satisfied.',
    meaningAr: 'ولسوف يعطيك ربك فترضى',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Yûsuf 12:86',
    referenceEn: 'Yusuf 12:86',
    referenceAr: 'يوسف ١٢:٨٦',
    arabic: 'إِنَّمَا أَشْكُو بَثِّي وَحُزْنِي إِلَى اللَّهِ',
    meaningTr: 'Ben kederimi ve hüznümü yalnız Allah\'a arz ederim.',
    meaningEn: 'I only complain of my suffering and my grief to Allah.',
    meaningAr: 'إنما أشكو بثي وحزني إلى الله',
  ),
  WidgetPreviewQuote(
    referenceTr: 'İnşirâh 94:5-6',
    referenceEn: 'Ash-Sharh 94:5-6',
    referenceAr: 'الشرح ٩٤:٥-٦',
    arabic: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا ۝ إِنَّ مَعَ الْعُسْرِ يُسْرًا',
    meaningTr: 'Elbette zorluğun yanında bir kolaylık vardır; gerçekten her güçlükle beraber bir kolaylık vardır.',
    meaningEn: 'For indeed, with hardship will be ease. Indeed, with hardship will be ease.',
    meaningAr: 'فإن مع العسر يسرا إن مع العسر يسرا',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Tevbe 9:40',
    referenceEn: 'At-Tawbah 9:40',
    referenceAr: 'التوبة ٩:٤٠',
    arabic: 'لَا تَحْزَنْ إِنَّ اللَّهَ مَعَنَا',
    meaningTr: 'Üzülme! Şüphesiz Allah bizimle beraberdir.',
    meaningEn: 'Do not grieve; indeed Allah is with us.',
    meaningAr: 'لا تحزن إن الله معنا',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Ra\'d 13:28',
    referenceEn: 'Ar-Ra\'d 13:28',
    referenceAr: 'الرعد ١٣:٢٨',
    arabic: 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
    meaningTr: 'Bilin ki, yorgun kalpler ancak Allah\'ı anmakla huzur bulur.',
    meaningEn: 'Unquestionably, by the remembrance of Allah hearts are assured.',
    meaningAr: 'ألا بذكر الله تطمئن القلوب',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Kâf 50:16',
    referenceEn: 'Qaf 50:16',
    referenceAr: 'ق ٥٠:١٦',
    arabic: 'وَنَحْنُ أَقْرَبُ إِلَيْهِ مِنْ حَبْلِ الْوَرِيدِ',
    meaningTr: 'Biz insana şah damarından daha yakınız; kalbinden geçen her fısıltıyı biliriz.',
    meaningEn: 'We know what his soul whispers to him, and We are closer to him than his jugular vein.',
    meaningAr: 'ونحن أقرب إليه من حبل الوريد',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Bakara 2:186',
    referenceEn: 'Al-Baqarah 2:186',
    referenceAr: 'البقرة ٢:١٨٦',
    arabic: 'وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ ۖ أُجِيبُ دَعْوَةَ الدَّاعِ',
    meaningTr: 'Kullarım Beni sorarlarsa, şüphesiz Ben onlara çok yakınım; bana el açanın duasına icabet ederim.',
    meaningEn: 'When My servants ask you concerning Me, indeed I am near; I respond to the invocation of the supplicant.',
    meaningAr: 'وإذا سألك عبادي عني فإني قريب أجيب دعوة الداع',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Zümer 39:53',
    referenceEn: 'Az-Zumar 39:53',
    referenceAr: 'الزمر ٣٩:٥٣',
    arabic: 'لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ ۚ إِنَّ اللَّهَ يَغْفِرُ الذُّنُوبَ جَمِيعًا',
    meaningTr: 'Allah\'ın rahmetinden asla ümidinizi kesmeyin! Şüphesiz Allah bütün günahları bağışlar.',
    meaningEn: 'Do not despair of the mercy of Allah. Indeed, Allah forgives all sins.',
    meaningAr: 'لا تقنطوا من رحمة الله إن الله يغفر الذنوب جميعا',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Talâk 65:7',
    referenceEn: 'At-Talaq 65:7',
    referenceAr: 'الطلاق ٦٥:٧',
    arabic: 'سَيَجْعَلُ اللَّهُ بَعْدَ عُسْرٍ يُسْرًا',
    meaningTr: 'Allah her darlığın ve güçlüğün ardından mutlaka bir ferahlık yaratacaktır.',
    meaningEn: 'Allah will bring about, after hardship, ease.',
    meaningAr: 'سيجعل الله بعد عسر يسرا',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Meryem 19:64',
    referenceEn: 'Maryam 19:64',
    referenceAr: 'مريم ١٩:٦٤',
    arabic: 'وَمَا كَانَ رَبُّكَ نَسِيًّا',
    meaningTr: 'Senin Rabbin seni de, dualarını da asla unutkan değildir.',
    meaningEn: 'And never is your Lord forgetful.',
    meaningAr: 'وما كان ربك نسيا',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Hicr 15:97-98',
    referenceEn: 'Al-Hijr 15:97-98',
    referenceAr: 'الحجر ١٥:٩٧-٩٨',
    arabic: 'وَلَقَدْ نَعْلَمُ أَنَّكَ يَضِيقُ صَدْرُكَ بِمَا يَقُولُونَ ۝ فَسَبِّحْ بِحَمْدِ رَبِّكَ',
    meaningTr: 'Onların söyledikleri yüzünden göğsünün daraldığını biliyoruz; sen Rabbini hamd ile tesbih et ve secdeye kapan.',
    meaningEn: 'We already know that your breast is constrained by what they say; so exalt your Lord with praise.',
    meaningAr: 'ولقد نعلم أنك يضيق صدرك بما يقولون فسبح بحمد ربك',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Bakara 2:216',
    referenceEn: 'Al-Baqarah 2:216',
    referenceAr: 'البقرة ٢:٢١٦',
    arabic: 'وَعَسَىٰ أَن تَكْرَهُوا شَيْئًا وَهُوَ خَيْرٌ لَّكُمْ ۖ وَاللَّهُ يَعْلَمُ وَأَنتُمْ لَا تَعْلَمُونَ',
    meaningTr: 'Olur ki hoşunuza gitmeyen bir şey sizin için hayırlıdır; Allah bilir, siz bilmezsiniz.',
    meaningEn: 'Perhaps you dislike a thing and it is good for you; and Allah knows, while you know not.',
    meaningAr: 'وعسى أن تكرهوا شيئا وهو خير لكم والله يعلم وأنتم لا تعلمون',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Enbiyâ 21:83',
    referenceEn: 'Al-Anbiya 21:83',
    referenceAr: 'الأنبياء ٢١:٨٣',
    arabic: 'أَنِّي مَسَّنِيَ الضُّرُّ وَأَنتَ أَرْحَمُ الرَّاحِمِينَ',
    meaningTr: 'Rabbim! Bana gerçekten dert dokundu; Sen merhametlilerin en merhametlisisin.',
    meaningEn: 'Indeed, adversity has touched me, and You are the Most Merciful of the merciful.',
    meaningAr: 'أني مسني الضر وأنت أرحم الراحمين',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Şuarâ 26:62',
    referenceEn: 'Ash-Shu\'ara 26:62',
    referenceAr: 'الشعراء ٢٦:٦٢',
    arabic: 'كَلَّا ۖ إِنَّ مَعِيَ رَبِّي سَيَهْدِينِ',
    meaningTr: 'Asla ümitsizliğe düşme! Rabbim benimle beraberdir; bana mutlaka bir çıkış yolu gösterecektir.',
    meaningEn: 'No! Indeed, with me is my Lord; He will guide me.',
    meaningAr: 'كلا إن معي ربي سيهدين',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Tâhâ 20:46',
    referenceEn: 'Taha 20:46',
    referenceAr: 'طه ٢٠:٤٦',
    arabic: 'لَا تَخَافَا ۖ إِنَّنِي مَعَكُمَا أَسْمَعُ وَأَرَىٰ',
    meaningTr: 'Korkmayın! Şüphesiz Ben sizinle beraberim; her şeyi işitir ve görürüm.',
    meaningEn: 'Fear not. Indeed, I am with you; I hear and I see.',
    meaningAr: 'لا تخافا إنني معكما أسمع وأرى',
  ),
  WidgetPreviewQuote(
    referenceTr: 'İnşirâh 94:1-3',
    referenceEn: 'Ash-Sharh 94:1-3',
    referenceAr: 'الشرح ٩٤:١-٣',
    arabic: 'أَلَمْ نَشْرَحْ لَكَ صَدْرَكَ ۝ وَوَضَعْنَا عَنكَ وِزْرَكَ',
    meaningTr: 'Senin daralan göğsünü açıp genişletmedik mi? Belini büken o ağır yükü üzerinden kaldırmadık mı?',
    meaningEn: 'Did We not expand for you your breast? And We removed from you your burden.',
    meaningAr: 'ألم نشرح لك صدرك ووضعنا عنك وزرك',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Duhâ 93:6-8',
    referenceEn: 'Ad-Duhaa 93:6-8',
    referenceAr: 'الضحى ٩٣:٦-٨',
    arabic: 'أَلَمْ يَجِدْكَ يَتِيمًا فَآوَىٰ ۝ وَوَجَدَكَ ضَالًّا فَهَدَىٰ',
    meaningTr: 'O seni yetim bulup da barındırmadı mı? Seni çaresiz bulup da yol göstermedi mi?',
    meaningEn: 'Did He not find you an orphan and give you refuge? And He found you lost and guided you.',
    meaningAr: 'ألم يجدك يتيما فآوى ووجدك ضالا فهدى',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Fetih 48:4',
    referenceEn: 'Al-Fath 48:4',
    referenceAr: 'الفتح ٤٨:٤',
    arabic: 'هُوَ الَّذِي أَنزَلَ السَّكِينَةَ فِي قُلُوبِ الْمُؤْمِنِينَ',
    meaningTr: 'Müminlerin yorgun kalplerine huzur ve sekînet indiren O\'dur.',
    meaningEn: 'It is He who sent down tranquility into the hearts of the believers.',
    meaningAr: 'هو الذي أنزل السكينة في قلوب المؤمنين',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Meryem 19:24',
    referenceEn: 'Maryam 19:24',
    referenceAr: 'مريم ١٩:٢٤',
    arabic: 'أَلَّا تَحْزَنِي قَدْ جَعَلَ رَبُّكِ تَحْتَكِ سَرِيًّا',
    meaningTr: 'Sakın üzülme! Rabbin senin kalbine ferahlık ve rahmet pınarı var etti.',
    meaningEn: 'Do not grieve; your Lord has provided beneath you a stream of mercy.',
    meaningAr: 'ألا تحزني قد جعل ربك تحتك سريا',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Kasas 28:7',
    referenceEn: 'Al-Qasas 28:7',
    referenceAr: 'القصص ٢٨:٧',
    arabic: 'وَلَا تَخَافِي وَلَا تَحْزَنِي',
    meaningTr: 'Korkma ve mahzun olma! Allah senin kalbine emanet ettiğini koruyacaktır.',
    meaningEn: 'Do not fear and do not grieve.',
    meaningAr: 'ولا تخافي ولا تحزني',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Hadîd 57:4',
    referenceEn: 'Al-Hadid 57:4',
    referenceAr: 'الحديد ٥٧:٤',
    arabic: 'وَهُوَ مَعَكُمْ أَيْنَ مَا كُنتُمْ',
    meaningTr: 'Yalnız hissetme; nerede olursanız olun, O sizinle beraberdir.',
    meaningEn: 'And He is with you wherever you are.',
    meaningAr: 'وهو معكم أين ما كنتم',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Bakara 2:286',
    referenceEn: 'Al-Baqarah 2:286',
    referenceAr: 'البقرة ٢:٢٨٦',
    arabic: 'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا',
    meaningTr: 'Allah hiçbir kalbe taşıyabileceğinden daha ağır bir yük yüklemez.',
    meaningEn: 'Allah does not burden a soul beyond that it can bear.',
    meaningAr: 'لا يكلف الله نفسا إلا وسعها',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Hûd 11:90',
    referenceEn: 'Hud 11:90',
    referenceAr: 'هود ١١:٩٠',
    arabic: 'إِنَّ رَبِّي رَحِيمٌ وَدُودٌ',
    meaningTr: 'Şüphesiz benim Rabbim çok merhametlidir, kullarını çok sevendir.',
    meaningEn: 'Indeed, my Lord is Merciful and Affectionate.',
    meaningAr: 'إن ربي رحيم ودود',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Âl-i İmrân 3:139',
    referenceEn: 'Ali \'Imran 3:139',
    referenceAr: 'آل عمران ٣:١٣٩',
    arabic: 'وَلَا تَهِنُوا وَلَا تَحْزَنُوا وَأَنتُمُ الْأَعْلَوْنَ',
    meaningTr: 'Gevşemeyin, hüzne kapılmayın; eğer inanıyorsanız üstün gelecek olan sizsiniz.',
    meaningEn: 'Do not weaken and do not grieve, and you will be superior if you are believers.',
    meaningAr: 'ولا تهنوا ولا تحزنوا وأنتم الأعلون',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Bakara 2:257',
    referenceEn: 'Al-Baqarah 2:257',
    referenceAr: 'البقرة ٢:٢٥٧',
    arabic: 'اللَّهُ وَلِيُّ الَّذِينَ آمَنُوا يُخْرِجُهُم مِّنَ الظُّلُمَاتِ إِلَى النُّورِ',
    meaningTr: 'Allah inananların dostudur; onları karanlıklardan aydınlığa çıkarır.',
    meaningEn: 'Allah is the ally of those who believe; He brings them out from darknesses into the light.',
    meaningAr: 'الله ولي الذين آمنوا يخرجهم من الظلمات إلى النور',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Yûnus 10:62',
    referenceEn: 'Yunus 10:62',
    referenceAr: 'يونس ١٠:٦٢',
    arabic: 'أَلَا إِنَّ أَوْلِيَاءَ اللَّهِ لَا خَوْفٌ عَلَيْهِمْ وَلَا هُمْ يَحْزَنُونَ',
    meaningTr: 'İyi bilin ki, Allah\'ın dostlarına hiçbir korku yoktur ve onlar mahzun olmayacaklardır.',
    meaningEn: 'Unquestionably, for the allies of Allah there will be no fear nor will they grieve.',
    meaningAr: 'ألا إن أولياء الله لا خوف عليهم ولا هم يحزنون',
  ),
  WidgetPreviewQuote(
    referenceTr: 'İsrâ 17:82',
    referenceEn: 'Al-Isra 17:82',
    referenceAr: 'الإسراء ١٧:٨٢',
    arabic: 'وَنُنَزِّلُ مِنَ الْقُرْآنِ مَا هُوَ شِفَاءٌ وَرَحْمَةٌ لِّلْمُؤْمِنِينَ',
    meaningTr: 'Biz Kur\'an\'dan, müminlerin yaralı gönüllerine şifa ve rahmet olan âyetler indiriyoruz.',
    meaningEn: 'And We send down of the Quran that which is healing and mercy for the believers.',
    meaningAr: 'وننزل من القرآن ما هو شفاء ورحمة للمؤمنين',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Necm 53:43',
    referenceEn: 'An-Najm 53:43',
    referenceAr: 'النجم ٥٣:٤٣',
    arabic: 'وَأَنَّهُ هُوَ أَضْحَكَ وَأَبْكَىٰ',
    meaningTr: 'Doğrusu güldüren de ağlatan da O\'dur; her gözyaşının ardında O\'nun hikmeti vardır.',
    meaningEn: 'And that it is He who makes one laugh and weep.',
    meaningAr: 'وأنه هو أضحك وأبكى',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Fâtır 35:2',
    referenceEn: 'Fatir 35:2',
    referenceAr: 'فاطر ٣٥:٢',
    arabic: 'مَّا يَفْتَحِ اللَّهُ لِلنَّاسِ مِن رَّحْمَةٍ فَلَا مُمْسِكَ لَهَا',
    meaningTr: 'Allah\'ın insanlara açacağı rahmet kapısını kapatabilecek hiçbir güç yoktur.',
    meaningEn: 'Whatever Allah grants to people of mercy – none can withhold it.',
    meaningAr: 'ما يفتح الله للناس من رحمة فلا ممسك لها',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Meryem 19:96',
    referenceEn: 'Maryam 19:96',
    referenceAr: 'مريم ١٩:٩٦',
    arabic: 'سَيَجْعَلُ لَهُمُ الرَّحْمَٰنُ وُدًّا',
    meaningTr: 'İman edip güzel işler yapanlar için Rahmân, gönüllerde sıcak bir sevgi yaratacaktır.',
    meaningEn: 'The Most Merciful will appoint for them affection in hearts.',
    meaningAr: 'سيجعل لهم الرحمن ودا',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Şuarâ 26:80',
    referenceEn: 'Ash-Shu\'ara 26:80',
    referenceAr: 'الشعراء ٢٦:٨٠',
    arabic: 'وَإِذَا مَرِضْتُ فَهُوَ يَشْفِينِ',
    meaningTr: 'Hastalandığım ve dermanım tükendiği zaman bana şifa veren ancak O\'dur.',
    meaningEn: 'And when I am ill, it is He who cures me.',
    meaningAr: 'وإذا مرضت فهو يشفين',
  ),
];

const List<WidgetPreviewQuote> _sabrQuotes = [
  WidgetPreviewQuote(
    referenceTr: 'Bakara 2:153',
    referenceEn: 'Al-Baqarah 2:153',
    referenceAr: 'البقرة ٢:١٥٣',
    arabic: 'يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ ۚ إِنَّ اللَّهَ مَعَ الصَّابِرِينَ',
    meaningTr: 'Ey iman edenler! Sabır ve namazla yardım dileyin. Şüphesiz Allah sabredenlerle beraberdir.',
    meaningEn: 'O you who believe! Seek help through patience and prayer. Indeed, Allah is with the patient.',
    meaningAr: 'يا أيها الذين آمنوا استعينوا بالصبر والصلاة إن الله مع الصابرين',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Yûsuf 12:18',
    referenceEn: 'Yusuf 12:18',
    referenceAr: 'يوسف ١٢:١٨',
    arabic: 'فَصَبْرٌ جَمِيلٌ ۖ وَاللَّهُ الْمُسْتَعَانُ',
    meaningTr: 'Bana düşen, şikâyetsiz güzel bir sabırdır (Sabr-ı Cemîl). Yardımına sığınılacak olan yalnız Allah\'tır.',
    meaningEn: 'So patience is most fitting. And Allah is the one sought for help.',
    meaningAr: 'فصبر جميل والله المستعان',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Zümer 39:10',
    referenceEn: 'Az-Zumar 39:10',
    referenceAr: 'الزمر ٣٩:١٠',
    arabic: 'إِنَّمَا يُوَفَّى الصَّابِرُونَ أَجْرَهُم بِغَيْرِ حِسَابٍ',
    meaningTr: 'Sabredenlere mükâfatları hesapsızca, sınırsızca verilecektir.',
    meaningEn: 'Indeed, the patient will be given their reward without account.',
    meaningAr: 'إنما يوفى الصابرون أجرهم بغير حساب',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Bakara 2:155',
    referenceEn: 'Al-Baqarah 2:155',
    referenceAr: 'البقرة ٢:١٥٥',
    arabic: 'وَبَشِّرِ الصَّابِرِينَ',
    meaningTr: 'Zorluklara göğüs gerip sabredenleri müjdele!',
    meaningEn: 'And give good tidings to the patient.',
    meaningAr: 'وبشر الصابرين',
  ),
  WidgetPreviewQuote(
    referenceTr: 'İbrâhîm 14:7',
    referenceEn: 'Ibrahim 14:7',
    referenceAr: 'إبراهيم ١٤:٧',
    arabic: 'لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ',
    meaningTr: 'Andolsun, eğer şükrederseniz nimetimi ve huzurunuzu mutlaka artırırım.',
    meaningEn: 'If you are grateful, I will surely increase you in favor.',
    meaningAr: 'لئن شكرتم لأزيدنكم',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Hûd 11:115',
    referenceEn: 'Hud 11:115',
    referenceAr: 'هود ١١:١١٥',
    arabic: 'وَاصْبِرْ فَإِنَّ اللَّهَ لَا يُضِيعُ أَجْرَ الْمُحْسِنِينَ',
    meaningTr: 'Sabret! Çünkü Allah güzel davrananların emeğini ve gözyaşını asla zayi etmez.',
    meaningEn: 'And be patient, for indeed, Allah does not allow the reward of those who do good to be lost.',
    meaningAr: 'واصبر فإن الله لا يضيع أجر المحسنين',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Âl-i İmrân 3:146',
    referenceEn: 'Ali \'Imran 3:146',
    referenceAr: 'آل عمران ٣:١٤٦',
    arabic: 'وَاللَّهُ يُحِبُّ الصَّابِرِينَ',
    meaningTr: 'Şüphesiz Allah sabredenleri sever.',
    meaningEn: 'And Allah loves the steadfast.',
    meaningAr: 'والله يحب الصابرين',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Tûr 52:48',
    referenceEn: 'At-Tur 52:48',
    referenceAr: 'الطور ٥٢:٤٨',
    arabic: 'وَاصْبِرْ لِحُكْمِ رَبِّكَ فَإِنَّكَ بِأَعْيُنِنَا',
    meaningTr: 'Rabbinin hükmüne sabret; çünkü sen Bizim gözetimimiz ve korumamız altındasın.',
    meaningEn: 'And be patient for the decision of your Lord, for indeed, you are in Our eyes.',
    meaningAr: 'واصبر لحكم ربك فإنك بأعيننا',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Ra\'d 13:24',
    referenceEn: 'Ar-Ra\'d 13:24',
    referenceAr: 'الرعد ١٣:٢٤',
    arabic: 'سَلَامٌ عَلَيْكُم بِمَا صَبَرْتُمْ ۚ فَنِعْمَ عُقْبَى الدَّارِ',
    meaningTr: 'Sabrettiğiniz için size selâm olsun! Dünya yurdunun sonu ne güzeldir.',
    meaningEn: 'Peace be upon you for what you patiently endured. And excellent is the final home.',
    meaningAr: 'سلام عليكم بما صبرتم فنعم عقبى الدار',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Yûsuf 12:90',
    referenceEn: 'Yusuf 12:90',
    referenceAr: 'يوسف ١٢:٩٠',
    arabic: 'إِنَّهُ مَن يَتَّقِ وَيَصْبِرْ فَإِنَّ اللَّهَ لَا يُضِيعُ أَجْرَ الْمُحْسِنِينَ',
    meaningTr: 'Kim Allah\'tan sakınır ve sabrederse, şüphesiz Allah iyilik edenlerin mükâfatını zayi etmez.',
    meaningEn: 'Indeed, he who fears Allah and is patient, then indeed, Allah does not allow the reward of the doers of good to be lost.',
    meaningAr: 'إنه من يتق ويصبر فإن الله لا يضيع أجر المحسنين',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Ankebût 29:69',
    referenceEn: 'Al-\'Ankabut 29:69',
    referenceAr: 'العنكبوت ٢٩:٦٩',
    arabic: 'وَالَّذِينَ جَاهَدُوا فِينَا لَنَهْدِيَنَّهُمْ سُبُلَنَا',
    meaningTr: 'Bizim uğrumuzda gayret gösterip direnenleri elbette kendi yollarımıza eriştireceğiz.',
    meaningEn: 'And those who strive for Us – We will surely guide them to Our ways.',
    meaningAr: 'والذين جاهدوا فينا لنهدينهم سبلنا',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Meâric 70:5',
    referenceEn: 'Al-Ma\'arij 70:5',
    referenceAr: 'المعارج ٧٠:٥',
    arabic: 'فَاصْبِرْ صَبْرًا جَمِيلًا',
    meaningTr: 'Şimdi sen, gönlünü daraltmadan güzel bir sabırla sabret.',
    meaningEn: 'So be patient with gracious patience.',
    meaningAr: 'فاصبر صبرا جميلا',
  ),
];

const List<WidgetPreviewQuote> _duaQuotes = [
  WidgetPreviewQuote(
    referenceTr: 'Tâhâ 20:25-26',
    referenceEn: 'Taha 20:25-26',
    referenceAr: 'طه ٢٠:٢٥-٢٦',
    arabic: 'رَبِّ اشْرَحْ لِي صَدْرِي ۝ وَيَسِّرْ لِي أَمْرِي',
    meaningTr: 'Rabbim! Daralan gönlüme genişlik ve ferahlık ver, zor işimi bana kolaylaştır.',
    meaningEn: 'My Lord, expand for me my chest and ease for me my task.',
    meaningAr: 'رب اشرح لي صدري ويسر لي أمري',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Enbiyâ 21:87',
    referenceEn: 'Al-Anbiya 21:87',
    referenceAr: 'الأنبياء ٢١:٨٧',
    arabic: 'لَّا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ',
    meaningTr: 'Senden başka ilâh yoktur; Seni tenzih ederim. Gerçekten ben nefsine yazık edenlerden oldum.',
    meaningEn: 'There is no deity except You; exalted are You. Indeed, I have been of the wrongdoers.',
    meaningAr: 'لا إله إلا أنت سبحانك إني كنت من الظالمين',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Kasas 28:24',
    referenceEn: 'Al-Qasas 28:24',
    referenceAr: 'القصص ٢٨:٢٤',
    arabic: 'رَبِّ إِنِّي لِمَا أَنزَلْتَ إِلَيَّ مِنْ خَيْرٍ فَقِيرٌ',
    meaningTr: 'Rabbim! Doğrusu bana indireceğin her hayra öyle muhtacım ki...',
    meaningEn: 'My Lord, indeed I am, for whatever good You would send down to me, in need.',
    meaningAr: 'رب إني لما أنزلت إلي من خير فقير',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Bakara 2:201',
    referenceEn: 'Al-Baqarah 2:201',
    referenceAr: 'البقرة ٢:٢٠١',
    arabic: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
    meaningTr: 'Rabbimiz! Bize dünyada da iyilik ve güzellik ver, ahirette de iyilik ver.',
    meaningEn: 'Our Lord, give us in this world good and in the Hereafter good and protect us from the punishment of the Fire.',
    meaningAr: 'ربنا آتنا في الدنيا حسنة وفي الآخرة حسنة وقنا عذاب النار',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Mü\'min 40:60',
    referenceEn: 'Ghafir 40:60',
    referenceAr: 'غافر ٤٠:٦٠',
    arabic: 'وَقَالَ رَبُّكُمُ ادْعُونِي أَسْتَجِبْ لَكُمْ',
    meaningTr: 'Rabbiniz buyurdu ki: Bana dua edin, size icabet edeyim.',
    meaningEn: 'And your Lord says: Call upon Me; I will respond to you.',
    meaningAr: 'وقال ربكم ادعوني أستجب لكم',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Kehf 18:10',
    referenceEn: 'Al-Kahf 18:10',
    referenceAr: 'الكهف ١٨:١٠',
    arabic: 'رَبَّنَا آتِنَا مِن لَّدُنكَ رَحْمَةً وَهَيِّئْ لَنَا مِنْ أَمْرِنَا رَشَدًا',
    meaningTr: 'Rabbimiz! Katından bize bir rahmet ver ve şu işimizde bize kurtuluş yolu hazırla.',
    meaningEn: 'Our Lord, grant us from Yourself mercy and prepare for us from our affair right guidance.',
    meaningAr: 'ربنا آتنا من لدنك رحمة وهيئ لنا من أمرنا رشدا',
  ),
  WidgetPreviewQuote(
    referenceTr: 'İbrâhîm 14:40',
    referenceEn: 'Ibrahim 14:40',
    referenceAr: 'إبراهيم ١٤:٤٠',
    arabic: 'رَبِّ اجْعَلْنِي مُقِيمَ الصَّلَاةِ وَمِن ذُرِّيَّتِي ۚ رَبَّنَا وَتَقَبَّلْ دُعَاءِ',
    meaningTr: 'Rabbim! Beni ve soyumu namazı aşkla yaşayanlardan eyle; Rabbimiz, duamı kabul buyur.',
    meaningEn: 'My Lord, make me an establisher of prayer, and from my descendants. Our Lord, and accept my supplication.',
    meaningAr: 'رب اجعلني مقيم الصلاة ومن ذريتي ربنا وتقبل دعاء',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Âl-i İmrân 3:8',
    referenceEn: 'Ali \'Imran 3:8',
    referenceAr: 'آل عمران ٣:٨',
    arabic: 'رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِن لَّدُنكَ رَحْمَةً',
    meaningTr: 'Rabbimiz! Bizi doğru yola ilettikten sonra kalplerimizi kaydırma ve bize katından rahmet bağışla.',
    meaningEn: 'Our Lord, let not our hearts deviate after You have guided us and grant us from Yourself mercy.',
    meaningAr: 'ربنا لا تزغ قلوبنا بعد إذ هديتنا وهب لنا من لدنك رحمة',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Furkân 25:74',
    referenceEn: 'Al-Furqan 25:74',
    referenceAr: 'الفرقان ٢٥:٧٤',
    arabic: 'رَبَّنَا هَبْ لَنَا مِنْ أَزْوَاجِنَا وَذُرِّيَّاتِنَا قُرَّةَ أَعْيُنٍ',
    meaningTr: 'Rabbimiz! Bize eşlerimizden ve evlatlarımızdan gözümüzün aydınlığı olacak iyilikler lütfet.',
    meaningEn: 'Our Lord, grant us from among our spouses and offspring comfort to our eyes.',
    meaningAr: 'ربنا هب لنا من أزواجنا وذرياتنا قرة أعين',
  ),
  WidgetPreviewQuote(
    referenceTr: 'A\'râf 7:55',
    referenceEn: 'Al-A\'raf 7:55',
    referenceAr: 'الأعراف ٧:٥٥',
    arabic: 'ادْعُوا رَبَّكُمْ تَضَرُّعًا وَخُفْيَةً',
    meaningTr: 'Rabbinize boyun bükerek, gönülden ve gizlice yalvarın.',
    meaningEn: 'Call upon your Lord in humility and privately.',
    meaningAr: 'ادعوا ربكم تضرعا وخفية',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Yûsuf 12:101',
    referenceEn: 'Yusuf 12:101',
    referenceAr: 'يوسف ١٢:١٠١',
    arabic: 'أَنتَ وَلِيِّي فِي الدُّنْيَا وَالْآخِرَةِ ۖ تَوَفَّنِي مُسْلِمًا وَأَلْحِقْنِي بِالصَّالِحِينَ',
    meaningTr: 'Dünyada da ahirette de benim dostum Sensin; canımı Müslüman olarak al ve beni iyilere kat.',
    meaningEn: 'You are my protector in this world and the Hereafter. Cause me to die a Muslim and join me with the righteous.',
    meaningAr: 'أنت وليي في الدنيا والآخرة توفني مسلما وألحقني بالصالحين',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Tahrîm 66:8',
    referenceEn: 'At-Tahrim 66:8',
    referenceAr: 'التحريم ٦٦:٨',
    arabic: 'رَبَّنَا أَتْمِمْ لَنَا نُورَنَا وَاغْفِرْ لَنَا ۖ إِنَّكَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
    meaningTr: 'Rabbimiz! Nurumuzu tamamla ve bizi bağışla; şüphesiz Sen her şeye kadirsin.',
    meaningEn: 'Our Lord, perfect for us our light and forgive us. Indeed, You are over all things competent.',
    meaningAr: 'ربنا أتمم لنا نورنا واغفر لنا إنك على كل شيء قدير',
  ),
];

const List<WidgetPreviewQuote> _tawakkulQuotes = [
  WidgetPreviewQuote(
    referenceTr: 'Talâk 65:3',
    referenceEn: 'At-Talaq 65:3',
    referenceAr: 'الطلاق ٦٥:٣',
    arabic: 'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ',
    meaningTr: 'Kim kalbini Allah\'a yaslayıp tevekkül ederse, O kendisine yeter.',
    meaningEn: 'And whoever relies upon Allah – then He is sufficient for him.',
    meaningAr: 'ومن يتوكل على الله فهو حسبه',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Âl-i İmrân 3:173',
    referenceEn: 'Ali \'Imran 3:173',
    referenceAr: 'آل عمران ٣:١٧٣',
    arabic: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
    meaningTr: 'Allah bize yeter; O ne güzel dost ve ne güzel vekildir!',
    meaningEn: 'Sufficient for us is Allah, and He is the best Disposer of affairs.',
    meaningAr: 'حسبنا الله ونعم الوكيل',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Tevbe 9:129',
    referenceEn: 'At-Tawbah 9:129',
    referenceAr: 'التوبة ٩:١٢٩',
    arabic: 'حَسْبِيَ اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ ۖ عَلَيْهِ تَوَكَّلْتُ',
    meaningTr: 'Bana Allah yeter! O\'ndan başka ilâh yoktur; ben yalnız O\'na güvenip dayandım.',
    meaningEn: 'Sufficient for me is Allah; there is no deity except Him. On Him I have relied.',
    meaningAr: 'حسبي الله لا إله إلا هو عليه توكلت',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Zümer 39:36',
    referenceEn: 'Az-Zumar 39:36',
    referenceAr: 'الزمر ٣٩:٣٦',
    arabic: 'أَلَيْسَ اللَّهُ بِكَافٍ عَبْدَهُ',
    meaningTr: 'Allah kuluna kâfi değil midir? O varken kimden korkarsın?',
    meaningEn: 'Is not Allah sufficient for His servant?',
    meaningAr: 'أليس الله بكاف عبده',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Mü\'min 40:44',
    referenceEn: 'Ghafir 40:44',
    referenceAr: 'غافر ٤٠:٤٤',
    arabic: 'وَأُفَوِّضُ أَمْرِي إِلَى اللَّهِ ۚ إِنَّ اللَّهَ بَصِيرٌ بِالْعِبَادِ',
    meaningTr: 'Ben işimi ve kaderimi Allah\'a havale ediyorum; şüphesiz Allah kullarını hakkıyla görendir.',
    meaningEn: 'And I entrust my affair to Allah. Indeed, Allah is Seeing of His servants.',
    meaningAr: 'وأفوض أمري إلى الله إن الله بصير بالعباد',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Âl-i İmrân 3:160',
    referenceEn: 'Ali \'Imran 3:160',
    referenceAr: 'آل عمران ٣:١٦٠',
    arabic: 'إِن يَنصُرْكُمُ اللَّهُ فَلَا غَالِبَ لَكُمْ',
    meaningTr: 'Eğer Allah size yardım ederse, artık sizi yenecek hiçbir güç yoktur.',
    meaningEn: 'If Allah should aid you, no one can overcome you.',
    meaningAr: 'إن ينصركم الله فلا غالب لكم',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Furkân 25:58',
    referenceEn: 'Al-Furqan 25:58',
    referenceAr: 'الفرقان ٢٥:٥٨',
    arabic: 'وَتَوَكَّلْ عَلَى الْحَيِّ الَّذِي لَا يَمُوتُ',
    meaningTr: 'Sen, asla ölmeyecek olan o diri ve bâkî Allah\'a tevekkül et.',
    meaningEn: 'And rely upon the Ever-Living who does not die.',
    meaningAr: 'وتوكل على الحي الذي لا يموت',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Tevbe 9:51',
    referenceEn: 'At-Tawbah 9:51',
    referenceAr: 'التوبة ٩:٥١',
    arabic: 'قُل لَّن يُصِيبَنَا إِلَّا مَا كَتَبَ اللَّهُ لَنَا هُوَ مَوْلَانَا',
    meaningTr: 'De ki: Allah\'ın bizim için yazdığından başkası bize asla ulaşmaz; O bizim Mevlâmızdır.',
    meaningEn: 'Say: Never will we be struck except by what Allah has decreed for us; He is our protector.',
    meaningAr: 'قل لن يصيبنا إلا ما كتب الله لنا هو مولانا',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Âl-i İmrân 3:159',
    referenceEn: 'Ali \'Imran 3:159',
    referenceAr: 'آل عمران ٣:١٥٩',
    arabic: 'إِنَّ اللَّهَ يُحِبُّ الْمُتَوَكِّلِينَ',
    meaningTr: 'Şüphesiz Allah, kendisine güvenip tevekkül edenleri sever.',
    meaningEn: 'Indeed, Allah loves those who rely upon Him.',
    meaningAr: 'إن الله يحب المتوكلين',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Yûnus 10:107',
    referenceEn: 'Yunus 10:107',
    referenceAr: 'يونس ١٠:١٠٧',
    arabic: 'وَإِن يُرِدْكَ بِخَيْرٍ فَلَا رَادَّ لِفَضْلِهِ',
    meaningTr: 'Allah senin için bir hayır dilerse, O\'nun lütfunu geri çevirebilecek kimse yoktur.',
    meaningEn: 'And if He intends for you good, then there is no repeller of His bounty.',
    meaningAr: 'وإن يردك بخير فلا راد لفضله',
  ),
];

const List<WidgetPreviewQuote> _akhlaqQuotes = [
  WidgetPreviewQuote(
    referenceTr: 'Fussilet 41:34',
    referenceEn: 'Fussilat 41:34',
    referenceAr: 'فصلت ٤١:٣٤',
    arabic: 'ادْفَعْ بِالَّتِي هِيَ أَحْسَنُ فَإِذَا الَّذِي بَيْنَكَ وَبَيْنَهُ عَدَاوَةٌ كَأَنَّهُ وَلِيٌّ حَمِيمٌ',
    meaningTr: 'Kötülüğü en güzel olanla sav; bir de bakarsın ki düşmanın sımsıcak bir dost oluvermiş.',
    meaningEn: 'Repel evil by that which is better; and thereupon the one between whom and you is enmity will become as though a devoted friend.',
    meaningAr: 'ادفع بالتي هي أحسن فإذا الذي بينك وبينه عداوة كأنه ولي حميم',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Kalem 68:4',
    referenceEn: 'Al-Qalam 68:4',
    referenceAr: 'القلم ٦٨:٤',
    arabic: 'وَإِنَّكَ لَعَلَىٰ خُلُقٍ عَظِيمٍ',
    meaningTr: 'Ve şüphesiz sen pek yüce bir ahlâk üzerindesin.',
    meaningEn: 'And indeed, you are of a great moral character.',
    meaningAr: 'وإنك لعلى خلق عظيم',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Âl-i İmrân 3:134',
    referenceEn: 'Ali \'Imran 3:134',
    referenceAr: 'آل عمران ٣:١٣٤',
    arabic: 'وَالْكَاظِمِينَ الْغَيْظَ وَالْعَافِينَ عَنِ النَّاسِ ۗ وَاللَّهُ يُحِبُّ الْمُحْسِنِينَ',
    meaningTr: 'Onlar öfkelerini yutarlar ve insanları affederler. Allah güzel davrananları sever.',
    meaningEn: 'Who restrain anger and who pardon the people – and Allah loves the doers of good.',
    meaningAr: 'والكاظمين الغيظ والعافين عن الناس والله يحب المحسنين',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Nûr 24:22',
    referenceEn: 'An-Nur 24:22',
    referenceAr: 'النور ٢٤:٢٢',
    arabic: 'وَلْيَعْفُوا وَلْيَصْفَحُوا ۗ أَلَا تُحِبُّونَ أَن يَغْفِرَ اللَّهُ لَكُمْ',
    meaningTr: 'Affetsinler ve hoş görsünler. Allah\'ın sizi bağışlamasını istemez misiniz?',
    meaningEn: 'Let them pardon and overlook. Would you not like that Allah should forgive you?',
    meaningAr: 'وليعفوا وليصفحوا ألا تحبون أن يغفر الله لكم',
  ),
  WidgetPreviewQuote(
    referenceTr: 'İsrâ 17:53',
    referenceEn: 'Al-Isra 17:53',
    referenceAr: 'الإسراء ١٧:٥٣',
    arabic: 'وَقُل لِّعِبَادِي يَقُولُوا الَّتِي هِيَ أَحْسَنُ',
    meaningTr: 'Kullarıma söyle: Kalp kırmasınlar, daima sözün en güzelini söylesinler.',
    meaningEn: 'And tell My servants to say that which is best.',
    meaningAr: 'وقل لعبادي يقولوا التي هي أحسن',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Rahmân 55:60',
    referenceEn: 'Ar-Rahman 55:60',
    referenceAr: 'الرحمن ٥٥:٦٠',
    arabic: 'هَلْ جَزَاءُ الْإِحْسَانِ إِلَّا الْإِحْسَانُ',
    meaningTr: 'İyiliğin karşılığı, iyilikten başka mıdır?',
    meaningEn: 'Is the reward for good anything but good?',
    meaningAr: 'هل جزاء الإحسان إلا الإحسان',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Hucurât 49:10',
    referenceEn: 'Al-Hujurat 49:10',
    referenceAr: 'الحجرات ٤٩:١٠',
    arabic: 'إِنَّمَا الْمُؤْمِنُونَ إِخْوَةٌ فَأَصْلِحُوا بَيْنَ أَخَوَيْكُمْ',
    meaningTr: 'Şüphesiz müminler ancak kardeştirler; öyleyse kardeşlerinizin arasını düzeltin.',
    meaningEn: 'The believers are but brothers, so make settlement between your brothers.',
    meaningAr: 'إنما المؤمنون إخوة فأصلحوا بين أخويكم',
  ),
  WidgetPreviewQuote(
    referenceTr: 'A\'râf 7:199',
    referenceEn: 'Al-A\'raf 7:199',
    referenceAr: 'الأعراف ٧:١٩٩',
    arabic: 'خُذِ الْعَفْوَ وَأْمُرْ بِالْعُرْفِ وَأَعْرِضْ عَنِ الْجَاهِلِينَ',
    meaningTr: 'Sen af yolunu tut, iyiliği emret ve cahillerden yüz çevir.',
    meaningEn: 'Take what is given freely, enjoin what is good, and turn away from the ignorant.',
    meaningAr: 'خذ العفو وأمر بالعرف وأعرض عن الجاهلين',
  ),
  WidgetPreviewQuote(
    referenceTr: 'Lokmân 31:18',
    referenceEn: 'Luqman 31:18',
    referenceAr: 'لقمان ٣١:١٨',
    arabic: 'وَلَا تُصَعِّرْ خَدَّكَ لِلنَّاسِ وَلَا تَمْشِ فِي الْأَرْضِ مَرَحًا',
    meaningTr: 'İnsanlardan kibirle yüz çevirme ve yeryüzünde böbürlenerek yürüme.',
    meaningEn: 'And do not turn your cheek in contempt toward people and do not walk through the earth exultantly.',
    meaningAr: 'ولا تصعر خدك للناس ولا تمش في الأرض مرحا',
  ),
];

const Map<String, List<WidgetPreviewQuote>> kWidgetCategoryQuotes = {
  'comfort': _comfortQuotes,
  'sabr': _sabrQuotes,
  'dua': _duaQuotes,
  'tawakkul': _tawakkulQuotes,
  'akhlaq': _akhlaqQuotes,
  'all': [
    WidgetPreviewQuote(
      referenceTr: 'Ra\'d 13:28',
      referenceEn: 'Ar-Ra\'d 13:28',
      referenceAr: 'الرعد ١٣:٢٨',
      arabic: 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
      meaningTr: 'Bilin ki, yorgun kalpler ancak Allah\'ı anmakla huzur bulur.',
      meaningEn: 'Unquestionably, by the remembrance of Allah hearts are assured.',
      meaningAr: 'ألا بذكر الله تطمئن القلوب',
    ),
    WidgetPreviewQuote(
      referenceTr: 'Bakara 2:152',
      referenceEn: 'Al-Baqarah 2:152',
      referenceAr: 'البقرة ٢:١٥٢',
      arabic: 'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
      meaningTr: 'Öyleyse siz Beni anın ki, Ben de sizi anayım. Bana şükredin.',
      meaningEn: 'So remember Me; I will remember you. And be grateful to Me.',
      meaningAr: 'فاذكروني أذكركم واشكروا لي ولا تكفرون',
    ),
    ..._comfortQuotes,
    ..._sabrQuotes,
    ..._duaQuotes,
    ..._tawakkulQuotes,
    ..._akhlaqQuotes,
  ],
};

/// Kilit Ekranı & Widget Yönetim ve Özelleştirme Merkezi
class WidgetCenterScreen extends ConsumerStatefulWidget {
  const WidgetCenterScreen({super.key});

  @override
  ConsumerState<WidgetCenterScreen> createState() => _WidgetCenterScreenState();
}


class _WidgetCenterScreenState extends ConsumerState<WidgetCenterScreen> {
  WidgetCategoryType _selectedCategory = WidgetCategoryType.quotes;

  // Özelleştirme ayarları (Artık standart kodlarla saklanır)
  String _selectedQuoteCategory = 'all';
  String _verseViewMode = 'meal_only';
  String _refreshInterval = '1h';
  String _textSize = 'standard';
  String _fontFamily = 'standard';
  String? _appliedVerseRef;
  bool _isPinned = false;

  int _quoteIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedPreferences();
  }

  Future<void> _loadSavedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _selectedQuoteCategory = prefs.getString('widget_quote_category') ?? 'all';
      _verseViewMode = prefs.getString('widget_verse_view') ?? 'meal_only';
      _refreshInterval = prefs.getString('widget_refresh_interval') ?? '1h';
      _textSize = prefs.getString('widget_text_size') ?? 'standard';
      _fontFamily = prefs.getString('widget_font_family') ?? 'standard';
      _isPinned = prefs.getBool('widget_is_pinned') ?? false;
      final savedRef = prefs.getString('widget_applied_verse_ref');
      _appliedVerseRef = (savedRef != null && savedRef.isNotEmpty) ? savedRef : null;

      // Eski Türkçe ayar değerlerini yeni standart kodlara dönüştür
      if (_selectedQuoteCategory == 'Tümü') _selectedQuoteCategory = 'all';
      if (_selectedQuoteCategory == 'Kalbe Huzur & Teselli') _selectedQuoteCategory = 'comfort';
      if (_selectedQuoteCategory == 'Sabır ve Şükür') _selectedQuoteCategory = 'sabr';
      if (_selectedQuoteCategory == 'Dualar') _selectedQuoteCategory = 'dua';
      if (_selectedQuoteCategory == 'İman ve Tevekkül') _selectedQuoteCategory = 'tawakkul';
      if (_selectedQuoteCategory == 'Ahlak') _selectedQuoteCategory = 'akhlaq';

      if (_verseViewMode == 'Yalnızca Meal') _verseViewMode = 'meal_only';
      if (_verseViewMode == 'Arapça + Meal') _verseViewMode = 'arabic_meal';
      if (_verseViewMode == 'Yalnızca Arapça') _verseViewMode = 'arabic_only';

      if (_refreshInterval == '15 Dakika') _refreshInterval = '15m';
      if (_refreshInterval == '30 Dakika') _refreshInterval = '30m';
      if (_refreshInterval == 'Her saat') _refreshInterval = '1h';
      if (_refreshInterval == 'Her gün') _refreshInterval = '1d';

      if (_textSize == 'Küçük') _textSize = 'small';
      if (_textSize == 'Standart') _textSize = 'standard';
      if (_textSize == 'Büyük') _textSize = 'large';

      if (_fontFamily == 'Standart') _fontFamily = 'standard';
      if (_fontFamily == 'Zarif (Lato)') _fontFamily = 'lato';
      if (_fontFamily == 'Klasik (Amiri)') _fontFamily = 'amiri';

      if (_appliedVerseRef != null) {
        final list = kWidgetCategoryQuotes[_selectedQuoteCategory] ?? kWidgetCategoryQuotes['all']!;
        final idx = list.indexWhere((q) =>
            q.referenceTr == _appliedVerseRef ||
            q.referenceEn == _appliedVerseRef ||
            q.referenceAr == _appliedVerseRef);
        if (idx >= 0) {
          _quoteIndex = idx;
          final currentLang = ref.read(appStringsProvider).language;
          _appliedVerseRef = list[idx].getReference(currentLang);
        }
      }

      _isLoading = false;
    });
  }

  Future<void> _savePreference(String key, String value, Function(String) updater) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    if (!mounted) return;
    setState(() {
      updater(value);
      if (key == 'widget_quote_category') {
        _quoteIndex = 0;
      }
    });
    HapticFeedback.lightImpact();

    await WidgetService().updateAllWidgets();
  }

   (String, String, String, String) _resolveActivePreviewVerse(AppLanguage lang) {
    final langCode = lang.code;
    if (_selectedCategory == WidgetCategoryType.dailyVerse) {
      final verse = ShortVerseNotification.pool[_quoteIndex % ShortVerseNotification.pool.length];
      final refText = verse.localizedReference(langCode);
      final meal = verse.localizedText(langCode);
      final arabic = verse.arabicText;
      final formatted = (_verseViewMode == 'arabic_only' || _verseViewMode == 'Yalnızca Arapça')
          ? arabic
          : ((_verseViewMode == 'arabic_meal' || _verseViewMode == 'Arapça + Meal')
              ? '$arabic\n$meal'
              : meal);
      return (refText, formatted, arabic, verse.verseReference);
    }
    final currentQuote = _getCurrentQuote();
    final refText = currentQuote.localizedReference(langCode);
    final formatted = currentQuote.formatForViewMode(_verseViewMode, langCode);
    return (refText, formatted, currentQuote.arabic, currentQuote.referenceTr);
  }

  void _showWidgetFeedbackSnackBar(IconData icon, String msg) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: BeyanColors.tone(0xFFFFDF7A), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: BeyanColors.tone(0xFF0A382E),
        elevation: 8,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 98),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: BeyanColors.tone(0xFFFFDF7A), width: 1.2),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _syncAndApplyWidgetSettings() async {
    HapticFeedback.mediumImpact();
    await HomeWidget.setAppGroupId(AppConstants.appGroupId);
    final prefs = await SharedPreferences.getInstance();
    final strings = ref.read(appStringsProvider);

    await prefs.setString('widget_quote_category', _selectedQuoteCategory);
    await prefs.setString('widget_verse_view', _verseViewMode);
    await prefs.setString('widget_refresh_interval', _refreshInterval);
    await HomeWidget.saveWidgetData<String>('widget_refresh_interval', _refreshInterval);
    await prefs.setString('widget_text_size', _textSize);
    await prefs.setString('widget_font_family', _fontFamily);
    await prefs.setString('widget_active_category', _selectedCategory.name);

    final (refText, formattedText, arabicText, trRef) = _resolveActivePreviewVerse(strings.language);
    final nonce = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await prefs.setString('widget_applied_verse_ref', refText);
    await prefs.setString('widget_applied_verse_text', formattedText);
    await prefs.setInt('widget_apply_nonce', nonce);
    await HomeWidget.saveWidgetData<String>('widget_applied_verse_ref', refText);
    await HomeWidget.saveWidgetData<String>('widget_applied_verse_text', formattedText);
    await HomeWidget.saveWidgetData<String>('widget_applied_verse_arabic', arabicText);
    await HomeWidget.saveWidgetData<int>('widget_apply_nonce', nonce);

    final refMatch = RegExp(r'(\d+):(\d+)').firstMatch(trRef);
    final surahNum = refMatch != null ? int.tryParse(refMatch.group(1)!) ?? 0 : 0;
    final verseNum = refMatch != null ? int.tryParse(refMatch.group(2)!) ?? 0 : 0;
    if (surahNum > 0) {
      await prefs.setInt('widget_applied_verse_surah', surahNum);
      await prefs.setInt('widget_applied_verse_number', verseNum);
      await HomeWidget.saveWidgetData<int>('widget_applied_verse_surah', surahNum);
      await HomeWidget.saveWidgetData<int>('widget_applied_verse_number', verseNum);
    }

    if (!mounted) return;
    setState(() {
      _appliedVerseRef = refText;
    });

    await WidgetService().updateAllWidgets();

    if (mounted) {
      final msg = strings.language == AppLanguage.turkish
          ? '✨ $refText kilit ekranı widget\'ına uygulandı!'
          : (strings.language == AppLanguage.arabic
              ? '✨ تم تطبيق $refText على ويدجت شاشة القفل!'
              : (strings.language == AppLanguage.indonesian
                  ? '✨ $refText diterapkan ke widget layar kunci!'
                  : '✨ $refText applied to Lock Screen widget!'));

      _showWidgetFeedbackSnackBar(Icons.check_circle, msg);
    }
  }

  /// Seçili ayeti kilit ekranına sabitler (kullanıcı özellikle isterse)
  Future<void> _pinCurrentVerse() async {
    HapticFeedback.mediumImpact();
    await HomeWidget.setAppGroupId(AppConstants.appGroupId);
    final prefs = await SharedPreferences.getInstance();
    final strings = ref.read(appStringsProvider);
    final (refText, formattedText, arabicText, trRef) = _resolveActivePreviewVerse(strings.language);
    final nonce = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await prefs.setBool('widget_is_pinned', true);
    await HomeWidget.saveWidgetData<bool>('widget_is_pinned', true);
    await prefs.setString('widget_applied_verse_ref', refText);
    await prefs.setString('widget_applied_verse_text', formattedText);
    await prefs.setInt('widget_apply_nonce', nonce);
    await HomeWidget.saveWidgetData<String>('widget_applied_verse_ref', refText);
    await HomeWidget.saveWidgetData<String>('widget_applied_verse_text', formattedText);
    await HomeWidget.saveWidgetData<String>('widget_applied_verse_arabic', arabicText);
    await HomeWidget.saveWidgetData<int>('widget_apply_nonce', nonce);

    final refMatch = RegExp(r'(\d+):(\d+)').firstMatch(trRef);
    final surahNum = refMatch != null ? int.tryParse(refMatch.group(1)!) ?? 0 : 0;
    final verseNum = refMatch != null ? int.tryParse(refMatch.group(2)!) ?? 0 : 0;
    if (surahNum > 0) {
      await prefs.setInt('widget_applied_verse_surah', surahNum);
      await prefs.setInt('widget_applied_verse_number', verseNum);
      await HomeWidget.saveWidgetData<int>('widget_applied_verse_surah', surahNum);
      await HomeWidget.saveWidgetData<int>('widget_applied_verse_number', verseNum);
    }

    if (!mounted) return;
    setState(() {
      _isPinned = true;
      _appliedVerseRef = refText;
    });

    await WidgetService().updateAllWidgets();

    if (mounted) {
      _showWidgetFeedbackSnackBar(Icons.push_pin, strings.versePinnedSnackBar(refText));
    }
  }

  Future<void> _restoreAutomaticVerseRotation() async {
    HapticFeedback.lightImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('widget_is_pinned', false);
    await HomeWidget.saveWidgetData<bool>('widget_is_pinned', false);

    if (!mounted) return;
    setState(() {
      _isPinned = false;
    });

    await WidgetService().updateAllWidgets();

    if (mounted) {
      final strings = ref.read(appStringsProvider);
      final msg = strings.language == AppLanguage.turkish
          ? 'Kilit ekranı widget\'ı otomatik âyet döngüsüne geri döndü!'
          : (strings.language == AppLanguage.arabic
              ? 'تمت استعادة التدوير التلقائي للآيات على ويدجت شاشة القفل!'
              : (strings.language == AppLanguage.indonesian
                  ? 'Widget layar kunci dikembalikan ke siklus otomatis ayat!'
                  : 'Lock screen widget restored to automatic rotation!'));

      _showWidgetFeedbackSnackBar(Icons.autorenew, msg);
    }
  }

  String _getLocalizedVerseView(String mode, AppLanguage lang) {
    final strings = ref.read(appStringsProvider);
    if (mode == 'meal_only' || mode == 'Yalnızca Meal') {
      return strings.translationOnly;
    }
    if (mode == 'arabic_meal' || mode == 'Arapça + Meal') {
      return strings.arabicPlusTranslation;
    }
    if (mode == 'arabic_only' || mode == 'Yalnızca Arapça') {
      return strings.arabicOnly;
    }
    return mode;
  }

  String _getLocalizedRefreshInterval(String interval, AppLanguage lang) {
    final strings = ref.read(appStringsProvider);
    if (interval == '15m' || interval == '15 Dakika') {
      return strings.interval15m;
    }
    if (interval == '30m' || interval == '30 Dakika') {
      return strings.interval30m;
    }
    if (interval == '1h' || interval == 'Her saat') {
      return strings.interval1h;
    }
    if (interval == '1d' || interval == 'Her gün') {
      return strings.interval1d;
    }
    return interval;
  }

  String _getLocalizedCategory(String cat, AppLanguage lang) {
    final strings = ref.read(appStringsProvider);
    if (cat == 'all' || cat == 'Tümü') {
      return strings.allCategories;
    }
    if (cat == 'comfort' || cat == 'Kalbe Huzur & Teselli') {
      return strings.comfortAndSolace;
    }
    if (cat == 'sabr' || cat == 'Sabır ve Şükür') {
      return strings.patienceAndGratitude;
    }
    if (cat == 'dua' || cat == 'Dualar') {
      return strings.supplications;
    }
    if (cat == 'tawakkul' || cat == 'İman ve Tevekkül') {
      return strings.faithAndTrust;
    }
    if (cat == 'akhlaq' || cat == 'Ahlak') {
      return strings.moralsAndEthics;
    }
    return cat;
  }

  String _getLocalizedTextSize(String size, AppLanguage lang) {
    final strings = ref.read(appStringsProvider);
    if (size == 'small' || size == 'Küçük') {
      return strings.textSizeSmall;
    }
    if (size == 'standard' || size == 'Standart') {
      return strings.textSizeStandard;
    }
    if (size == 'large' || size == 'Büyük') {
      return strings.textSizeLarge;
    }
    return size;
  }

  String _getLocalizedFontFamily(String font, AppLanguage lang) {
    final strings = ref.read(appStringsProvider);
    if (font == 'standard' || font == 'Standart') {
      return strings.fontStandard;
    }
    if (font == 'lato' || font == 'Zarif (Lato)') {
      return strings.fontLato;
    }
    if (font == 'amiri' || font == 'Klasik (Amiri)') {
      return strings.fontAmiri;
    }
    return font;
  }

  String _getAppliedPrefix(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.turkish:
        return 'Uygulanan âyet';
      case AppLanguage.french:
        return 'Verset appliqué';
      case AppLanguage.arabic:
        return 'الآية المطبقة';
      case AppLanguage.indonesian:
        return 'Ayat yang diterapkan';
      case AppLanguage.german:
        return 'Angewandter Vers';
      case AppLanguage.russian:
        return 'Применённый аят';
      case AppLanguage.urdu:
        return 'لاگو شدہ آیت';
      default:
        return 'Applied verse';
    }
  }

  void _showOptionSheet<T>({
    required String title,
    required List<String> options,
    required String currentValue,
    String Function(String)? labelBuilder,
    required Function(String) onSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? BeyanColors.tone(0xFF07211C) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...options.map((opt) {
                final displayLabel = labelBuilder != null ? labelBuilder(opt) : opt;
                final isSelected = opt == currentValue || (labelBuilder != null && (labelBuilder(opt) == currentValue || opt == currentValue));
                return ListTile(
                  title: Text(
                    displayLabel,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? BeyanColors.tone(0xFFD4AF37)
                          : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_rounded, color: BeyanColors.tone(0xFFD4AF37))
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    onSelected(opt);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectivePalette = ref.watch(effectivePaletteProvider);
    BeyanColors.setPalette(effectivePalette);
    final strings = ref.watch(appStringsProvider);

    return Scaffold(
      backgroundColor: BeyanColors.tone(0xFF051C17),
      appBar: AppBar(
        backgroundColor: BeyanColors.tone(0xFF051C17),
        elevation: 0,
        title: Text(
          strings.lockScreenWidgetsTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: BeyanColors.tone(0xFFD4AF37)))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── iOS Kilit Ekranı Ekleme Bilgilendirme Kartı ───────────
                  _buildLockScreenGuideBanner(strings),

                  const SizedBox(height: 14),

                  // ── Yatay Kategori İkon Seçici (6 İkon) ───────────────────
                  _buildCategoryIconsBar(),

                  const SizedBox(height: 24),

                  // ── Gerçekçi Kilit Ekranı Canlı Önizlemesi (9:41) ──────────
                  _buildLockScreenPhoneMockup(strings),

                  const SizedBox(height: 24),

                  // ── Başlık ve Açıklama ───────────────────────────────────
                  _buildWidgetTitleAndDescription(strings),

                  const SizedBox(height: 20),

                  // ── Özelleştirilebilir Seçenekler Listesi ─────────────────
                  _buildCustomizationOptionsCard(strings),

                  const SizedBox(height: 16),

                  // ── Kilit Ekranı Widget'ına Uygula Butonu ─────────────────
                  _buildApplyWidgetButton(strings),

                  const SizedBox(height: 24),

                  // ── Özellikler (Yeşil Onay İşaretleri) ────────────────────
                  _buildFeaturesCard(strings),

                  const SizedBox(height: 24),

                  // ── Nasıl Eklenir Adımları ────────────────────────────────
                  _buildHowToAddGuide(strings),

                  const SizedBox(height: 20),

                  // Alt banner reklam
                  const BannerAdWidget(),
                ],
              ),
            ),
    );
  }

  // ── iOS Kilit Ekranı Ekleme Bilgilendirme Kartı ───────────────────────────
  Widget _buildLockScreenGuideBanner(AppStrings strings) {
    final tipText = strings.widgetTip;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: BeyanColors.tone(0xFF0C2923),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BeyanColors.tone(0xFF10B981).withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: BeyanColors.tone(0xFF2DD4BF), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tipText,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 6 İkonlu Yatay Kategori Çubuğu (Screenshots 2-5 üst kısmı) ─────────────
  Widget _buildCategoryIconsBar() {
    final categories = [
      (WidgetCategoryType.quotes, Icons.format_quote_rounded),
      (WidgetCategoryType.dailyVerse, Icons.menu_book_rounded),
      (WidgetCategoryType.prayerTimes, Icons.access_time_rounded),
      (WidgetCategoryType.countdown, Icons.timer_outlined),
      (WidgetCategoryType.hijri, Icons.nightlight_round),
      (WidgetCategoryType.sunTimes, Icons.wb_sunny_outlined),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: categories.map((item) {
          final isSelected = _selectedCategory == item.$1;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () async {
                HapticFeedback.selectionClick();
                setState(() => _selectedCategory = item.$1);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('widget_active_category', item.$1.name);
                if (ref.read(premiumProvider).hasWidgetAccess) {
                  await WidgetService().updateAllWidgets();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? BeyanColors.tone(0xFF10B981)
                      : BeyanColors.tone(0xFF0E2C24),
                  border: Border.all(
                    color: isSelected
                        ? BeyanColors.tone(0xFF34D399)
                        : Colors.white.withValues(alpha: 0.1),
                    width: 1.2,
                  ),
                ),
                child: Icon(
                  item.$2,
                  color: isSelected ? Colors.white : Colors.white60,
                  size: 22,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Gerçekçi iPhone Kilit Ekranı Önizlemesi ────────────────────────────────
  Widget _buildLockScreenPhoneMockup(AppStrings strings) {
    final asrLabel = '${strings.asr}: 2:15:30';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
      decoration: BoxDecoration(
        color: BeyanColors.tone(0xFF041713),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Kilit Ekranı Tarihi veya Kompakt Satır Widget'ı ───────────────
          if (_selectedCategory == WidgetCategoryType.countdown) ...[
            // Screenshot 5: "Pazartesi, 6 Haziran | ⏱️ İkindi: 2:15:30"
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  strings.mockupDate,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  '|',
                  style: TextStyle(color: Colors.white38),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.timer_outlined, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(
                  asrLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(
              strings.mockupDate,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          const SizedBox(height: 6),

          // ── Büyük Saat: "9:41" ───────────────────────────────────────────
          const Text(
            '9:41',
            style: TextStyle(
              fontSize: 76,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              letterSpacing: -2,
              height: 1.0,
            ),
          ),

          const SizedBox(height: 14),

          // ── Kilit Ekranı Saat Altı Widget Alanı ───────────────────────────
          _buildActiveWidgetPreviewContent(),

          // ── Önizlemede Farklı Âyet Gösterme Butonu (< Başka Ayet Dene >) ──
          if (_selectedCategory == WidgetCategoryType.quotes ||
              _selectedCategory == WidgetCategoryType.dailyVerse) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    final total = _selectedCategory == WidgetCategoryType.dailyVerse
                        ? ShortVerseNotification.pool.length
                        : (kWidgetCategoryQuotes[_selectedQuoteCategory] ?? kWidgetCategoryQuotes['all']!).length;
                    setState(() => _quoteIndex = (_quoteIndex - 1 + total) % total);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: Icon(Icons.chevron_left_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 18),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _quoteIndex++);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shuffle_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 14),
                        const SizedBox(width: 5),
                        Text(
                          strings.previewAnotherVerse,
                          style: TextStyle(
                            color: BeyanColors.tone(0xFFFFDF7A),
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _quoteIndex++);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: Icon(Icons.chevron_right_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 18),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Font Boyutu Hesaplayıcıları (_textSize) ───────────────────────────────
  double get _previewTitleFontSize {
    switch (_textSize) {
      case 'small':
      case 'Küçük':
        return 11.0;
      case 'large':
      case 'Büyük':
        return 15.0;
      case 'standard':
      case 'Standart':
      default:
        return 13.0;
    }
  }

  double get _previewBodyFontSize {
    switch (_textSize) {
      case 'small':
      case 'Küçük':
        return 11.0;
      case 'large':
      case 'Büyük':
        return 15.0;
      case 'standard':
      case 'Standart':
      default:
        return 12.5;
    }
  }

  double get _previewArabicFontSize {
    switch (_textSize) {
      case 'small':
      case 'Küçük':
        return 14.5;
      case 'large':
      case 'Büyük':
        return 21.0;
      case 'standard':
      case 'Standart':
      default:
        return 17.5;
    }
  }

  String? get _previewFontFamily {
    switch (_fontFamily) {
      case 'amiri':
      case 'Klasik (Amiri)':
        return 'Amiri';
      case 'lato':
      case 'Zarif (Lato)':
        return 'Lato';
      default:
        return null;
    }
  }

  // Kategori bazlı aktif ayet verisi
  WidgetPreviewQuote _getCurrentQuote() {
    final list = kWidgetCategoryQuotes[_selectedQuoteCategory] ??
        kWidgetCategoryQuotes['all'] ??
        kWidgetCategoryQuotes.values.first;
    return list[_quoteIndex % list.length];
  }

  Widget _buildQuotePreviewWidget({
    required String reference,
    required String arabic,
    required String meaning,
  }) {
    final showArabic = _verseViewMode == 'arabic_meal' ||
        _verseViewMode == 'arabic_only' ||
        _verseViewMode == 'Arapça + Meal' ||
        _verseViewMode == 'Yalnızca Arapça';
    final showMeal = _verseViewMode == 'meal_only' ||
        _verseViewMode == 'arabic_meal' ||
        _verseViewMode == 'Yalnızca Meal' ||
        _verseViewMode == 'Arapça + Meal';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sûre Referansı
          Text(
            reference,
            style: TextStyle(
              color: BeyanColors.tone(0xFFFFDF7A),
              fontWeight: FontWeight.bold,
              fontSize: _previewTitleFontSize,
              fontFamily: _previewFontFamily,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),

          // Arapça Metin (Varsa)
          if (showArabic) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                arabic,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: _previewArabicFontSize,
                  height: 1.45,
                  color: Colors.white,
                ),
              ),
            ),
            if (showMeal) const SizedBox(height: 4),
          ],

          // Meal (Varsa)
          if (showMeal)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                meaning,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontSize: _previewBodyFontSize,
                  fontFamily: _previewFontFamily,
                  height: 1.3,
                  fontStyle: (_verseViewMode == 'arabic_meal' || _verseViewMode == 'Arapça + Meal') ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Aktif Kategoriye Göre Widget Önizleme İçeriği
  Widget _buildActiveWidgetPreviewContent() {
    final strings = ref.watch(appStringsProvider);
    final langCode = strings.language.code;

    switch (_selectedCategory) {
      case WidgetCategoryType.quotes:
        final quote = _getCurrentQuote();
        return _buildQuotePreviewWidget(
          reference: quote.localizedReference(langCode),
          arabic: quote.arabic,
          meaning: quote.localizedMeaning(langCode),
        );

      case WidgetCategoryType.dailyVerse:
        final verse = ShortVerseNotification.pool[_quoteIndex % ShortVerseNotification.pool.length];
        return _buildQuotePreviewWidget(
          reference: verse.localizedReference(langCode),
          arabic: verse.arabicText,
          meaning: verse.localizedText(langCode),
        );

      case WidgetCategoryType.prayerTimes:
        final timeScale = (_textSize == 'small' || _textSize == 'Küçük') ? 0.85 : ((_textSize == 'large' || _textSize == 'Büyük') ? 1.25 : 1.0);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wb_sunny_rounded, color: Colors.white70, size: 13 * timeScale),
                  const SizedBox(width: 4),
                  Text('${strings.dhuhr} 12:30 PM', style: TextStyle(color: Colors.white70, fontSize: 11 * timeScale, fontFamily: _previewFontFamily)),
                  const SizedBox(width: 8),
                  Icon(Icons.wb_twilight_rounded, color: Colors.white70, size: 13 * timeScale),
                  const SizedBox(width: 4),
                  Text('${strings.asr} 3:45 PM', style: TextStyle(color: Colors.white70, fontSize: 11 * timeScale, fontFamily: _previewFontFamily)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '2:15:30',
                style: TextStyle(
                  fontSize: 26 * timeScale,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                  fontFamily: _previewFontFamily,
                ),
              ),
            ],
          ),
        );

      case WidgetCategoryType.countdown:
        final timeScale = (_textSize == 'small' || _textSize == 'Küçük') ? 0.9 : ((_textSize == 'large' || _textSize == 'Büyük') ? 1.25 : 1.0);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Text(
            strings.language == AppLanguage.turkish
                ? 'İkindi vaktine 2 saat 15 dk kaldı'
                : (strings.language == AppLanguage.arabic
                    ? 'ساعتان و١٥ دقيقة حتى صلاة العصر'
                    : (strings.language == AppLanguage.indonesian
                        ? '2 jam 15 mnt menuju waktu Ashar'
                        : '2 hrs 15 mins until Asr prayer')),
            style: TextStyle(color: Colors.white70, fontSize: 12 * timeScale, fontFamily: _previewFontFamily),
          ),
        );

      case WidgetCategoryType.hijri:
        final timeScale = (_textSize == 'small' || _textSize == 'Küçük') ? 0.9 : ((_textSize == 'large' || _textSize == 'Büyük') ? 1.25 : 1.0);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Column(
            children: [
              Text(
                strings.language == AppLanguage.turkish
                    ? '🌙 18 Ramazan 1447'
                    : (strings.language == AppLanguage.arabic
                        ? '🌙 ١٨ رمضان ١٤٤٧'
                        : '🌙 18 Ramadan 1447'),
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13 * timeScale, fontFamily: _previewFontFamily),
              ),
              const SizedBox(height: 2),
              Text(
                strings.language == AppLanguage.turkish
                    ? 'Kadir Gecesine 9 Gün Kaldı'
                    : (strings.language == AppLanguage.arabic
                        ? '٩ أيام حتى ليلة القدر'
                        : (strings.language == AppLanguage.indonesian
                            ? '9 Hari menuju Malam Lailatul Qadr'
                            : '9 Days to Laylat al-Qadr')),
                style: TextStyle(color: Colors.white70, fontSize: 11.5 * timeScale, fontFamily: _previewFontFamily),
              ),
            ],
          ),
        );

      case WidgetCategoryType.sunTimes:
        final timeScale = (_textSize == 'small' || _textSize == 'Küçük') ? 0.9 : ((_textSize == 'large' || _textSize == 'Büyük') ? 1.25 : 1.0);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wb_sunny_outlined, color: Colors.amber, size: 16 * timeScale),
              const SizedBox(width: 6),
              Text(
                strings.language == AppLanguage.turkish
                    ? 'Güneş: 05:42 • İşrak: 06:27'
                    : (strings.language == AppLanguage.arabic
                        ? 'الشروق: ٠٥:٤٢ • الإشراق: ٠٦:٢٧'
                        : (strings.language == AppLanguage.indonesian
                            ? 'Terbit: 05:42 • Isyraq: 06:27'
                            : 'Sunrise: 05:42 • Ishraq: 06:27')),
                style: TextStyle(color: Colors.white, fontSize: 12 * timeScale, fontWeight: FontWeight.w600, fontFamily: _previewFontFamily),
              ),
            ],
          ),
        );
    }
  }


  // ── Başlık & Açıklama Metni ───────────────────────────────────────────────
  Widget _buildWidgetTitleAndDescription(AppStrings strings) {
    String title;
    String desc;

    switch (_selectedCategory) {
      case WidgetCategoryType.quotes:
        title = strings.widgetFeatureTitle;
        desc = strings.widgetFeatureDesc;
        break;
      case WidgetCategoryType.dailyVerse:
        title = strings.dailyVerseWidgetTitle;
        desc = strings.dailyVerseDesc;
        break;
      case WidgetCategoryType.prayerTimes:
        title = strings.prayerTimesWidgetTitle;
        desc = strings.prayerTimesWidgetDesc;
        break;
      case WidgetCategoryType.countdown:
        title = strings.countdownWidgetTitle;
        desc = strings.prayerCountdownDesc;
        break;
      case WidgetCategoryType.hijri:
        title = strings.hijriCalendarWidgetTitle;
        desc = strings.hijriCalendarDesc;
        break;
      case WidgetCategoryType.sunTimes:
        title = strings.sunIshraqWidgetTitle;
        desc = strings.sunTimesWidgetDesc;
        break;
    }

    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            desc,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.white.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  // ── Özelleştirilebilir Seçenekler Kartı (Screenshots 2-3) ───────────────────
  Widget _buildCustomizationOptionsCard(AppStrings strings) {
    return Container(
      decoration: BoxDecoration(
        color: BeyanColors.tone(0xFF0A241F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          // 1. Görüntülenecek Kategoriler (Yalnızca Quotes için)
          if (_selectedCategory == WidgetCategoryType.quotes) ...[
            _buildOptionTile(
              title: strings.displayCategories,
              value: _getLocalizedCategory(_selectedQuoteCategory, strings.language),
              onTap: () => _showOptionSheet(
                title: strings.displayCategories,
                options: const ['all', 'comfort', 'sabr', 'dua', 'tawakkul', 'akhlaq'],
                currentValue: _selectedQuoteCategory,
                labelBuilder: (c) => _getLocalizedCategory(c, strings.language),
                onSelected: (val) => _savePreference('widget_quote_category', val, (v) => _selectedQuoteCategory = v),
              ),
            ),
            _buildDivider(),
          ],

          // 2. Ayet Görünümü
          if (_selectedCategory == WidgetCategoryType.quotes ||
              _selectedCategory == WidgetCategoryType.dailyVerse) ...[
            _buildOptionTile(
              title: strings.verseView,
              value: _getLocalizedVerseView(_verseViewMode, strings.language),
              onTap: () => _showOptionSheet(
                title: strings.verseView,
                options: const ['meal_only', 'arabic_meal', 'arabic_only'],
                currentValue: _verseViewMode,
                labelBuilder: (v) => _getLocalizedVerseView(v, strings.language),
                onSelected: (val) => _savePreference('widget_verse_view', val, (v) => _verseViewMode = v),
              ),
            ),
            _buildDivider(),
          ],

          // 3. Alıntı Yenileme Sıklığı
          _buildOptionTile(
            title: strings.quoteRefreshInterval,
            value: _getLocalizedRefreshInterval(_refreshInterval, strings.language),
            onTap: () => _showOptionSheet(
              title: strings.quoteRefreshInterval,
              options: const ['15m', '30m', '1h', '1d'],
              currentValue: _refreshInterval,
              labelBuilder: (i) => _getLocalizedRefreshInterval(i, strings.language),
              onSelected: (val) => _savePreference('widget_refresh_interval', val, (v) => _refreshInterval = v),
            ),
          ),
          _buildDivider(),

          // 4. Metin Boyutu
          _buildOptionTile(
            title: strings.textSize,
            value: _getLocalizedTextSize(_textSize, strings.language),
            onTap: () => _showOptionSheet(
              title: strings.textSize,
              options: const ['small', 'standard', 'large'],
              currentValue: _textSize,
              labelBuilder: (s) => _getLocalizedTextSize(s, strings.language),
              onSelected: (val) => _savePreference('widget_text_size', val, (v) => _textSize = v),
            ),
          ),
          _buildDivider(),

          // 5. Yazı Tipi
          _buildOptionTile(
            title: strings.fontFamily,
            value: _getLocalizedFontFamily(_fontFamily, strings.language),
            onTap: () => _showOptionSheet(
              title: strings.fontFamily,
              options: const ['standard', 'lato', 'amiri'],
              currentValue: _fontFamily,
              labelBuilder: (f) => _getLocalizedFontFamily(f, strings.language),
              onSelected: (val) => _savePreference('widget_font_family', val, (v) => _fontFamily = v),
            ),
          ),
        ],
      ),
    );
  }

  // ── Kilit Ekranı Widget'ına Uygula Butonu ─────────────────────────────────
  Widget _buildApplyWidgetButton(AppStrings strings) {
    final btnText = strings.applySettingsToWidget;
    final pinBtnText = strings.pinVerseToLockscreen;
    final pinnedNotice = strings.currentlyPinnedLabel;
    final rotatingNotice = strings.dynamicVerseCycleActive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Döngü veya Sabitleme Durum Kartı
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: BeyanColors.tone(0xFF0B2B24),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isPinned
                  ? BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.5)
                  : BeyanColors.tone(0xFF2DD4BF).withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              Icon(
                _isPinned ? Icons.push_pin : Icons.autorenew,
                color: _isPinned ? BeyanColors.tone(0xFFFFDF7A) : BeyanColors.tone(0xFF2DD4BF),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isPinned
                      ? '$pinnedNotice ${_appliedVerseRef ?? ""}'
                      : (_appliedVerseRef != null && _appliedVerseRef!.isNotEmpty
                          ? '${_getAppliedPrefix(strings.language)} : $_appliedVerseRef • $rotatingNotice'
                          : rotatingNotice),
                  style: TextStyle(
                    color: (_isPinned || (_appliedVerseRef != null && _appliedVerseRef!.isNotEmpty))
                        ? BeyanColors.tone(0xFFFFDF7A)
                        : Colors.white70,
                    fontSize: 12,
                    fontWeight: (_isPinned || (_appliedVerseRef != null && _appliedVerseRef!.isNotEmpty))
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
              if (_isPinned)
                TextButton(
                  onPressed: _restoreAutomaticVerseRotation,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    strings.rotateAction,
                    style: TextStyle(
                      color: BeyanColors.tone(0xFFFFDF7A),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Ana Uygula Butonu
        ElevatedButton.icon(
          onPressed: _syncAndApplyWidgetSettings,
          icon: Icon(Icons.sync_rounded, color: BeyanColors.tone(0xFF071F1B), size: 20),
          label: Text(
            btnText,
            style: TextStyle(
              color: BeyanColors.tone(0xFF071F1B),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: BeyanColors.tone(0xFFFFDF7A),
            foregroundColor: BeyanColors.tone(0xFF071F1B),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
          ),
        ),

        // Özel Olarak Sabitlemek İsteyenler İçin Buton
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _pinCurrentVerse,
          icon: Icon(Icons.push_pin_outlined, color: BeyanColors.tone(0xFFFFDF7A), size: 18),
          label: Text(
            pinBtnText,
            style: TextStyle(
              color: BeyanColors.tone(0xFFFFDF7A),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.35)),
            padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white38,
            size: 13,
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.8,
      color: Colors.white.withValues(alpha: 0.08),
      indent: 16,
      endIndent: 16,
    );
  }

  // ── Özellikler Listesi (Screenshots 3-4) ──────────────────────────────────
  Widget _buildFeaturesCard(AppStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.features,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: BeyanColors.tone(0xFF0A241F),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            children: [
              _buildFeatureItem(strings.featCountdown),
              const SizedBox(height: 12),
              _buildFeatureItem(strings.featCurrentPrayers),
              const SizedBox(height: 12),
              _buildFeatureItem(strings.featAutoUpdate),
              const SizedBox(height: 12),
              _buildFeatureItem(strings.featBatterySave),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: BeyanColors.tone(0xFF10B981),
          ),
          child: Icon(
            Icons.check_rounded,
            size: 14,
            color: BeyanColors.tone(0xFF032620),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ── Nasıl Eklenir Adımları (Screenshots 4-5) ──────────────────────────────
  Widget _buildHowToAddGuide(AppStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.howToAdd,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: BeyanColors.tone(0xFF0A241F),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            children: [
              _buildStepItem(
                number: '1',
                text: strings.howToAddStep1,
              ),
              const SizedBox(height: 14),
              _buildStepItem(
                number: '2',
                text: strings.howToAddStep2,
              ),
              const SizedBox(height: 14),
              _buildStepItem(
                number: '3',
                text: strings.howToAddStep3,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepItem({required String number, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: BeyanColors.tone(0xFF10B981),
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: BeyanColors.tone(0xFF032620),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

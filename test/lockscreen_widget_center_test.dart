import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/core/utils/app_constants.dart';
import 'package:islamic_app/features/widget_service/screens/widget_center_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Kilit Ekranı Widget Merkezi & Metin Boyutu Testleri', () {
    test('Widget category options ve sabit metin ölçekleri doğru tanımlanmalı', () {
      // 6 Temel kategori
      expect(WidgetCategoryType.values.length, 6);
      expect(WidgetCategoryType.quotes.name, 'quotes');
      expect(WidgetCategoryType.dailyVerse.name, 'dailyVerse');
      expect(WidgetCategoryType.prayerTimes.name, 'prayerTimes');
      expect(WidgetCategoryType.countdown.name, 'countdown');
      expect(WidgetCategoryType.hijri.name, 'hijri');
      expect(WidgetCategoryType.sunTimes.name, 'sunTimes');
    });

    test('iOS Widget Bundle adları AppConstants üzerinde eksiksiz ve doğru olmalı', () {
      expect(AppConstants.appGroupId, 'group.com.smhisk60.beyan');
      expect(AppConstants.iOSVerseWidgetName, 'BeyanVerseWidget');
      expect(AppConstants.iOSPrayerWidgetName, 'BeyanPrayerWidget');
      expect(AppConstants.iOSCountdownWidgetName, 'BeyanCountdownWidget');
      expect(AppConstants.iOSHijriWidgetName, 'BeyanHijriWidget');
      expect(AppConstants.iOSSunWidgetName, 'BeyanSunWidget');
      expect(AppConstants.iOSKazaWidgetName, 'BeyanKazaWidget');
    });

    test('SharedPreferences widget ayarları doğru saklanıp okunmalı', () async {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('widget_text_size', 'large');
      await prefs.setString('widget_verse_view', 'arabic_meal');
      await prefs.setString('widget_refresh_interval', '30m');
      await prefs.setBool('widget_is_pinned', true);
      await prefs.setString('widget_applied_verse_ref', 'Duhâ 93:3');
      await prefs.setString('widget_applied_verse_text', 'Rabbin seni terk etmedi');

      expect(prefs.getString('widget_text_size'), 'large');
      expect(prefs.getString('widget_verse_view'), 'arabic_meal');
      expect(prefs.getString('widget_refresh_interval'), '30m');
      expect(prefs.getBool('widget_is_pinned'), isTrue);
      expect(prefs.getString('widget_applied_verse_ref'), 'Duhâ 93:3');
    });

    test('WidgetPreviewQuote model çok dilli ve görünüm modlarını doğru uygulamalı', () {
      const quote = WidgetPreviewQuote(
        referenceTr: 'İnşirâh 94:5-6',
        referenceEn: 'Ash-Sharh 94:5-6',
        referenceAr: 'الشرح ٩٤:٥-٦',
        arabic: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا',
        meaningTr: 'Elbette zorluğun yanında bir kolaylık vardır.',
        meaningEn: 'For indeed, with hardship will be ease.',
        meaningAr: 'فإن مع العسر يسرا',
      );

      expect(quote.localizedReference('tr'), 'İnşirâh 94:5-6');
      expect(quote.localizedReference('en'), 'Ash-Sharh 94:5-6');
      expect(quote.localizedReference('ar'), 'الشرح ٩٤:٥-٦');

      // meal_only
      expect(quote.formatForViewMode('meal_only', 'tr'), 'Elbette zorluğun yanında bir kolaylık vardır.');
      // arabic_only
      expect(quote.formatForViewMode('arabic_only', 'tr'), 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا');
      // arabic_meal
      expect(quote.formatForViewMode('arabic_meal', 'tr'), 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا\nElbette zorluğun yanında bir kolaylık vardır.');
    });
  });
}

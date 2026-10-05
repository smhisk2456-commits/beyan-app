import AppIntents
import WidgetKit

/// iOS 17+ için AppIntent desteği – kullanıcı aksiyonlarına izin verir.
/// Şimdilik sadece widget'ı yenile eylemi tanımlanmıştır.
@available(iOS 17.0, *)
struct RefreshWidgetIntent: AppIntent {
    static var title: LocalizedStringResource = "Widget'ı Yenile"
    static var description = IntentDescription("Namaz vakitlerini ve ayeti günceller.")

    func perform() async throws -> some IntentResult {
        // Widget timeline'ını geçersiz kıl → yeniden hesaplansın
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

import Foundation

/// Tiny rule-based intent classifier. Lookup is O(n) over a phrase list — perfectly
/// fine for our ~20 intents. We match on substrings normalised by lowercasing and
/// stripping punctuation. Works for ru / kk / en simultaneously because each intent
/// has triggers in all three languages.
final class CommandRouter {

    static let shared = CommandRouter()

    /// Map intent → set of triggering phrases.
    private let triggers: [(VoiceIntent, [String])] = [
        (.openCompanion, ["эдит", "помощник", "ассистент", "edit", "companion", "көмекші"]),
        (.openVision, ["сканируй", "сканировать", "опиши", "что вокруг", "scan", "describe", "сипатта"]),
        (.openOCR, ["прочитай", "распознай", "текст", "read", "ocr", "оқы"]),
        (.openMagnifier, ["лупа", "увеличь", "magnify", "zoom", "лупаны"]),
        (.openNavigation, ["маршрут", "куда", "навигация", "карты", "route", "navigate", "бағыт"]),
        (.openLocator, ["локатор", "комната", "locate", "locator"]),
        (.openWalking, ["ходьба", "иду", "walking", "жүру"]),
        (.openSOS, ["sos", "экстренно", "помогите", "помощь", "danger", "emergency", "көмек"]),
        (.openHealth, ["здоровье", "лекарства", "пульс", "health", "денсаулық"]),
        (.openLearning, ["учёба", "учеба", "урок", "learn", "lesson", "оқу"]),
        (.openWhatsApp, ["ватсап", "whatsapp", "ватсапп"]),
        (.openTelegram, ["телеграм", "telegram", "телеграмм"]),
        (.openMusic, ["музыка", "трек", "music", "song", "ән"]),
        (.openDiary, ["дневник", "запиши", "diary", "journal", "күнделік"]),
        (.openSmartHome, ["умный дом", "свет", "smart home", "lights", "ақылды үй"]),
        (.openEyeComfort, ["глаза", "контраст", "eye comfort", "көру"]),
        (.openScene, ["сцена", "опиши сцену", "scene"]),
        (.openAccessibility, ["настройки", "доступность", "settings", "accessibility", "қолжетімділік"]),
        (.openCards, ["карточки", "фразы", "cards", "карточкалар"]),
        (.openListen, ["слух", "слушай", "listen", "ести"]),
        (.openCurrency, ["купюра", "купюры", "деньги", "money", "тенге", "ақша"]),
        (.stopAll, ["стоп", "остановись", "тише", "stop", "тоқта"])
    ]

    func route(_ raw: String) -> VoiceIntent? {
        let normalised = raw.lowercased()
            .components(separatedBy: CharacterSet.punctuationCharacters)
            .joined()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalised.isEmpty else { return nil }

        for (intent, phrases) in triggers {
            for phrase in phrases {
                if normalised.contains(phrase) {
                    return intent
                }
            }
        }
        return nil
    }
}

import Foundation

enum RiskLevel {
    case safe
    case caution

    var label: String {
        switch self {
        case .safe: return "Güvenli"
        case .caution: return "Dikkatli ol"
        }
    }

    var tint: String {
        switch self {
        case .safe: return "green"
        case .caution: return "orange"
        }
    }
}

/// Bir tarama kategorisinin nerede ve nasıl aranacağını tanımlar.
struct JunkCategoryDefinition: Identifiable {
    let id = UUID()
    let name: String
    let explanation: String
    let risk: RiskLevel
    let locations: [URL]
    /// Sadece bu uzantılara sahip dosyaları dikkate al (klasörleri değil). nil ise tüm alt öğeler dikkate alınır.
    let extensionFilter: Set<String>?
    /// Bu süreden (gün) daha az süredir dokunulmamışsa gösterme. nil ise yaş filtresi yok.
    let minAgeDays: Int?
}

struct JunkItem: Identifiable, Hashable {
    let id: String
    let url: URL
    let name: String
    var size: Int64
    let lastAccessed: Date?
    let lastModified: Date?
    let categoryName: String

    static func == (lhs: JunkItem, rhs: JunkItem) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    var referenceDate: Date? { lastAccessed ?? lastModified }

    var ageDescription: String {
        guard let date = referenceDate else { return "Bilinmiyor" }
        let days = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
        if days <= 0 { return "Bugün" }
        if days == 1 { return "1 gün önce" }
        if days < 30 { return "\(days) gün önce" }
        let months = days / 30
        if months < 12 { return "\(months) ay önce" }
        let years = months / 12
        return "\(years) yıl önce"
    }
}

enum ByteFormat {
    static let formatter: ByteCountFormatter = {
        let f = ByteCountFormatter()
        f.countStyle = .file
        return f
    }()

    static func string(_ bytes: Int64) -> String {
        formatter.string(fromByteCount: bytes)
    }
}

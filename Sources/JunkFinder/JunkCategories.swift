import Foundation

/// Bilinen, kullanıcının normalde elle açıp kontrol etmediği ama disk doldurma eğiliminde olan
/// macOS konumlarının tanımları. Her biri "neden gereksiz" açıklamasıyla birlikte gelir.
enum JunkCategories {
    static let home = FileManager.default.homeDirectoryForCurrentUser

    static func lib(_ path: String) -> URL {
        home.appendingPathComponent("Library/" + path)
    }

    static let all: [JunkCategoryDefinition] = [
        JunkCategoryDefinition(
            name: "Uygulama Önbellekleri",
            explanation: "Uygulamaların kendi başına ürettiği geçici dosyalar. Kullanıcı bunları hiç açmaz; silinince uygulamalar gerektiğinde yeniden oluşturur.",
            risk: .safe,
            locations: [lib("Caches")],
            extensionFilter: nil,
            minAgeDays: nil
        ),
        JunkCategoryDefinition(
            name: "Uygulama Günlükleri",
            explanation: "Uygulamaların arka planda yazdığı log dosyaları (çökme raporları dahil). Sorun giderme dışında kimse bunları okumaz.",
            risk: .safe,
            locations: [lib("Logs")],
            extensionFilter: nil,
            minAgeDays: nil
        ),
        JunkCategoryDefinition(
            name: "Kaydedilmiş Pencere Durumları",
            explanation: "macOS'un uygulamaları yeniden açarken pencere konumunu hatırlamak için tuttuğu dosyalar. Görünür bir şekilde hiç kullanılmaz.",
            risk: .safe,
            locations: [lib("Saved Application State")],
            extensionFilter: nil,
            minAgeDays: nil
        ),
        JunkCategoryDefinition(
            name: "Xcode Derived Data",
            explanation: "Xcode'un derleme sırasında ürettiği ara dosyalar. Proje her açıldığında yeniden oluşturulur; genelde gigabaytlarca yer kaplar.",
            risk: .safe,
            locations: [lib("Developer/Xcode/DerivedData")],
            extensionFilter: nil,
            minAgeDays: nil
        ),
        JunkCategoryDefinition(
            name: "Xcode Arşivleri",
            explanation: "Eskiden App Store'a yüklenmiş uygulama arşivleri. Yüklemeden sonra genelde bir daha açılmaz.",
            risk: .caution,
            locations: [lib("Developer/Xcode/Archives")],
            extensionFilter: nil,
            minAgeDays: nil
        ),
        JunkCategoryDefinition(
            name: "Eski Cihaz Sembol Dosyaları",
            explanation: "Artık kullanılmayan eski iOS/watchOS sürümleri için indirilen hata ayıklama sembolleri. Yeni cihaz bağlandığında otomatik yeniden iner.",
            risk: .safe,
            locations: [
                lib("Developer/Xcode/iOS DeviceSupport"),
                lib("Developer/Xcode/watchOS DeviceSupport"),
                lib("Developer/Xcode/tvOS DeviceSupport")
            ],
            extensionFilter: nil,
            minAgeDays: nil
        ),
        JunkCategoryDefinition(
            name: "Simülatör Önbellekleri",
            explanation: "iOS Simulator'ün biriktirdiği önbellek verileri. Simulator her çalıştığında yeniden üretilir.",
            risk: .safe,
            locations: [lib("Developer/CoreSimulator/Caches")],
            extensionFilter: nil,
            minAgeDays: nil
        ),
        JunkCategoryDefinition(
            name: "İndirilenler'deki Unutulmuş Kurulum Dosyaları",
            explanation: "Downloads klasöründe duran .dmg/.pkg/.zip/.iso dosyaları; genelde bir kez kurulup bir daha hiç açılmaz. Sadece 90 günden uzun süredir dokunulmamış olanlar gösterilir.",
            risk: .caution,
            locations: [home.appendingPathComponent("Downloads")],
            extensionFilter: ["dmg", "pkg", "iso", "zip"],
            minAgeDays: 90
        )
    ]
}

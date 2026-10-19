import Foundation

/// Dosyaları kalıcı olarak silmez; macOS Çöp Kutusu'na taşır.
/// Kullanıcı istediğinde Çöp Kutusu'ndan geri alabilir.
enum TrashService {
    /// Döner: başarısız olan öğelerin id -> hata açıklaması eşlemesi.
    static func moveToTrash(_ items: [JunkItem]) async -> [String: String] {
        await Task.detached(priority: .userInitiated) {
            var failures: [String: String] = [:]
            for item in items {
                do {
                    try FileManager.default.trashItem(at: item.url, resultingItemURL: nil)
                } catch {
                    failures[item.id] = "\(item.name): \(error.localizedDescription)"
                }
            }
            return failures
        }.value
    }
}

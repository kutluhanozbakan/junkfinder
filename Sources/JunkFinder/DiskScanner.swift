import Foundation

/// Dosya sistemini okuyan, boyut hesaplayan arka plan tarayıcısı.
/// Hiçbir şey silmez; sadece raporlar.
actor DiskScanner {
    func scanAll(progress: @Sendable @escaping (String) -> Void) async -> [String: [JunkItem]] {
        var result: [String: [JunkItem]] = [:]
        for def in JunkCategories.all {
            progress(def.name)
            result[def.name] = scan(def)
        }
        return result
    }

    private func scan(_ def: JunkCategoryDefinition) -> [JunkItem] {
        let fm = FileManager.default
        var items: [JunkItem] = []

        for location in def.locations {
            var isDir: ObjCBool = false
            guard fm.fileExists(atPath: location.path, isDirectory: &isDir), isDir.boolValue else { continue }

            let children = try? fm.contentsOfDirectory(
                at: location,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            )

            for child in children ?? [] {
                if let filter = def.extensionFilter {
                    let isChildDir = (try? child.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false
                    guard !isChildDir, filter.contains(child.pathExtension.lowercased()) else { continue }
                }

                let dates = Self.dates(of: child)

                if let minAge = def.minAgeDays {
                    let reference = dates.accessed ?? dates.modified ?? Date()
                    let age = Calendar.current.dateComponents([.day], from: reference, to: Date()).day ?? 0
                    guard age >= minAge else { continue }
                }

                let size = Self.size(of: child)
                items.append(
                    JunkItem(
                        id: child.path,
                        url: child,
                        name: child.lastPathComponent,
                        size: size,
                        lastAccessed: dates.accessed,
                        lastModified: dates.modified,
                        categoryName: def.name
                    )
                )
            }
        }

        return items.sorted { $0.size > $1.size }
    }

    private static func size(of url: URL) -> Int64 {
        let fm = FileManager.default
        var isDir: ObjCBool = false
        guard fm.fileExists(atPath: url.path, isDirectory: &isDir) else { return 0 }

        if !isDir.boolValue {
            let attrs = try? fm.attributesOfItem(atPath: url.path)
            return (attrs?[.size] as? Int64) ?? 0
        }

        var total: Int64 = 0
        guard let enumerator = fm.enumerator(
            at: url,
            includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey],
            options: [],
            errorHandler: { _, _ in true }
        ) else { return 0 }

        for case let fileURL as URL in enumerator {
            let values = try? fileURL.resourceValues(forKeys: [.fileSizeKey, .isDirectoryKey])
            if values?.isDirectory != true {
                total += Int64(values?.fileSize ?? 0)
            }
        }
        return total
    }

    private static func dates(of url: URL) -> (accessed: Date?, modified: Date?) {
        let values = try? url.resourceValues(forKeys: [.contentAccessDateKey, .contentModificationDateKey])
        return (values?.contentAccessDate, values?.contentModificationDate)
    }
}

import Foundation

@MainActor
final class ScannerViewModel: ObservableObject {
    @Published private(set) var itemsByCategory: [String: [JunkItem]] = [:]
    @Published private(set) var isScanning = false
    @Published private(set) var hasScannedOnce = false
    @Published var currentCategory: String = ""
    @Published var selectedIDs: Set<String> = []
    @Published var errorMessage: String?
    @Published var isMoving = false

    private let scanner = DiskScanner()

    var orderedCategoryNames: [String] {
        JunkCategories.all.map(\.name).filter { !(itemsByCategory[$0]?.isEmpty ?? true) }
    }

    func totalSize(for category: String) -> Int64 {
        (itemsByCategory[category] ?? []).reduce(0) { $0 + $1.size }
    }

    var grandTotalSize: Int64 {
        itemsByCategory.values.flatMap { $0 }.reduce(0) { $0 + $1.size }
    }

    var allItems: [JunkItem] { itemsByCategory.values.flatMap { $0 } }

    var totalSelectedSize: Int64 {
        allItems.filter { selectedIDs.contains($0.id) }.reduce(0) { $0 + $1.size }
    }

    var selectedCount: Int { selectedIDs.count }

    func scan() {
        guard !isScanning else { return }
        isScanning = true
        selectedIDs = []
        Task {
            let result = await scanner.scanAll { [weak self] name in
                Task { @MainActor in self?.currentCategory = name }
            }
            self.itemsByCategory = result
            self.isScanning = false
            self.hasScannedOnce = true
        }
    }

    func toggle(_ item: JunkItem) {
        if selectedIDs.contains(item.id) {
            selectedIDs.remove(item.id)
        } else {
            selectedIDs.insert(item.id)
        }
    }

    func selectAll(in category: String) {
        for item in itemsByCategory[category] ?? [] {
            selectedIDs.insert(item.id)
        }
    }

    func deselectAll(in category: String) {
        for item in itemsByCategory[category] ?? [] {
            selectedIDs.remove(item.id)
        }
    }

    func moveSelectedToTrash() {
        let targets = allItems.filter { selectedIDs.contains($0.id) }
        guard !targets.isEmpty else { return }
        isMoving = true
        Task {
            let failures = await TrashService.moveToTrash(targets)
            for key in itemsByCategory.keys {
                itemsByCategory[key]?.removeAll { item in
                    targets.contains(item) && !failures.keys.contains(item.id)
                }
            }
            selectedIDs.removeAll()
            if !failures.isEmpty {
                let names = failures.values.joined(separator: "\n")
                errorMessage = "Bazı öğeler taşınamadı:\n\(names)"
            }
            isMoving = false
        }
    }
}

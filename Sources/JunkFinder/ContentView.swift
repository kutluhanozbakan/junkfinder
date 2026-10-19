import AppKit
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var vm: ScannerViewModel
    @State private var selectedCategory: String?
    @State private var showTrashConfirm = false

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            detail
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    vm.scan()
                } label: {
                    if vm.isScanning {
                        HStack(spacing: 6) {
                            ProgressView().controlSize(.small)
                            Text(vm.currentCategory.isEmpty ? "Taranıyor…" : "Taranıyor: \(vm.currentCategory)")
                        }
                    } else {
                        Label(vm.hasScannedOnce ? "Yeniden Tara" : "Taramayı Başlat", systemImage: "arrow.clockwise")
                    }
                }
                .disabled(vm.isScanning)
            }
        }
        .alert("Hata", isPresented: Binding(get: { vm.errorMessage != nil }, set: { _ in vm.errorMessage = nil })) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(vm.errorMessage ?? "")
        }
        .alert("Çöp Kutusu'na Taşınsın mı?", isPresented: $showTrashConfirm) {
            Button("İptal", role: .cancel) {}
            Button("Taşı", role: .destructive) { vm.moveSelectedToTrash() }
        } message: {
            Text("\(vm.selectedCount) öğe (\(ByteFormat.string(vm.totalSelectedSize))) Çöp Kutusu'na taşınacak. Kalıcı silinmez, Çöp Kutusu'ndan geri alabilirsin.")
        }
        .onAppear {
            if !vm.hasScannedOnce { vm.scan() }
        }
    }

    private var sidebar: some View {
        List(selection: $selectedCategory) {
            if vm.hasScannedOnce && vm.orderedCategoryNames.isEmpty {
                Text("Gereksiz dosya bulunamadı 🎉")
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            }
            ForEach(vm.orderedCategoryNames, id: \.self) { name in
                NavigationLink(value: name) {
                    HStack {
                        Text(name)
                        Spacer()
                        Text(ByteFormat.string(vm.totalSize(for: name)))
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                }
            }
        }
        .navigationTitle("JunkFinder")
        .safeAreaInset(edge: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Divider()
                HStack {
                    Text("Toplam")
                    Spacer()
                    Text(ByteFormat.string(vm.grandTotalSize)).bold()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .background(.bar)
        }
    }

    @ViewBuilder
    private var detail: some View {
        if let category = selectedCategory, let def = JunkCategories.all.first(where: { $0.name == category }) {
            CategoryDetailView(definition: def, showTrashConfirm: $showTrashConfirm)
        } else {
            VStack(spacing: 12) {
                Image(systemName: "trash.circle")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                Text("Soldan bir kategori seç")
                    .foregroundStyle(.secondary)
                if !vm.hasScannedOnce && !vm.isScanning {
                    Text("Başlamak için yukarıdaki 'Taramayı Başlat' düğmesine tıkla.")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct CategoryDetailView: View {
    let definition: JunkCategoryDefinition
    @Binding var showTrashConfirm: Bool
    @EnvironmentObject private var vm: ScannerViewModel

    private var items: [JunkItem] { vm.itemsByCategory[definition.name] ?? [] }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            List {
                ForEach(items) { item in
                    ItemRow(item: item, isSelected: vm.selectedIDs.contains(item.id)) {
                        vm.toggle(item)
                    }
                }
            }
            .listStyle(.inset)
        }
        .navigationTitle(definition.name)
        .safeAreaInset(edge: .bottom) {
            if !vm.selectedIDs.isEmpty {
                HStack {
                    Text("\(vm.selectedCount) öğe seçildi · \(ByteFormat.string(vm.totalSelectedSize))")
                        .font(.callout)
                    Spacer()
                    Button(role: .destructive) {
                        showTrashConfirm = true
                    } label: {
                        if vm.isMoving {
                            ProgressView().controlSize(.small)
                        } else {
                            Label("Çöp Kutusu'na Taşı", systemImage: "trash")
                        }
                    }
                    .disabled(vm.isMoving)
                }
                .padding()
                .background(.bar)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(definition.risk.label)
                    .font(.caption).bold()
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(definition.risk == .safe ? Color.green.opacity(0.18) : Color.orange.opacity(0.18))
                    .foregroundStyle(definition.risk == .safe ? .green : .orange)
                    .clipShape(Capsule())
                Spacer()
                Button("Tümünü Seç") { vm.selectAll(in: definition.name) }
                    .font(.caption)
                Button("Seçimi Kaldır") { vm.deselectAll(in: definition.name) }
                    .font(.caption)
            }
            Text(definition.explanation)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

struct ItemRow: View {
    let item: JunkItem
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack {
            Toggle("", isOn: Binding(get: { isSelected }, set: { _ in onToggle() }))
                .labelsHidden()
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name).font(.body)
                Text(item.url.path)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(ByteFormat.string(item.size)).font(.callout).monospacedDigit()
                Text("Son erişim: \(item.ageDescription)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Button {
                NSWorkspace.shared.activateFileViewerSelecting([item.url])
            } label: {
                Image(systemName: "folder")
            }
            .buttonStyle(.plain)
            .help("Finder'da göster")
        }
        .contentShape(Rectangle())
        .onTapGesture { onToggle() }
        .padding(.vertical, 2)
    }
}

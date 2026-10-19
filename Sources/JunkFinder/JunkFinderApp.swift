import SwiftUI

@main
struct JunkFinderApp: App {
    @StateObject private var viewModel = ScannerViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .frame(minWidth: 820, minHeight: 560)
        }
        .windowResizability(.contentSize)
    }
}

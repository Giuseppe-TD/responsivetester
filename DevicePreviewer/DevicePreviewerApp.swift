import SwiftUI

@main
struct DevicePreviewerApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup("Device Previewer") {
            ContentView()
                .environmentObject(appState)
                .frame(minWidth: 1000, idealWidth: 1400, minHeight: 700)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: false))
        .defaultSize(width: 1400, height: 900)
    }
}

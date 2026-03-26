import SwiftUI

@main
struct ScreenlabApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup("Screenlab") {
            ContentView()
                .environmentObject(appState)
                .frame(minWidth: 1000, idealWidth: 1440, minHeight: 700)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: false))
        .defaultSize(width: 1440, height: 900)
    }
}

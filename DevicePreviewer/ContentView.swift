import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var urlInput: String = ""
    @State private var showAddDevice = false
    @State private var showLiveReloadOptions = false

    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            DeviceListSidebarView(showAddDevice: $showAddDevice)
                .navigationSplitViewColumnWidth(min: 180, ideal: 215, max: 260)
        } detail: {
            VStack(spacing: 0) {

                // ── Toolbar ─────────────────────────────────────────────
                HStack(spacing: 8) {

                    // Indietro / Avanti
                    Button { appState.goBack() } label: {
                        Image(systemName: "chevron.left")
                    }
                    .buttonStyle(.plain)
                    .help("Indietro")

                    Button { appState.goForward() } label: {
                        Image(systemName: "chevron.right")
                    }
                    .buttonStyle(.plain)
                    .help("Avanti")

                    // URL bar
                    HStack(spacing: 4) {
                        Image(systemName: "globe")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        TextField("https://", text: $urlInput)
                            .textFieldStyle(.plain)
                            .onSubmit { commitURL() }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(Color.secondary.opacity(0.3), lineWidth: 0.5))

                    Button(action: commitURL) {
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(.plain)
                    .help("Carica URL")

                    Button { appState.reloadAll() } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut("r", modifiers: .command)
                    .help("Ricarica tutto (⌘R)")

                    // ── Separatore ──
                    Divider().frame(height: 20)

                    // Live Reload
                    Toggle(isOn: $appState.liveReloadEnabled) {
                        Label("Live", systemImage: "bolt.fill")
                            .font(.caption)
                    }
                    .toggleStyle(.button)
                    .onChange(of: appState.liveReloadEnabled) { _ in
                        appState.updateLiveReload()
                    }
                    .help("Ricarica automatica ogni \(Int(appState.liveReloadInterval))s")

                    // Intervallo live reload
                    if appState.liveReloadEnabled {
                        Picker("", selection: $appState.liveReloadInterval) {
                            Text("1s").tag(1.0)
                            Text("2s").tag(2.0)
                            Text("3s").tag(3.0)
                            Text("5s").tag(5.0)
                        }
                        .pickerStyle(.menu)
                        .frame(width: 50)
                        .font(.caption)
                        .onChange(of: appState.liveReloadInterval) { _ in
                            appState.updateLiveReload()
                        }
                    }

                    // Sync Scroll
                    Toggle(isOn: $appState.syncScrollEnabled) {
                        Label("Sync", systemImage: "arrow.up.and.down")
                            .font(.caption)
                    }
                    .toggleStyle(.button)
                    .help("Sincronizza scroll tra dispositivi")

                    // ── Separatore ──
                    Divider().frame(height: 20)

                    // View Mode
                    Picker("", selection: $appState.viewMode) {
                        Image(systemName: "rectangle.grid.3x2").tag(ViewMode.multi)
                        Image(systemName: "rectangle.portrait").tag(ViewMode.single)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 72)
                    .help("Multi / Single")

                    // Scale slider (solo multi mode)
                    if appState.viewMode == .multi {
                        HStack(spacing: 4) {
                            Image(systemName: "minus").font(.caption2).foregroundColor(.secondary)
                            Slider(value: $appState.scale, in: 0.2...0.8, step: 0.02)
                                .frame(width: 90)
                            Image(systemName: "plus").font(.caption2).foregroundColor(.secondary)
                        }
                        Text("\(Int(appState.scale * 100))%")
                            .font(.caption).monospacedDigit()
                            .frame(width: 34)
                            .foregroundColor(.secondary)
                    }

                    // ── Separatore ──
                    Divider().frame(height: 20)

                    // Screenshot tutti
                    Button { appState.exportScreenshots() } label: {
                        Image(systemName: "camera")
                    }
                    .buttonStyle(.plain)
                    .help("Esporta screenshot di tutti i dispositivi attivi")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Color(nsColor: .windowBackgroundColor))

                Divider()

                // ── Contenuto ────────────────────────────────────────────
                Group {
                    if appState.viewMode == .multi {
                        MultiDeviceView()
                    } else {
                        SingleDeviceView()
                    }
                }
            }
        }
        .onAppear { urlInput = appState.urlString }
        .sheet(isPresented: $showAddDevice) {
            AddCustomDeviceView()
        }
    }

    private func commitURL() {
        appState.urlString = urlInput
        appState.loadURL()
    }
}

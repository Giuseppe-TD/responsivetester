import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var urlInput: String = ""
    @State private var showAddDevice = false
    @State private var sidebarVisibility: NavigationSplitViewVisibility = .all
    @FocusState private var urlFocused: Bool

    var body: some View {
        NavigationSplitView(columnVisibility: $sidebarVisibility) {

            // ── Sidebar ──────────────────────────────────────────────
            DeviceListSidebarView(showAddDevice: $showAddDevice)
                .navigationSplitViewColumnWidth(min: 185, ideal: 215, max: 265)

        } detail: {
            VStack(spacing: 0) {

                // ── Toolbar ──────────────────────────────────────────
                toolbar

                Divider()
                    .opacity(0.5)

                // ── Contenuto ─────────────────────────────────────────
                if appState.viewMode == .multi {
                    MultiDeviceView()
                } else {
                    SingleDeviceView()
                }
            }
        }
        .onAppear { urlInput = appState.urlString }
        .sheet(isPresented: $showAddDevice) {
            AddCustomDeviceView()
        }
    }

    // MARK: - Toolbar

    private var toolbar: some View {
        HStack(spacing: 0) {

            // Nav buttons
            Group {
                ToolbarButton(icon: "chevron.left",  help: "Indietro")  { appState.goBack() }
                ToolbarButton(icon: "chevron.right", help: "Avanti")    { appState.goForward() }
            }
            .padding(.leading, 10)

            toolbarDivider

            // URL bar
            urlBar
                .padding(.horizontal, 8)
                .frame(maxWidth: 680)

            // Reload
            ToolbarButton(icon: "arrow.clockwise", help: "Ricarica tutto (⌘R)") {
                appState.reloadAll()
            }
            .keyboardShortcut("r", modifiers: .command)

            toolbarDivider

            // DevTools
            ToolbarToggleButton(
                icon: "curlybraces",
                label: "DevTools",
                help: "Apri Web Inspector · o right-click → Inspect Element"
            ) {
                appState.showInspectorForActive()
            }

            toolbarDivider

            // Live reload
            Toggle(isOn: $appState.liveReloadEnabled) {
                Label("Live", systemImage: "bolt.fill").font(.caption)
            }
            .toggleStyle(.button)
            .onChange(of: appState.liveReloadEnabled) { _ in appState.updateLiveReload() }
            .help("Ricarica automatica")
            .padding(.horizontal, 4)

            if appState.liveReloadEnabled {
                Picker("", selection: $appState.liveReloadInterval) {
                    Text("1s").tag(1.0)
                    Text("2s").tag(2.0)
                    Text("3s").tag(3.0)
                    Text("5s").tag(5.0)
                }
                .pickerStyle(.menu)
                .frame(width: 52)
                .font(.caption)
                .onChange(of: appState.liveReloadInterval) { _ in appState.updateLiveReload() }
            }

            // Sync Scroll
            Toggle(isOn: $appState.syncScrollEnabled) {
                Label("Sync", systemImage: "arrow.up.and.down").font(.caption)
            }
            .toggleStyle(.button)
            .help("Sincronizza scroll tra dispositivi")
            .padding(.horizontal, 4)

            toolbarDivider

            // View mode
            Picker("", selection: $appState.viewMode) {
                Image(systemName: "rectangle.grid.3x2").tag(ViewMode.multi)
                Image(systemName: "rectangle.portrait").tag(ViewMode.single)
            }
            .pickerStyle(.segmented)
            .frame(width: 72)
            .padding(.horizontal, 6)
            .help("Multi / Single")

            // Zoom + Spacing (solo multi)
            if appState.viewMode == .multi {
                toolbarDivider

                // Zoom
                HStack(spacing: 4) {
                    Image(systemName: "minus.magnifyingglass")
                        .font(.caption2).foregroundColor(.secondary)
                    Slider(value: $appState.scale, in: 0.15...1.0, step: 0.01)
                        .frame(width: 80)
                    Image(systemName: "plus.magnifyingglass")
                        .font(.caption2).foregroundColor(.secondary)
                    Text("\(Int(appState.scale * 100))%")
                        .font(.caption2).monospacedDigit()
                        .foregroundColor(.secondary)
                        .frame(width: 30)
                }
                .padding(.horizontal, 4)

                toolbarDivider

                // Spacing
                HStack(spacing: 4) {
                    Image(systemName: "arrow.left.and.right")
                        .font(.caption2).foregroundColor(.secondary)
                    Slider(value: $appState.deviceSpacing, in: 8...80, step: 4)
                        .frame(width: 60)
                    Text("\(Int(appState.deviceSpacing))px")
                        .font(.caption2).monospacedDigit()
                        .foregroundColor(.secondary)
                        .frame(width: 30)
                }
                .padding(.horizontal, 4)
            }

            toolbarDivider

            // Screenshot
            ToolbarButton(
                icon: "square.and.arrow.down",
                help: "Esporta screenshot di tutti i dispositivi attivi"
            ) {
                appState.exportScreenshots()
            }
            .padding(.trailing, 10)
        }
        .padding(.vertical, 6)
        .frame(height: 42)
        .background(.bar)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    withAnimation {
                        sidebarVisibility = sidebarVisibility == .all ? .detailOnly : .all
                    }
                } label: {
                    Image(systemName: "sidebar.left")
                }
                .help("Mostra/nascondi sidebar (⌘⇧L)")
                .keyboardShortcut("l", modifiers: [.command, .shift])
            }
        }
    }

    // MARK: - URL Bar

    private var urlBar: some View {
        HStack(spacing: 6) {
            Image(systemName: "globe")
                .font(.system(size: 11))
                .foregroundColor(.secondary)

            TextField("https://", text: $urlInput)
                .textFieldStyle(.plain)
                .font(.system(size: 12))
                .focused($urlFocused)
                .onSubmit { commitURL() }

            if !urlInput.isEmpty {
                Button {
                    urlInput = ""
                    urlFocused = true
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }

            Button(action: commitURL) {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
            .help("Carica URL (Invio)")
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(nsColor: .textBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(
                            urlFocused
                                ? Color.accentColor.opacity(0.6)
                                : Color.secondary.opacity(0.2),
                            lineWidth: urlFocused ? 1.5 : 0.5
                        )
                )
        )
    }

    private var toolbarDivider: some View {
        Divider()
            .frame(height: 20)
            .padding(.horizontal, 4)
            .opacity(0.5)
    }

    private func commitURL() {
        appState.urlString = urlInput
        appState.loadURL()
    }
}

// MARK: - Toolbar helpers

struct ToolbarButton: View {
    let icon: String
    let help: String
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .frame(width: 28, height: 28)
                .background(isHovered ? Color.secondary.opacity(0.15) : Color.clear,
                            in: RoundedRectangle(cornerRadius: 6))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(help)
        .onHover { isHovered = $0 }
    }
}

struct ToolbarToggleButton: View {
    let icon: String
    let label: String
    let help: String
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 11, weight: .medium))
                Text(label).font(.caption)
            }
            .padding(.horizontal, 8)
            .frame(height: 26)
            .background(isHovered ? Color.secondary.opacity(0.15) : Color.clear,
                        in: RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
        .help(help)
        .onHover { isHovered = $0 }
    }
}

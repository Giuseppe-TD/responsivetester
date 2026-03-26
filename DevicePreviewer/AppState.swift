import Foundation
import WebKit
import Combine

enum ViewMode: String, CaseIterable, Identifiable {
    case multi  = "Multi"
    case single = "Single"
    var id: String { rawValue }
}

class AppState: ObservableObject {

    // URL
    @Published var urlString: String = "https://example.com"

    // Dispositivi attivi in multi view
    @Published var activeDeviceIds: Set<UUID> = Set(DeviceModel.catalog.prefix(3).map(\.id))

    // Dispositivo selezionato in single view
    @Published var singleDeviceId: UUID? = DeviceModel.catalog.first?.id

    // Modalità
    @Published var viewMode: ViewMode = .multi

    // Impostazioni
    @Published var syncScrollEnabled: Bool  = true
    @Published var liveReloadEnabled: Bool  = false
    @Published var liveReloadInterval: Double = 3.0
    @Published var scale: CGFloat           = 0.42

    // Dispositivi custom
    @Published var customDevices: [DeviceModel] = []

    // WebView registry
    private(set) var webViews: [UUID: WKWebView] = [:]
    private var reloadTimer: Timer?
    private var isSyncingScroll = false

    // MARK: - Computed

    var allDevices: [DeviceModel] { DeviceModel.catalog + customDevices }

    var activeDevices: [DeviceModel] {
        allDevices.filter { activeDeviceIds.contains($0.id) }
    }

    var singleDevice: DeviceModel? {
        guard let id = singleDeviceId else { return nil }
        return allDevices.first { $0.id == id }
    }

    // MARK: - WebView registry

    func registerWebView(_ webView: WKWebView, for deviceId: UUID) {
        DispatchQueue.main.async { self.webViews[deviceId] = webView }
    }

    func unregisterWebView(for deviceId: UUID) {
        DispatchQueue.main.async { self.webViews.removeValue(forKey: deviceId) }
    }

    // MARK: - Navigazione

    func loadURL() {
        var s = urlString.trimmingCharacters(in: .whitespaces)
        if !s.hasPrefix("http://") && !s.hasPrefix("https://") { s = "https://" + s }
        urlString = s
        guard let url = URL(string: s) else { return }
        let req = URLRequest(url: url)
        webViews.values.forEach { $0.load(req) }
    }

    func reloadAll() {
        webViews.values.forEach { $0.reload() }
    }

    func goBack() {
        webViews.values.filter(\.canGoBack).forEach { $0.goBack() }
    }

    func goForward() {
        webViews.values.filter(\.canGoForward).forEach { $0.goForward() }
    }

    // MARK: - Scroll sync

    func propagateScroll(x: Double, y: Double, excludingDevice deviceId: UUID) {
        guard !isSyncingScroll else { return }
        isSyncingScroll = true
        let js = """
        (function(){
            var mxX=Math.max(0,document.documentElement.scrollWidth-window.innerWidth);
            var mxY=Math.max(0,document.documentElement.scrollHeight-window.innerHeight);
            window.scrollTo({left:\(x)*mxX,top:\(y)*mxY,behavior:'instant'});
        })();
        """
        for (id, wv) in webViews where id != deviceId {
            wv.evaluateJavaScript(js, completionHandler: nil)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { self.isSyncingScroll = false }
    }

    // MARK: - Live reload

    func updateLiveReload() {
        stopLiveReload()
        if liveReloadEnabled { startLiveReload() }
    }

    private func startLiveReload() {
        reloadTimer = Timer.scheduledTimer(withTimeInterval: liveReloadInterval, repeats: true) { [weak self] _ in
            self?.reloadAll()
        }
    }

    private func stopLiveReload() {
        reloadTimer?.invalidate()
        reloadTimer = nil
    }

    // MARK: - Screenshot

    func exportScreenshots(for deviceIds: [UUID]? = nil) {
        let ids     = deviceIds ?? Array(webViews.keys)
        let devices = allDevices.filter { ids.contains($0.id) }
        guard !devices.isEmpty else { return }

        let panel = NSOpenPanel()
        panel.canChooseFiles        = false
        panel.canChooseDirectories  = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Salva screenshot qui"
        panel.message = "Scegli la cartella di destinazione"

        panel.begin { [weak self] response in
            guard response == .OK, let folder = panel.url, let self = self else { return }
            for device in devices {
                guard let wv = self.webViews[device.id] else { continue }
                wv.takeSnapshot(with: nil) { image, _ in
                    guard let image = image else { return }
                    let safeName = device.name
                        .replacingOccurrences(of: " ", with: "_")
                        .replacingOccurrences(of: "\"", with: "in")
                        .replacingOccurrences(of: "/", with: "-")
                    let dest = folder.appendingPathComponent(
                        "\(safeName)_\(Int(device.width))x\(Int(device.height)).png"
                    )
                    if let tiff = image.tiffRepresentation,
                       let rep  = NSBitmapImageRep(data: tiff),
                       let png  = rep.representation(using: .png, properties: [:]) {
                        try? png.write(to: dest)
                    }
                }
            }
        }
    }

    // MARK: - Dispositivi custom

    func addCustomDevice(_ device: DeviceModel) {
        customDevices.append(device)
    }

    func removeCustomDevice(_ device: DeviceModel) {
        customDevices.removeAll { $0.id == device.id }
        activeDeviceIds.remove(device.id)
        if singleDeviceId == device.id { singleDeviceId = allDevices.first?.id }
    }
}

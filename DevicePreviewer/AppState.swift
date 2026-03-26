import Foundation
import WebKit
import Combine

enum ViewMode: String, CaseIterable, Identifiable {
    case multi  = "Multi"
    case single = "Single"
    var id: String { rawValue }
}

// MARK: - Persistence helper

private func persist<T>(_ keyPath: ReferenceWritableKeyPath<AppState, T>, key: String, default def: T) -> T
    where T: Codable
{
    if let data = UserDefaults.standard.data(forKey: key),
       let val  = try? JSONDecoder().decode(T.self, from: data) {
        return val
    }
    return def
}

class AppState: ObservableObject {

    // ── URL ──────────────────────────────────────────────────────────
    @Published var urlString: String {
        didSet { save("sl_url", urlString) }
    }

    // ── Dispositivi attivi ───────────────────────────────────────────
    @Published var activeDeviceIds: Set<UUID> {
        didSet {
            // Salva i NOMI (stabili) non gli UUID (rigenerati ad ogni avvio)
            let names = allDevices
                .filter { activeDeviceIds.contains($0.id) }
                .map(\.name)
            save("sl_activeNames", names)
        }
    }

    // ── Single device selezionato ────────────────────────────────────
    @Published var singleDeviceId: UUID? {
        didSet {
            let name = allDevices.first { $0.id == singleDeviceId }?.name
            save("sl_singleName", name ?? "")
        }
    }

    // ── View mode ────────────────────────────────────────────────────
    @Published var viewMode: ViewMode {
        didSet { save("sl_viewMode", viewMode.rawValue) }
    }

    // ── Impostazioni ─────────────────────────────────────────────────
    @Published var syncScrollEnabled: Bool {
        didSet { save("sl_syncScroll", syncScrollEnabled) }
    }
    @Published var liveReloadEnabled: Bool {
        didSet { save("sl_liveReload", liveReloadEnabled) }
    }
    @Published var liveReloadInterval: Double {
        didSet { save("sl_liveInterval", liveReloadInterval) }
    }
    @Published var scale: CGFloat {
        didSet { save("sl_scale", Double(scale)) }
    }
    @Published var deviceSpacing: CGFloat {
        didSet { save("sl_spacing", Double(deviceSpacing)) }
    }

    // ── Dispositivi custom ───────────────────────────────────────────
    @Published var customDevices: [DeviceModel] {
        didSet { save("sl_customDevices", customDevices) }
    }

    // ── Internal ─────────────────────────────────────────────────────
    private(set) var webViews: [UUID: WKWebView] = [:]
    private var reloadTimer: Timer?
    private var isSyncingScroll = false
    // Ultimo device con cui l'utente ha interagito (per DevTools)
    var lastActiveDeviceId: UUID? = nil

    // MARK: - Init

    init() {
        let ud = UserDefaults.standard

        // Helper per leggere valori salvati con JSONEncoder
        func load<T: Codable>(_ key: String, default def: T) -> T {
            guard let data = ud.data(forKey: key),
                  let val  = try? JSONDecoder().decode(T.self, from: data)
            else { return def }
            return val
        }

        // URL
        urlString          = load("sl_url",         default: "https://www.google.com")

        // View mode
        let modeRaw        = load("sl_viewMode",    default: ViewMode.multi.rawValue)
        viewMode           = ViewMode(rawValue: modeRaw) ?? .multi

        // Settings
        syncScrollEnabled  = load("sl_syncScroll",  default: true)
        liveReloadEnabled  = load("sl_liveReload",  default: false)
        liveReloadInterval = load("sl_liveInterval",default: 3.0)
        scale              = CGFloat(max(0.15, min(1.0, load("sl_scale",   default: 0.42) as Double)))
        deviceSpacing      = CGFloat(max(8.0,  min(80.0, load("sl_spacing", default: 32.0) as Double)))

        // Custom devices (prima, così allDevices è completo per il restore)
        customDevices      = load("sl_customDevices", default: [DeviceModel]())

        // Active devices — ricostruisce UUID dai nomi salvati
        let savedNames: [String] = load("sl_activeNames", default: [String]())
        let allDevs = DeviceModel.catalog + customDevices
        if savedNames.isEmpty {
            activeDeviceIds = Set(DeviceModel.catalog.prefix(3).map(\.id))
        } else {
            let matched = allDevs.filter { savedNames.contains($0.name) }.map(\.id)
            activeDeviceIds = matched.isEmpty
                ? Set(DeviceModel.catalog.prefix(3).map(\.id))
                : Set(matched)
        }

        // Single device — ricostruisce UUID dal nome salvato
        let savedSingleName: String = load("sl_singleName", default: "")
        if savedSingleName.isEmpty {
            singleDeviceId = DeviceModel.catalog.first?.id
        } else {
            singleDeviceId = allDevs.first { $0.name == savedSingleName }?.id
                ?? DeviceModel.catalog.first?.id
        }
    }

    // MARK: - Computed

    var allDevices: [DeviceModel]   { DeviceModel.catalog + customDevices }
    var activeDevices: [DeviceModel] { allDevices.filter { activeDeviceIds.contains($0.id) } }
    var singleDevice: DeviceModel?  {
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

    func reloadAll()  { webViews.values.forEach { $0.reload() } }
    func goBack()     { webViews.values.filter(\.canGoBack).forEach    { $0.goBack() } }
    func goForward()  { webViews.values.filter(\.canGoForward).forEach { $0.goForward() } }

    // MARK: - DevTools

    func showInspectorForActive() {
        // Apre solo il DevTools dell'ultimo device interagito,
        // oppure il primo attivo disponibile
        let targetId = lastActiveDeviceId ?? activeDevices.first?.id
        guard let id = targetId, let wv = webViews[id] else { return }
        showInspector(for: wv)
    }

    func showInspector(for webView: WKWebView) {
        if let inspector = webView.value(forKey: "_inspector") as? NSObject {
            inspector.perform(Selector(("show")))
        }
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
        reloadTimer?.invalidate()
        reloadTimer = nil
        if liveReloadEnabled {
            reloadTimer = Timer.scheduledTimer(withTimeInterval: liveReloadInterval, repeats: true) { [weak self] _ in
                self?.reloadAll()
            }
        }
    }

    // MARK: - Screenshot

    func exportScreenshots(for deviceIds: [UUID]? = nil) {
        let ids     = deviceIds ?? Array(webViews.keys)
        let devices = allDevices.filter { ids.contains($0.id) }
        guard !devices.isEmpty else { return }
        let panel               = NSOpenPanel()
        panel.canChooseFiles    = false
        panel.canChooseDirectories  = true
        panel.allowsMultipleSelection = false
        panel.prompt  = "Salva screenshot qui"
        panel.begin { [weak self] response in
            guard response == .OK, let folder = panel.url, let self = self else { return }
            for device in devices {
                guard let wv = self.webViews[device.id] else { continue }
                wv.takeSnapshot(with: nil) { image, _ in
                    guard let image = image else { return }
                    let safe = device.name
                        .replacingOccurrences(of: " ", with: "_")
                        .replacingOccurrences(of: "\"", with: "in")
                        .replacingOccurrences(of: "/",  with: "-")
                    let dest = folder.appendingPathComponent("\(safe)_\(Int(device.width))x\(Int(device.height)).png")
                    if let tiff = image.tiffRepresentation,
                       let rep  = NSBitmapImageRep(data: tiff),
                       let png  = rep.representation(using: .png, properties: [:]) {
                        try? png.write(to: dest)
                    }
                }
            }
        }
    }

    // MARK: - Custom devices

    func addCustomDevice(_ device: DeviceModel) {
        customDevices.append(device)
        activeDeviceIds.insert(device.id)
    }

    func removeCustomDevice(_ device: DeviceModel) {
        customDevices.removeAll { $0.id == device.id }
        activeDeviceIds.remove(device.id)
        if singleDeviceId == device.id { singleDeviceId = allDevices.first?.id }
    }

    // MARK: - Persist helper

    private func save<T: Codable>(_ key: String, _ value: T) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

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
        didSet { save("sl_activeIds", Array(activeDeviceIds)) }
    }

    // ── Single device selezionato ────────────────────────────────────
    @Published var singleDeviceId: UUID? {
        didSet { save("sl_singleId", singleDeviceId) }
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

    // MARK: - Init

    init() {
        let ud = UserDefaults.standard

        // URL
        urlString = ud.string(forKey: "sl_url") ?? "https://www.google.com"

        // View mode
        let modeRaw = ud.string(forKey: "sl_viewMode") ?? ViewMode.multi.rawValue
        viewMode = ViewMode(rawValue: modeRaw) ?? .multi

        // Settings
        syncScrollEnabled  = ud.object(forKey: "sl_syncScroll")   == nil ? true  : ud.bool(forKey: "sl_syncScroll")
        liveReloadEnabled  = ud.bool(forKey: "sl_liveReload")
        liveReloadInterval = ud.object(forKey: "sl_liveInterval") == nil ? 3.0   : ud.double(forKey: "sl_liveInterval")
        let savedScale     = ud.object(forKey: "sl_scale")        == nil ? 0.42  : ud.double(forKey: "sl_scale")
        scale              = CGFloat(savedScale)
        let savedSpacing   = ud.object(forKey: "sl_spacing")      == nil ? 32.0  : ud.double(forKey: "sl_spacing")
        deviceSpacing      = CGFloat(savedSpacing)

        // Custom devices
        if let data = ud.data(forKey: "sl_customDevices"),
           let devs = try? JSONDecoder().decode([DeviceModel].self, from: data) {
            customDevices = devs
        } else {
            customDevices = []
        }

        // Active IDs (default: primi 3)
        if let data = ud.data(forKey: "sl_activeIds"),
           let ids  = try? JSONDecoder().decode([UUID].self, from: data) {
            activeDeviceIds = Set(ids)
        } else {
            activeDeviceIds = Set(DeviceModel.catalog.prefix(3).map(\.id))
        }

        // Single ID
        if let data = ud.data(forKey: "sl_singleId"),
           let sid  = try? JSONDecoder().decode(UUID?.self, from: data) {
            singleDeviceId = sid
        } else {
            singleDeviceId = DeviceModel.catalog.first?.id
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

    func showInspectorForAllActive() {
        activeDevices.compactMap { webViews[$0.id] }.forEach { showInspector(for: $0) }
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

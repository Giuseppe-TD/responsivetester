import Foundation

enum DeviceCategory: String, CaseIterable, Identifiable, Codable {
    case iPhone  = "iPhone"
    case iPad    = "iPad"
    case android = "Android"
    case custom  = "Custom"
    var id: String { rawValue }
}

struct DeviceModel: Identifiable, Hashable, Equatable, Codable {
    var id: UUID
    var name: String
    var width: CGFloat
    var height: CGFloat
    var userAgent: String
    var category: DeviceCategory
    var isCustom: Bool

    init(id: UUID = UUID(), name: String, width: CGFloat, height: CGFloat,
         userAgent: String, category: DeviceCategory, isCustom: Bool = false) {
        self.id = id; self.name = name; self.width = width; self.height = height
        self.userAgent = userAgent; self.category = category; self.isCustom = isCustom
    }

    static func == (lhs: DeviceModel, rhs: DeviceModel) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Catalogo

extension DeviceModel {
    static let catalog: [DeviceModel] = iphones + ipads + androids

    private static let ua17 = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1"
    private static let ua18 = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Mobile/15E148 Safari/604.1"
    private static let ua19 = "Mozilla/5.0 (iPhone; CPU iPhone OS 19_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/19.0 Mobile/15E148 Safari/604.1"
    private static let uaIP = "Mozilla/5.0 (iPad; CPU OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1"

    static let iphones: [DeviceModel] = [
        // ── iPhone 17 ─────────────────────────────────────────────
        DeviceModel(name: "iPhone 17 Air",       width: 390, height: 844,  userAgent: ua19, category: .iPhone),
        DeviceModel(name: "iPhone 17",           width: 393, height: 852,  userAgent: ua19, category: .iPhone),
        DeviceModel(name: "iPhone 17 Pro",       width: 402, height: 874,  userAgent: ua19, category: .iPhone),
        DeviceModel(name: "iPhone 17 Pro Max",   width: 440, height: 956,  userAgent: ua19, category: .iPhone),
        // ── iPhone 16 ─────────────────────────────────────────────
        DeviceModel(name: "iPhone 16",           width: 393, height: 852,  userAgent: ua18, category: .iPhone),
        DeviceModel(name: "iPhone 16 Plus",      width: 430, height: 932,  userAgent: ua18, category: .iPhone),
        DeviceModel(name: "iPhone 16 Pro",       width: 402, height: 874,  userAgent: ua18, category: .iPhone),
        DeviceModel(name: "iPhone 16 Pro Max",   width: 440, height: 956,  userAgent: ua18, category: .iPhone),
        // ── iPhone 15 ─────────────────────────────────────────────
        DeviceModel(name: "iPhone 15",           width: 393, height: 852,  userAgent: ua17, category: .iPhone),
        DeviceModel(name: "iPhone 15 Plus",      width: 430, height: 932,  userAgent: ua17, category: .iPhone),
        DeviceModel(name: "iPhone 15 Pro",       width: 393, height: 852,  userAgent: ua17, category: .iPhone),
        DeviceModel(name: "iPhone 15 Pro Max",   width: 430, height: 932,  userAgent: ua17, category: .iPhone),
        // ── iPhone 14 ─────────────────────────────────────────────
        DeviceModel(name: "iPhone 14",           width: 390, height: 844,  userAgent: ua17, category: .iPhone),
        DeviceModel(name: "iPhone 14 Plus",      width: 428, height: 926,  userAgent: ua17, category: .iPhone),
        DeviceModel(name: "iPhone 14 Pro",       width: 393, height: 852,  userAgent: ua17, category: .iPhone),
        DeviceModel(name: "iPhone 14 Pro Max",   width: 430, height: 932,  userAgent: ua17, category: .iPhone),
        // ── iPhone 13 ─────────────────────────────────────────────
        DeviceModel(name: "iPhone 13 mini",      width: 375, height: 812,  userAgent: ua17, category: .iPhone),
        DeviceModel(name: "iPhone 13",           width: 390, height: 844,  userAgent: ua17, category: .iPhone),
        DeviceModel(name: "iPhone 13 Pro",       width: 390, height: 844,  userAgent: ua17, category: .iPhone),
        DeviceModel(name: "iPhone 13 Pro Max",   width: 428, height: 926,  userAgent: ua17, category: .iPhone),
        // ── Classici ──────────────────────────────────────────────
        DeviceModel(name: "iPhone SE (3rd gen)", width: 375, height: 667,  userAgent: ua17, category: .iPhone),
        DeviceModel(name: "iPhone 12",           width: 390, height: 844,  userAgent: ua17, category: .iPhone),
        DeviceModel(name: "iPhone 12 mini",      width: 375, height: 812,  userAgent: ua17, category: .iPhone),
    ]

    static let ipads: [DeviceModel] = [
        DeviceModel(name: "iPad mini 6",         width: 744,  height: 1133, userAgent: uaIP, category: .iPad),
        DeviceModel(name: "iPad (10th gen)",     width: 820,  height: 1180, userAgent: uaIP, category: .iPad),
        DeviceModel(name: "iPad Air 5",          width: 820,  height: 1180, userAgent: uaIP, category: .iPad),
        DeviceModel(name: "iPad Air 13\"",       width: 1024, height: 1366, userAgent: uaIP, category: .iPad),
        DeviceModel(name: "iPad Pro 11\"",       width: 834,  height: 1194, userAgent: uaIP, category: .iPad),
        DeviceModel(name: "iPad Pro 12.9\"",     width: 1024, height: 1366, userAgent: uaIP, category: .iPad),
        DeviceModel(name: "iPad Pro 13\" M4",    width: 1032, height: 1376, userAgent: uaIP, category: .iPad),
    ]

    static let androids: [DeviceModel] = [
        DeviceModel(name: "Samsung Galaxy S25",       width: 384, height: 832,
            userAgent: "Mozilla/5.0 (Linux; Android 15; SM-S931B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Mobile Safari/537.36", category: .android),
        DeviceModel(name: "Samsung Galaxy S25 Ultra", width: 412, height: 915,
            userAgent: "Mozilla/5.0 (Linux; Android 15; SM-S938B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Mobile Safari/537.36", category: .android),
        DeviceModel(name: "Samsung Galaxy S24",       width: 384, height: 832,
            userAgent: "Mozilla/5.0 (Linux; Android 14; SM-S921B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36", category: .android),
        DeviceModel(name: "Samsung Galaxy S24 Ultra", width: 412, height: 915,
            userAgent: "Mozilla/5.0 (Linux; Android 14; SM-S928B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36", category: .android),
        DeviceModel(name: "Samsung Galaxy A55",       width: 360, height: 800,
            userAgent: "Mozilla/5.0 (Linux; Android 14; SM-A556B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36", category: .android),
        DeviceModel(name: "Samsung Galaxy Z Fold 6",  width: 346, height: 861,
            userAgent: "Mozilla/5.0 (Linux; Android 14; SM-F956B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36", category: .android),
        DeviceModel(name: "Google Pixel 9",           width: 412, height: 892,
            userAgent: "Mozilla/5.0 (Linux; Android 15; Pixel 9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Mobile Safari/537.36", category: .android),
        DeviceModel(name: "Google Pixel 9 Pro",       width: 412, height: 892,
            userAgent: "Mozilla/5.0 (Linux; Android 15; Pixel 9 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Mobile Safari/537.36", category: .android),
        DeviceModel(name: "Google Pixel 9 Pro XL",    width: 448, height: 998,
            userAgent: "Mozilla/5.0 (Linux; Android 15; Pixel 9 Pro XL) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Mobile Safari/537.36", category: .android),
        DeviceModel(name: "OnePlus 13",               width: 412, height: 919,
            userAgent: "Mozilla/5.0 (Linux; Android 15; CPH2687) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Mobile Safari/537.36", category: .android),
        DeviceModel(name: "Xiaomi 15 Pro",            width: 393, height: 852,
            userAgent: "Mozilla/5.0 (Linux; Android 15; 24129PN74G) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Mobile Safari/537.36", category: .android),
    ]
}

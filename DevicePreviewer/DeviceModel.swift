import Foundation

enum DeviceCategory: String, CaseIterable, Identifiable {
    case iPhone  = "iPhone"
    case iPad    = "iPad"
    case android = "Android"
    case custom  = "Custom"
    var id: String { rawValue }
}

struct DeviceModel: Identifiable, Hashable, Equatable {
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

    private static let iphones: [DeviceModel] = [
        DeviceModel(name: "iPhone SE (3rd gen)",   width: 375, height: 667,
            userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1",
            category: .iPhone),
        DeviceModel(name: "iPhone 13 mini",        width: 375, height: 812,
            userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1",
            category: .iPhone),
        DeviceModel(name: "iPhone 14",             width: 390, height: 844,
            userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1",
            category: .iPhone),
        DeviceModel(name: "iPhone 14 Pro",         width: 393, height: 852,
            userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1",
            category: .iPhone),
        DeviceModel(name: "iPhone 14 Pro Max",     width: 430, height: 932,
            userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1",
            category: .iPhone),
        DeviceModel(name: "iPhone 15",             width: 393, height: 852,
            userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1",
            category: .iPhone),
        DeviceModel(name: "iPhone 15 Plus",        width: 430, height: 932,
            userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1",
            category: .iPhone),
        DeviceModel(name: "iPhone 15 Pro",         width: 393, height: 852,
            userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1",
            category: .iPhone),
        DeviceModel(name: "iPhone 15 Pro Max",     width: 430, height: 932,
            userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1",
            category: .iPhone),
        DeviceModel(name: "iPhone 16 Pro Max",     width: 440, height: 956,
            userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Mobile/15E148 Safari/604.1",
            category: .iPhone),
    ]

    private static let ipads: [DeviceModel] = [
        DeviceModel(name: "iPad mini 6",           width: 744,  height: 1133,
            userAgent: "Mozilla/5.0 (iPad; CPU OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1",
            category: .iPad),
        DeviceModel(name: "iPad (10th gen)",       width: 820,  height: 1180,
            userAgent: "Mozilla/5.0 (iPad; CPU OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1",
            category: .iPad),
        DeviceModel(name: "iPad Air 5",            width: 820,  height: 1180,
            userAgent: "Mozilla/5.0 (iPad; CPU OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1",
            category: .iPad),
        DeviceModel(name: "iPad Pro 11\"",         width: 834,  height: 1194,
            userAgent: "Mozilla/5.0 (iPad; CPU OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1",
            category: .iPad),
        DeviceModel(name: "iPad Pro 12.9\"",       width: 1024, height: 1366,
            userAgent: "Mozilla/5.0 (iPad; CPU OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1",
            category: .iPad),
    ]

    private static let androids: [DeviceModel] = [
        DeviceModel(name: "Samsung Galaxy S24",       width: 384, height: 832,
            userAgent: "Mozilla/5.0 (Linux; Android 14; SM-S921B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36",
            category: .android),
        DeviceModel(name: "Samsung Galaxy S24 Ultra", width: 412, height: 915,
            userAgent: "Mozilla/5.0 (Linux; Android 14; SM-S928B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36",
            category: .android),
        DeviceModel(name: "Samsung Galaxy A54",       width: 360, height: 800,
            userAgent: "Mozilla/5.0 (Linux; Android 14; SM-A546B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36",
            category: .android),
        DeviceModel(name: "Google Pixel 8",           width: 412, height: 915,
            userAgent: "Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36",
            category: .android),
        DeviceModel(name: "Google Pixel 8 Pro",       width: 448, height: 998,
            userAgent: "Mozilla/5.0 (Linux; Android 14; Pixel 8 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36",
            category: .android),
        DeviceModel(name: "Google Pixel 9 Pro XL",    width: 448, height: 998,
            userAgent: "Mozilla/5.0 (Linux; Android 15; Pixel 9 Pro XL) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Mobile Safari/537.36",
            category: .android),
        DeviceModel(name: "OnePlus 12",               width: 412, height: 919,
            userAgent: "Mozilla/5.0 (Linux; Android 14; CPH2581) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36",
            category: .android),
        DeviceModel(name: "Xiaomi 14 Pro",            width: 393, height: 852,
            userAgent: "Mozilla/5.0 (Linux; Android 14; 23116PN5BC) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36",
            category: .android),
    ]
}

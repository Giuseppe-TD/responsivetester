import SwiftUI

struct DeviceCardView: View {
    let device: DeviceModel
    let scale: CGFloat
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 6) {
            // Header
            HStack(spacing: 4) {
                Image(systemName: iconName)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(device.name)
                    .font(.caption).fontWeight(.medium)
                    .lineLimit(1)
                Text("·").foregroundColor(.secondary)
                Text("\(Int(device.width))×\(Int(device.height))")
                    .font(.caption2).foregroundColor(.secondary).monospacedDigit()
                Spacer()
                Button {
                    appState.exportScreenshots(for: [device.id])
                } label: {
                    Image(systemName: "camera").font(.caption2)
                }
                .buttonStyle(.plain).foregroundColor(.secondary)
                .help("Screenshot \(device.name)")
            }
            .frame(width: device.width * scale)

            // WebView frame
            WebViewRepresentable(device: device)
                .frame(width: device.width, height: device.height)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(Color.primary.opacity(0.18), lineWidth: 0.5)
                )
                .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 3)
                .scaleEffect(scale, anchor: .topLeading)
                .frame(width: device.width * scale, height: device.height * scale)
        }
    }

    private var iconName: String {
        switch device.category {
        case .iPhone:  return "iphone"
        case .iPad:    return "ipad"
        case .android: return "iphone"         // nessuna icona Android in SF Symbols
        case .custom:  return "rectangle.portrait"
        }
    }
}

import SwiftUI

struct DeviceCardView: View {
    let device: DeviceModel
    let scale: CGFloat
    @EnvironmentObject var appState: AppState
    @State private var isHovered = false

    private var cornerRadius: CGFloat {
        switch device.category {
        case .iPhone:  return 52
        case .iPad:    return 30
        case .android: return 46
        case .custom:  return 22
        }
    }

    var body: some View {
        VStack(spacing: 10) {

            // ── Label ──────────────────────────────────────────────────
            deviceLabel

            // ── Telefono ───────────────────────────────────────────────
            phoneBody
        }
    }

    // MARK: - Label

    private var deviceLabel: some View {
        HStack(spacing: 5) {
            Image(systemName: sfIcon)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)

            Text(device.name)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)

            Text("·")
                .foregroundStyle(.quaternary)

            Text("\(Int(device.width))×\(Int(device.height))")
                .font(.system(size: 10, weight: .regular).monospacedDigit())
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.08), radius: 4, y: 1)
        )
    }

    // MARK: - Phone body

    private var phoneBody: some View {
        ZStack(alignment: .top) {
            // WebView
            WebViewRepresentable(device: device)
                .frame(width: device.width, height: device.height)

            // Cornice
            PhoneFrameOverlay(device: device)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .shadow(
            color: .black.opacity(isHovered ? 0.35 : 0.20),
            radius: isHovered ? 22 : 12,
            x: 0,
            y: isHovered ? 10 : 5
        )
        .overlay(alignment: .topTrailing) {
            // Screenshot button su hover
            screenshotButton
        }
        .scaleEffect(scale, anchor: .top)
        .frame(width: device.width * scale, height: device.height * scale)
        .onHover { isHovered = $0 }
        .animation(.easeOut(duration: 0.14), value: isHovered)
    }

    // MARK: - Screenshot hover button

    private var screenshotButton: some View {
        Button {
            appState.exportScreenshots(for: [device.id])
        } label: {
            Image(systemName: "camera.fill")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(.ultraThinMaterial, in: Circle())
                .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
        .padding(10)
        .opacity(isHovered ? 1 : 0)
        .scaleEffect(isHovered ? 1 : 0.7)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isHovered)
        // controcorregge la scala del genitore
        .scaleEffect(1 / scale, anchor: .topTrailing)
        .help("Screenshot \(device.name)")
    }

    private var sfIcon: String {
        switch device.category {
        case .iPhone:  return "iphone"
        case .iPad:    return "ipad"
        case .android: return "phone"
        case .custom:  return "rectangle.portrait"
        }
    }
}

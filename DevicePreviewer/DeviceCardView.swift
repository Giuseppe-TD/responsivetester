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
        VStack(spacing: 0) {

            // ── Header: nome + screenshot ──────────────────────────────
            deviceHeader
                .frame(width: device.width * scale)
                .padding(.bottom, 8)

            // ── Telefono ───────────────────────────────────────────────
            phoneBody
        }
    }

    // MARK: - Header

    private var deviceHeader: some View {
        HStack(spacing: 6) {
            Image(systemName: sfIcon)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 0) {
                Text(device.name)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text("\(Int(device.width)) × \(Int(device.height))")
                    .font(.system(size: 9).monospacedDigit())
                    .foregroundStyle(.tertiary)
            }

            Spacer(minLength: 4)

            // Screenshot sempre visibile
            Button {
                appState.exportScreenshots(for: [device.id])
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "camera")
                        .font(.system(size: 10, weight: .medium))
                    Text("Screenshot")
                        .font(.system(size: 10))
                }
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(isHovered
                            ? Color.secondary.opacity(0.18)
                            : Color.secondary.opacity(0.10))
                )
            }
            .buttonStyle(.plain)
            .help("Screenshot \(device.name)")
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Phone body

    private var phoneBody: some View {
        ZStack(alignment: .top) {
            WebViewRepresentable(device: device)
                .frame(width: device.width, height: device.height)
            PhoneFrameOverlay(device: device)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .shadow(
            color: .black.opacity(isHovered ? 0.35 : 0.20),
            radius: isHovered ? 22 : 12,
            x: 0,
            y: isHovered ? 10 : 5
        )
        .scaleEffect(scale, anchor: .top)
        .frame(width: device.width * scale, height: device.height * scale)
        .onHover { isHovered = $0 }
        .animation(.easeOut(duration: 0.14), value: isHovered)
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

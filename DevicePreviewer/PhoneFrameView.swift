import SwiftUI

struct PhoneFrameOverlay: View {
    let device: DeviceModel

    var cornerRadius: CGFloat {
        switch device.category {
        case .iPhone:  return 52
        case .iPad:    return 28
        case .android: return 44
        case .custom:  return 20
        }
    }

    // Dynamic Island: iPhone 14 Pro+ (h >= 852, w >= 393)
    // iPhone 17 Air è 390x844 → notch, non DI
    private var hasDynamicIsland: Bool {
        device.category == .iPhone
            && device.width >= 393
            && device.height >= 852
    }

    // Notch: iPhone X → 13 range (812–844 altezza)
    private var hasNotch: Bool {
        device.category == .iPhone
            && device.height >= 812
            && device.height <= 844
            && !hasDynamicIsland
    }

    // Pill speaker: iPhone SE / più vecchi (no notch, no DI)
    private var hasSpeakerPill: Bool {
        device.category == .iPhone
            && device.height < 812
    }

    private var hasHomeIndicator: Bool {
        (device.category == .iPhone && device.height >= 812)
            || device.category == .iPad
    }

    var body: some View {
        ZStack(alignment: .top) {

            // ── Bordo metallico ──────────────────────────────────────
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(
                    LinearGradient(
                        stops: [
                            .init(color: .white.opacity(0.40), location: 0.00),
                            .init(color: .white.opacity(0.12), location: 0.20),
                            .init(color: .black.opacity(0.55), location: 0.60),
                            .init(color: .white.opacity(0.22), location: 1.00),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 4.5
                )

            // Inner shadow
            RoundedRectangle(cornerRadius: cornerRadius - 2)
                .strokeBorder(Color.black.opacity(0.40), lineWidth: 1.5)
                .padding(2.5)

            // ── Dynamic Island ───────────────────────────────────────
            if hasDynamicIsland {
                Capsule()
                    .fill(Color.black)
                    .frame(width: device.width * 0.28, height: 14)
                    .padding(.top, 14)
            }

            // ── Notch ────────────────────────────────────────────────
            if hasNotch {
                Rectangle()
                    .fill(Color.black)
                    .frame(width: device.width * 0.58, height: 30)
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            // ── Speaker pill (SE e vecchi) ───────────────────────────
            if hasSpeakerPill {
                Capsule()
                    .fill(Color.black.opacity(0.75))
                    .frame(width: 44, height: 7)
                    .padding(.top, 18)
            }

            // ── Tasti laterali iPhone ────────────────────────────────
            if device.category == .iPhone {
                sideButtons
            }

            // ── Tasti laterali Android ───────────────────────────────
            if device.category == .android {
                androidSideButtons
            }

            // ── Home indicator ───────────────────────────────────────
            if hasHomeIndicator {
                VStack {
                    Spacer()
                    Capsule()
                        .fill(Color.white.opacity(0.50))
                        .frame(width: device.width * 0.32, height: 5)
                        .padding(.bottom, 9)
                }
            }
        }
        .frame(width: device.width, height: device.height)
        .allowsHitTesting(false)
    }

    // MARK: - Tasti iPhone

    private var sideButtons: some View {
        ZStack {
            // Sinistra: mute + vol+ + vol-
            VStack(alignment: .leading, spacing: 0) {
                Spacer().frame(height: device.height * 0.18)
                // Mute
                sideBtn(h: 26).offset(x: -2)
                Spacer().frame(height: 10)
                // Vol +
                sideBtn(h: 42).offset(x: -2)
                Spacer().frame(height: 10)
                // Vol -
                sideBtn(h: 42).offset(x: -2)
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Destra: power
            VStack(alignment: .trailing, spacing: 0) {
                Spacer().frame(height: device.height * 0.24)
                sideBtn(h: 56).offset(x: 2)
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(width: device.width, height: device.height)
    }

    // MARK: - Tasti Android

    private var androidSideButtons: some View {
        ZStack {
            // Destra: power + vol
            VStack(alignment: .trailing, spacing: 0) {
                Spacer().frame(height: device.height * 0.22)
                sideBtn(h: 38).offset(x: 2)
                Spacer().frame(height: 10)
                sideBtn(h: 60).offset(x: 2)
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(width: device.width, height: device.height)
    }

    private func sideBtn(h: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(
                LinearGradient(
                    colors: [.white.opacity(0.22), .white.opacity(0.06)],
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .frame(width: 3.5, height: h)
    }
}

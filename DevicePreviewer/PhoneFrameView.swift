import SwiftUI

struct PhoneFrameOverlay: View {
    let device: DeviceModel

    var cornerRadius: CGFloat {
        switch device.category {
        case .iPhone:  return 52
        case .iPad:    return 30
        case .android: return 46
        case .custom:  return 22
        }
    }

    private var hasDynamicIsland: Bool {
        device.category == .iPhone && device.width >= 393 && device.height >= 852
    }
    private var hasNotch: Bool {
        device.category == .iPhone && device.height >= 812 && !hasDynamicIsland
    }
    private var hasHomeIndicator: Bool {
        device.category == .iPhone || device.category == .iPad
    }

    var body: some View {
        ZStack(alignment: .top) {
            // Bordo metallico
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(
                    LinearGradient(
                        stops: [
                            .init(color: .white.opacity(0.35), location: 0),
                            .init(color: .white.opacity(0.10), location: 0.25),
                            .init(color: .black.opacity(0.50), location: 0.60),
                            .init(color: .white.opacity(0.18), location: 1),
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    lineWidth: 4
                )

            // Inner shadow
            RoundedRectangle(cornerRadius: cornerRadius - 2)
                .strokeBorder(Color.black.opacity(0.45), lineWidth: 1.5)
                .padding(2.5)

            // Dynamic Island
            if hasDynamicIsland {
                Capsule()
                    .fill(Color.black)
                    .frame(width: device.width * 0.27, height: 13)
                    .padding(.top, 15)
            }

            // Notch
            if hasNotch {
                Rectangle()
                    .fill(Color.black)
                    .frame(width: device.width * 0.55, height: 28)
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            // Pulsanti laterali iPhone
            if device.category == .iPhone {
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        RoundedRectangle(cornerRadius: 2).fill(sideGrad).frame(width: 3.5, height: 24).offset(x: -1.5).padding(.top, device.height * 0.17)
                        RoundedRectangle(cornerRadius: 2).fill(sideGrad).frame(width: 3.5, height: 38).offset(x: -1.5).padding(.top, 10)
                        RoundedRectangle(cornerRadius: 2).fill(sideGrad).frame(width: 3.5, height: 38).offset(x: -1.5).padding(.top, 10)
                    }
                    Spacer()
                    RoundedRectangle(cornerRadius: 2).fill(sideGrad).frame(width: 3.5, height: 50).offset(x: 1.5).padding(.top, device.height * 0.22)
                }
                .frame(width: device.width, height: device.height)
            }

            // Home indicator
            if hasHomeIndicator {
                VStack {
                    Spacer()
                    Capsule()
                        .fill(Color.white.opacity(0.55))
                        .frame(width: device.width * 0.33, height: 5)
                        .padding(.bottom, 10)
                }
            }
        }
        .frame(width: device.width, height: device.height)
        .allowsHitTesting(false)
    }

    private var sideGrad: LinearGradient {
        LinearGradient(colors: [.white.opacity(0.20), .white.opacity(0.06)],
                       startPoint: .leading, endPoint: .trailing)
    }
}

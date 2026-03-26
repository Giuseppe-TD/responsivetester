import SwiftUI

struct MultiDeviceView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        if appState.activeDevices.isEmpty {
            emptyState
        } else {
            ScrollView([.horizontal, .vertical]) {
                LazyHStack(alignment: .top, spacing: appState.deviceSpacing) {
                    ForEach(appState.activeDevices) { device in
                        DeviceCardView(device: device, scale: appState.scale)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, max(36, appState.deviceSpacing))
                .padding(.vertical, 36)
            }
            .background(canvasBackground)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "iphone.slash")
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundStyle(.secondary)
            Text("Nessun dispositivo selezionato")
                .font(.title3)
                .foregroundStyle(.secondary)
            Text("Spunta i dispositivi nella sidebar per visualizzarli")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(canvasBackground)
    }

    // Sfondo a griglia sottile stile canvas
    private var canvasBackground: some View {
        ZStack {
            Color(nsColor: .underPageBackgroundColor)
            Canvas { ctx, size in
                let step: CGFloat = 24
                var path = Path()
                var x: CGFloat = 0
                while x <= size.width  { path.move(to: .init(x: x, y: 0)); path.addLine(to: .init(x: x, y: size.height)); x += step }
                var y: CGFloat = 0
                while y <= size.height { path.move(to: .init(x: 0, y: y)); path.addLine(to: .init(x: size.width, y: y)); y += step }
                ctx.stroke(path, with: .color(.primary.opacity(0.028)), lineWidth: 0.5)
            }
        }
    }
}

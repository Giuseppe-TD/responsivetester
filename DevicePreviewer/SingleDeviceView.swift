import SwiftUI

struct SingleDeviceView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        if let device = appState.singleDevice {
            GeometryReader { geo in
                let padding: CGFloat = 60
                let scaleW = (geo.size.width  - padding) / device.width
                let scaleH = (geo.size.height - padding) / device.height
                let scale  = min(scaleW, scaleH, 1.0)

                VStack {
                    DeviceCardView(device: device, scale: scale)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(canvasBackground)
        } else {
            Text("Seleziona un dispositivo dalla sidebar")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(canvasBackground)
        }
    }

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

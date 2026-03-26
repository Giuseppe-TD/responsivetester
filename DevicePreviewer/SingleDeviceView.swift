import SwiftUI

struct SingleDeviceView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        if let device = appState.singleDevice {
            GeometryReader { geo in
                let padding: CGFloat = 48
                let scaleW = (geo.size.width  - padding) / device.width
                let scaleH = (geo.size.height - padding) / device.height
                let scale  = min(scaleW, scaleH, 1.0)   // non upscalare mai

                VStack {
                    DeviceCardView(device: device, scale: scale)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(Color(nsColor: .underPageBackgroundColor))
        } else {
            Text("Seleziona un dispositivo dalla sidebar")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(nsColor: .underPageBackgroundColor))
        }
    }
}

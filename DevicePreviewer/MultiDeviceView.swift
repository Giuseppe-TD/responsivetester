import SwiftUI

struct MultiDeviceView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        if appState.activeDevices.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "iphone.slash")
                    .font(.system(size: 44))
                    .foregroundColor(.secondary)
                Text("Nessun dispositivo selezionato")
                    .font(.title3).foregroundColor(.secondary)
                Text("Spunta i dispositivi nella sidebar per visualizzarli")
                    .font(.caption).foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(nsColor: .underPageBackgroundColor))
        } else {
            ScrollView([.horizontal, .vertical]) {
                HStack(alignment: .top, spacing: 28) {
                    ForEach(appState.activeDevices) { device in
                        DeviceCardView(device: device, scale: appState.scale)
                    }
                }
                .padding(28)
            }
            .background(Color(nsColor: .underPageBackgroundColor))
        }
    }
}

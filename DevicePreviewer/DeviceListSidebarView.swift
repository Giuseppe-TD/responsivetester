import SwiftUI

struct DeviceListSidebarView: View {
    @EnvironmentObject var appState: AppState
    @Binding var showAddDevice: Bool

    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach(DeviceCategory.allCases) { category in
                    let devices = appState.allDevices.filter { $0.category == category }
                    if !devices.isEmpty {
                        Section(category.rawValue) {
                            ForEach(devices) { device in
                                DeviceRowView(device: device)
                            }
                        }
                    }
                }
            }
            .listStyle(.sidebar)

            Divider()

            HStack {
                Button {
                    showAddDevice = true
                } label: {
                    Label("Aggiungi", systemImage: "plus.circle")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)
                Spacer()
            }
            .padding(10)
        }
    }
}

struct DeviceRowView: View {
    @EnvironmentObject var appState: AppState
    let device: DeviceModel

    var isActive: Bool   { appState.activeDeviceIds.contains(device.id) }
    var isSelected: Bool { appState.singleDeviceId == device.id }

    var body: some View {
        HStack(spacing: 6) {
            Toggle("", isOn: Binding(
                get:  { isActive },
                set:  { v in
                    if v { appState.activeDeviceIds.insert(device.id) }
                    else { appState.activeDeviceIds.remove(device.id) }
                }
            ))
            .toggleStyle(.checkbox)
            .labelsHidden()

            VStack(alignment: .leading, spacing: 1) {
                Text(device.name)
                    .font(.caption).lineLimit(1)
                Text("\(Int(device.width))×\(Int(device.height))")
                    .font(.caption2).foregroundColor(.secondary)
            }

            Spacer()

            if appState.viewMode == .single {
                Circle()
                    .fill(isSelected ? Color.accentColor : Color.secondary.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if appState.viewMode == .single {
                appState.singleDeviceId = device.id
            }
        }
        .background(
            (appState.viewMode == .single && isSelected)
                ? Color.accentColor.opacity(0.08)
                : Color.clear
        )
        .cornerRadius(4)
        .contextMenu {
            if device.isCustom {
                Button("Rimuovi dispositivo", role: .destructive) {
                    appState.removeCustomDevice(device)
                }
            }
        }
    }
}

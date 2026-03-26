import SwiftUI

struct DeviceListSidebarView: View {
    @EnvironmentObject var appState: AppState
    @Binding var showAddDevice: Bool

    var body: some View {
        VStack(spacing: 0) {

            // ── Header ────────────────────────────────────────────────
            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 7)
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.10, green: 0.18, blue: 0.55),
                                         Color(red: 0.05, green: 0.10, blue: 0.38)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Image(systemName: "iphone.gen3")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .frame(width: 28, height: 28)

                VStack(alignment: .leading, spacing: 0) {
                    Text("Screenlab")
                        .font(.system(size: 13, weight: .bold))
                    Text("\(appState.activeDeviceIds.count) attivi")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)

            Divider().opacity(0.5)

            // ── Lista ─────────────────────────────────────────────────
            List {
                ForEach(DeviceCategory.allCases) { category in
                    let devices = appState.allDevices.filter { $0.category == category }
                    if !devices.isEmpty {
                        Section {
                            ForEach(devices) { device in
                                DeviceRowView(device: device)
                            }
                        } header: {
                            HStack {
                                Image(systemName: categoryIcon(category))
                                    .font(.caption2)
                                Text(category.rawValue.uppercased())
                                    .font(.system(size: 9, weight: .semibold))
                                    .tracking(0.8)
                            }
                            .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .listStyle(.sidebar)

            Divider().opacity(0.5)

            // ── Footer ────────────────────────────────────────────────
            Button {
                showAddDevice = true
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "plus.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.accentColor)
                    Text("Aggiungi dispositivo")
                        .font(.caption)
                        .foregroundStyle(.accentColor)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
            }
            .buttonStyle(.plain)
        }
    }

    private func categoryIcon(_ c: DeviceCategory) -> String {
        switch c {
        case .iPhone:  return "iphone"
        case .iPad:    return "ipad"
        case .android: return "phone"
        case .custom:  return "slider.horizontal.3"
        }
    }
}

// MARK: - Row

struct DeviceRowView: View {
    @EnvironmentObject var appState: AppState
    let device: DeviceModel
    @State private var isHovered = false

    var isActive:   Bool { appState.activeDeviceIds.contains(device.id) }
    var isSelected: Bool { appState.singleDeviceId == device.id }

    var body: some View {
        HStack(spacing: 7) {
            // Checkbox
            Toggle("", isOn: Binding(
                get:  { isActive },
                set:  { v in
                    if v { appState.activeDeviceIds.insert(device.id) }
                    else { appState.activeDeviceIds.remove(device.id) }
                }
            ))
            .toggleStyle(.checkbox)
            .labelsHidden()

            // Nome + dimensioni
            VStack(alignment: .leading, spacing: 1) {
                Text(device.name)
                    .font(.system(size: 11, weight: isActive ? .medium : .regular))
                    .foregroundStyle(isActive ? .primary : .secondary)
                    .lineLimit(1)
                Text("\(Int(device.width)) × \(Int(device.height))")
                    .font(.system(size: 9).monospacedDigit())
                    .foregroundStyle(.tertiary)
            }

            Spacer(minLength: 0)

            // Indicatore single-mode
            if appState.viewMode == .single {
                Circle()
                    .fill(isSelected ? Color.accentColor : Color.secondary.opacity(0.2))
                    .frame(width: 7, height: 7)
            }
        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
        .background(
            (appState.viewMode == .single && isSelected)
                ? Color.accentColor.opacity(0.08)
                : (isHovered ? Color.secondary.opacity(0.06) : Color.clear),
            in: RoundedRectangle(cornerRadius: 5)
        )
        .onHover { isHovered = $0 }
        .onTapGesture {
            if appState.viewMode == .single { appState.singleDeviceId = device.id }
        }
        .contextMenu {
            if device.isCustom {
                Button("Rimuovi dispositivo", role: .destructive) {
                    appState.removeCustomDevice(device)
                }
            }
        }
    }
}

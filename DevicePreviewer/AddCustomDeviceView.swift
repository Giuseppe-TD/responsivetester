import SwiftUI

struct AddCustomDeviceView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    @State private var name: String = ""
    @State private var width: String = "390"
    @State private var height: String = "844"
    @State private var userAgent: String = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1"
    @State private var category: DeviceCategory = .custom

    private let presets: [(String, String)] = [
        ("iPhone Safari",  "Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1"),
        ("iPad Safari",    "Mozilla/5.0 (iPad; CPU OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1"),
        ("Android Chrome", "Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36"),
        ("Desktop Chrome", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36"),
    ]

    var isValid: Bool { !name.isEmpty && Double(width) != nil && Double(height) != nil && !userAgent.isEmpty }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Aggiungi dispositivo")
                    .font(.headline)
                Spacer()
                Button("Annulla") { dismiss() }
            }
            .padding()

            Divider()

            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Nome").font(.caption).foregroundStyle(.secondary)
                    TextField("es. Galaxy Z Fold interno", text: $name).textFieldStyle(.roundedBorder)
                }

                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Larghezza (px)").font(.caption).foregroundStyle(.secondary)
                        TextField("390", text: $width).textFieldStyle(.roundedBorder).frame(width: 90)
                    }
                    Text("×").foregroundStyle(.secondary).padding(.top, 14)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Altezza (px)").font(.caption).foregroundStyle(.secondary)
                        TextField("844", text: $height).textFieldStyle(.roundedBorder).frame(width: 90)
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Categoria").font(.caption).foregroundStyle(.secondary)
                        Picker("", selection: $category) {
                            ForEach(DeviceCategory.allCases) { c in Text(c.rawValue).tag(c) }
                        }
                        .frame(width: 110)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("User Agent").font(.caption).foregroundStyle(.secondary)
                        Spacer()
                        Menu("Preset ▾") {
                            ForEach(presets, id: \.0) { n, ua in Button(n) { userAgent = ua } }
                        }
                        .font(.caption)
                    }
                    TextEditor(text: $userAgent)
                        .font(.system(.caption, design: .monospaced))
                        .frame(height: 70)
                        .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(Color.secondary.opacity(0.3)))
                }
            }
            .padding()

            Divider()

            HStack {
                Spacer()
                Button("Aggiungi") {
                    let w = CGFloat(Double(width) ?? 390)
                    let h = CGFloat(Double(height) ?? 844)
                    appState.addCustomDevice(DeviceModel(name: name, width: w, height: h,
                        userAgent: userAgent, category: category, isCustom: true))
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isValid)
            }
            .padding()
        }
        .frame(width: 480)
    }
}

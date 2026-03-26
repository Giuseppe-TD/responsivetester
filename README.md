# Device Previewer

App macOS nativa Swift/SwiftUI + WebKit per testare siti su più dispositivi contemporaneamente.
Alternativa leggera e nativa a Sizzy.

## Feature

- **Multi view** — dispositivi affiancati con scroll orizzontale
- **Single view** — dispositivo singolo scalato alla finestra
- **Sync scroll** — scrolling sincronizzato via JS injection in WKWebView
- **Live reload** — ricarica automatica ogni N secondi (1/2/3/5s)
- **User Agent per dispositivo** — Safari iOS, Safari iPadOS, Chrome Android
- **Screenshot PNG** — esporta screenshot per dispositivo in cartella scelta
- **Dispositivi custom** — aggiungi qualunque dimensione + UA
- 20 dispositivi predefiniti: iPhone SE → iPhone 16 Pro Max, iPad mini → iPad Pro 12.9", Samsung Galaxy, Pixel, OnePlus, Xiaomi

---

## Setup — Metodo 1: XcodeGen (consigliato)

```bash
# Installa XcodeGen se non ce l'hai
brew install xcodegen

# Nella root del progetto
cd DevicePreviewer
xcodegen generate

# Apri in Xcode
open DevicePreviewer.xcodeproj
```

Poi **⌘R** per buildare e avviare.

---

## Setup — Metodo 2: Xcode manuale

1. **File > New > Project > macOS > App**
   - Product Name: `DevicePreviewer`
   - Interface: `SwiftUI` / Language: `Swift`
   - Deployment Target: **macOS 13.0**

2. Elimina i file generati automaticamente:
   - `ContentView.swift`
   - `DevicePreviewerApp.swift` (quello generato da Xcode)

3. **Trascina** tutti i file `.swift` della cartella `DevicePreviewer/` nel progetto
   _(assicurati che "Copy items if needed" sia selezionato)_

4. **Aggiungi WebKit framework**:
   - Seleziona il target nel Project Navigator
   - Tab **General** → **Frameworks, Libraries, and Embedded Content**
   - `+` → cerca `WebKit` → aggiungi `WebKit.framework`

5. **Info.plist**: sostituisci quello generato con il file `Info.plist` incluso
   _(serve `NSAllowsArbitraryLoads` per caricare http:// localhost)_

6. **Entitlements**: nella tab **Signing & Capabilities** → **App Sandbox**:
   - ✅ Outgoing Connections (Client)
   - ✅ User Selected File → Read/Write
   _(oppure usa il file `.entitlements` incluso)_

7. **⌘R** → Build & Run

---

## Struttura file

```
DevicePreviewer/
├── DevicePreviewerApp.swift      # @main entry point
├── AppState.swift                # ObservableObject: URL, registry WKWebView, scroll sync, screenshot
├── DeviceModel.swift             # Struct + catalogo 20 dispositivi
├── ContentView.swift             # Layout principale + toolbar completa
├── DeviceListSidebarView.swift   # Sidebar con checkbox dispositivi
├── MultiDeviceView.swift         # Vista multi-dispositivo (HStack scrollabile)
├── SingleDeviceView.swift        # Vista singolo dispositivo (auto-scale)
├── DeviceCardView.swift          # Card: header + WKWebView scalato
├── WebViewRepresentable.swift    # NSViewRepresentable per WKWebView + scroll JS
├── AddCustomDeviceView.swift     # Sheet aggiunta dispositivo custom
├── Info.plist                    # NSAllowsArbitraryLoads
└── DevicePreviewer.entitlements  # Sandbox + network + file write
```

---

## Note tecniche

- **Sync scroll**: JS iniettato via `WKUserScript` traccia `scroll` eventi con `requestAnimationFrame`
  e invia le coordinate percentuali (0..1) via `webkit.messageHandlers`. L'app propaga a tutti
  gli altri webview eseguendo `window.scrollTo()` via `evaluateJavaScript`.
- **Screenshot**: usa `WKWebView.takeSnapshot(with:completionHandler:)` → `NSImage` → PNG
- **Scale**: `.scaleEffect(scale, anchor: .topLeading)` + `.frame(w*scale, h*scale)` — il WKWebView
  renderizza a risoluzione reale del dispositivo, l'intera card viene ridimensionata visivamente
- **Live reload**: `Timer` scheduledTimer che chiama `webView.reload()` sull'intervallo scelto
- **NSAllowsArbitraryLoads**: necessario per caricare `http://localhost:xxxx` in sviluppo locale

---

## Aggiungere dispositivi al catalogo

Apri `DeviceModel.swift` e aggiungi un elemento negli array `iphones`, `ipads` o `androids`:

```swift
DeviceModel(
    name: "Galaxy Z Fold 5 esterno",
    width: 346, height: 745,
    userAgent: "Mozilla/5.0 (Linux; Android 14; SM-F946B) ...",
    category: .android
),
```

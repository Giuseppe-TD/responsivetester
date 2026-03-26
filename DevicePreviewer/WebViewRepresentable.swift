import SwiftUI
import WebKit

struct WebViewRepresentable: NSViewRepresentable {
    let device: DeviceModel
    @EnvironmentObject var appState: AppState

    func makeCoordinator() -> Coordinator {
        Coordinator(device: device, appState: appState)
    }

    func makeNSView(context: Context) -> WKWebView {
        let wv = context.coordinator.buildWebView()
        appState.registerWebView(wv, for: device.id)
        if let url = URL(string: appState.urlString) {
            wv.load(URLRequest(url: url))
        }
        return wv
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        if nsView.customUserAgent != device.userAgent {
            nsView.customUserAgent = device.userAgent
            nsView.reload()
        }
    }

    static func dismantleNSView(_ nsView: WKWebView, coordinator: Coordinator) {
        coordinator.appState.unregisterWebView(for: coordinator.device.id)
        nsView.configuration.userContentController.removeScriptMessageHandler(forName: "scrollSync")
    }

    class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        let device: DeviceModel
        let appState: AppState

        init(device: DeviceModel, appState: AppState) {
            self.device = device
            self.appState = appState
        }

        func buildWebView() -> WKWebView {
            let config = WKWebViewConfiguration()
            let ucc    = WKUserContentController()

            config.preferences.setValue(true, forKey: "developerExtrasEnabled")

            let scrollJS = """
            (function(){
                var ticking = false;
                document.addEventListener('scroll', function(){
                    if(ticking) return;
                    ticking = true;
                    requestAnimationFrame(function(){
                        ticking = false;
                        var el  = document.documentElement;
                        var mxX = Math.max(1, el.scrollWidth  - window.innerWidth);
                        var mxY = Math.max(1, el.scrollHeight - window.innerHeight);
                        try {
                            window.webkit.messageHandlers.scrollSync.postMessage({
                                x: window.scrollX / mxX,
                                y: window.scrollY / mxY
                            });
                        } catch(e){}
                    });
                }, { passive: true, capture: true });
            })();
            """
            let script = WKUserScript(source: scrollJS, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            ucc.addUserScript(script)
            ucc.add(self, name: "scrollSync")
            config.userContentController = ucc
            config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")

            let wv = WKWebView(frame: .zero, configuration: config)
            wv.customUserAgent = device.userAgent
            wv.navigationDelegate = self
            wv.allowsBackForwardNavigationGestures = true
            return wv
        }

        func userContentController(_ userContentController: WKUserContentController,
                                   didReceive message: WKScriptMessage) {
            guard message.name == "scrollSync",
                  appState.syncScrollEnabled,
                  let body = message.body as? [String: Double],
                  let x = body["x"], let y = body["y"]
            else { return }
            appState.propagateScroll(x: x, y: y, excludingDevice: device.id)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {}

        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            decisionHandler(.allow)
        }
    }
}

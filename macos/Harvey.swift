import Cocoa
import WebKit

class AppDelegate: NSObject, NSApplicationDelegate, WKNavigationDelegate, WKUIDelegate {
    var window: NSWindow!
    var web: WKWebView!
    var server: Process?
    let root = Bundle.main.object(forInfoDictionaryKey: "HarveyWorkspaceRoot") as? String ?? (NSHomeDirectory() + "/Work/GitHub/harvey")
    let base = "http://127.0.0.1:15555"
    var attempts = 0
    func applicationDidFinishLaunching(_ notification: Notification) {
        let menu = NSMenu()
        let item = NSMenuItem(); menu.addItem(item)
        let submenu = NSMenu(); item.submenu = submenu
        submenu.addItem(withTitle: "Quit Harvey", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        NSApp.mainMenu = menu
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1280, height: 840), styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: false)
        window.title = "Harvey"; window.center()
        web = WKWebView(frame: .zero); web.navigationDelegate = self; web.uiDelegate = self
        window.contentView = web
        web.loadHTMLString("<body style='font:20px -apple-system;padding:60px'>Starting Harvey…</body>", baseURL: nil)
        window.makeKeyAndOrderFront(nil); NSApp.activate(ignoringOtherApps: true)
        let process = Process()
        process.executableURL = URL(fileURLWithPath: root + "/.venv/bin/python")
        process.currentDirectoryURL = URL(fileURLWithPath: root)
        process.arguments = ["-c", "from harvey.dashboard import app, token_store; from harvey.state import StateManager; import asyncio, uvicorn; asyncio.run(StateManager().init_db()); token_store.get(); uvicorn.run(app, host='127.0.0.1', port=15555, log_level='warning', proxy_headers=False, server_header=False, date_header=False)"]
        var env = ProcessInfo.processInfo.environment
        env["PATH"] = root + "/.venv/bin:" + NSHomeDirectory() + "/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        process.environment = env
        let log = NSHomeDirectory() + "/Library/Logs/Harvey.log"
        if !FileManager.default.fileExists(atPath: log) { FileManager.default.createFile(atPath: log, contents: nil, attributes: [.posixPermissions: 0o600]) }
        let handle = FileHandle(forWritingAtPath: log)!
        handle.seekToEndOfFile(); process.standardOutput = handle; process.standardError = handle
        do { try process.run(); server = process; ready() }
        catch { fail(error.localizedDescription) }
    }
    func ready() {
        attempts += 1
        if let process = server, !process.isRunning { fail("The dashboard could not start. See ~/Library/Logs/Harvey.log."); return }
        URLSession.shared.dataTask(with: URL(string: base + "/")!) { _, response, _ in
            DispatchQueue.main.async {
                if let response = response as? HTTPURLResponse, response.statusCode == 200,
                   let token = try? String(contentsOfFile: self.root + "/data/dashboard-token", encoding: .utf8) {
                    self.web.load(URLRequest(url: URL(string: self.base + "/#token=" + token.trimmingCharacters(in: .whitespacesAndNewlines))!))
                } else if self.attempts < 120 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.ready() }
                } else { self.fail("The dashboard did not respond. See ~/Library/Logs/Harvey.log.") }
            }
        }.resume()
    }
    func fail(_ message: String) { let alert = NSAlert(); alert.messageText = "Harvey could not start"; alert.informativeText = message; alert.runModal(); NSApp.terminate(nil) }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else { decisionHandler(.cancel); return }
        if url.scheme == "about" || (url.host == "127.0.0.1" && url.port == 15555) { decisionHandler(.allow) }
        else { NSWorkspace.shared.open(url); decisionHandler(.cancel) }
    }
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url { NSWorkspace.shared.open(url) }; return nil
    }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
    func applicationWillTerminate(_ notification: Notification) { if let process = server, process.isRunning { process.terminate() } }
}
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.run()

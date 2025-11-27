import AppKit
import SwiftUI
import ApplicationServices

final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var controller: AppController?
    var statusItem: NSStatusItem?
    private var preferencesWindow: NSWindow?
    func applicationDidFinishLaunching(_ notification: Notification) {
        controller = AppController()
        NSApp.setActivationPolicy(.accessory)
        ensureAccessibilityPermission()
        setApplicationIconFromPublic()
        controller?.start()
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = item.button {
            let fm = FileManager.default
            if let base = Bundle.main.resourceURL {
                let png = base.appendingPathComponent("public/menubar.png")
                if fm.fileExists(atPath: png.path), let img = NSImage(contentsOf: png) {
                    let thickness = NSStatusBar.system.thickness
                    let target = NSSize(width: thickness - 4, height: thickness - 4)
                    img.size = target
                    img.isTemplate = true
                    button.image = img
                    button.imageScaling = .scaleProportionallyDown
                    button.imagePosition = .imageOnly
                    button.title = ""
                } else if let symbol = NSImage(systemSymbolName: "clipboard", accessibilityDescription: nil) {
                    symbol.isTemplate = true
                    button.image = symbol
                    button.title = ""
                } else {
                    button.title = "MiniClip"
                }
            } else if let symbol = NSImage(systemSymbolName: "clipboard", accessibilityDescription: nil) {
                symbol.isTemplate = true
                button.image = symbol
                button.title = ""
            } else {
                button.title = "MiniClip"
            }
        }
        item.menu = buildStatusMenu()
        statusItem = item
        observeLanguageChanges()
    }
    private func buildStatusMenu() -> NSMenu {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: L("panel.menu.panel"), action: #selector(openPanel), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: L("panel.menu.settings"), action: #selector(openSettings), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: L("panel.menu.quit"), action: #selector(quitApp), keyEquivalent: ""))
        return menu
    }
    private func observeLanguageChanges() {
        NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            if let item = self.statusItem { item.menu = self.buildStatusMenu() }
            if let w = self.preferencesWindow { w.title = L("window.settings.title") }
        }
    }
    private func ensureAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        let trusted = AXIsProcessTrustedWithOptions(options)
        if !trusted {
            let alert = NSAlert()
            alert.messageText = L("alert.accessibility.title")
            alert.informativeText = L("alert.accessibility.message")
            alert.addButton(withTitle: L("alert.accessibility.openSettings"))
            alert.addButton(withTitle: L("alert.accessibility.later"))
            let r = alert.runModal()
            if r == .alertFirstButtonReturn {
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                    NSWorkspace.shared.open(url)
                }
            }
        }
    }
    private func setApplicationIconFromPublic() {
        let fm = FileManager.default
        if let base = Bundle.main.resourceURL {
            let png = base.appendingPathComponent("public/logo.png")
            let icns = base.appendingPathComponent("public/logo.icns")
            if fm.fileExists(atPath: png.path), let img = NSImage(contentsOf: png) {
                NSApp.applicationIconImage = img
                return
            }
            if fm.fileExists(atPath: icns.path), let img = NSImage(contentsOf: icns) {
                NSApp.applicationIconImage = img
                return
            }
        }
    }
    @objc func openPanel() { controller?.panel.show() }
    @objc func openSettings() {
        NSApp.activate(ignoringOtherApps: true)
        let handled = NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        if !handled {
            if preferencesWindow == nil {
                let w = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 600, height: 460), styleMask: [.titled, .closable, .miniaturizable], backing: .buffered, defer: false)
                w.title = L("window.settings.title")
                w.isReleasedWhenClosed = false
                w.delegate = self
                let hosting = NSHostingView(rootView: SettingsView())
                hosting.translatesAutoresizingMaskIntoConstraints = false
                let content = NSView()
                content.translatesAutoresizingMaskIntoConstraints = false
                w.contentView = content
                content.addSubview(hosting)
                NSLayoutConstraint.activate([
                    hosting.leadingAnchor.constraint(equalTo: content.leadingAnchor),
                    hosting.trailingAnchor.constraint(equalTo: content.trailingAnchor),
                    hosting.topAnchor.constraint(equalTo: content.topAnchor),
                    hosting.bottomAnchor.constraint(equalTo: content.bottomAnchor)
                ])
                preferencesWindow = w
            }
            preferencesWindow?.center()
            preferencesWindow?.makeKeyAndOrderFront(nil)
        }
    }

    @objc func quitApp() { NSApp.terminate(nil) }

    func windowWillClose(_ notification: Notification) {
        if let w = notification.object as? NSWindow, w == preferencesWindow {
            preferencesWindow = nil
        }
    }
}

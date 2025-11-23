import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var controller: AppController?
    var statusItem: NSStatusItem?
    private var preferencesWindow: NSWindow?
    func applicationDidFinishLaunching(_ notification: Notification) {
        controller = AppController()
        controller?.start()
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        item.button?.title = "⇧⌘P"
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "打开面板", action: #selector(openPanel), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "设置", action: #selector(openSettings), keyEquivalent: ""))
        item.menu = menu
        statusItem = item
    }
    @objc func openPanel() { controller?.panel.show() }
    @objc func openSettings() {
        NSApp.activate(ignoringOtherApps: true)
        let handled = NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        if !handled {
            if preferencesWindow == nil {
                let w = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 600, height: 460), styleMask: [.titled, .closable, .miniaturizable], backing: .buffered, defer: false)
                w.title = "设置"
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

    func windowWillClose(_ notification: Notification) {
        if let w = notification.object as? NSWindow, w == preferencesWindow {
            preferencesWindow = nil
        }
    }
}

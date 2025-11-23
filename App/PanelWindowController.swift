import AppKit
import SwiftUI
import ApplicationServices

// 面板窗口控制器：创建半透明浮层窗口并处理显示/隐藏与定位
public final class PanelWindowController: NSObject, NSWindowDelegate {
    private var window: NSWindow?
    private var rootView: AnyView?
    private var outsideClickMonitor: Any?
    private var effectView: NSVisualEffectView?
    private var toastWindow: NSWindow?
    public override init() { super.init() }
    private func targetWidth() -> CGFloat {
        let s = activeScreen() ?? NSScreen.main
        guard let screen = s else { return 960 }
        return min(screen.visibleFrame.width * 0.8, 2048)
    }
    private func targetHeight() -> CGFloat {
        let raw = UserDefaults.standard.string(forKey: "historyLayoutStyle") ?? "horizontal"
        let style = HistoryLayoutStyle(rawValue: raw) ?? .horizontal
        switch style {
        case .horizontal: return 280
        case .grid: return 720
        }
    }
    // 设置 SwiftUI 根视图
    public func setRoot<V: View>(_ view: V) { rootView = AnyView(view) }
    public func show() {
        guard let rootView = rootView else { return }
        if window == nil {
            // 首次创建辅助窗口（utility）透明浮层，置于前台但不激活
            let w = NSPanel(contentRect: NSRect(x: 0, y: 0, width: targetWidth(), height: targetHeight()), styleMask: [.utilityWindow, .nonactivatingPanel], backing: .buffered, defer: false)
            w.isReleasedWhenClosed = false
            w.titleVisibility = .hidden
            w.titlebarAppearsTransparent = true
            w.isOpaque = false
            w.level = .statusBar
            w.collectionBehavior = [.transient, .moveToActiveSpace, .fullScreenAuxiliary, .ignoresCycle]
            w.isMovableByWindowBackground = false
            w.isFloatingPanel = true
            w.becomesKeyOnlyIfNeeded = true
            // HUD 材质效果与圆角
            let ev = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: targetWidth(), height: targetHeight()))
            ev.material = .hudWindow
            ev.blendingMode = .withinWindow
            ev.state = .active
            ev.wantsLayer = true
            ev.layer?.cornerRadius = 16
            ev.layer?.masksToBounds = true
            // 使用 NSHostingView 承载 SwiftUI 内容
            let hosting = NSHostingView(rootView: rootView)
            hosting.translatesAutoresizingMaskIntoConstraints = false
            ev.addSubview(hosting)
            NSLayoutConstraint.activate([
                hosting.leadingAnchor.constraint(equalTo: ev.leadingAnchor),
                hosting.trailingAnchor.constraint(equalTo: ev.trailingAnchor),
                hosting.topAnchor.constraint(equalTo: ev.topAnchor),
                hosting.bottomAnchor.constraint(equalTo: ev.bottomAnchor)
            ])
            w.contentView = ev
            effectView = ev
            w.backgroundColor = .clear
            w.hasShadow = false
            w.delegate = self
            window = w
        } else {
            let width = targetWidth()
            window?.setContentSize(NSSize(width: width, height: targetHeight()))
        }
        positionCenter()
        window?.orderFrontRegardless()
        // 安装失焦与外部点击自动隐藏行为
        installHidingBehavior()
    }
    public func hide() { window?.orderOut(nil) }
    public func toggle() {
        if window?.isVisible == true { hide() } else { show() }
    }
    public func updateLayoutHeight(animated: Bool = true) {
        guard let w = window else { return }
        let newH = targetHeight()
        var f = w.frame
        let delta = f.height - newH
        f.size.height = newH
        f.origin.y += delta / 2
        if animated {
            NSAnimationContext.runAnimationGroup { ctx in
                ctx.duration = 0.12
                (w.animator()).setFrame(f, display: true)
                effectView?.animator().setFrameSize(NSSize(width: f.size.width, height: newH))
            }
        } else {
            w.setFrame(f, display: true, animate: false)
            effectView?.setFrameSize(NSSize(width: f.size.width, height: newH))
        }
    }
    
    private func positionCenter() {
        guard let w = window else { return }
        let s = activeScreen() ?? NSScreen.main
        guard let screen = s else { return }
        let f = screen.visibleFrame
        let x = f.midX - (w.frame.width / 2)
        let y = f.midY - (w.frame.height / 2)
        w.setFrameOrigin(NSPoint(x: x, y: y))
    }

    private func activeScreen() -> NSScreen? {
        let p = NSEvent.mouseLocation
        for s in NSScreen.screens {
            if s.frame.contains(p) { return s }
        }
        return nil
    }
    private func installHidingBehavior() {
        if outsideClickMonitor == nil {
            // 全局监听鼠标点击以便面板自动隐藏
            outsideClickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
                guard let self = self else { return }
                if self.window?.isVisible == true { self.hide() }
            }
        }
        // 应用失活时隐藏面板
        NotificationCenter.default.addObserver(self, selector: #selector(appDidResignActive), name: NSApplication.didResignActiveNotification, object: nil)
    }
    @objc private func appDidResignActive() { hide() }
    public func windowDidResignKey(_ notification: Notification) { hide() }
    public func showToast(_ text: String, duration: TimeInterval = 1.6) {
        toastWindow?.orderOut(nil)
        toastWindow = nil
        let size = NSSize(width: 180, height: 180)
        let w = NSPanel(contentRect: NSRect(x: 0, y: 0, width: size.width, height: size.height), styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        w.isReleasedWhenClosed = false
        w.titleVisibility = .hidden
        w.titlebarAppearsTransparent = true
        w.isOpaque = false
        w.level = .statusBar
        w.collectionBehavior = [.transient, .moveToActiveSpace, .fullScreenAuxiliary]
        w.backgroundColor = .clear
        w.ignoresMouseEvents = true
        w.hasShadow = false
        let ev = NSVisualEffectView(frame: NSRect(origin: .zero, size: size))
        ev.material = .popover
        ev.blendingMode = .withinWindow
        ev.state = .active
        ev.wantsLayer = true
        ev.layer?.cornerRadius = 18
        ev.layer?.masksToBounds = true
        let v = AnyView(
            VStack(spacing: 10) {
                Image(systemName: "checkmark")
                    .font(.system(size: 56, weight: .semibold))
                    .foregroundColor(.secondary)
                Text(text)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        )
        let hosting = NSHostingView(rootView: v)
        hosting.translatesAutoresizingMaskIntoConstraints = false
        ev.addSubview(hosting)
        NSLayoutConstraint.activate([
            hosting.leadingAnchor.constraint(equalTo: ev.leadingAnchor),
            hosting.trailingAnchor.constraint(equalTo: ev.trailingAnchor),
            hosting.topAnchor.constraint(equalTo: ev.topAnchor),
            hosting.bottomAnchor.constraint(equalTo: ev.bottomAnchor)
        ])
        w.contentView = ev
        if let s = activeScreen() ?? NSScreen.main {
            let f = s.visibleFrame
            let x = f.midX - (size.width / 2)
            let y = f.midY - (size.height / 2)
            w.setFrameOrigin(NSPoint(x: x, y: y))
        }
        toastWindow = w
        w.orderFrontRegardless()
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            guard let self = self else { return }
            self.toastWindow?.orderOut(nil)
            self.toastWindow = nil
        }
    }
}
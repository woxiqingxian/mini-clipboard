import Foundation

// 隐私设置：屏幕共享时是否隐藏
public struct PrivacySettings: Codable, Equatable {
    public var hideOnScreenShare: Bool
    public init(hideOnScreenShare: Bool = true) { self.hideOnScreenShare = hideOnScreenShare }
}

// 快捷键设置：展示面板、快速粘贴、栈切换、纯文本粘贴
public struct Shortcuts: Codable, Equatable {
    public var showPanel: String
    public var quickPaste: [String]
    public var stackToggle: String
    public var pastePlainText: String
    public init(showPanel: String = "shift+cmd+p", quickPaste: [String] = ["cmd+1","cmd+2","cmd+3","cmd+4","cmd+5","cmd+6","cmd+7","cmd+8","cmd+9"], stackToggle: String = "shift+cmd+c", pastePlainText: String = "shift+return") {
        self.showPanel = showPanel
        self.quickPaste = quickPaste
        self.stackToggle = stackToggle
        self.pastePlainText = pastePlainText
    }
}

// 应用设置：历史保留、忽略应用、同步开关、隐私与快捷键
public struct AppSettings: Codable, Equatable {
    public var historyRetentionDays: Int
    public var ignoredApps: [String]
    public var syncEnabled: Bool
    public var privacy: PrivacySettings
    public var shortcuts: Shortcuts
    public init(historyRetentionDays: Int = 30, ignoredApps: [String] = [], syncEnabled: Bool = false, privacy: PrivacySettings = PrivacySettings(), shortcuts: Shortcuts = Shortcuts()) {
        self.historyRetentionDays = historyRetentionDays
        self.ignoredApps = ignoredApps
        self.syncEnabled = syncEnabled
        self.privacy = privacy
        self.shortcuts = shortcuts
    }
}
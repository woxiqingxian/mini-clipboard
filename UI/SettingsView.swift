import SwiftUI

public struct SettingsView: View {
    @State private var settings = AppSettings()
    @AppStorage("historyLayoutStyle") private var layoutStyleRaw: String = "horizontal"
    private let settingsStore = SettingsStore()
    public init() {}
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("设置")
                .font(.system(size: 16, weight: .semibold))
            VStack(alignment: .leading, spacing: 8) {
                Text("通用")
                    .font(.system(size: 13, weight: .medium))
                VStack(spacing: 6) {
                    HStack {
                        Text("保留天数")
                            .font(.system(size: 13))
                            .frame(width: 80, alignment: .leading)
                        Spacer()
                        Stepper(value: $settings.historyRetentionDays, in: 7...365) {
                            Text("\(settings.historyRetentionDays)")
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                        }
                        .frame(width: 120)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                    HStack {
                        Text("历史布局")
                            .font(.system(size: 13))
                            .frame(width: 80, alignment: .leading)
                        Spacer()
                        Picker("", selection: Binding(get: { HistoryLayoutStyle(rawValue: layoutStyleRaw) ?? .horizontal }, set: { layoutStyleRaw = $0.rawValue })) {
                            Text("横向列表").tag(HistoryLayoutStyle.horizontal)
                            Text("网格布局").tag(HistoryLayoutStyle.grid)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 160)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                }
            }
            .padding(10)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
            )
            VStack(alignment: .leading, spacing: 8) {
                Text("快捷键")
                    .font(.system(size: 13, weight: .medium))
                VStack(spacing: 6) {
                    HStack {
                        Text("面板")
                            .font(.system(size: 13))
                            .frame(width: 80, alignment: .leading)
                        Spacer()
                        ShortcutRecorder(shortcut: Binding(get: { settings.shortcuts.showPanel }, set: { settings.shortcuts.showPanel = $0 }))
                            .frame(width: 160, height: 22)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                }
            }
            .padding(10)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
            )
            VStack(alignment: .leading, spacing: 8) {
                Text("声明")
                    .font(.system(size: 13, weight: .medium))
                VStack(spacing: 6) {
                    HStack {
                        Text("本软件开源，致力于提供简约、好看、丝滑的使用体验。")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                }
            }
            .padding(10)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
            )
        }
        .padding(10)
        .frame(maxWidth: 360)
        .controlSize(.small)
        .onAppear { settings = settingsStore.load() }
        .onChange(of: settings) { s in
            try? settingsStore.save(s)
            HotkeyService.shared?.unregisterAll()
            HotkeyService.shared?.registerShowPanel()
            HotkeyService.shared?.registerQuickPasteSlots()
            HotkeyService.shared?.registerStackToggle()
        }
    }
}
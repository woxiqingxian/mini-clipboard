import SwiftUI
import AppKit
import CoreImage
import Combine

// 历史时间轴视图：横向滚动展示剪贴条目的卡片列表
public struct HistoryTimelineView: View {
    public let items: [ClipItem]
    public let boards: [Pinboard]
    public let defaultBoardID: UUID
    public let onPaste: (ClipItem, Bool) -> Void
    public let onAddToBoard: (ClipItem, UUID) -> Void
    public let onDelete: (ClipItem) -> Void
    public let selectedItemID: UUID?
    public let onSelect: (ClipItem) -> Void
    public let onRename: (ClipItem, String) -> Void
    @AppStorage("historyLayoutStyle") private var layoutStyleRaw: String = "horizontal"
    public init(items: [ClipItem], boards: [Pinboard], defaultBoardID: UUID, onPaste: @escaping (ClipItem, Bool) -> Void, onAddToBoard: @escaping (ClipItem, UUID) -> Void, onDelete: @escaping (ClipItem) -> Void, selectedItemID: UUID?, onSelect: @escaping (ClipItem) -> Void, onRename: @escaping (ClipItem, String) -> Void) {
        self.items = items
        self.boards = boards
        self.defaultBoardID = defaultBoardID
        self.onPaste = onPaste
        self.onAddToBoard = onAddToBoard
        self.onDelete = onDelete
        self.selectedItemID = selectedItemID
        self.onSelect = onSelect
        self.onRename = onRename
    }
    public var body: some View {
        Group {
            if layoutStyle == .horizontal {
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 12) {
                        ForEach(items) { item in
                            ItemCardView(item: item, boards: boards, defaultBoardID: defaultBoardID, onPaste: onPaste, onAddToBoard: onAddToBoard, onDelete: onDelete, selectedItemID: selectedItemID, onSelect: onSelect, onRename: onRename, cardWidth: gridCardWidth)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(columns: gridColumns, alignment: .leading, spacing: 12) {
                        ForEach(items) { item in
                            ItemCardView(item: item, boards: boards, defaultBoardID: defaultBoardID, onPaste: onPaste, onAddToBoard: onAddToBoard, onDelete: onDelete, selectedItemID: selectedItemID, onSelect: onSelect, onRename: onRename, cardWidth: gridCardWidth)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
    private func title(for item: ClipItem) -> String { item.text ?? item.contentRef?.lastPathComponent ?? "Item" }
    private var layoutStyle: HistoryLayoutStyle { HistoryLayoutStyle(rawValue: layoutStyleRaw) ?? .horizontal }
    private var gridCardWidth: CGFloat { 240 }
    private var gridColumns: [GridItem] { [GridItem(.adaptive(minimum: gridCardWidth, maximum: gridCardWidth), spacing: 12)] }
}

private struct ItemCardView: View {
    let item: ClipItem
    let boards: [Pinboard]
    let defaultBoardID: UUID
    let onPaste: (ClipItem, Bool) -> Void
    let onAddToBoard: (ClipItem, UUID) -> Void
    let onDelete: (ClipItem) -> Void
    let selectedItemID: UUID?
    let onSelect: (ClipItem) -> Void
    let onRename: (ClipItem, String) -> Void
    var cardWidth: CGFloat = 240
    @State private var hovering = false
    @State private var showNamePopover = false
    @State private var nameInput: String = ""
    @FocusState private var nameFocused: Bool
    @State private var hoverPaste = false
    @State private var hoverPlain = false
    @State private var hoverDelete = false
    @State private var hoverMenu = false
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(spacing: 0) {
                ZStack {
                    Rectangle()
                        .fill(headerGradient)
                    HStack {
                        Text(item.name)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        nameInput = item.name
                        showNamePopover = true
                        DispatchQueue.main.async { nameFocused = true }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                }
                .frame(height: 36)
                .popover(isPresented: $showNamePopover) {
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("名称", text: $nameInput)
                            .textFieldStyle(.roundedBorder)
                            .focused($nameFocused)
                            .onSubmit {
                                let n = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
                                if !n.isEmpty { onRename(item, n) }
                                showNamePopover = false
                            }
                        HStack {
                            Spacer()
                            Button("保存") {
                                let n = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
                                if !n.isEmpty { onRename(item, n) }
                                showNamePopover = false
                            }
                            Button("取消") { showNamePopover = false }
                        }
                    }
                    .padding(12)
                    .frame(width: 260)
                }
                VStack(alignment: .leading, spacing: 8) {
                    contentPreview
                    Spacer()
                    HStack {
                        Text("\(characterCount) characters")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(relativeTime)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .background(
                        GeometryReader { g in
                            Color.clear.preference(key: SizePreferenceKey.self, value: g.size)
                        }
                    )
                }
                .padding(12)
                .onPreferenceChange(SizePreferenceKey.self) { s in
                    metaHeight = s.height
                }
                .background(
                    GeometryReader { g in
                        Color.clear
                            .onAppear { contentHeight = g.size.height }
                            .onChange(of: g.size) { contentHeight = $0.height }
                    }
                )
                if isSelected {
                    VStack(spacing: 0) {
                        Divider()
                        HStack(spacing: 14) {
                            Button { onPaste(item, false) } label: {
                                Image(systemName: "doc.on.clipboard")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.blue)
                                    .scaleEffect(hoverPaste ? 1.2 : 1.0)
                                    .animation(.spring(response: 0.2, dampingFraction: 0.85), value: hoverPaste)
                            }
                            .buttonStyle(.borderless)
                            .onHover { h in
                                hoverPaste = h
                                if h { NSCursor.pointingHand.set() } else { NSCursor.arrow.set() }
                            }
                            .help("复制到剪贴板")

                            Button { onPaste(item, true) } label: {
                                Image(systemName: "textformat")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.teal)
                                    .scaleEffect(hoverPlain ? 1.2 : 1.0)
                                    .animation(.spring(response: 0.2, dampingFraction: 0.85), value: hoverPlain)
                            }
                            .buttonStyle(.borderless)
                            .onHover { h in
                                hoverPlain = h
                                if h { NSCursor.pointingHand.set() } else { NSCursor.arrow.set() }
                            }
                            .help("以纯文本复制")

                            Button { onDelete(item) } label: {
                                Image(systemName: "trash")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.red)
                                    .scaleEffect(hoverDelete ? 1.2 : 1.0)
                                    .animation(.spring(response: 0.2, dampingFraction: 0.85), value: hoverDelete)
                            }
                            .buttonStyle(.borderless)
                            .onHover { h in
                                hoverDelete = h
                                if h { NSCursor.pointingHand.set() } else { NSCursor.arrow.set() }
                            }
                            .help("删除")

                            Menu {
                                ForEach(boards.filter { $0.id != defaultBoardID }) { b in
                                    Button(action: { onAddToBoard(item, b.id) }) {
                                        HStack(spacing: 8) {
                                            Circle()
                                                .fill(boardColor(b))
                                                .frame(width: 8, height: 8)
                                            Text(b.name)
                                        }
                                    }
                                }
                            } label: {
                                Image(systemName: "folder.badge.plus")
                                    .foregroundColor(.indigo)
                                    .imageScale(.medium)
                                    .scaleEffect(hoverMenu ? 1.2 : 1.0)
                                    .animation(.spring(response: 0.2, dampingFraction: 0.85), value: hoverMenu)
                                    .contentShape(Rectangle())
                            }
                            .menuStyle(.borderlessButton)
                            .onHover { h in
                                hoverMenu = h
                                if h { NSCursor.pointingHand.set() } else { NSCursor.arrow.set() }
                            }
                            .help("添加至分组")
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .frame(width: cardWidth, height: 220)
            .background(cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(borderColor, lineWidth: borderWidth)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(alignment: .topTrailing) {
                if let img = appIcon {
                    Image(nsImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.white.opacity(0.8), lineWidth: 1))
                        .padding(6)
                }
            }
            .shadow(color: isSelected ? Color.accentColor.opacity(0.35) : .clear, radius: 6, x: 0, y: 0)
            // .shadow(color: shadowColor, radius: hovering ? 8 : 4, x: 0, y: hovering ? 6 : 3)
            .scaleEffect(hovering ? 1.03 : 1.0)
            .onHover { hovering = $0 }
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: hovering)
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: isSelected)
            .highPriorityGesture(TapGesture(count: 2).onEnded { onPaste(item, false) })
            .simultaneousGesture(TapGesture(count: 1).onEnded { onSelect(item) })
        }
    }
    @ViewBuilder private var contentPreview: some View {
        switch item.type {
        case .image:
            if let u = item.contentRef, let img = NSImage(contentsOf: u) {
                let available = max(60, (contentHeight > 0 ? (contentHeight - metaHeight - 8) : 120))
                let cap = isSelected ? 86 : 120
                let h = min(available, CGFloat(cap))
                Image(nsImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .frame(height: h)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Text(mainTitle)
                    .font(.system(size: 13))
                    .lineLimit(max(1, Int(floor((contentHeight - metaHeight - 8) / textLineHeight))))
            }
        case .link:
            if let u = item.contentRef {
                Link(destination: u) {
                    Text(u.absoluteString)
                        .font(.system(size: 13))
                        .lineLimit(max(1, Int(floor((contentHeight - metaHeight - 8) / textLineHeight))))
                }
            } else {
                Text(mainTitle)
                    .font(.system(size: 13))
                    .lineLimit(max(1, Int(floor((contentHeight - metaHeight - 8) / textLineHeight))))
            }
        case .color:
            let available = max(60, (contentHeight > 0 ? (contentHeight - metaHeight - 8) : 120))
            let cap = isSelected ? 86 : 120
            let h = min(available, CGFloat(cap))
            let hex = item.metadata["colorHex"]
            let c: Color = {
                if let s = hex, !s.isEmpty { return colorFromString(s) }
                return headerColor
            }()
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(c)
                if let s = hex, !s.isEmpty {
                    Text(s)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(textColorForHex(s))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: h)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
            )
        case .text:
            let available = max(60, (contentHeight > 0 ? (contentHeight - metaHeight - 8) : 120))
            let cap = isSelected ? 86 : 120
            let h = min(available, CGFloat(cap))
            if let u = item.contentRef, let a = loadAttributedString(u) {
                Text(AttributedString(a))
                    .lineLimit(max(1, Int(floor((contentHeight - metaHeight - 8) / textLineHeight))))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: h, alignment: .topLeading)
            } else {
                Text(mainTitle)
                    .font(.system(size: 13))
                    .lineLimit(max(1, Int(floor((contentHeight - metaHeight - 8) / textLineHeight))))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: h, alignment: .topLeading)
            }
        default:
            Text(mainTitle)
                .font(.system(size: 13))
                .lineLimit(max(1, Int(floor((contentHeight - metaHeight - 8) / textLineHeight))))
        }
    }
    private var textLineHeight: CGFloat {
        let f = NSFont.systemFont(ofSize: 14)
        return f.ascender - f.descender + f.leading
    }
    private struct SizePreferenceKey: PreferenceKey {
        static var defaultValue: CGSize = .zero
        static func reduce(value: inout CGSize, nextValue: () -> CGSize) { value = nextValue() }
    }
    @State private var metaHeight: CGFloat = 0
    @State private var contentHeight: CGFloat = 0
    private var mainTitle: String { item.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? item.text! : (item.contentRef?.lastPathComponent ?? "Item") }
    private var typeIcon: String {
        switch item.type {
        case .text: return "text.alignleft"
        case .link: return "link"
        case .image: return "photo"
        case .file: return "doc"
        case .color: return "paintpalette"
        }
    }
    private var cardBackground: some View { Color.white }
    private var borderColor: Color { isSelected ? Color.accentColor.opacity(0.85) : Color.primary.opacity(0.06) }
    private var borderWidth: CGFloat { isSelected ? 2 : 0.8 }
    private var shadowColor: Color { Color.black.opacity(0.15) }
    private var isSelected: Bool { selectedItemID == item.id }
    private var gradientColors: [Color] {
        switch item.type {
        case .text: return [Color.blue, Color.indigo]
        case .link: return [Color.green, Color.teal]
        case .image: return [Color.pink, Color.orange]
        case .file: return [Color.gray, Color.blue]
        case .color: return [Color.purple, Color.cyan]
        }
    }
    private var headerColor: Color {
        if let img = appIcon, let c = averageColor(img) {
            var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            c.usingColorSpace(.deviceRGB)?.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
            let sAdj = min(max(s, 0.35), 0.55)
            let bAdj = min(max(b, 0.78), 0.88)
            let adj = NSColor(hue: h, saturation: sAdj, brightness: bAdj, alpha: 1.0)
            return Color(adj)
        }
        switch item.type {
        case .text: return .orange
        case .link: return .green
        case .image: return .pink
        case .file: return .blue
        case .color: return .purple
        }
    }
    private var headerGradient: LinearGradient {
        if let img = appIcon, let c = averageColor(img) {
            var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            c.usingColorSpace(.deviceRGB)?.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
            let sAdj = min(max(s, 0.55), 0.85)
            let bAdj = min(max(b, 0.80), 0.94)
            let c1 = NSColor(hue: h, saturation: sAdj * 0.95, brightness: min(bAdj + 0.05, 0.98), alpha: 1)
            let c2 = NSColor(hue: h, saturation: sAdj * 0.85, brightness: max(bAdj - 0.08, 0.70), alpha: 1)
            return LinearGradient(colors: [Color(c1), Color(c2)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        return LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    private var relativeTime: String {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .full
        return f.localizedString(for: item.copiedAt, relativeTo: Date())
    }
    private var characterCount: Int { (item.text ?? mainTitle).count }
    private var bundleID: String? { item.metadata["bundleID"] ?? NSWorkspace.shared.runningApplications.first(where: { $0.localizedName == item.sourceApp })?.bundleIdentifier }
    private var appIcon: NSImage? {
        guard let bid = bundleID, let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bid) else { return nil }
        return NSWorkspace.shared.icon(forFile: url.path)
    }
    private func boardColor(_ b: Pinboard) -> Color {
        guard let s = b.color?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(), !s.isEmpty else { return .accentColor }
        switch s {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "blue": return .blue
        case "indigo": return .indigo
        case "purple": return .purple
        case "pink": return .pink
        default:
            let hex = s.hasPrefix("#") ? String(s.dropFirst()) : s
            if hex.count == 6, let v = Int(hex, radix: 16) {
                let r = Double((v >> 16) & 0xFF) / 255.0
                let g = Double((v >> 8) & 0xFF) / 255.0
                let b = Double(v & 0xFF) / 255.0
                return Color(red: r, green: g, blue: b)
            }
            return .accentColor
        }
    }
    private func averageColor(_ nsImage: NSImage) -> NSColor? {
        guard let tiff = nsImage.tiffRepresentation, let ciImage = CIImage(data: tiff) else { return nil }
        let extent = ciImage.extent
        let filter = CIFilter(name: "CIAreaAverage")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height), forKey: kCIInputExtentKey)
        guard let output = filter?.value(forKey: kCIOutputImageKey) as? CIImage else { return nil }
        var bitmap = [UInt8](repeating: 0, count: 4)
        let ctx = CIContext(options: nil)
        ctx.render(output, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
        return NSColor(red: CGFloat(bitmap[0]) / 255.0, green: CGFloat(bitmap[1]) / 255.0, blue: CGFloat(bitmap[2]) / 255.0, alpha: CGFloat(bitmap[3]) / 255.0)
    }
    private func colorFromString(_ s: String) -> Color {
        let v = s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if v.isEmpty { return .accentColor }
        switch v {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "blue": return .blue
        case "indigo": return .indigo
        case "purple": return .purple
        case "pink": return .pink
        default:
            let hex = v.hasPrefix("#") ? String(v.dropFirst()) : v
            if hex.count == 6, let iv = Int(hex, radix: 16) {
                let r = Double((iv >> 16) & 0xFF) / 255.0
                let g = Double((iv >> 8) & 0xFF) / 255.0
                let b = Double(iv & 0xFF) / 255.0
                return Color(red: r, green: g, blue: b)
            }
            return .accentColor
        }
    }
    private func textColorForHex(_ s: String) -> Color {
        let v = s.trimmingCharacters(in: .whitespacesAndNewlines)
        let hex = v.hasPrefix("#") ? String(v.dropFirst()) : v
        if hex.count == 6, let iv = Int(hex, radix: 16) {
            let r = Double((iv >> 16) & 0xFF)
            let g = Double((iv >> 8) & 0xFF)
            let b = Double(iv & 0xFF)
            let luma = 0.299 * r + 0.587 * g + 0.114 * b
            return luma > 186 ? .black : .white
        }
        return .primary
    }
    private func loadAttributedString(_ url: URL) -> NSAttributedString? {
        if let a = try? NSAttributedString(url: url, options: [:], documentAttributes: nil) { return a }
        if let d = try? Data(contentsOf: url), let a = try? NSAttributedString(data: d, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) { return a }
        if let d = try? Data(contentsOf: url), let a = NSAttributedString(rtf: d, documentAttributes: nil) { return a }
        return nil
    }
}

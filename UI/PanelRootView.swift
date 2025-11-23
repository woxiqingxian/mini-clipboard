import SwiftUI
import AppKit

struct PanelRootView: View {
    @ObservedObject var controller: AppController
    @State private var showSearchPopover: Bool = false
    @FocusState private var searchPopoverFocused: Bool
    @State private var tab: Int = 0
    @State private var sidebarWidth: CGFloat = 180
    @State private var dragStartWidth: CGFloat = 180
    @State private var isDragging: Bool = false
    @State private var showNewBoardPopover: Bool = false
    @State private var newBoardName: String = ""
    @State private var editingBoard: Pinboard?
    @State private var showRenamePopover: Bool = false
    @State private var showColorPopover: Bool = false
    @State private var renameInput: String = ""
    @State private var colorInput: String = ""
    @AppStorage("historyLayoutStyle") private var layoutStyleRaw: String = "horizontal"
    var body: some View {
        ZStack(alignment: .top) {
            HStack(spacing: 0) {
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "magnifyingglass")
                    SearchPopoverField(text: $controller.query)
                    if !controller.query.isEmpty {
                        Button(action: { controller.query = ""; controller.refresh() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.borderless)
                    }
                    Button(action: { showNewBoardPopover = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .buttonStyle(.borderless)
                    .popover(isPresented: $showNewBoardPopover) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("新增收藏分组").font(.system(size: 13, weight: .medium))
                            TextField("名称", text: $newBoardName)
                                .textFieldStyle(.roundedBorder)
                                .onSubmit {
                                    let name = newBoardName.trimmingCharacters(in: .whitespacesAndNewlines)
                                    let presetColors = ["red","orange","yellow","green","blue","indigo","purple","pink"]
                                    let randomColor = presetColors.randomElement()
                                    _ = controller.store.createPinboard(name: name.isEmpty ? "新分组" : name, color: randomColor)
                                    controller.refresh()
                                    showNewBoardPopover = false
                                    newBoardName = ""
                                }
                            HStack {
                                Spacer()
                                Button("取消") { showNewBoardPopover = false; newBoardName = "" }
                                Button("添加") {
                                    let name = newBoardName.trimmingCharacters(in: .whitespacesAndNewlines)
                                    let presetColors = ["red","orange","yellow","green","blue","indigo","purple","pink"]
                                    let randomColor = presetColors.randomElement()
                                    _ = controller.store.createPinboard(name: name.isEmpty ? "新分组" : name, color: randomColor)
                                    controller.refresh()
                                    showNewBoardPopover = false
                                    newBoardName = ""
                                }
                                .keyboardShortcut(.defaultAction)
                            }
                        }
                        .padding(12)
                        .frame(width: 220)
                    }
                    Button(action: {
                        layoutStyleRaw = ((HistoryLayoutStyle(rawValue: layoutStyleRaw) ?? .horizontal) == .horizontal ? HistoryLayoutStyle.grid.rawValue : HistoryLayoutStyle.horizontal.rawValue)
                        controller.panel.updateLayoutHeight(animated: true)
                    }) {
                        Image(systemName: ((HistoryLayoutStyle(rawValue: layoutStyleRaw) ?? .horizontal) == .horizontal) ? "square.grid.2x2" : "list.bullet.rectangle")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .buttonStyle(.borderless)
                }
                .padding(.horizontal, 12)
                .frame(height: 32)
                .background(.thickMaterial)
                .clipShape(Capsule())
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(controller.boards) { b in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(boardColor(b))
                                    .frame(width: 10, height: 10)
                                Text(b.name)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(.primary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background((controller.selectedBoardID == b.id) ? .thickMaterial : .ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .contextMenu {
                                if b.id == controller.store.defaultBoardID {
                                    Text("默认分组不可更改")
                                } else {
                                    Button("编辑名称…") {
                                        editingBoard = b
                                        renameInput = b.name
                                        showRenamePopover = true
                                    }
                                    Button("修改颜色…") {
                                        editingBoard = b
                                        colorInput = b.color ?? ""
                                        showColorPopover = true
                                    }
                                    Divider()
                                    Button("删除分组") {
                                        try? controller.store.deletePinboard(b.id)
                                        controller.refresh()
                                    }
                                }
                            }
                            .onTapGesture { controller.selectBoard(b.id) }
                            .popover(isPresented: Binding(get: { showRenamePopover && editingBoard?.id == b.id }, set: { v in showRenamePopover = v })) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("重命名").font(.system(size: 13, weight: .medium))
                                    TextField("名称", text: $renameInput)
                                        .textFieldStyle(.roundedBorder)
                                        .onSubmit {
                                            let name = renameInput.trimmingCharacters(in: .whitespacesAndNewlines)
                                            if let id = editingBoard?.id { controller.store.updatePinboardName(id, name: name.isEmpty ? "未命名" : name) }
                                            controller.refresh()
                                            showRenamePopover = false
                                        }
                                    HStack {
                                        Spacer()
                                        Button("取消") { showRenamePopover = false }
                                        Button("保存") {
                                            let name = renameInput.trimmingCharacters(in: .whitespacesAndNewlines)
                                            if let id = editingBoard?.id { controller.store.updatePinboardName(id, name: name.isEmpty ? "未命名" : name) }
                                            controller.refresh()
                                            showRenamePopover = false
                                        }.keyboardShortcut(.defaultAction)
                                    }
                                }
                                .padding(12)
                                .frame(width: 220)
                            }
                            .popover(isPresented: Binding(get: { showColorPopover && editingBoard?.id == b.id }, set: { v in showColorPopover = v })) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("分组颜色").font(.system(size: 13, weight: .medium))
                                    HStack(spacing: 8) {
                                        ForEach(["red","orange","yellow","green","blue","indigo","purple","pink"], id: \.self) { c in
                                            Circle()
                                                .fill(boardColor(Pinboard(name: "", color: c)))
                                                .frame(width: 16, height: 16)
                                                .onTapGesture {
                                                    if let id = editingBoard?.id { controller.store.updatePinboardColor(id, color: c) }
                                                    controller.refresh()
                                                    showColorPopover = false
                                                }
                                        }
                                        Button("清除") {
                                            if let id = editingBoard?.id { controller.store.updatePinboardColor(id, color: nil) }
                                            controller.refresh()
                                            showColorPopover = false
                                        }
                                    }
                                    TextField("十六进制，例如 #FF8800", text: $colorInput)
                                        .textFieldStyle(.roundedBorder)
                                    HStack {
                                        Spacer()
                                        Button("取消") { showColorPopover = false }
                                        Button("保存") {
                                            var s = colorInput.trimmingCharacters(in: .whitespacesAndNewlines)
                                            if s.isEmpty { s = "" }
                                            if let id = editingBoard?.id { controller.store.updatePinboardColor(id, color: s.isEmpty ? nil : s) }
                                            controller.refresh()
                                            showColorPopover = false
                                        }.keyboardShortcut(.defaultAction)
                                    }
                                }
                                .padding(12)
                                .frame(width: 260)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
                }
            }
            .padding(12)
            .frame(width: sidebarWidth)
            ZStack {
                Rectangle()
                    .fill(Color.secondary.opacity(0.25))
                    .frame(width: 1)
                    .frame(maxHeight: .infinity)
            }
                .frame(width: 8)
                .frame(maxHeight: .infinity)
                .contentShape(Rectangle())
                .onHover { hovering in
                    if !isDragging {
                        if hovering { NSCursor.resizeLeftRight.set() } else { NSCursor.arrow.set() }
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .global)
                        .onChanged { value in
                            if !isDragging { isDragging = true; dragStartWidth = sidebarWidth }
                            let minW: CGFloat = 180
                            let maxW: CGFloat = 480
                            let newW = dragStartWidth + value.translation.width
                            sidebarWidth = max(minW, min(maxW, newW))
                        }
                        .onEnded { _ in
                            isDragging = false
                            NSCursor.arrow.set()
                        }
                )
                VStack(spacing: 0) {
                    HistoryTimelineView(items: controller.items, boards: controller.boards, defaultBoardID: controller.store.defaultBoardID, onPaste: { item, plain in controller.pasteItem(item, plain: plain) }, onAddToBoard: { item, bid in controller.addToBoard(item, bid) }, onDelete: { item in controller.deleteItem(item) }, selectedItemID: controller.selectedItemID, onSelect: { item in controller.selectItem(item) }, onRename: { item, name in controller.renameItem(item, name: name) })
                        .animation(.easeInOut(duration: 0.35), value: controller.items)
                        .animation(.easeInOut(duration: 0.35), value: layoutStyleRaw)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onChange(of: layoutStyleRaw) { _ in controller.panel.updateLayoutHeight(animated: true) }
        .frame(minWidth: 880, minHeight: 290)
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
}
struct SearchPopoverField: View {
    @Binding var text: String
    @State private var show: Bool = false
    @FocusState private var focused: Bool
    var body: some View {
        ZStack {
            TextField("搜索", text: $text)
                .textFieldStyle(.plain)
                .frame(maxWidth: .infinity)
                .onSubmit { }
                .allowsHitTesting(false)
            Rectangle()
                .fill(Color.clear)
                .contentShape(Rectangle())
                .onTapGesture { show = true; DispatchQueue.main.async { focused = true } }
        }
        .popover(isPresented: $show) {
            VStack(alignment: .leading, spacing: 8) {
                TextField("搜索", text: $text)
                    .textFieldStyle(.roundedBorder)
                    .focused($focused)
                    .onSubmit { }
                HStack {
                    Spacer()
                    Button("关闭") { show = false }
                }
            }
            .padding(12)
            .frame(width: 280)
        }
    }
}

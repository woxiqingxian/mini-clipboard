import SwiftUI
import Combine

final class AppController: ObservableObject {
    let store: IndexStore
    let monitor: ClipboardMonitor
    let paste: PasteService
    let hotkeys: HotkeyService
    let panel: PanelWindowController
    @Published var items: [ClipItem] = []
    @Published var query: String = ""
    @Published var filters: SearchFilters = SearchFilters()
    @Published var boards: [Pinboard] = []
    @Published var selectedBoardID: UUID?
    @Published var selectedItemID: UUID?
    private let search: SearchService
    private var cancellables: Set<AnyCancellable> = []
    init() {
        store = IndexStore()
        monitor = ClipboardMonitor()
        paste = PasteService()
        hotkeys = HotkeyService()
        panel = PanelWindowController()
        search = SearchService(store: store)
        if let bid = Bundle.main.bundleIdentifier { monitor.setIgnoredApps([bid]) }
        monitor.onItemCaptured = { [weak self] item in
            try? self?.store.save(item)
            self?.paste.pushToStack(item)
            self?.refresh()
        }
        hotkeys.onShowPanel = { [weak self] in self?.panel.toggle() }
        hotkeys.onQuickPaste = { [weak self] idx, plain in
            guard let self = self else { return }
            let list = self.search.search(self.query, filters: self.filters, limit: 100)
            if idx-1 < list.count {
                self.monitor.suppressCaptures(for: 1.0)
                self.paste.paste(list[idx-1], plainText: plain)
            }
        }
        hotkeys.onStackToggle = { [weak self] in
            guard let self = self else { return }
            self.paste.activateStack(directionAsc: true)
        }
        panel.setRoot(PanelRootView(controller: self))
        selectedBoardID = store.defaultBoardID

        $query
            .debounce(for: .milliseconds(250), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] _ in self?.refresh() }
            .store(in: &cancellables)
    }
    
    func start() {
        monitor.start()
        hotkeys.registerShowPanel()
        hotkeys.registerQuickPasteSlots()
        hotkeys.registerStackToggle()
        refresh()
    }
    func refresh() {
        if let bid = selectedBoardID, bid != store.defaultBoardID {
            var r = store.listItems(in: bid)
            if !filters.types.isEmpty { r = r.filter { filters.types.contains($0.type) } }
            if !filters.sourceApps.isEmpty { r = r.filter { filters.sourceApps.contains($0.sourceApp) } }
            if !query.isEmpty {
                let qs = query.lowercased()
                r = r.filter { ($0.text?.lowercased().contains(qs) ?? false) || ($0.metadata["url"]?.lowercased().contains(qs) ?? false) }
            }
            items = Array(r.prefix(200))
        } else {
            items = search.search(query, filters: filters, limit: 200)
        }
        boards = store.listPinboards()
    }
    func pasteItem(_ item: ClipItem, plain: Bool) {
        monitor.suppressCaptures(for: 1.0)
        paste.paste(item, plainText: plain)
        panel.hide()
        let msg = plain ? "已复制为纯文本" : "已复制到剪贴板"
        panel.showToast(msg)
    }
    func addToBoard(_ item: ClipItem, _ boardID: UUID) {
        try? store.pin(item.id, to: boardID)
        refresh()
        panel.showToast("已添加到分组")
    }
    func deleteItem(_ item: ClipItem) {
        try? store.delete(item.id)
        if selectedItemID == item.id { selectedItemID = nil }
        refresh()
        panel.showToast("已删除")
    }
    func renameItem(_ item: ClipItem, name: String) {
        var updated = item
        updated.name = name
        try? store.save(updated)
        refresh()
    }
    func selectBoard(_ id: UUID) {
        selectedBoardID = id
        refresh()
    }
    func selectItem(_ item: ClipItem) {
        selectedItemID = item.id
    }
}
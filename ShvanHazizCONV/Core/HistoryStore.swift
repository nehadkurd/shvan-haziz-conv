import Foundation

final class HistoryStore: ObservableObject {
    @Published private(set) var items: [HistoryItem] = []

    private let key = "conv.history.v1"

    init() {
        load()
    }

    func add(_ item: HistoryItem) {
        items.insert(item, at: 0)
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([HistoryItem].self, from: data) else {
            items = []
            return
        }
        items = decoded
    }
}

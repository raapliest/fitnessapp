import Foundation

@MainActor
final class CustomExerciseStore: ObservableObject {
    @Published private(set) var items: [ExerciseLibraryItem] {
        didSet { persist() }
    }

    private let storageKey = "customExerciseLibraryItems"

    init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([ExerciseLibraryItem].self, from: data) {
            items = decoded
        } else {
            items = []
        }
    }

    func add(_ item: ExerciseLibraryItem) {
        items.insert(item, at: 0)
    }

    func update(_ item: ExerciseLibraryItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index] = item
    }

    func delete(_ item: ExerciseLibraryItem) {
        items.removeAll { $0.id == item.id }
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}

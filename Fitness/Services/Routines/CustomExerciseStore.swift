import Foundation

@MainActor
final class CustomExerciseStore: ObservableObject {
    @Published private(set) var items: [ExerciseLibraryItem] {
        didSet { persist() }
    }

    var userID: String = "guest"
    private let firestore = FirestoreService.shared

    init() {
        items = []
        loadLocal()
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

    func setUserID(_ userID: String) {
        self.userID = userID.isEmpty ? "guest" : userID
        loadLocal()
        Task { await fetchFromFirestore() }
    }

    func load() { loadLocal() }

    // MARK: - Private

    private func persist() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: localKey)
        firestore.save(items, userID: userID, store: "customExercises")
    }

    private func loadLocal() {
        if let data = UserDefaults.standard.data(forKey: localKey),
           let decoded = try? JSONDecoder().decode([ExerciseLibraryItem].self, from: data) {
            items = decoded
        } else {
            items = []
        }
    }

    private func fetchFromFirestore() async {
        guard let remote = await firestore.load([ExerciseLibraryItem].self, userID: userID, store: "customExercises") else { return }
        items = remote
        if let data = try? JSONEncoder().encode(remote) {
            UserDefaults.standard.set(data, forKey: localKey)
        }
    }

    var storageKey: String { localKey }
    private var localKey: String { "customExerciseLibraryItems.\(userID)" }
}

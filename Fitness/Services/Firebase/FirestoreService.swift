import Foundation
import FirebaseFirestore

// Simpan/ambil data tiap store sebagai JSON string di satu dokumen per user.
// Path: users/{uid}/stores/{storeName}
final class FirestoreService {
    static let shared = FirestoreService()

    private let db = Firestore.firestore()
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    private init() {
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    func save<T: Encodable>(_ value: T, userID: String, store: String) {
        guard !userID.isEmpty, userID != "guest" else { return }
        guard let data = try? encoder.encode(value),
              let payload = String(data: data, encoding: .utf8) else { return }
        let ref = db.document("users/\(userID)/stores/\(store)")
        ref.setData(["payload": payload, "updatedAt": FieldValue.serverTimestamp()]) { _ in }
    }

    func load<T: Decodable>(_ type: T.Type, userID: String, store: String) async -> T? {
        guard !userID.isEmpty, userID != "guest" else { return nil }
        guard let snapshot = try? await db.document("users/\(userID)/stores/\(store)").getDocument(),
              snapshot.exists,
              let payload = snapshot.data()?["payload"] as? String,
              let data = payload.data(using: .utf8) else { return nil }
        return try? decoder.decode(type, from: data)
    }
}

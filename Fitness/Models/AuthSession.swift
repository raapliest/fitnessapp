import Foundation

struct AuthSession: Equatable {
    var userID: String
    var email: String
    var displayName: String
    var provider: String

    static let empty = AuthSession(userID: "", email: "", displayName: "", provider: "")

    var isAuthenticated: Bool {
        !userID.isEmpty
    }
}

import Foundation

#if canImport(FirebaseAuth) && canImport(FirebaseCore)
import FirebaseAuth
import FirebaseCore
#endif

final class FirebaseAuthService: AuthServicing {
    func currentSession() async -> AuthSession {
        #if canImport(FirebaseAuth)
        if let user = Auth.auth().currentUser {
            return AuthSession(
                userID: user.uid,
                email: user.email ?? "",
                displayName: user.displayName ?? user.email ?? "Fitness User",
                provider: user.providerData.first?.providerID ?? "password"
            )
        }
        #endif
        return .empty
    }

    func signIn(email: String, password: String) async throws -> AuthSession {
        #if canImport(FirebaseAuth)
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return makeSession(from: result.user)
        #else
        return AuthSession(userID: email.lowercased(), email: email, displayName: email, provider: "local")
        #endif
    }

    func register(email: String, password: String) async throws -> AuthSession {
        #if canImport(FirebaseAuth)
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return makeSession(from: result.user)
        #else
        return AuthSession(userID: email.lowercased(), email: email, displayName: email, provider: "local")
        #endif
    }

    func signInWithGoogle() async throws -> AuthSession {
        throw NSError(
            domain: "FirebaseAuthService",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Google Sign-In still needs the GoogleSignIn package and iOS URL scheme setup."]
        )
    }

    func signOut() async throws {
        #if canImport(FirebaseAuth)
        try Auth.auth().signOut()
        #endif
    }

    #if canImport(FirebaseAuth)
    private func makeSession(from user: User) -> AuthSession {
        AuthSession(
            userID: user.uid,
            email: user.email ?? "",
            displayName: user.displayName ?? user.email ?? "Fitness User",
            provider: user.providerData.first?.providerID ?? "password"
        )
    }
    #endif
}

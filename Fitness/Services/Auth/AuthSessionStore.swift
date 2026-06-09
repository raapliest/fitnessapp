import Foundation

@MainActor
final class AuthSessionStore: ObservableObject {
    @Published private(set) var session: AuthSession = .empty
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let authService: AuthServicing

    init(authService: AuthServicing = FirebaseAuthService()) {
        self.authService = authService
    }

    func bootstrap() async {
        isLoading = true
        defer { isLoading = false }
        session = await authService.currentSession()
    }

    func signIn(email: String, password: String) async {
        await perform {
            try await self.authService.signIn(email: email, password: password)
        }
    }

    func register(email: String, password: String) async {
        await perform {
            try await self.authService.register(email: email, password: password)
        }
    }

    func signInWithGoogle() async {
        await perform {
            try await self.authService.signInWithGoogle()
        }
    }

    func signOut() async {
        await perform {
            try await self.authService.signOut()
            return .empty
        }
    }

    private func perform(_ action: @escaping () async throws -> AuthSession) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            session = try await action()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

protocol AuthServicing {
    func currentSession() async -> AuthSession
    func signIn(email: String, password: String) async throws -> AuthSession
    func register(email: String, password: String) async throws -> AuthSession
    func signInWithGoogle() async throws -> AuthSession
    func signOut() async throws
}

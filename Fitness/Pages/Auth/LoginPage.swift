import SwiftUI

struct LoginPage: View {
    @EnvironmentObject private var auth: AuthSessionStore

    @State private var email = ""
    @State private var password = ""
    @State private var isRegisterMode = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    formCard
                    actions
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.16),
                        Color(.systemBackground),
                        Color.green.opacity(0.12)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Sign In")
            .alert("Login Error", isPresented: Binding(
                get: { auth.errorMessage != nil },
                set: { if !$0 { auth.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {
                    auth.errorMessage = nil
                }
            } message: {
                Text(auth.errorMessage ?? "")
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Welcome back")
                .font(.largeTitle.bold())

            Text("Login pakai email/password atau Google. Setelah masuk, workout history dan chat history disimpan terpisah per uid.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }

    private var formCard: some View {
        VStack(spacing: 12) {
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textFieldStyle(.roundedBorder)

            SecureField("Password", text: $password)
                .textContentType(.password)
                .textFieldStyle(.roundedBorder)

            Toggle("Create new account", isOn: $isRegisterMode)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var actions: some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    if isRegisterMode {
                        await auth.register(email: email, password: password)
                    } else {
                        await auth.signIn(email: email, password: password)
                    }
                }
            } label: {
                Text(isRegisterMode ? "Create Account" : "Sign In")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(auth.isLoading || email.isEmpty || password.isEmpty)

            Button {
                Task { await auth.signInWithGoogle() }
            } label: {
                Label("Continue with Google", systemImage: "g.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(auth.isLoading)
        }
    }
}

import SwiftUI

struct ProfilePage: View {
    @EnvironmentObject private var profileStore: ProfileStore
    @EnvironmentObject private var auth: AuthSessionStore

    @State private var showSignOutConfirm = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Account") {
                    HStack {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.blue)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(profileStore.profile.displayName.isEmpty ? "Fitness User" : profileStore.profile.displayName)
                                .font(.headline)
                            Text(auth.session.email)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            if !auth.session.provider.isEmpty {
                                Text("via \(auth.session.provider)")
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                    .padding(.vertical, 4)

                    TextField("Display name", text: $profileStore.profile.displayName)
                        .textContentType(.name)
                }

                Section("Training profile") {
                    TextField("Goal", text: $profileStore.profile.goal)
                    Picker("Experience", selection: $profileStore.profile.experienceLevel) {
                        Text("Beginner").tag("Beginner")
                        Text("Intermediate").tag("Intermediate")
                        Text("Advanced").tag("Advanced")
                    }
                    TextField("Equipment", text: $profileStore.profile.equipment)
                    TextField("Limitations or injuries", text: $profileStore.profile.limitations, axis: .vertical)
                        .lineLimit(2...5)
                }

                Section {
                    Button(role: .destructive) {
                        showSignOutConfirm = true
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Profile")
            .confirmationDialog("Sign out from this account?", isPresented: $showSignOutConfirm, titleVisibility: .visible) {
                Button("Sign Out", role: .destructive) {
                    Task { await auth.signOut() }
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}

struct ProfilePage_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePage()
            .environmentObject(ProfileStore())
            .environmentObject(AuthSessionStore())
    }
}

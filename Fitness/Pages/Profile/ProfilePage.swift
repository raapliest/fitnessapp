import SwiftUI

struct ProfilePage: View {
    @EnvironmentObject private var profileStore: ProfileStore

    var body: some View {
        NavigationStack {
            Form {
                Section("Account") {
                    if profileStore.isLoggedIn {
                        Label("Signed in locally", systemImage: "person.crop.circle.fill.badge.checkmark")
                            .foregroundStyle(.green)
                    } else {
                        Label("Local profile", systemImage: "person.crop.circle")
                            .foregroundStyle(.secondary)
                    }

                    TextField("Name", text: $profileStore.profile.displayName)
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
                        profileStore.signOut()
                    } label: {
                        Label("Reset Profile", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

struct ProfilePage_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePage()
            .environmentObject(ProfileStore())
    }
}

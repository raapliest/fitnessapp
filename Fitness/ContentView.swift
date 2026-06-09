import SwiftUI

struct ContentView: View {
    @StateObject private var auth = AuthSessionStore()
    @StateObject private var settings = AppSettings()
    @StateObject private var healthKit = HealthKitManager()
    @StateObject private var historyStore = WorkoutHistoryStore()
    @StateObject private var workoutStore = DailyWorkoutStore()
    @StateObject private var chatStore = CoachChatStore()
    @StateObject private var profileStore = ProfileStore()
    @StateObject private var routineStore = RoutineStore()
    @StateObject private var customExerciseStore = CustomExerciseStore()
    @State private var selectedTab = FitnessTab.workout

    var body: some View {
        Group {
            if auth.session.isAuthenticated {
                TabView(selection: $selectedTab) {
                    WorkoutPage()
                        .environmentObject(settings)
                        .environmentObject(healthKit)
                        .environmentObject(historyStore)
                        .environmentObject(workoutStore)
                        .environmentObject(routineStore)
                        .environmentObject(customExerciseStore)
                        .tabItem {
                            Label("Workout", systemImage: "checklist")
                        }
                        .tag(FitnessTab.workout)

                    CoachPage()
                        .environmentObject(settings)
                        .environmentObject(healthKit)
                        .environmentObject(historyStore)
                        .environmentObject(workoutStore)
                        .environmentObject(chatStore)
                        .environmentObject(profileStore)
                        .tabItem {
                            Label("Coach", systemImage: "message.fill")
                        }
                        .tag(FitnessTab.coach)

                    FormCoachPage()
                        .tabItem {
                            Label("Camera", systemImage: "camera.viewfinder")
                        }
                        .tag(FitnessTab.camera)

                    ProfilePage()
                        .environmentObject(profileStore)
                        .environmentObject(auth)
                        .tabItem {
                            Label("Profile", systemImage: "person.crop.circle")
                        }
                        .tag(FitnessTab.profile)

                    SettingsPage()
                        .environmentObject(settings)
                        .environmentObject(healthKit)
                        .environmentObject(historyStore)
                        .environmentObject(chatStore)
                        .environmentObject(workoutStore)
                        .tabItem {
                            Label("Settings", systemImage: "gearshape")
                        }
                        .tag(FitnessTab.settings)
                }
            } else {
                LoginPage()
                    .environmentObject(auth)
            }
        }
        .environmentObject(auth)
        .task {
            await auth.bootstrap()
            syncUserScopedStores()
            if auth.session.isAuthenticated {
                await healthKit.requestAuthorization()
            }
        }
        .onChange(of: auth.session.userID) { _ in
            syncUserScopedStores()
            if auth.session.isAuthenticated {
                Task {
                    await healthKit.requestAuthorization()
                }
            }
        }
        .fullScreenCover(
            isPresented: Binding(
                get: { !settings.hasAcceptedMedicalDisclaimer },
                set: { isPresented in
                    if !isPresented {
                        settings.hasAcceptedMedicalDisclaimer = true
                    }
                }
            )
        ) {
            MedicalDisclaimerView {
                settings.hasAcceptedMedicalDisclaimer = true
            }
        }
    }

    private func syncUserScopedStores() {
        let userID = auth.session.isAuthenticated ? auth.session.userID : "guest"
        historyStore.setUserID(userID)
        workoutStore.setUserID(userID)
        chatStore.setUserID(userID)
        routineStore.setUserID(userID)
        customExerciseStore.setUserID(userID)
        profileStore.setUserID(userID)
        profileStore.populateIfEmpty(from: auth.session)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

import SwiftUI

struct ContentView: View {
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
        .task {
            await healthKit.requestAuthorization()
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

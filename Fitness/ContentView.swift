import SwiftUI

struct ContentView: View {
    @StateObject private var settings = AppSettings()
    @StateObject private var healthKit = HealthKitManager()
    @State private var selectedTab = FitnessTab.today

    var body: some View {
        TabView(selection: $selectedTab) {
            MainPage()
                .environmentObject(settings)
                .environmentObject(healthKit)
                .tabItem {
                    Label("Today", systemImage: "flame")
                }
                .tag(FitnessTab.today)

            CoachPage()
                .environmentObject(settings)
                .environmentObject(healthKit)
                .tabItem {
                    Label("Coach", systemImage: "figure.strengthtraining.traditional")
                }
                .tag(FitnessTab.coach)

            FormCoachPage()
                .tabItem {
                    Label("Form", systemImage: "camera.viewfinder")
                }
                .tag(FitnessTab.form)

            LaunchPage()
                .tabItem {
                    Label("Launch", systemImage: "checkmark.seal")
                }
                .tag(FitnessTab.launch)
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

import SwiftUI

struct LaunchPage: View {
    private let readinessItems = [
        ReadinessItem(title: "HealthKit purpose strings", detail: "Explains active-energy read access clearly.", isComplete: true),
        ReadinessItem(title: "Camera privacy string", detail: "Explains live form feedback and on-device analysis.", isComplete: true),
        ReadinessItem(title: "No required third-party SDKs", detail: "Keeps the first submission simpler.", isComplete: true),
        ReadinessItem(title: "Core ML upgrade path", detail: "Trainer scoring interface, rep counting, and movement-specific UI are ready for a compiled model.", isComplete: true),
        ReadinessItem(title: "Medical disclaimer", detail: "Onboarding copy appears before coaching guidance is shown.", isComplete: true),
        ReadinessItem(title: "Real device QA", detail: "Validate HealthKit and camera behavior on iPhone.", isComplete: false)
    ]

    private let deviceQAItems = [
        ReadinessItem(title: "Install on iPhone", detail: "Run a debug or TestFlight build on physical hardware.", isComplete: false),
        ReadinessItem(title: "HealthKit permission", detail: "Confirm the Apple Health prompt appears and denied access is handled clearly.", isComplete: false),
        ReadinessItem(title: "Active energy refresh", detail: "Compare Today active calories against the Health app after a workout or walk.", isComplete: false),
        ReadinessItem(title: "Camera permission", detail: "Confirm first-run permission, denied state, and front-camera startup.", isComplete: false),
        ReadinessItem(title: "Live form feedback", detail: "Verify squat, lunge, and plank scoring in good and low light.", isComplete: false)
    ]

    var body: some View {
        NavigationStack {
            List {
                Section("Launch readiness") {
                    ForEach(readinessItems) { item in
                        ReadinessRow(item: item)
                    }
                }

                Section("Real device QA") {
                    ForEach(deviceQAItems) { item in
                        ReadinessRow(item: item)
                    }
                }
            }
            .navigationTitle("Launch")
        }
    }
}

struct LaunchPage_Previews: PreviewProvider {
    static var previews: some View {
        LaunchPage()
    }
}

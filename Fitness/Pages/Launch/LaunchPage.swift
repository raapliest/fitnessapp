import SwiftUI

struct LaunchPage: View {
    private let items = [
        ReadinessItem(title: "HealthKit purpose strings", detail: "Explains active-energy read access clearly.", isComplete: true),
        ReadinessItem(title: "Camera privacy string", detail: "Explains live form feedback and on-device analysis.", isComplete: true),
        ReadinessItem(title: "No required third-party SDKs", detail: "Keeps the first submission simpler.", isComplete: true),
        ReadinessItem(title: "Core ML upgrade path", detail: "Add a trained model for rep counting and movement-specific scores.", isComplete: false),
        ReadinessItem(title: "Medical disclaimer", detail: "Add onboarding copy before shipping coaching guidance.", isComplete: false),
        ReadinessItem(title: "Real device QA", detail: "Validate HealthKit and camera behavior on iPhone.", isComplete: false)
    ]

    var body: some View {
        NavigationStack {
            List(items) { item in
                ReadinessRow(item: item)
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

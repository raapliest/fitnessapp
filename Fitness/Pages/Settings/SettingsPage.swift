import SwiftUI

struct SettingsPage: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var healthKit: HealthKitManager
    @EnvironmentObject private var historyStore: WorkoutHistoryStore
    @EnvironmentObject private var chatStore: CoachChatStore
    @EnvironmentObject private var workoutStore: DailyWorkoutStore

    private var hasGroqKey: Bool {
        let environment = ProcessInfo.processInfo.environment
        return ["GROQ_API_KEY", "GROQAI_API_KEY", "GROQ_KEY"].contains { key in
            !(environment[key] ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("AI") {
                    Label(
                        hasGroqKey ? "Groq connected" : "Groq key missing",
                        systemImage: hasGroqKey ? "checkmark.circle.fill" : "exclamationmark.triangle.fill"
                    )
                    .foregroundStyle(hasGroqKey ? .green : .orange)

                    Button(role: .destructive) {
                        chatStore.clear()
                    } label: {
                        Label("Clear Coach Chat", systemImage: "trash")
                    }
                }

                Section("Tools") {
                    NavigationLink {
                        HistoryPage()
                            .environmentObject(historyStore)
                    } label: {
                        Label("Progress", systemImage: "chart.xyaxis.line")
                    }

                    Button {
                        workoutStore.resetToday()
                    } label: {
                        Label("Reset Today's Workout", systemImage: "arrow.counterclockwise")
                    }
                }

                Section("Health") {
                    Text(healthKit.statusMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Button {
                        Task {
                            await healthKit.requestAuthorization()
                            await healthKit.refreshTodayMetrics()
                        }
                    } label: {
                        Label("Refresh Health Permissions", systemImage: "heart.text.square")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsPage_Previews: PreviewProvider {
    static var previews: some View {
        SettingsPage()
            .environmentObject(AppSettings())
            .environmentObject(HealthKitManager())
            .environmentObject(WorkoutHistoryStore())
            .environmentObject(CoachChatStore())
            .environmentObject(DailyWorkoutStore())
    }
}

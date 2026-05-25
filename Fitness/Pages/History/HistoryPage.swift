import SwiftUI

struct HistoryPage: View {
    @EnvironmentObject private var historyStore: WorkoutHistoryStore

    var body: some View {
        NavigationStack {
            List {
                if historyStore.recommendations.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "clock")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                            .accessibilityHidden(true)

                        Text("No Workouts Yet")
                            .font(.headline)

                        Text("Quick start a recommendation to save it here.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    ForEach(historyStore.recommendations) { recommendation in
                        NavigationLink {
                            WorkoutHistoryDetailPage(recommendation: recommendation)
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                WorkoutRecommendationRow(workout: recommendation)
                                Text(recommendation.generatedAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .destructive) {
                        historyStore.clear()
                    } label: {
                        Label("Clear History", systemImage: "trash")
                    }
                    .disabled(historyStore.recommendations.isEmpty)
                }
            }
        }
    }
}

struct HistoryPage_Previews: PreviewProvider {
    static var previews: some View {
        HistoryPage()
            .environmentObject(WorkoutHistoryStore())
    }
}

import SwiftUI

struct RoutineDetailPage: View {
    @EnvironmentObject private var routineStore: RoutineStore
    @EnvironmentObject private var historyStore: WorkoutHistoryStore
    @EnvironmentObject private var customExerciseStore: CustomExerciseStore
    @State private var routine: WorkoutRoutine
    @State private var isEditingRoutine = false

    init(routine: WorkoutRoutine) {
        _routine = State(initialValue: routine)
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(routine.note.isEmpty ? "Ready to train." : routine.note)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    NavigationLink {
                        RoutineSessionPage(routine: routine)
                            .environmentObject(routineStore)
                            .environmentObject(historyStore)
                    } label: {
                        Label("Start Workout", systemImage: "play.circle.fill")
                            .font(.headline)
                    }
                }
                .padding(.vertical, 4)
            }

            Section("Exercises") {
                ForEach(routine.exercises) { exercise in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(exercise.name)
                                .font(.headline)
                            Text(exercise.targetSummary)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(exercise.category)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle(routine.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isEditingRoutine = true
                } label: {
                    Label("Edit Routine", systemImage: "pencil")
                }
            }
        }
        .sheet(isPresented: $isEditingRoutine) {
            RoutineEditorPage(title: "Edit Routine", routine: routine) { updated in
                routine = updated
                routineStore.updateRoutine(updated)
            }
            .environmentObject(customExerciseStore)
        }
    }
}

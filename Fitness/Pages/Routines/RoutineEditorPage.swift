import SwiftUI

struct RoutineEditorPage: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var customExerciseStore: CustomExerciseStore
    let title: String
    let onSave: (WorkoutRoutine) -> Void

    @State private var routine: WorkoutRoutine
    @State private var isPickingExercise = false

    init(
        title: String,
        routine: WorkoutRoutine = WorkoutRoutine(name: "", exercises: []),
        onSave: @escaping (WorkoutRoutine) -> Void
    ) {
        self.title = title
        self.onSave = onSave
        _routine = State(initialValue: routine)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Routine") {
                    TextField("Routine name", text: $routine.name)
                    TextField("Note", text: $routine.note, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section("Exercises") {
                    ForEach($routine.exercises) { $exercise in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(exercise.name)
                                .font(.headline)

                            Stepper("Sets: \(exercise.targetSets)", value: $exercise.targetSets, in: 1...10)
                            TextField(exercise.trackingType.targetFieldLabel, text: $exercise.targetReps)
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { offsets in
                        routine.exercises.remove(atOffsets: offsets)
                    }

                    Button {
                        isPickingExercise = true
                    } label: {
                        Label("Add From Exercise List", systemImage: "list.bullet.rectangle")
                    }
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(routine)
                        dismiss()
                    }
                    .disabled(
                        routine.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                        routine.exercises.isEmpty
                    )
                }
            }
            .sheet(isPresented: $isPickingExercise) {
                ExercisePickerPage { item in
                    routine.exercises.append(
                        WorkoutRoutineExercise(
                            name: item.name,
                            category: item.category,
                            targetSets: item.category == "Cardio" ? 1 : 3,
                            targetReps: item.category == "Cardio" ? "10-20 min" : item.trackingType.defaultTarget,
                            trackingType: item.trackingType
                        )
                    )
                }
                .environmentObject(customExerciseStore)
            }
        }
    }
}

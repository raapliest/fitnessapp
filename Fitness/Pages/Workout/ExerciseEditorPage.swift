import SwiftUI

struct ExerciseEditorPage: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    let onSave: (WorkoutExercise) -> Void

    @State private var exercise: WorkoutExercise

    init(
        title: String,
        exercise: WorkoutExercise = WorkoutExercise(name: "", detail: "", sets: 3, reps: "10", minutes: 5),
        onSave: @escaping (WorkoutExercise) -> Void
    ) {
        self.title = title
        self.onSave = onSave
        _exercise = State(initialValue: exercise)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise") {
                    TextField("Name", text: $exercise.name)
                    TextField("Details", text: $exercise.detail, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section("Plan") {
                    Stepper("Sets: \(exercise.sets)", value: $exercise.sets, in: 1...10)
                    TextField("Reps", text: $exercise.reps)
                    Stepper("Minutes: \(exercise.minutes)", value: $exercise.minutes, in: 1...120)
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
                        onSave(exercise)
                        dismiss()
                    }
                    .disabled(exercise.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

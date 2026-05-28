import SwiftUI

struct RoutineSessionPage: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var routineStore: RoutineStore
    @EnvironmentObject private var historyStore: WorkoutHistoryStore
    let routine: WorkoutRoutine
    @State private var logs: [RoutineSetLog]
    @State private var didFinish = false

    init(routine: WorkoutRoutine) {
        self.routine = routine
        _logs = State(
            initialValue: routine.exercises.flatMap { exercise in
                (1...max(exercise.targetSets, 1)).map { setNumber in
                    RoutineSetLog(
                        exerciseID: exercise.id,
                        exerciseName: exercise.name,
                        setNumber: setNumber,
                        trackingType: exercise.trackingType
                    )
                }
            }
        )
    }

    var body: some View {
        List {
            ForEach(routine.exercises) { exercise in
                Section {
                    ForEach(logIndices(for: exercise), id: \.self) { index in
                        HStack(spacing: 12) {
                            Text("Set \(logs[index].setNumber)")
                                .font(.subheadline.bold())
                                .frame(width: 52, alignment: .leading)

                            if let loadFieldLabel = logs[index].trackingType.loadFieldLabel {
                                TextField(loadFieldLabel, text: $logs[index].kilograms)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.roundedBorder)
                            }

                            TextField(logs[index].trackingType.logFieldLabel, text: $logs[index].reps)
                                .keyboardType(logs[index].trackingType.usesNumericValueKeyboard ? .numberPad : .numbersAndPunctuation)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                } header: {
                    Text("\(exercise.name) • target \(exercise.targetReps)")
                }
            }
        }
        .navigationTitle(routine.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    finishWorkout()
                } label: {
                    Label("Finish Workout", systemImage: "checkmark.circle.fill")
                }
                .disabled(logs.allSatisfy { $0.kilograms.isEmpty && $0.reps.isEmpty })
            }
        }
        .alert("Workout saved", isPresented: $didFinish) {
            Button("Done") {
                dismiss()
            }
        } message: {
            Text("Your routine was added to Progress.")
        }
    }

    private func finishWorkout() {
        routineStore.saveFinishedSession(
            RoutineWorkoutSession(routineName: routine.name, logs: logs),
            to: historyStore
        )
        didFinish = true
    }

    private func logIndices(for exercise: WorkoutRoutineExercise) -> [Int] {
        logs.indices.filter { logs[$0].exerciseID == exercise.id }
    }
}

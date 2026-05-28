import SwiftUI

struct MyRoutinesPage: View {
    @EnvironmentObject private var routineStore: RoutineStore
    @EnvironmentObject private var historyStore: WorkoutHistoryStore
    @EnvironmentObject private var customExerciseStore: CustomExerciseStore
    @State private var isCreatingRoutine = false

    var body: some View {
        List {
            Section("Workout routines") {
                ForEach(routineStore.routines) { routine in
                    NavigationLink {
                        RoutineDetailPage(routine: routine)
                            .environmentObject(routineStore)
                            .environmentObject(historyStore)
                            .environmentObject(customExerciseStore)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(routine.name)
                                .font(.headline)

                            Text("\(routine.exercises.count) exercises")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            if !routine.note.isEmpty {
                                Text(routine.note)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete { offsets in
                    routineStore.deleteRoutine(at: offsets)
                }
            }
        }
        .navigationTitle("My Routine")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isCreatingRoutine = true
                } label: {
                    Label("New Routine", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isCreatingRoutine) {
            RoutineEditorPage(title: "New Routine") { routine in
                routineStore.addRoutine(routine)
            }
            .environmentObject(customExerciseStore)
        }
    }
}

struct MyRoutinesPage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MyRoutinesPage()
                .environmentObject(RoutineStore())
                .environmentObject(WorkoutHistoryStore())
                .environmentObject(CustomExerciseStore())
        }
    }
}

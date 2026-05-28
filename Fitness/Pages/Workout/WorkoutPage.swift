import SwiftUI

struct WorkoutPage: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var healthKit: HealthKitManager
    @EnvironmentObject private var historyStore: WorkoutHistoryStore
    @EnvironmentObject private var workoutStore: DailyWorkoutStore
    @EnvironmentObject private var routineStore: RoutineStore
    @EnvironmentObject private var customExerciseStore: CustomExerciseStore
    @State private var editingExercise: WorkoutExercise?
    @State private var isAddingExercise = false
    private let engine = RecommendationEngine()

    private var recommendation: WorkoutRecommendation {
        engine.recommendation(
            activeEnergy: healthKit.activeEnergy,
            calorieGoal: settings.dailyCalorieGoal,
            focus: settings.preferredFocus,
            availableMinutes: settings.availableWorkoutMinutes,
            intensity: settings.preferredIntensity,
            isBeginner: settings.isBeginner
        )
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    summaryHeader
                }

                Section("Workout defaults") {
                    Picker("Time", selection: $settings.availableWorkoutMinutes) {
                        Text("15 min").tag(15)
                        Text("30 min").tag(30)
                        Text("60 min").tag(60)
                    }

                    Picker("Intensity", selection: $settings.preferredIntensity) {
                        ForEach(WorkoutIntensity.allCases) { intensity in
                            Text(intensity.title).tag(intensity)
                        }
                    }

                    Picker("Focus", selection: $settings.preferredFocus) {
                        ForEach(WorkoutFocus.allCases) { focus in
                            Text(focus.title).tag(focus)
                        }
                    }

                    Toggle("Beginner safety mode", isOn: $settings.isBeginner)
                    CalorieGoalCard(goal: $settings.dailyCalorieGoal)
                }

                Section("Recommendation") {
                    recommendationHeader

                    Text("Warm-up")
                        .font(.headline)
                    Text(recommendation.warmup)
                        .font(.subheadline)

                    ForEach(recommendation.mainWork) { block in
                        RecommendationSetRow(block: block)
                    }

                    Text("Cooldown")
                        .font(.headline)
                    Text(recommendation.cooldown)
                        .font(.subheadline)

                    Button {
                        workoutStore.applyRecommendation(recommendation)
                    } label: {
                        Label("Use This Workout", systemImage: "wand.and.stars")
                    }
                    .buttonStyle(.borderedProminent)
                }

                Section("My Routine") {
                    NavigationLink {
                        MyRoutinesPage()
                            .environmentObject(routineStore)
                            .environmentObject(historyStore)
                            .environmentObject(customExerciseStore)
                    } label: {
                        Label("Open My Routine", systemImage: "dumbbell.fill")
                    }

                    Text("\(routineStore.routines.count) saved routines, including Push Day, Pull Day, and Leg Day.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Today's workout") {
                    ForEach(workoutStore.workout.exercises) { exercise in
                        Button {
                            workoutStore.toggleExercise(exercise)
                        } label: {
                            WorkoutExerciseRow(exercise: exercise)
                        }
                        .buttonStyle(.plain)
                        .swipeActions(edge: .trailing) {
                            Button {
                                editingExercise = exercise
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                    }
                    .onDelete { offsets in
                        workoutStore.deleteExercise(at: offsets)
                    }

                    Button {
                        isAddingExercise = true
                    } label: {
                        Label("Add Exercise", systemImage: "plus.circle.fill")
                    }
                }

                Section("Notes") {
                    TextEditor(
                        text: Binding(
                            get: { workoutStore.workout.notes },
                            set: { workoutStore.updateNotes($0) }
                        )
                    )
                    .frame(minHeight: 80)
                }
            }
            .navigationTitle("Workout")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            workoutStore.resetToday()
                        } label: {
                            Label("Reset Today", systemImage: "arrow.counterclockwise")
                        }
                    } label: {
                        Label("Workout actions", systemImage: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $isAddingExercise) {
                ExerciseEditorPage(title: "Add Exercise") { exercise in
                    workoutStore.addExercise(exercise)
                }
            }
            .sheet(item: $editingExercise) { exercise in
                ExerciseEditorPage(title: "Edit Exercise", exercise: exercise) { updated in
                    workoutStore.updateExercise(updated)
                }
            }
            .task {
                await healthKit.refreshTodayMetrics()
            }
        }
    }

    private var summaryHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workoutStore.workout.title)
                        .font(.title3.bold())
                    Text("\(workoutStore.workout.totalMinutes) min • \(workoutStore.workout.completedCount)/\(workoutStore.workout.exercises.count) complete")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Gauge(
                    value: Double(workoutStore.workout.completedCount),
                    in: 0...Double(max(workoutStore.workout.exercises.count, 1))
                ) {
                    Text("Progress")
                }
                .gaugeStyle(.accessoryCircularCapacity)
            }

            ProgressView(
                value: Double(workoutStore.workout.completedCount),
                total: Double(max(workoutStore.workout.exercises.count, 1))
            )

            Text("\(Int(healthKit.activeEnergy)) kcal active today • goal \(Int(settings.dailyCalorieGoal)) kcal")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private var recommendationHeader: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: recommendation.systemImage)
                .font(.title2)
                .frame(width: 32)
                .foregroundStyle(.green)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(recommendation.title)
                    .font(.headline)

                Text(recommendation.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("\(recommendation.durationMinutes) min • ~\(recommendation.estimatedCalories) kcal • \(recommendation.intensity.title) intensity")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct WorkoutExerciseRow: View {
    let exercise: WorkoutExercise

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: exercise.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(exercise.isCompleted ? .green : .secondary)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.headline)
                    .strikethrough(exercise.isCompleted)

                Text(exercise.detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("\(exercise.sets) sets • \(exercise.reps) • \(exercise.minutes) min")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}

private struct RecommendationSetRow: View {
    let block: WorkoutBlock

    private var setText: String {
        var parts = ["\(block.minutes) min"]

        if let sets = block.sets {
            parts.append("\(sets) sets")
        }

        if let reps = block.reps {
            parts.append(reps)
        }

        return parts.joined(separator: " • ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(block.name)
                .font(.subheadline.bold())

            Text(block.detail)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Label(setText, systemImage: "list.number")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct WorkoutPage_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutPage()
            .environmentObject(AppSettings())
            .environmentObject(HealthKitManager())
            .environmentObject(WorkoutHistoryStore())
            .environmentObject(DailyWorkoutStore())
            .environmentObject(RoutineStore())
            .environmentObject(CustomExerciseStore())
    }
}

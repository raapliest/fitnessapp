import Foundation

enum ExerciseLibrary {
    static let items: [ExerciseLibraryItem] = [
        ExerciseLibraryItem(name: "Bench Press", category: "Push", primaryMuscle: "Chest"),
        ExerciseLibraryItem(name: "Incline Dumbbell Press", category: "Push", primaryMuscle: "Chest"),
        ExerciseLibraryItem(name: "Shoulder Press", category: "Push", primaryMuscle: "Shoulders"),
        ExerciseLibraryItem(name: "Lateral Raise", category: "Push", primaryMuscle: "Shoulders"),
        ExerciseLibraryItem(name: "Triceps Pushdown", category: "Push", primaryMuscle: "Triceps"),
        ExerciseLibraryItem(name: "Pull-up", category: "Pull", primaryMuscle: "Back"),
        ExerciseLibraryItem(name: "Weighted Pull-up", category: "Pull", primaryMuscle: "Back", trackingType: .weightedBodyweight),
        ExerciseLibraryItem(name: "Weighted Dip", category: "Push", primaryMuscle: "Chest", trackingType: .weightedBodyweight),
        ExerciseLibraryItem(name: "Lat Pulldown", category: "Pull", primaryMuscle: "Back"),
        ExerciseLibraryItem(name: "Barbell Row", category: "Pull", primaryMuscle: "Back"),
        ExerciseLibraryItem(name: "Seated Cable Row", category: "Pull", primaryMuscle: "Back"),
        ExerciseLibraryItem(name: "Biceps Curl", category: "Pull", primaryMuscle: "Biceps"),
        ExerciseLibraryItem(name: "Back Squat", category: "Legs", primaryMuscle: "Quads"),
        ExerciseLibraryItem(name: "Romanian Deadlift", category: "Legs", primaryMuscle: "Hamstrings"),
        ExerciseLibraryItem(name: "Leg Press", category: "Legs", primaryMuscle: "Quads"),
        ExerciseLibraryItem(name: "Walking Lunge", category: "Legs", primaryMuscle: "Glutes"),
        ExerciseLibraryItem(name: "Calf Raise", category: "Legs", primaryMuscle: "Calves"),
        ExerciseLibraryItem(name: "Plank", category: "Core", primaryMuscle: "Core", trackingType: .duration),
        ExerciseLibraryItem(name: "Weighted Plank", category: "Core", primaryMuscle: "Core", trackingType: .weightedDuration),
        ExerciseLibraryItem(name: "Dead Bug", category: "Core", primaryMuscle: "Core"),
        ExerciseLibraryItem(name: "Cable Crunch", category: "Core", primaryMuscle: "Abs"),
        ExerciseLibraryItem(name: "Treadmill Run", category: "Cardio", primaryMuscle: "Cardio", trackingType: .duration),
        ExerciseLibraryItem(name: "Stationary Bike", category: "Cardio", primaryMuscle: "Cardio", trackingType: .duration)
    ]
}

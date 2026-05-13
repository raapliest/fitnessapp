import Combine
import Foundation

final class AppSettings: ObservableObject {
    @Published var dailyCalorieGoal: Double {
        didSet {
            UserDefaults.standard.set(dailyCalorieGoal, forKey: Self.dailyCalorieGoalKey)
        }
    }

    @Published var preferredFocus: WorkoutFocus = .balanced {
        didSet {
            UserDefaults.standard.set(preferredFocus.rawValue, forKey: Self.preferredFocusKey)
        }
    }

    private static let dailyCalorieGoalKey = "dailyCalorieGoal"
    private static let preferredFocusKey = "preferredWorkoutFocus"

    init() {
        let storedGoal = UserDefaults.standard.double(forKey: Self.dailyCalorieGoalKey)
        dailyCalorieGoal = storedGoal == 0 ? 550 : storedGoal

        let storedFocus = UserDefaults.standard.string(forKey: Self.preferredFocusKey)
        preferredFocus = storedFocus.flatMap(WorkoutFocus.init(rawValue:)) ?? .balanced
    }
}

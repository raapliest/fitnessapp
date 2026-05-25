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

    @Published var availableWorkoutMinutes: Int {
        didSet {
            UserDefaults.standard.set(availableWorkoutMinutes, forKey: Self.availableWorkoutMinutesKey)
        }
    }

    @Published var preferredIntensity: WorkoutIntensity {
        didSet {
            UserDefaults.standard.set(preferredIntensity.rawValue, forKey: Self.preferredIntensityKey)
        }
    }

    @Published var isBeginner: Bool {
        didSet {
            UserDefaults.standard.set(isBeginner, forKey: Self.isBeginnerKey)
        }
    }

    @Published var hasAcceptedMedicalDisclaimer: Bool {
        didSet {
            UserDefaults.standard.set(hasAcceptedMedicalDisclaimer, forKey: Self.medicalDisclaimerKey)
        }
    }

    private static let dailyCalorieGoalKey = "dailyCalorieGoal"
    private static let preferredFocusKey = "preferredWorkoutFocus"
    private static let availableWorkoutMinutesKey = "availableWorkoutMinutes"
    private static let preferredIntensityKey = "preferredWorkoutIntensity"
    private static let isBeginnerKey = "isBeginner"
    private static let medicalDisclaimerKey = "hasAcceptedMedicalDisclaimer"

    init() {
        let storedGoal = UserDefaults.standard.double(forKey: Self.dailyCalorieGoalKey)
        dailyCalorieGoal = storedGoal == 0 ? 550 : storedGoal

        let storedFocus = UserDefaults.standard.string(forKey: Self.preferredFocusKey)
        preferredFocus = storedFocus.flatMap(WorkoutFocus.init(rawValue:)) ?? .balanced

        let storedMinutes = UserDefaults.standard.integer(forKey: Self.availableWorkoutMinutesKey)
        availableWorkoutMinutes = [15, 30, 60].contains(storedMinutes) ? storedMinutes : 30

        let storedIntensity = UserDefaults.standard.string(forKey: Self.preferredIntensityKey)
        preferredIntensity = storedIntensity.flatMap(WorkoutIntensity.init(rawValue:)) ?? .medium

        isBeginner = UserDefaults.standard.object(forKey: Self.isBeginnerKey) as? Bool ?? true

        hasAcceptedMedicalDisclaimer = UserDefaults.standard.bool(forKey: Self.medicalDisclaimerKey)
    }
}

import Foundation
import HealthKit

@MainActor
final class HealthKitManager: ObservableObject {
    @Published private(set) var activeEnergy: Double = 0
    @Published private(set) var stepCount: Double = 0
    @Published private(set) var authorizationStatus: HealthAuthorizationStatus = .notDetermined
    @Published private(set) var statusMessage = "Connect Apple Health to track active energy."

    private let healthStore = HKHealthStore()

    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            authorizationStatus = .unavailable
            statusMessage = "Health data is not available on this device."
            return
        }

        guard let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned),
              let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)
        else {
            authorizationStatus = .unavailable
            statusMessage = "Required HealthKit metrics are unavailable."
            return
        }

        do {
            let workoutType = HKObjectType.workoutType()
            try await healthStore.requestAuthorization(
                toShare: [workoutType],
                read: [activeEnergyType, stepCountType, workoutType]
            )
            authorizationStatus = .authorized
            statusMessage = "Active energy and steps are synced from Apple Health."
            await refreshTodayMetrics()
        } catch {
            authorizationStatus = .denied
            statusMessage = "Health permission was not granted."
        }
    }

    func refreshTodayMetrics() async {
        await refreshActiveEnergy()
        await refreshStepCount()
    }

    func refreshActiveEnergy() async {
        guard let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            return
        }

        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: Date(),
            options: .strictStartDate
        )

        do {
            let quantity = try await statistics(
                for: activeEnergyType,
                predicate: predicate
            )
            activeEnergy = quantity?.doubleValue(for: .kilocalorie()) ?? 0
        } catch {
            statusMessage = "Could not refresh active energy."
        }
    }

    func refreshStepCount() async {
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return
        }

        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: Date(),
            options: .strictStartDate
        )

        do {
            let quantity = try await statistics(
                for: stepCountType,
                predicate: predicate
            )
            stepCount = quantity?.doubleValue(for: .count()) ?? 0
        } catch {
            statusMessage = "Could not refresh step count."
        }
    }

    func saveWorkout(_ recommendation: WorkoutRecommendation) async {
        guard HKHealthStore.isHealthDataAvailable() else {
            statusMessage = "Health data is not available on this device."
            return
        }

        let endDate = Date()
        let startDate = endDate.addingTimeInterval(TimeInterval(-recommendation.durationMinutes * 60))
        let calories = HKQuantity(
            unit: .kilocalorie(),
            doubleValue: Double(recommendation.estimatedCalories)
        )
        let workout = HKWorkout(
            activityType: activityType(for: recommendation),
            start: startDate,
            end: endDate,
            duration: TimeInterval(recommendation.durationMinutes * 60),
            totalEnergyBurned: calories,
            totalDistance: nil,
            metadata: [
                HKMetadataKeyWorkoutBrandName: "Fitness Coach",
                "FitnessCoachRecommendationID": recommendation.id.uuidString
            ]
        )

        do {
            try await healthStore.save(workout)
            statusMessage = "Workout was saved to Apple Health."
            await refreshTodayMetrics()
        } catch {
            statusMessage = "Workout could not be saved to Apple Health."
        }
    }

    private func activityType(for recommendation: WorkoutRecommendation) -> HKWorkoutActivityType {
        let title = recommendation.title.lowercased()

        if title.contains("cardio") || title.contains("run") {
            return .running
        }

        if title.contains("strength") {
            return .traditionalStrengthTraining
        }

        if title.contains("mobility") || title.contains("recovery") {
            return .flexibility
        }

        return .functionalStrengthTraining
    }

    private func statistics(
        for quantityType: HKQuantityType,
        predicate: NSPredicate
    ) async throws -> HKQuantity? {
        try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                continuation.resume(returning: statistics?.sumQuantity())
            }

            healthStore.execute(query)
        }
    }
}

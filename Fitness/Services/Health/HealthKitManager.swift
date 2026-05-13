import Foundation
import HealthKit

@MainActor
final class HealthKitManager: ObservableObject {
    @Published private(set) var activeEnergy: Double = 0
    @Published private(set) var authorizationStatus: HealthAuthorizationStatus = .notDetermined
    @Published private(set) var statusMessage = "Connect Apple Health to track active energy."

    private let healthStore = HKHealthStore()

    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            authorizationStatus = .unavailable
            statusMessage = "Health data is not available on this device."
            return
        }

        guard let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            authorizationStatus = .unavailable
            statusMessage = "Active energy is unavailable."
            return
        }

        do {
            try await healthStore.requestAuthorization(toShare: [], read: [activeEnergyType])
            authorizationStatus = .authorized
            statusMessage = "Active energy is synced from Apple Health."
            await refreshActiveEnergy()
        } catch {
            authorizationStatus = .denied
            statusMessage = "Health permission was not granted."
        }
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

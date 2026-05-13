import SwiftUI

struct ActiveEnergyCard: View {
    let activeEnergy: Double
    let calorieGoal: Double
    let statusMessage: String
    let refresh: () -> Void

    private var progress: Double {
        guard calorieGoal > 0 else {
            return 0
        }

        return min(activeEnergy / calorieGoal, 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Active Energy", systemImage: "flame.fill")
                    .font(.headline)
                    .foregroundStyle(.orange)

                Spacer()

                Button(action: refresh) {
                    Label("Refresh Health", systemImage: "arrow.clockwise")
                }
                .labelStyle(.iconOnly)
            }

            ProgressView(value: progress) {
                Text("\(Int(activeEnergy)) / \(Int(calorieGoal)) kcal")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
            }
            .tint(.orange)

            Text(statusMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct ActiveEnergyCard_Previews: PreviewProvider {
    static var previews: some View {
        ActiveEnergyCard(
            activeEnergy: 320,
            calorieGoal: 550,
            statusMessage: "Active energy is synced from Apple Health.",
            refresh: {}
        )
    }
}

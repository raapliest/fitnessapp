import SwiftUI

struct CalorieGoalCard: View {
    @Binding var goal: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Daily calorie goal", systemImage: "target")
                .font(.headline)

            HStack(alignment: .firstTextBaseline) {
                TextField("Goal", value: $goal, format: .number)
                    .keyboardType(.numberPad)
                    .font(.title.bold())
                    .textFieldStyle(.roundedBorder)

                Text("kcal")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            Slider(value: $goal, in: 150...1200, step: 25) {
                Text("Daily calorie goal")
            } minimumValueLabel: {
                Text("150")
            } maximumValueLabel: {
                Text("1200")
            }
            .tint(.green)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct CalorieGoalCard_Previews: PreviewProvider {
    static var previews: some View {
        CalorieGoalCard(goal: .constant(550))
    }
}

import SwiftUI

struct ReadinessRow: View {
    let item: ReadinessItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: item.isComplete ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(item.isComplete ? .green : .secondary)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 5) {
                Text(item.title)
                    .font(.headline)

                Text(item.detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}

struct ReadinessRow_Previews: PreviewProvider {
    static var previews: some View {
        ReadinessRow(
            item: ReadinessItem(
                title: "HealthKit purpose strings",
                detail: "Explains active-energy read access clearly.",
                isComplete: true
            )
        )
    }
}

import SwiftUI

struct InsightCard: View {
    let title: String
    let message: String
    let systemImage: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(.green)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)

                Text(message)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct InsightCard_Previews: PreviewProvider {
    static var previews: some View {
        InsightCard(
            title: "Today’s coaching note",
            message: "A short walk keeps momentum high.",
            systemImage: "sparkles"
        )
    }
}

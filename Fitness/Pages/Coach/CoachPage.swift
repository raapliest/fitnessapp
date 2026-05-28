import SwiftUI

struct CoachPage: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var healthKit: HealthKitManager
    @EnvironmentObject private var historyStore: WorkoutHistoryStore
    @EnvironmentObject private var workoutStore: DailyWorkoutStore
    @EnvironmentObject private var chatStore: CoachChatStore
    @EnvironmentObject private var profileStore: ProfileStore
    @StateObject private var viewModel: CoachViewModel
    @State private var messageText = ""

    init(historyStore: WorkoutHistoryStore? = nil) {
        _viewModel = StateObject(
            wrappedValue: CoachViewModel(
                historyStore: historyStore ?? WorkoutHistoryStore()
            )
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                messagesView
                composer
            }
            .navigationTitle("Coach")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        workoutStore.applyRecommendation(viewModel.currentRecommendation)
                    } label: {
                        Label("Apply Recommendation", systemImage: "wand.and.stars")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .destructive) {
                        chatStore.clear()
                    } label: {
                        Label("Clear Chat", systemImage: "trash")
                    }
                }
            }
            .task {
                refreshRecommendation()
            }
            .onChange(of: healthKit.activeEnergy) { _ in refreshRecommendation() }
            .onChange(of: settings.dailyCalorieGoal) { _ in refreshRecommendation() }
            .onChange(of: settings.preferredFocus) { _ in refreshRecommendation() }
            .onChange(of: settings.availableWorkoutMinutes) { _ in refreshRecommendation() }
            .onChange(of: settings.preferredIntensity) { _ in refreshRecommendation() }
            .onChange(of: settings.isBeginner) { _ in refreshRecommendation() }
        }
    }

    private var messagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    recommendationStrip

                    ForEach(chatStore.messages) { message in
                        ChatBubble(message: message)
                            .id(message.id)
                    }

                    if viewModel.isSendingCoachQuestion {
                        HStack {
                            ProgressView()
                            Text("Coach is thinking")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .onChange(of: chatStore.messages.count) { _ in
                guard let last = chatStore.messages.last else { return }
                withAnimation {
                    proxy.scrollTo(last.id, anchor: .bottom)
                }
            }
        }
    }

    private var recommendationStrip: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Context", systemImage: viewModel.currentRecommendation.systemImage)
                .font(.caption.bold())
                .foregroundStyle(.green)

            Text(viewModel.currentRecommendation.title)
                .font(.headline)

            Text("\(workoutStore.workout.exercises.count) exercises in today's workout • \(workoutStore.workout.completedCount) done")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal)
    }

    private var composer: some View {
        HStack(alignment: .bottom, spacing: 8) {
            TextField("Message your coach", text: $messageText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...5)
                .submitLabel(.send)
                .disabled(viewModel.isSendingCoachQuestion)
                .onSubmit(sendMessage)

            Button {
                sendMessage()
            } label: {
                Image(systemName: "paperplane.fill")
                    .frame(width: 22, height: 22)
            }
            .buttonStyle(.borderedProminent)
            .disabled(
                viewModel.isSendingCoachQuestion ||
                messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            )
            .accessibilityLabel("Send message")
        }
        .padding()
        .background(Color(.systemBackground))
    }

    private func refreshRecommendation() {
        viewModel.refresh(
            activeEnergy: healthKit.activeEnergy,
            calorieGoal: settings.dailyCalorieGoal,
            focus: settings.preferredFocus,
            availableMinutes: settings.availableWorkoutMinutes,
            intensity: settings.preferredIntensity,
            isBeginner: settings.isBeginner
        )
    }

    private func sendMessage() {
        let question = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty else { return }

        messageText = ""
        Task {
            await viewModel.askCoach(
                question: question,
                isBeginner: settings.isBeginner,
                dailyWorkout: workoutStore.workout,
                profile: profileStore.profile,
                chatStore: chatStore
            )
        }
    }
}

private struct ChatBubble: View {
    let message: CoachChatMessage

    private var isUser: Bool {
        message.role == .user
    }

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 48) }

            Text(message.text)
                .font(.body)
                .padding(12)
                .foregroundStyle(isUser ? .white : .primary)
                .background(isUser ? Color.accentColor : Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .accessibilityLabel(isUser ? "Your message" : "Coach message")

            if !isUser { Spacer(minLength: 48) }
        }
        .padding(.horizontal)
    }
}

struct CoachPage_Previews: PreviewProvider {
    static var previews: some View {
        CoachPage(historyStore: WorkoutHistoryStore())
            .environmentObject(AppSettings())
            .environmentObject(HealthKitManager())
            .environmentObject(WorkoutHistoryStore())
            .environmentObject(DailyWorkoutStore())
            .environmentObject(CoachChatStore())
            .environmentObject(ProfileStore())
    }
}

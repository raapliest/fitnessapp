import Foundation

struct CoachChatService {
    enum CoachChatError: LocalizedError {
        case missingAPIKey
        case invalidResponse
        case requestFailed(String)

        var errorDescription: String? {
            switch self {
            case .missingAPIKey:
                return "GROQ_API_KEY was not found. Add it under Product > Scheme > Edit Scheme > Run > Arguments > Environment Variables, make sure the checkbox is on, then stop and run the app from Xcode."
            case .invalidResponse:
                return "The AI coach response was empty."
            case .requestFailed(let message):
                return message
            }
        }
    }

    private let apiKey: String
    private let urlSession: URLSession

    init(
        apiKey: String = CoachChatService.resolveAPIKey(),
        urlSession: URLSession = .shared
    ) {
        self.apiKey = apiKey
        self.urlSession = urlSession
    }

    func response(
        for question: String,
        recommendation: WorkoutRecommendation,
        isBeginner: Bool,
        dailyWorkout: DailyWorkout,
        profile: UserProfile,
        recentMessages: [CoachChatMessage]
    ) async throws -> String {
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedKey.isEmpty else { throw CoachChatError.missingAPIKey }

        var request = URLRequest(url: URL(string: "https://api.groq.com/openai/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(trimmedKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(
            GroqChatRequest(
                model: "llama-3.3-70b-versatile",
                messages: [
                    .init(role: "system", content: instructions),
                    .init(
                        role: "user",
                        content: prompt(
                            question: question,
                            recommendation: recommendation,
                            isBeginner: isBeginner,
                            dailyWorkout: dailyWorkout,
                            profile: profile,
                            recentMessages: recentMessages
                        )
                    )
                ],
                maxCompletionTokens: 220,
                temperature: 0.4
            )
        )

        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw CoachChatError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            let apiError = try? JSONDecoder().decode(GroqErrorResponse.self, from: data)
            throw CoachChatError.requestFailed(
                apiError?.error.message ?? "AI coach request failed with status \(httpResponse.statusCode)."
            )
        }

        let decodedResponse = try JSONDecoder().decode(GroqChatResponse.self, from: data)
        guard let text = decodedResponse.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty else {
            throw CoachChatError.invalidResponse
        }

        return text
    }

    private var instructions: String {
        """
        You are a careful fitness coach inside an iOS fitness app. Give concise, practical workout guidance.
        Do not diagnose, prescribe medical treatment, or override safety warnings. Tell the user to stop and seek professional help for pain, dizziness, chest pressure, or unusual shortness of breath.
        Keep replies under 90 words.
        """
    }

    private static func resolveAPIKey() -> String {
        let environment = ProcessInfo.processInfo.environment
        let possibleKeys = [
            "GROQ_API_KEY",
            "GROQAI_API_KEY",
            "GROQ_KEY"
        ]

        for key in possibleKeys {
            if let value = environment[key]?.trimmingCharacters(in: .whitespacesAndNewlines),
               !value.isEmpty {
                return value
            }
        }

        for key in possibleKeys {
            if let value = Bundle.main.object(forInfoDictionaryKey: key) as? String {
                let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmedValue.isEmpty {
                    return trimmedValue
                }
            }
        }

        return ""
    }

    private func prompt(
        question: String,
        recommendation: WorkoutRecommendation,
        isBeginner: Bool,
        dailyWorkout: DailyWorkout,
        profile: UserProfile,
        recentMessages: [CoachChatMessage]
    ) -> String {
        """
        User profile:
        Name: \(profile.displayName.isEmpty ? "Not set" : profile.displayName)
        Goal: \(profile.goal)
        Experience: \(profile.experienceLevel)
        Equipment: \(profile.equipment)
        Limitations: \(profile.limitations.isEmpty ? "None listed" : profile.limitations)

        Today's editable workout:
        Title: \(dailyWorkout.title)
        Notes: \(dailyWorkout.notes)
        Exercises: \(dailyWorkout.exercises.map { "\($0.name), \($0.sets) sets, \($0.reps), \($0.minutes) min, completed: \($0.isCompleted)" }.joined(separator: "; "))

        Current workout:
        Title: \(recommendation.title)
        Subtitle: \(recommendation.subtitle)
        Duration: \(recommendation.durationMinutes) minutes
        Intensity: \(recommendation.intensity.title)
        Estimated calories: \(recommendation.estimatedCalories)
        Beginner safety mode: \(isBeginner ? "on" : "off")
        Warm-up: \(recommendation.warmup)
        Main work: \(recommendation.mainWork.map { "\($0.name): \($0.detail)" }.joined(separator: "; "))
        Cooldown: \(recommendation.cooldown)
        Safety notes: \(recommendation.safetyNotes.joined(separator: "; "))

        Recent chat:
        \(recentMessages.suffix(6).map { "\($0.role.rawValue): \($0.text)" }.joined(separator: "\n"))

        User question:
        \(question)
        """
    }
}

private struct GroqChatRequest: Encodable {
    let model: String
    let messages: [Message]
    let maxCompletionTokens: Int
    let temperature: Double

    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case maxCompletionTokens = "max_completion_tokens"
        case temperature
    }

    struct Message: Encodable {
        let role: String
        let content: String
    }
}

private struct GroqChatResponse: Decodable {
    let choices: [Choice]

    struct Choice: Decodable {
        let message: Message
    }

    struct Message: Decodable {
        let content: String
    }
}

private struct GroqErrorResponse: Decodable {
    let error: APIError

    struct APIError: Decodable {
        let message: String
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}

import Foundation

struct UserProfile: Codable, Equatable {
    var displayName: String
    var goal: String
    var experienceLevel: String
    var equipment: String
    var limitations: String

    static let empty = UserProfile(
        displayName: "",
        goal: "Build consistency",
        experienceLevel: "Beginner",
        equipment: "Bodyweight",
        limitations: ""
    )
}

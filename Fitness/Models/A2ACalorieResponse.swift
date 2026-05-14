import Foundation

struct A2ACalorieResponse: Decodable {
    let jsonrpc: String
    let id: String
    let result: Result

    struct Result: Decodable {
        let persona: Persona
        let message: Message
    }

    struct Persona: Decodable {
        let name: String
        let role: String
        let tone: String
    }

    struct Message: Decodable {
        let role: String
        let parts: [Part]
    }

    struct Part: Decodable {
        let type: String
        let data: CalorieData
    }

    struct CalorieData: Decodable {
        let activeCalories: Int
        let goalCalories: Int
        let consumedCalories: Int
        let restingCalories: Int
        let remainingCalories: Int
        let source: String
        let samples: [Sample]
        let insight: String
    }

    struct Sample: Decodable, Identifiable {
        let label: String
        let calories: Int

        var id: String {
            label
        }
    }

    var calorieData: CalorieData? {
        result.message.parts.first { $0.type == "calorie_data" }?.data
    }
}

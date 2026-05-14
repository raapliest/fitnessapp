import Foundation

enum FitnessAppPersona {
    static let mockA2ACalorieJSON = """
    {
      "jsonrpc": "2.0",
      "id": "fitnessapp-calories-demo-001",
      "result": {
        "persona": {
          "name": "FitnessApp Persona",
          "role": "daily fitness coach",
          "tone": "encouraging, direct, practical"
        },
        "message": {
          "role": "agent",
          "parts": [
            {
              "type": "calorie_data",
              "data": {
                "activeCalories": 420,
                "goalCalories": 650,
                "consumedCalories": 1780,
                "restingCalories": 1610,
                "remainingCalories": 230,
                "source": "mock A2A response",
                "samples": [
                  {
                    "label": "Morning walk",
                    "calories": 145
                  },
                  {
                    "label": "Strength circuit",
                    "calories": 210
                  },
                  {
                    "label": "Mobility cooldown",
                    "calories": 65
                  }
                ],
                "insight": "You are 230 kcal from today's active goal. A short incline walk or steady bike session would close the gap without overreaching."
              }
            }
          ]
        }
      }
    }
    """

    static func calorieResponse() throws -> A2ACalorieResponse {
        let data = Data(mockA2ACalorieJSON.utf8)
        return try JSONDecoder().decode(A2ACalorieResponse.self, from: data)
    }
}

import Foundation
import FoundationModels

/// Validation result structure
struct MeditationValidation: Codable {
    let isValid: Bool
    let feedback: String
    let score: Double
}

/// Apple Intelligence service for validating meditation responses
@available(iOS 18.2, *)
class AppleIntelligenceValidator {
    private var session: LanguageModelSession?

    init() {
        setupSession()
    }

    private func setupSession() {
        let model = SystemLanguageModel.default

        session = LanguageModelSession(
            model: model,
            guardrails: .default,
            tools: [],
            instructions: {
                """
                You are a thoughtful spiritual mentor validating meditation reflections on Bible verses.

                Assess if the user's reflection shows genuine engagement with the verse.

                Valid reflections:
                - Show understanding of verse meaning (doesn't need to be perfect)
                - Connect verse to personal life or situations
                - Show honest thought and effort (minimum 20 characters)
                - Can be simple but sincere

                Invalid reflections:
                - Too short (< 20 characters)
                - Generic/copy-paste responses
                - Completely off-topic
                - No personal connection or thought

                Always respond with valid JSON in this exact format:
                {"isValid": true/false, "feedback": "one sentence feedback", "score": 0.0-1.0}

                Be encouraging and supportive. Focus on effort and sincerity over perfection.
                """
            }
        )
    }

    /// Validate meditation response
    func validate(
        verseText: String,
        verseReference: String,
        userResponse: String,
        userGoals: String?,
        userStruggles: String?
    ) async throws -> MeditationValidation {
        guard let session = session else {
            throw ValidationError.sessionNotInitialized
        }

        // Build context-aware prompt
        var promptText = """
        Verse: "\(verseText)" (\(verseReference))

        User's reflection: "\(userResponse)"
        """

        if let goals = userGoals, !goals.isEmpty {
            promptText += "\n\nUser's goals: \(goals)"
        }

        if let struggles = userStruggles, !struggles.isEmpty {
            promptText += "\n\nUser's struggles: \(struggles)"
        }

        promptText += """


        Validate this reflection. Respond ONLY with JSON in this format:
        {"isValid": boolean, "feedback": "string", "score": number}
        """

        // Generate response
        let response = try await session.respond(
            to: Prompt(promptText),
            options: GenerationOptions(temperature: 0.3, maxOutputTokens: 150)
        )

        // Parse JSON response
        guard let jsonData = response.data(using: .utf8) else {
            throw ValidationError.invalidResponse
        }

        let decoder = JSONDecoder()
        let validation = try decoder.decode(MeditationValidation.self, from: jsonData)

        return validation
    }

    /// Check if Apple Intelligence is available
    static var isAvailable: Bool {
        if #available(iOS 18.2, *) {
            // Check if the device supports Foundation Models
            // This typically requires iPhone 15 Pro or later, or M1+ iPad
            return true // Foundation Models framework will handle device compatibility
        }
        return false
    }
}

enum ValidationError: Error {
    case sessionNotInitialized
    case deviceNotSupported
    case invalidResponse
}

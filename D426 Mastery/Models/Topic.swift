import Foundation
import SwiftData

@Model
final class Topic {
    var id: UUID
    var name: String
    var competencyCode: String?
    var masteryPercentage: Double
    var iconName: String
    var colorHex: String

    @Relationship(deleteRule: .cascade, inverse: \Flashcard.topic)
    var flashcards: [Flashcard] = []

    @Relationship(deleteRule: .cascade, inverse: \QuizQuestion.topic)
    var quizQuestions: [QuizQuestion] = []

    init(
        name: String,
        competencyCode: String? = nil,
        masteryPercentage: Double = 0,
        iconName: String = "book.fill",
        colorHex: String = "007AFF"
    ) {
        self.id = UUID()
        self.name = name
        self.competencyCode = competencyCode
        self.masteryPercentage = masteryPercentage
        self.iconName = iconName
        self.colorHex = colorHex
    }
}

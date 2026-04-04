import Foundation
import SwiftData

@Model
final class Flashcard {
    var id: UUID
    var question: String
    var answer: String
    var topic: Topic?
    var tags: [String]
    var lastReviewed: Date?
    var interval: Double
    var repetitions: Int
    var easeFactor: Double
    var nextReviewDate: Date

    init(
        question: String,
        answer: String,
        topic: Topic? = nil,
        tags: [String] = [],
        interval: Double = 0,
        repetitions: Int = 0,
        easeFactor: Double = 2.5,
        nextReviewDate: Date = .now
    ) {
        self.id = UUID()
        self.question = question
        self.answer = answer
        self.topic = topic
        self.tags = tags
        self.interval = interval
        self.repetitions = repetitions
        self.easeFactor = easeFactor
        self.nextReviewDate = nextReviewDate
    }
}

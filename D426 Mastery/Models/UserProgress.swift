import Foundation
import SwiftData

@Model
final class UserProgress {
    var id: UUID
    var totalStudyTime: TimeInterval
    var streak: Int
    var lastStudyDate: Date?
    var cardsReviewedToday: Int
    var quizzesTakenToday: Int
    var totalCardsReviewed: Int
    var totalQuizzesTaken: Int
    var totalCorrectAnswers: Int
    var totalQuestionsAnswered: Int
    var onboardingCompleted: Bool

    init() {
        self.id = UUID()
        self.totalStudyTime = 0
        self.streak = 0
        self.cardsReviewedToday = 0
        self.quizzesTakenToday = 0
        self.totalCardsReviewed = 0
        self.totalQuizzesTaken = 0
        self.totalCorrectAnswers = 0
        self.totalQuestionsAnswered = 0
        self.onboardingCompleted = false
    }

    func updateStreak() {
        let calendar = Calendar.current
        if let last = lastStudyDate, calendar.isDateInToday(last) {
            return
        } else if let last = lastStudyDate, calendar.isDateInYesterday(last) {
            streak += 1
        } else {
            streak = 1
        }
        lastStudyDate = .now
    }

    /// Resets daily counters if the last study date is not today
    func resetDailyIfNeeded() {
        let calendar = Calendar.current
        if let last = lastStudyDate, !calendar.isDateInToday(last) {
            cardsReviewedToday = 0
            quizzesTakenToday = 0
        }
    }
}

import Foundation

/// SM-2 Spaced Repetition Algorithm (Anki-style)
enum SRSRating: Int, CaseIterable {
    case again = 0    // Complete blackout
    case hard = 1     // Incorrect but recalled after seeing answer
    case good = 2     // Correct with difficulty
    case easy = 3     // Perfect recall

    var label: String {
        switch self {
        case .again: return "Again"
        case .hard: return "Hard"
        case .good: return "Good"
        case .easy: return "Easy"
        }
    }

    var color: String {
        switch self {
        case .again: return "red"
        case .hard: return "orange"
        case .good: return "blue"
        case .easy: return "green"
        }
    }
}

struct SRSEngine {
    static func processReview(
        card: Flashcard,
        rating: SRSRating
    ) {
        let quality = Double(rating.rawValue)

        if rating == .again {
            card.repetitions = 0
            card.interval = 1
        } else {
            if card.repetitions == 0 {
                card.interval = 1
            } else if card.repetitions == 1 {
                card.interval = 6
            } else {
                card.interval = card.interval * card.easeFactor
            }
            card.repetitions += 1
        }

        // Update ease factor (minimum 1.3)
        let ef = card.easeFactor + (0.1 - (3 - quality) * (0.08 + (3 - quality) * 0.02))
        card.easeFactor = max(1.3, ef)

        // Adjust interval for hard/easy
        if rating == .hard {
            card.interval *= 0.8
        } else if rating == .easy {
            card.interval *= 1.3
        }

        card.interval = max(1, card.interval)
        card.lastReviewed = .now
        card.nextReviewDate = Calendar.current.date(
            byAdding: .day,
            value: Int(card.interval),
            to: .now
        ) ?? .now
    }

    static func dueCards(from cards: [Flashcard]) -> [Flashcard] {
        cards.filter { $0.nextReviewDate <= .now }
            .sorted { $0.nextReviewDate < $1.nextReviewDate }
    }
}

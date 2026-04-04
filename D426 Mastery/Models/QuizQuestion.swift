import Foundation
import SwiftData

enum QuestionType: String, Codable, CaseIterable {
    case multipleChoice
    case sqlWrite
    case erdMatch
    case trueFalse

    var displayName: String {
        switch self {
        case .multipleChoice: return "Multiple Choice"
        case .sqlWrite: return "SQL Write"
        case .erdMatch: return "ERD Match"
        case .trueFalse: return "True/False"
        }
    }
}

@Model
final class QuizQuestion {
    var id: UUID
    var typeRaw: String
    var text: String
    var options: [String]?
    var correctAnswer: String
    var explanation: String
    var topic: Topic?

    var type: QuestionType {
        get { QuestionType(rawValue: typeRaw) ?? .multipleChoice }
        set { typeRaw = newValue.rawValue }
    }

    init(
        type: QuestionType = .multipleChoice,
        text: String,
        options: [String]? = nil,
        correctAnswer: String,
        explanation: String = "",
        topic: Topic? = nil
    ) {
        self.id = UUID()
        self.typeRaw = type.rawValue
        self.text = text
        self.options = options
        self.correctAnswer = correctAnswer
        self.explanation = explanation
        self.topic = topic
    }
}

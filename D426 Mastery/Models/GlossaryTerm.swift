import Foundation
import SwiftData

@Model
final class GlossaryTerm {
    var id: UUID
    var term: String
    var definition: String
    var category: String
    var relatedTerms: [String]

    init(term: String, definition: String, category: String = "", relatedTerms: [String] = []) {
        self.id = UUID()
        self.term = term
        self.definition = definition
        self.category = category
        self.relatedTerms = relatedTerms
    }
}

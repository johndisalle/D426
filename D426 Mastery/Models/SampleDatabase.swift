import Foundation
import SwiftData

@Model
final class SampleDatabase {
    var id: UUID
    var name: String
    var dbDescription: String
    var schemaSQL: String
    var sampleDataSQL: String
    var iconName: String

    init(
        name: String,
        description: String,
        schemaSQL: String,
        sampleDataSQL: String,
        iconName: String = "cylinder.fill"
    ) {
        self.id = UUID()
        self.name = name
        self.dbDescription = description
        self.schemaSQL = schemaSQL
        self.sampleDataSQL = sampleDataSQL
        self.iconName = iconName
    }
}

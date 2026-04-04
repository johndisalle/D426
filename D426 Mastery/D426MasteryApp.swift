import SwiftUI
import SwiftData

@main
struct D426MasteryApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Topic.self,
            Flashcard.self,
            QuizQuestion.self,
            SampleDatabase.self,
            UserProgress.self,
            GlossaryTerm.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .onAppear {
                    DataSeeder.seedIfNeeded(context: sharedModelContainer.mainContext)
                }
        }
        .modelContainer(sharedModelContainer)
    }
}

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
                    let ctx = sharedModelContainer.mainContext
                    DataSeeder.seedIfNeeded(context: ctx)
                    // Reset daily counters if new day
                    if let progress = try? ctx.fetch(FetchDescriptor<UserProgress>()).first {
                        progress.resetDailyIfNeeded()
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
}

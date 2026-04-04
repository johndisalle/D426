import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var context
    @Query private var topics: [Topic]
    @Query private var flashcards: [Flashcard]
    @Query private var progressList: [UserProgress]

    private var progress: UserProgress { progressList.first ?? UserProgress() }
    private var dueCards: Int { SRSEngine.dueCards(from: flashcards).count }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Greeting & Streak
                    headerSection

                    // Stats Row
                    statsRow

                    // Mastery Radar Chart
                    masterySection

                    // Quick Actions
                    quickActionsSection

                    // Topic Mastery List
                    topicMasterySection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("D426 Mastery")
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.title2.bold())
                Text(dueCards > 0 ? "\(dueCards) cards due for review" : "You're all caught up!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(spacing: 2) {
                Image(systemName: "flame.fill")
                    .font(.title2)
                    .foregroundStyle(.orange)
                Text("\(progress.streak)")
                    .font(.caption.bold())
                Text("streak")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.orange.opacity(0.1))
            )
        }
    }

    // MARK: - Stats
    private var statsRow: some View {
        HStack(spacing: 12) {
            StatCard(title: "Cards Done", value: "\(progress.totalCardsReviewed)", icon: "rectangle.stack.fill", color: .blue)
            StatCard(title: "Quizzes", value: "\(progress.totalQuizzesTaken)", icon: "checkmark.circle.fill", color: .green)
            StatCard(title: "Accuracy", value: accuracy, icon: "target", color: .purple)
        }
    }

    private var accuracy: String {
        guard progress.totalQuizzesTaken > 0 else { return "—" }
        let pct = Double(progress.totalCorrectAnswers) / Double(progress.totalQuizzesTaken) * 100
        return "\(Int(pct))%"
    }

    // MARK: - Radar
    private var masterySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mastery Overview")
                .font(.headline)

            let chartData = topics.prefix(8).map { ($0.name.components(separatedBy: " ").first ?? $0.name, $0.masteryPercentage) }
            if !chartData.isEmpty {
                RadarChartView(data: chartData, color: .teal)
                    .frame(height: 260)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.secondarySystemBackground))
                    )
            }
        }
    }

    // MARK: - Quick Actions
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)

            QuickActionButton(title: "Review Due Cards (\(dueCards))", icon: "rectangle.stack.fill", color: .blue) {}
            QuickActionButton(title: "Start Mock OA", icon: "doc.questionmark.fill", color: .green) {}
            QuickActionButton(title: "SQL Playground", icon: "terminal.fill", color: .purple) {}
        }
    }

    // MARK: - Topics
    private var topicMasterySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Topics")
                .font(.headline)

            ForEach(topics) { topic in
                HStack(spacing: 12) {
                    Image(systemName: topic.iconName)
                        .font(.title3)
                        .frame(width: 36, height: 36)
                        .foregroundStyle(Color(hex: topic.colorHex))
                        .background(Color(hex: topic.colorHex).opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(topic.name)
                            .font(.subheadline.weight(.medium))
                            .lineLimit(1)

                        ProgressView(value: topic.masteryPercentage, total: 100)
                            .tint(Color(hex: topic.colorHex))
                    }

                    Text("\(Int(topic.masteryPercentage))%")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                )
            }
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 122, 255)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

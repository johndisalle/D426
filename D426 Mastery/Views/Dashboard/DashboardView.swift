import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var context
    @Query private var topics: [Topic]
    @Query private var flashcards: [Flashcard]
    @Query private var progressList: [UserProgress]
    @Environment(\.scenePhase) private var scenePhase

    @Binding var selectedTab: Int
    @State private var sessionStart: Date? = nil

    private var progress: UserProgress { progressList.first ?? UserProgress() }
    private var dueCards: Int { SRSEngine.dueCards(from: flashcards).count }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    studyTimerSection
                    statsRow
                    masterySection
                    quickActionsSection
                    topicMasterySection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("D426 Mastery")
            .onAppear { startSession() }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .background || newPhase == .inactive {
                    pauseSession()
                } else if newPhase == .active {
                    startSession()
                }
            }
        }
    }

    // MARK: - Study Timer
    private func startSession() {
        if sessionStart == nil {
            sessionStart = .now
        }
    }

    private func pauseSession() {
        guard let start = sessionStart else { return }
        let elapsed = Date.now.timeIntervalSince(start)
        if let p = progressList.first {
            p.totalStudyTime += elapsed
        }
        sessionStart = nil
    }

    private var studyTimerSection: some View {
        HStack(spacing: 12) {
            Image(systemName: "clock.fill")
                .foregroundStyle(.teal)
            VStack(alignment: .leading, spacing: 2) {
                Text("Total Study Time")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(formattedStudyTime)
                    .font(.headline)
            }
            Spacer()
            if sessionStart != nil {
                HStack(spacing: 4) {
                    Circle()
                        .fill(.green)
                        .frame(width: 8, height: 8)
                    Text("Active")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var formattedStudyTime: String {
        let total = progress.totalStudyTime
        let hours = Int(total) / 3600
        let minutes = Int(total) % 3600 / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
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
        guard progress.totalQuestionsAnswered > 0 else { return "—" }
        let pct = Double(progress.totalCorrectAnswers) / Double(progress.totalQuestionsAnswered) * 100
        return "\(Int(pct))%"
    }

    // MARK: - Radar
    private var masterySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mastery Overview")
                .font(.headline)

            let chartData = topics.map { topic -> (String, Double) in
                let shortName: String
                if topic.name.contains("&") {
                    shortName = String(topic.name.prefix(while: { $0 != "&" })).trimmingCharacters(in: .whitespaces)
                } else if topic.name.contains("/") {
                    shortName = String(topic.name.prefix(while: { $0 != "/" })).trimmingCharacters(in: .whitespaces)
                } else {
                    shortName = String(topic.name.split(separator: " ").prefix(2).joined(separator: " "))
                }
                return (shortName, topic.masteryPercentage)
            }
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

            QuickActionButton(title: "Review Due Cards (\(dueCards))", icon: "rectangle.stack.fill", color: .blue) { selectedTab = 1 }
            QuickActionButton(title: "Start Mock OA", icon: "doc.questionmark.fill", color: .green) { selectedTab = 2 }
            QuickActionButton(title: "SQL Playground", icon: "terminal.fill", color: .purple) { selectedTab = 3 }
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

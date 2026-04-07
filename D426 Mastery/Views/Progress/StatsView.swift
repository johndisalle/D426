import SwiftUI
import SwiftData

struct StatsView: View {
    @Query private var progressList: [UserProgress]
    @Query private var flashcards: [Flashcard]
    @Query private var topics: [Topic]

    private var progress: UserProgress { progressList.first ?? UserProgress() }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Streak section
                    streakCard

                    // Stats grid
                    statsGrid

                    // Topic breakdown
                    topicBreakdown

                    // Study calendar placeholder
                    studyCalendar
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Statistics")
        }
    }

    // MARK: - Streak
    private var streakCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 4) {
                ForEach(0..<7, id: \.self) { day in
                    VStack(spacing: 4) {
                        Text(dayLabel(day))
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                        Circle()
                            .fill(day < progress.streak % 7 ? .orange : .gray.opacity(0.2))
                            .frame(width: 32, height: 32)
                            .overlay {
                                if day < progress.streak % 7 {
                                    Image(systemName: "flame.fill")
                                        .font(.caption)
                                        .foregroundStyle(.white)
                                }
                            }
                    }
                }
            }

            Text("\(progress.streak) Day Streak")
                .font(.headline)

            if let last = progress.lastStudyDate {
                Text("Last studied: \(last.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.orange.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.orange.opacity(0.2), lineWidth: 1)
                )
        )
    }

    // MARK: - Stats Grid
    private var statsGrid: some View {
        VStack(spacing: 12) {
            // Readiness score
            let readiness = topics.isEmpty ? 0 : topics.map(\.masteryPercentage).reduce(0, +) / Double(topics.count)
            VStack(spacing: 8) {
                Text("OA Readiness")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(Int(readiness))%")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(readiness >= 80 ? .green : readiness >= 50 ? .yellow : .red)
                Text(readiness >= 80 ? "Ready to take the OA!" : readiness >= 50 ? "Getting there, keep studying" : "More study time needed")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
            )

            LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 12) {
                StatCard(title: "Cards Reviewed", value: "\(progress.totalCardsReviewed)", icon: "rectangle.stack.fill", color: .blue)
                StatCard(title: "Quizzes Taken", value: "\(progress.totalQuizzesTaken)", icon: "checkmark.circle.fill", color: .green)
                StatCard(title: "Study Time", value: formatTime(progress.totalStudyTime), icon: "clock.fill", color: .purple)
                StatCard(title: "Cards Due", value: "\(dueCardCount)", icon: "clock.badge.exclamationmark", color: .orange)
                StatCard(title: "Cards Mastered", value: "\(masteredCount)", icon: "star.fill", color: .yellow)
                StatCard(title: "Accuracy", value: accuracyText, icon: "target", color: .teal)
            }
        }
    }

    private var dueCardCount: Int { SRSEngine.dueCards(from: flashcards).count }
    private var masteredCount: Int { flashcards.filter { $0.repetitions >= 3 && $0.easeFactor >= 2.5 }.count }

    // MARK: - Topic Breakdown
    private var topicBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Topic Mastery")
                .font(.headline)

            ForEach(topics.sorted(by: { $0.masteryPercentage > $1.masteryPercentage })) { topic in
                VStack(spacing: 4) {
                    HStack {
                        Image(systemName: topic.iconName)
                            .font(.caption)
                            .foregroundStyle(Color(hex: topic.colorHex))
                        Text(topic.name)
                            .font(.caption)
                            .lineLimit(1)
                        Spacer()
                        Text("\(Int(topic.masteryPercentage))%")
                            .font(.caption.bold())
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(.gray.opacity(0.2))
                            Capsule()
                                .fill(Color(hex: topic.colorHex))
                                .frame(width: geo.size.width * topic.masteryPercentage / 100)
                        }
                    }
                    .frame(height: 8)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }

    // MARK: - Calendar
    private var studyCalendar: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activity")
                .font(.headline)

            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 7), spacing: 4) {
                ForEach(0..<28, id: \.self) { day in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(day < progress.streak ? .green.opacity(Double.random(in: 0.3...1.0)) : .gray.opacity(0.1))
                        .frame(height: 24)
                }
            }

            Text("Last 4 weeks")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }

    // MARK: - Helpers
    private func dayLabel(_ day: Int) -> String {
        ["M", "T", "W", "T", "F", "S", "S"][day % 7]
    }

    private var accuracyText: String {
        guard progress.totalQuizzesTaken > 0 else { return "—" }
        let pct = Double(progress.totalCorrectAnswers) / Double(progress.totalQuizzesTaken) * 100
        return "\(Int(pct))%"
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        if hours > 0 { return "\(hours)h \(minutes)m" }
        return "\(minutes)m"
    }
}

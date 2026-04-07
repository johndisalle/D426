import SwiftUI
import SwiftData

struct QuizView: View {
    @Environment(\.modelContext) private var context
    @Query private var allQuestions: [QuizQuestion]
    @Query private var topics: [Topic]
    @Query private var progressList: [UserProgress]

    @State private var quizMode: QuizMode?
    @State private var selectedTopic: Topic?

    enum QuizMode: Identifiable {
        case mockOA
        case topicBased(Topic)
        var id: String {
            switch self {
            case .mockOA: return "mockOA"
            case .topicBased(let t): return t.id.uuidString
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Mock OA
                    Button {
                        quizMode = .mockOA
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: "doc.questionmark.fill")
                                .font(.largeTitle)
                                .foregroundStyle(.green)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Mock OA Exam")
                                    .font(.headline)
                                Text("60 random questions from all topics")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.green.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(.green.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                    .foregroundStyle(.primary)

                    // Topic quizzes
                    Text("Topic Quizzes")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ForEach(topics) { topic in
                        let count = allQuestions.filter { $0.topic?.id == topic.id }.count
                        Button {
                            quizMode = .topicBased(topic)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: topic.iconName)
                                    .font(.title3)
                                    .frame(width: 36, height: 36)
                                    .foregroundStyle(Color(hex: topic.colorHex))
                                    .background(Color(hex: topic.colorHex).opacity(0.15))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(topic.name)
                                        .font(.subheadline.weight(.medium))
                                        .lineLimit(1)
                                    Text("\(count) questions")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.secondarySystemBackground))
                            )
                        }
                        .foregroundStyle(.primary)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Quizzes")
            .fullScreenCover(item: $quizMode) { mode in
                switch mode {
                case .mockOA:
                    QuizSessionView(
                        questions: Array(allQuestions.shuffled().prefix(60)),
                        title: "Mock OA"
                    )
                case .topicBased(let topic):
                    QuizSessionView(
                        questions: allQuestions.filter { $0.topic?.id == topic.id }.shuffled(),
                        title: topic.name
                    )
                }
            }
        }
    }
}

// MARK: - Quiz Session
struct QuizSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var progressList: [UserProgress]

    let questions: [QuizQuestion]
    let title: String

    @State private var currentIndex = 0
    @State private var selectedAnswer: String?
    @State private var showExplanation = false
    @State private var correctCount = 0
    @State private var showResults = false
    @State private var answers: [String] = []
    @State private var shuffledOptions: [String] = []

    private var progress: UserProgress? { progressList.first }

    var body: some View {
        NavigationStack {
            if showResults {
                resultsView
            } else if let question = questions[safe: currentIndex] {
                questionView(question)
            }
        }
    }

    // MARK: - Question
    private func questionView(_ question: QuizQuestion) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // Progress
                HStack {
                    Text("Question \(currentIndex + 1) of \(questions.count)")
                        .font(.subheadline.bold())
                    Spacer()
                    Text("\(correctCount) correct")
                        .font(.caption)
                        .foregroundStyle(.green)
                }

                ProgressView(value: Double(currentIndex), total: Double(questions.count))
                    .tint(.blue)

                // Question
                Text(question.text)
                    .font(.body.weight(.medium))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemBackground))
                    )

                // Options (shuffled)
                if !shuffledOptions.isEmpty {
                    ForEach(shuffledOptions, id: \.self) { option in
                        Button {
                            selectAnswer(option, for: question)
                        } label: {
                            HStack {
                                Text(option)
                                    .font(.subheadline)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                                if showExplanation {
                                    if option == question.correctAnswer {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.green)
                                    } else if option == selectedAnswer {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.red)
                                    }
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(optionColor(option, correct: question.correctAnswer))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(optionBorder(option, correct: question.correctAnswer), lineWidth: 2)
                                    )
                            )
                        }
                        .foregroundStyle(.primary)
                        .disabled(showExplanation)
                    }
                }

                // Explanation
                if showExplanation {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Explanation", systemImage: "lightbulb.fill")
                            .font(.subheadline.bold())
                            .foregroundStyle(.yellow)
                        Text(question.explanation)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.yellow.opacity(0.1))
                    )

                    Button {
                        nextQuestion()
                    } label: {
                        Text(currentIndex < questions.count - 1 ? "Next Question" : "See Results")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding()
        }
        .onAppear { shuffleCurrentOptions() }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("End") { dismiss() }
            }
        }
    }

    // MARK: - Results
    private var resultsView: some View {
        VStack(spacing: 24) {
            Spacer()

            let pct = questions.isEmpty ? 0 : Double(correctCount) / Double(questions.count) * 100

            Image(systemName: pct >= 70 ? "trophy.fill" : "arrow.counterclockwise.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(pct >= 70 ? .yellow : .orange)

            Text(pct >= 70 ? "Great Job!" : "Keep Studying!")
                .font(.largeTitle.bold())

            Text("\(correctCount) / \(questions.count) correct")
                .font(.title2)

            Text("\(Int(pct))%")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(pct >= 70 ? .green : .orange)

            Text(pct >= 70 ? "You're on track to pass!" : "Review the topics and try again.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("Done")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .onAppear {
            if let progress {
                progress.totalQuizzesTaken += 1
                progress.totalCorrectAnswers += correctCount
                progress.quizzesTakenToday += 1
                progress.updateStreak()
            }
        }
    }

    // MARK: - Helpers
    private func selectAnswer(_ answer: String, for question: QuizQuestion) {
        selectedAnswer = answer
        if answer == question.correctAnswer {
            correctCount += 1
        }
        withAnimation(.spring(duration: 0.3)) {
            showExplanation = true
        }
    }

    private func nextQuestion() {
        if currentIndex < questions.count - 1 {
            currentIndex += 1
            selectedAnswer = nil
            showExplanation = false
            shuffleCurrentOptions()
        } else {
            showResults = true
        }
    }

    private func shuffleCurrentOptions() {
        if let question = questions[safe: currentIndex],
           let options = question.options {
            shuffledOptions = options.shuffled()
        } else {
            shuffledOptions = []
        }
    }

    private func optionColor(_ option: String, correct: String) -> Color {
        guard showExplanation else { return Color(.secondarySystemBackground) }
        if option == correct { return .green.opacity(0.15) }
        if option == selectedAnswer { return .red.opacity(0.15) }
        return Color(.secondarySystemBackground)
    }

    private func optionBorder(_ option: String, correct: String) -> Color {
        guard showExplanation else {
            return option == selectedAnswer ? .blue.opacity(0.5) : .clear
        }
        if option == correct { return .green.opacity(0.5) }
        if option == selectedAnswer { return .red.opacity(0.5) }
        return .clear
    }
}

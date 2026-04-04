import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var context
    @Query private var progressList: [UserProgress]
    @State private var currentPage = 0

    private var progress: UserProgress? { progressList.first }

    private let pages: [(icon: String, title: String, subtitle: String, color: Color)] = [
        ("graduationcap.fill", "Welcome to\nD426 Mastery", "Your complete study companion for WGU's Data Management Foundations course", .blue),
        ("rectangle.stack.fill", "400+ Flashcards", "Master every concept with spaced repetition. The app learns what you know and focuses on what you don't.", .teal),
        ("checkmark.circle.fill", "Mock OA Exams", "200+ exam-style questions that mirror the real Objective Assessment", .green),
        ("terminal.fill", "SQL Playground", "Write and execute real SQL queries against 5 sample databases", .purple),
        ("flame.fill", "Let's Get Started!", "Track your streak, build mastery, and pass D426 with confidence.", .orange)
    ]

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        VStack(spacing: 24) {
                            Spacer()

                            Image(systemName: pages[index].icon)
                                .font(.system(size: 80))
                                .foregroundStyle(pages[index].color)
                                .symbolEffect(.bounce, value: currentPage == index)

                            Text(pages[index].title)
                                .font(.largeTitle.bold())
                                .multilineTextAlignment(.center)

                            Text(pages[index].subtitle)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)

                            Spacer()
                            Spacer()
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Custom page indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        Capsule()
                            .fill(i == currentPage ? pages[currentPage].color : .gray.opacity(0.3))
                            .frame(width: i == currentPage ? 24 : 8, height: 8)
                            .animation(.spring(duration: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 32)

                // Button
                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation { currentPage += 1 }
                    } else {
                        completeOnboarding()
                    }
                } label: {
                    Text(currentPage == pages.count - 1 ? "Start Learning" : "Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(pages[currentPage].color)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)

                if currentPage < pages.count - 1 {
                    Button("Skip") {
                        completeOnboarding()
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                Spacer().frame(height: 24)
            }
        }
    }

    private func completeOnboarding() {
        if let progress {
            progress.onboardingCompleted = true
        } else {
            let p = UserProgress()
            p.onboardingCompleted = true
            context.insert(p)
        }
    }
}

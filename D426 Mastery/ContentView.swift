import SwiftUI
import SwiftData
import StoreKit

struct ContentView: View {
    @Query private var progressList: [UserProgress]
    @State private var selectedTab = 0

    private var showOnboarding: Bool {
        guard let progress = progressList.first else { return true }
        return !progress.onboardingCompleted
    }

    var body: some View {
        Group {
            if showOnboarding {
                OnboardingView()
            } else {
                mainTabView
            }
        }
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            DashboardView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .tag(0)

            FlashcardStudyView()
                .tabItem {
                    Label("Cards", systemImage: "rectangle.stack.fill")
                }
                .tag(1)

            QuizView()
                .tabItem {
                    Label("Quizzes", systemImage: "checkmark.circle.fill")
                }
                .tag(2)

            SQLPlaygroundView()
                .tabItem {
                    Label("SQL Lab", systemImage: "terminal.fill")
                }
                .tag(3)

            MoreView()
                .tabItem {
                    Label("More", systemImage: "ellipsis.circle.fill")
                }
                .tag(4)
        }
        .tint(.blue)
    }
}

struct MoreView: View {
    @Environment(\.requestReview) private var requestReview

    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    ERBuilderView()
                } label: {
                    Label("ER Diagram Builder", systemImage: "rectangle.3.group")
                }

                NavigationLink {
                    GlossaryView()
                } label: {
                    Label("Glossary", systemImage: "book.fill")
                }

                NavigationLink {
                    StatsView()
                } label: {
                    Label("Statistics", systemImage: "chart.bar.fill")
                }

                NavigationLink {
                    PremiumView()
                } label: {
                    Label {
                        Text("Premium")
                    } icon: {
                        Image(systemName: "crown.fill")
                            .foregroundStyle(.yellow)
                    }
                }

                Section("Support") {
                    Button {
                        requestReview()
                    } label: {
                        Label("Rate D426 Mastery", systemImage: "star.fill")
                            .foregroundStyle(.primary)
                    }

                    Link(destination: URL(string: "mailto:support@ellasid.com")!) {
                        Label("Contact Support", systemImage: "envelope.fill")
                            .foregroundStyle(.primary)
                    }

                    Link(destination: URL(string: "https://johndisalle.github.io/D426/support")!) {
                        Label("Help Center", systemImage: "questionmark.circle.fill")
                            .foregroundStyle(.primary)
                    }
                }

                Section("Legal") {
                    Link(destination: URL(string: "https://johndisalle.github.io/D426/terms-of-service")!) {
                        Label("Terms of Service", systemImage: "doc.text.fill")
                            .foregroundStyle(.primary)
                    }

                    Link(destination: URL(string: "https://johndisalle.github.io/D426/privacy-policy")!) {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                            .foregroundStyle(.primary)
                    }
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0").foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("More")
        }
    }
}

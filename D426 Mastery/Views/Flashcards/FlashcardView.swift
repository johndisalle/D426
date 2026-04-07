import SwiftUI
import SwiftData

struct FlashcardStudyView: View {
    @Environment(\.modelContext) private var context
    @Query private var allCards: [Flashcard]
    @Query private var progressList: [UserProgress]
    @Query private var topics: [Topic]

    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var offset: CGSize = .zero
    @State private var selectedTopic: Topic?
    @State private var showTopicPicker = false
    @State private var searchText = ""
    @State private var showBrowser = false
    @State private var showPremiumGate = false

    private var isPremium: Bool { PremiumManager.shared.isPremium }
    private var progress: UserProgress? { progressList.first }

    private static let freeCardLimit = 50

    private var availableCards: [Flashcard] {
        if isPremium { return allCards }
        return Array(allCards.prefix(Self.freeCardLimit))
    }

    private var dueCards: [Flashcard] {
        let cards = selectedTopic == nil ? availableCards : availableCards.filter { $0.topic?.id == selectedTopic?.id }
        return SRSEngine.dueCards(from: cards)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Premium upsell banner
                if !isPremium {
                    Button { showPremiumGate = true } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "lock.fill")
                                .foregroundStyle(.yellow)
                            Text("\(Self.freeCardLimit) of \(allCards.count) cards free")
                                .font(.caption.weight(.medium))
                            Spacer()
                            Text("Unlock All")
                                .font(.caption.bold())
                                .foregroundStyle(.yellow)
                        }
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.yellow.opacity(0.1))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(.yellow.opacity(0.2), lineWidth: 1))
                        )
                    }
                    .foregroundStyle(.primary)
                    .padding(.horizontal)
                }

                // Topic filter
                topicFilterBar

                if dueCards.isEmpty {
                    emptyState
                } else {
                    // Progress bar
                    HStack {
                        Text("\(currentIndex + 1) / \(dueCards.count)")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        ProgressView(value: Double(currentIndex), total: Double(max(1, dueCards.count)))
                            .tint(.blue)
                    }
                    .padding(.horizontal)

                    // Card
                    cardView
                        .padding(.horizontal)

                    // Rating buttons
                    if isFlipped {
                        ratingButtons
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else {
                        Text("Tap card to reveal answer")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()
            }
            .navigationTitle("Flashcards")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        Button { showBrowser = true } label: {
                            Image(systemName: "magnifyingglass")
                        }
                        Button { showTopicPicker.toggle() } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                        }
                    }
                }
            }
            .sheet(isPresented: $showTopicPicker) {
                topicPickerSheet
            }
            .sheet(isPresented: $showBrowser) {
                flashcardBrowserSheet
            }
            .sheet(isPresented: $showPremiumGate) {
                PremiumView()
            }
        }
    }

    // MARK: - Topic Filter
    private var topicFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: "All", isSelected: selectedTopic == nil) {
                    selectedTopic = nil
                    resetCard()
                }
                ForEach(topics) { topic in
                    FilterChip(
                        title: topic.name.components(separatedBy: " ").prefix(2).joined(separator: " "),
                        isSelected: selectedTopic?.id == topic.id
                    ) {
                        selectedTopic = topic
                        resetCard()
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Card
    private var cardView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.2), radius: 10, y: 5)

            VStack(spacing: 16) {
                if let card = dueCards[safe: currentIndex] {
                    if !isFlipped {
                        // Question side
                        VStack(spacing: 16) {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.largeTitle)
                                .foregroundStyle(.blue)

                            Text(card.question)
                                .font(.title3.weight(.medium))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)

                            if !card.tags.isEmpty {
                                HStack {
                                    ForEach(card.tags.prefix(3), id: \.self) { tag in
                                        Text(tag)
                                            .font(.caption2)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(.blue.opacity(0.1))
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                    } else {
                        // Answer side
                        VStack(spacing: 16) {
                            Image(systemName: "lightbulb.fill")
                                .font(.largeTitle)
                                .foregroundStyle(.yellow)

                            Text(card.answer)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(24)
        }
        .frame(height: 320)
        .rotation3DEffect(.degrees(isFlipped ? 0 : 0), axis: (x: 0, y: 1, z: 0))
        .onTapGesture {
            withAnimation(.spring(duration: 0.4)) {
                isFlipped.toggle()
            }
        }
        .offset(offset)
        .gesture(
            DragGesture()
                .onChanged { offset = $0.translation }
                .onEnded { _ in
                    withAnimation { offset = .zero }
                }
        )
    }

    // MARK: - Rating
    private var ratingButtons: some View {
        HStack(spacing: 12) {
            ForEach(SRSRating.allCases, id: \.rawValue) { rating in
                Button {
                    rateCard(rating)
                } label: {
                    VStack(spacing: 4) {
                        Text(rating.label)
                            .font(.subheadline.bold())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(ratingColor(rating).opacity(0.15))
                    .foregroundStyle(ratingColor(rating))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(.horizontal)
    }

    private func ratingColor(_ rating: SRSRating) -> Color {
        switch rating {
        case .again: return .red
        case .hard: return .orange
        case .good: return .blue
        case .easy: return .green
        }
    }

    // MARK: - Empty
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)
            Text("All Caught Up!")
                .font(.title2.bold())
            Text("No cards due for review right now.\nCheck back later or study a specific topic.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
    }

    // MARK: - Sheet
    private var topicPickerSheet: some View {
        NavigationStack {
            List {
                Button("All Topics") {
                    selectedTopic = nil
                    showTopicPicker = false
                    resetCard()
                }
                ForEach(topics) { topic in
                    Button {
                        selectedTopic = topic
                        showTopicPicker = false
                        resetCard()
                    } label: {
                        HStack {
                            Image(systemName: topic.iconName)
                                .foregroundStyle(Color(hex: topic.colorHex))
                            Text(topic.name)
                            Spacer()
                            Text("\(topic.flashcards.count) cards")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .foregroundStyle(.primary)
                }
            }
            .navigationTitle("Filter by Topic")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { showTopicPicker = false }
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Actions
    private func rateCard(_ rating: SRSRating) {
        guard let card = dueCards[safe: currentIndex] else { return }
        SRSEngine.processReview(card: card, rating: rating)

        // Haptic feedback
        switch rating {
        case .easy, .good: UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .hard: UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .again: UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }

        // Update progress
        if let progress {
            progress.totalCardsReviewed += 1
            progress.cardsReviewedToday += 1
            progress.updateStreak()
        }

        // Update topic mastery
        if let topic = card.topic {
            let topicCards = allCards.filter { $0.topic?.id == topic.id }
            let reviewed = topicCards.filter { $0.repetitions > 0 }
            let avgEase = reviewed.isEmpty ? 0 : reviewed.map(\.easeFactor).reduce(0, +) / Double(reviewed.count)
            topic.masteryPercentage = min(100, (avgEase / 2.5) * (Double(reviewed.count) / Double(topicCards.count)) * 100)
        }

        withAnimation {
            isFlipped = false
            if currentIndex < dueCards.count - 1 {
                currentIndex += 1
            } else {
                currentIndex = 0
            }
        }
    }

    private func resetCard() {
        currentIndex = 0
        isFlipped = false
    }

    // MARK: - Flashcard Browser with Search
    private var flashcardBrowserSheet: some View {
        NavigationStack {
            List {
                let filtered = allCards.filter { card in
                    searchText.isEmpty ||
                    card.question.localizedCaseInsensitiveContains(searchText) ||
                    card.answer.localizedCaseInsensitiveContains(searchText) ||
                    card.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
                }

                ForEach(filtered) { card in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(card.question)
                            .font(.subheadline.weight(.medium))
                        Text(card.answer)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                        if let topic = card.topic {
                            Text(topic.name)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(hex: topic.colorHex).opacity(0.2))
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .searchable(text: $searchText, prompt: "Search flashcards...")
            .navigationTitle("All Flashcards")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { showBrowser = false }
                }
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? .blue : Color(.tertiarySystemBackground))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

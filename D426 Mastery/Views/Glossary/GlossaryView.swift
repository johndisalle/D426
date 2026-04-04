import SwiftUI
import SwiftData

struct GlossaryView: View {
    @Query(sort: \GlossaryTerm.term) private var terms: [GlossaryTerm]
    @State private var searchText = ""
    @State private var selectedCategory = "All"

    private var categories: [String] {
        ["All"] + Array(Set(terms.map(\.category))).sorted()
    }

    private var filtered: [GlossaryTerm] {
        terms.filter { term in
            let matchesSearch = searchText.isEmpty ||
                term.term.localizedCaseInsensitiveContains(searchText) ||
                term.definition.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategory == "All" || term.category == selectedCategory
            return matchesSearch && matchesCategory
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(categories, id: \.self) { cat in
                            FilterChip(title: cat, isSelected: selectedCategory == cat) {
                                selectedCategory = cat
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }

                List(filtered) { term in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(term.term)
                                .font(.headline)
                            Spacer()
                            Text(term.category)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(.blue.opacity(0.1))
                                .clipShape(Capsule())
                        }

                        Text(term.definition)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        if !term.relatedTerms.isEmpty {
                            HStack(spacing: 4) {
                                Text("Related:")
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                                ForEach(term.relatedTerms.prefix(3), id: \.self) { related in
                                    Text(related)
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(.gray.opacity(0.1))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
            }
            .navigationTitle("Glossary")
            .searchable(text: $searchText, prompt: "Search terms...")
        }
    }
}

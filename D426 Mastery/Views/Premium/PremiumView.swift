import SwiftUI
import StoreKit

struct PremiumView: View {
    private let premium = PremiumManager.shared
    @State private var selectedProduct: Product?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(.yellow)

                    Text("D426 Mastery Premium")
                        .font(.title.bold())

                    Text("Unlock everything and pass D426\nwith confidence")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 32)

                // Features
                VStack(alignment: .leading, spacing: 16) {
                    premiumFeature(icon: "rectangle.3.group", title: "ER Diagram Builder", subtitle: "Interactive drag-and-drop entity diagrams")
                    premiumFeature(icon: "infinity", title: "Unlimited Mock OAs", subtitle: "Unlimited full-length practice exams")
                    premiumFeature(icon: "chart.bar.fill", title: "Advanced Analytics", subtitle: "Detailed performance insights by topic")
                    premiumFeature(icon: "star.fill", title: "Priority Content", subtitle: "Early access to new study materials")
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                )

                // StoreKit Product Buttons
                if premium.products.isEmpty {
                    // Fallback display before products load
                    VStack(spacing: 12) {
                        planCard(name: "Monthly", price: "$7.99/mo", desc: "Full access, cancel anytime", highlight: false)
                        planCard(name: "Lifetime", price: "$24.99", desc: "One-time purchase, forever access", highlight: true)
                    }
                } else {
                    VStack(spacing: 12) {
                        ForEach(premium.products, id: \.id) { product in
                            Button {
                                selectedProduct = product
                            } label: {
                                let isSelected = selectedProduct?.id == product.id
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(product.displayName)
                                            .font(.headline)
                                        Text(product.description)
                                            .font(.caption)
                                            .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
                                    }
                                    Spacer()
                                    Text(product.displayPrice)
                                        .font(.title3.bold())
                                        .foregroundStyle(isSelected ? .white : .primary)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(isSelected ? .blue : Color(.secondarySystemBackground))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(isSelected ? .blue : .gray.opacity(0.3), lineWidth: 2)
                                        )
                                )
                                .foregroundStyle(isSelected ? .white : .primary)
                            }
                        }
                    }
                }

                // Purchase button
                Button {
                    Task {
                        if let product = selectedProduct ?? premium.products.last {
                            _ = await premium.purchase(product)
                        }
                    }
                } label: {
                    HStack {
                        if premium.isLoading {
                            ProgressView()
                                .tint(.white)
                        }
                        Text("Subscribe Now")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                Button("Restore Purchases") {
                    Task { await premium.restore() }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                VStack(spacing: 4) {
                    Text("Subscriptions auto-renew unless cancelled.")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)

                    HStack(spacing: 4) {
                        Link("Terms of Service", destination: URL(string: "https://johndisalle.github.io/d426/terms-of-service")!)
                        Text("&").foregroundStyle(.tertiary)
                        Link("Privacy Policy", destination: URL(string: "https://johndisalle.github.io/d426/privacy-policy")!)
                    }
                    .font(.caption2)
                }
                .multilineTextAlignment(.center)
                    .padding(.bottom, 32)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .task {
            await premium.loadProducts()
            if selectedProduct == nil {
                selectedProduct = premium.products.last // default to lifetime
            }
        }
    }

    private func premiumFeature(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.yellow)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func planCard(name: String, price: String, desc: String, highlight: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(name).font(.headline)
                Text(desc).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text(price).font(.title3.bold())
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(highlight ? .blue : Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(highlight ? .blue : .gray.opacity(0.3), lineWidth: 2)
                )
        )
        .foregroundStyle(highlight ? .white : .primary)
    }
}

import SwiftUI

struct PremiumView: View {
    @State private var selectedPlan: PremiumManager.Plan = .lifetime
    @State private var isLoading = false

    private let premium = PremiumManager.shared

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
                    premiumFeature(icon: "diagram", title: "ER Diagram Builder", subtitle: "Interactive drag-and-drop entity diagrams")
                    premiumFeature(icon: "infinity", title: "Unlimited Mock OAs", subtitle: "Unlimited full-length practice exams")
                    premiumFeature(icon: "chart.bar.fill", title: "Advanced Analytics", subtitle: "Detailed performance insights by topic")
                    premiumFeature(icon: "star.fill", title: "Priority Content", subtitle: "Early access to new study materials")
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                )

                // Plans
                VStack(spacing: 12) {
                    ForEach(PremiumManager.Plan.allCases, id: \.rawValue) { plan in
                        Button {
                            selectedPlan = plan
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(plan.displayName)
                                        .font(.headline)
                                    Text(plan.description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(plan.price)
                                    .font(.title3.bold())
                                    .foregroundStyle(selectedPlan == plan ? .white : .primary)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedPlan == plan ? .blue : Color(.secondarySystemBackground))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedPlan == plan ? .blue : .gray.opacity(0.3), lineWidth: 2)
                                    )
                            )
                            .foregroundStyle(selectedPlan == plan ? .white : .primary)
                        }
                    }
                }

                // Purchase button
                Button {
                    Task {
                        await premium.purchase(selectedPlan)
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

                Text("Subscriptions auto-renew unless cancelled. Terms & Privacy apply.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 32)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
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
}

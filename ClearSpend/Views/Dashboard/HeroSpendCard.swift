//
//  HeroSpendCard.swift
//  ClearSpend
//

import SwiftUI

struct HeroSpendCard: View {

    let monthName: String
    let totalSpend: Double
    let transactionCount: Int

    private var formattedAmount: String {
        totalSpend.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {

            Text(monthName.uppercased())
                .font(DesignSystem.Typography.labelMedium)
                .tracking(1.2)
                .foregroundColor(.white.opacity(0.7))

            Text(formattedAmount)
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 10, weight: .bold))

                Text("\(transactionCount) transaction\(transactionCount == 1 ? "" : "s")")
                    .font(DesignSystem.Typography.labelMedium)
            }
            .foregroundColor(.white.opacity(0.8))
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(Capsule().fill(.white.opacity(0.15)))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xlarge)
                .fill(
                    LinearGradient(
                        colors: [
                            DesignSystem.Colors.heroGradientStart,
                            DesignSystem.Colors.heroGradientEnd
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .shadow(color: DesignSystem.Colors.primary.opacity(0.3), radius: 12, x: 0, y: 6)
    }
}

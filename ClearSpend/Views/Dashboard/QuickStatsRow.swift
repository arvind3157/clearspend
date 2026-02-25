//
//  QuickStatsRow.swift
//  ClearSpend
//

import SwiftUI

struct QuickStatsRow: View {

    let dailyAverage: Double
    let transactionCount: Int
    let topCategory: String

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            StatPill(
                icon: "calendar",
                label: "Daily Avg",
                value: dailyAverage.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD")),
                tint: DesignSystem.Colors.info
            )

            StatPill(
                icon: "arrow.left.arrow.right",
                label: "Transactions",
                value: "\(transactionCount)",
                tint: DesignSystem.Colors.success
            )

            StatPill(
                icon: "chart.bar.fill",
                label: "Top",
                value: topCategory,
                tint: DesignSystem.Colors.warning
            )
        }
    }
}

private struct StatPill: View {

    let icon: String
    let label: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(tint)

            Text(value)
                .font(DesignSystem.Typography.labelMedium)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(DesignSystem.Typography.labelSmall)
                .foregroundColor(DesignSystem.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.md)
        .padding(.horizontal, DesignSystem.Spacing.xs)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(tint.opacity(0.08))
        )
    }
}

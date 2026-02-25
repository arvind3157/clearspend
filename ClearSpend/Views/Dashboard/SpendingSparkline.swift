//
//  SpendingSparkline.swift
//  ClearSpend
//

import SwiftUI

struct SpendingSparkline: View {

    let data: [(day: Int, amount: Double)]

    private var maxAmount: Double {
        data.map(\.amount).max() ?? 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Daily Spending")
                .font(DesignSystem.Typography.headlineSmall)
                .foregroundColor(DesignSystem.Colors.textPrimary)

            GeometryReader { geo in
                let barWidth = max(2, (geo.size.width - CGFloat(data.count - 1) * 3) / CGFloat(data.count))
                let maxH = geo.size.height

                HStack(alignment: .bottom, spacing: 3) {
                    ForEach(data, id: \.day) { item in
                        let heightRatio = maxAmount > 0 ? item.amount / maxAmount : 0
                        RoundedRectangle(cornerRadius: 3)
                            .fill(barColor(for: heightRatio))
                            .frame(width: barWidth, height: max(2, CGFloat(heightRatio) * maxH))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
            .frame(height: 80)
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(DesignSystem.Colors.surface)
        )
        .shadow(color: DesignSystem.Shadows.small.color, radius: DesignSystem.Shadows.small.radius, x: DesignSystem.Shadows.small.x, y: DesignSystem.Shadows.small.y)
    }

    private func barColor(for ratio: Double) -> Color {
        if ratio > 0.7 {
            return DesignSystem.Colors.primary
        } else if ratio > 0.3 {
            return DesignSystem.Colors.primaryLight
        } else {
            return DesignSystem.Colors.primaryLight.opacity(0.5)
        }
    }
}

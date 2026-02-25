//
//  CategoryScrollCard.swift
//  ClearSpend
//

import SwiftUI

struct CategoryScrollCard: View {

    let name: String
    let icon: String
    let colorHex: String
    let amount: Double
    let percentage: Double

    private var color: Color {
        Color(hex: colorHex)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {

            // Icon circle
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
            }

            Text(name)
                .font(DesignSystem.Typography.titleMedium)
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .lineLimit(1)

            Text(amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                .font(DesignSystem.Typography.headlineSmall)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.Colors.textPrimary)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color.opacity(0.12))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(min(percentage, 1.0)), height: 6)
                }
            }
            .frame(height: 6)

            Text("\(Int(percentage * 100))%")
                .font(DesignSystem.Typography.labelSmall)
                .foregroundColor(DesignSystem.Colors.textTertiary)
        }
        .padding(DesignSystem.Spacing.md)
        .frame(width: 150)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(DesignSystem.Colors.surface)
        )
        .shadow(color: DesignSystem.Shadows.small.color, radius: DesignSystem.Shadows.small.radius, x: DesignSystem.Shadows.small.x, y: DesignSystem.Shadows.small.y)
    }
}

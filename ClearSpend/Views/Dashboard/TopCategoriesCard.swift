//
//  TopCategoriesCard.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftUI

struct TopCategoriesCard: View {

    let categories: [(name: String, amount: Double)]
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                Text("Top Categories")
                    .font(DesignSystem.Typography.titleSmall)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                Spacer()
                
                Image(systemName: "chart.bar.fill")
                    .font(DesignSystem.Typography.titleMedium)
                    .foregroundColor(color.opacity(0.7))
            }
            
            if categories.isEmpty {
                Text("No expenses yet")
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                    .italic()
            } else {
                VStack(spacing: DesignSystem.Spacing.xs) {
                    ForEach(Array(categories.enumerated()), id: \.offset) { index, category in
                        HStack {
                            Text("\(index + 1). \(category.name)")
                                .font(DesignSystem.Typography.bodyMedium)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Text(category.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                                .font(DesignSystem.Typography.bodyMedium)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                                .fontWeight(.medium)
                        }
                    }
                }
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(DesignSystem.Colors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                        .stroke(color.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: DesignSystem.Shadows.small.color, radius: DesignSystem.Shadows.small.radius, x: DesignSystem.Shadows.small.x, y: DesignSystem.Shadows.small.y)
    }
}

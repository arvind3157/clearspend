//
//  SummaryCard.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftUI

struct SummaryCard: View {

    let title: String
    let amount: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                Text(title)
                    .font(DesignSystem.Typography.titleSmall)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                Spacer()
                
                // Icon based on title
                Image(systemName: iconForTitle(title))
                    .font(DesignSystem.Typography.titleMedium)
                    .foregroundColor(color.opacity(0.7))
            }
            
            Text(amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                .font(DesignSystem.Typography.headlineSmall)
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .fontWeight(.semibold)
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
    
    private func iconForTitle(_ title: String) -> String {
        switch title.lowercased() {
        case "income":
            return "arrow.down.circle.fill"
        case "spent", "expenses":
            return "arrow.up.circle.fill"
        case "savings":
            return "piggy.bank.fill"
        default:
            return "chart.bar.fill"
        }
    }
}

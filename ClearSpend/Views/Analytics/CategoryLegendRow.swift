//
//  CategoryLegendRow.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftUI

struct CategoryLegendRow: View {
    let item: CategorySpend
    let totalAmount: Double
    
    init(item: CategorySpend, totalAmount: Double) {
        self.item = item
        self.totalAmount = totalAmount
    }
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Category Color Circle
            ZStack {
                Circle()
                    .fill(Color(hex: item.category.colorHex))
                    .frame(width: 16, height: 16)
                    .overlay(
                        Circle()
                            .stroke(DesignSystem.Colors.background, lineWidth: 2)
                    )
            }
            
            // Category Name and Icon
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: iconForCategory(item.category.name))
                    .font(DesignSystem.Typography.titleSmall)
                    .foregroundColor(colorForCategory(item.category.name))
                
                Text(item.category.name)
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            // Amount and Percentage
            VStack(alignment: .trailing, spacing: DesignSystem.Spacing.xs) {
                Text(
                    item.amount,
                    format: .currency(code: Locale.current.currency?.identifier ?? "USD")
                )
                .font(DesignSystem.Typography.bodyMedium)
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text(String(format: "%.1f%%", percentage))
                    .font(DesignSystem.Typography.bodySmall)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }
        }
        .padding(.vertical, DesignSystem.Spacing.sm)
        .contentShape(Rectangle())
    }
    
    private var percentage: Double {
        guard totalAmount > 0 else { return 0 }
        return (item.amount / totalAmount) * 100
    }
    
    private func iconForCategory(_ categoryName: String) -> String {
        switch categoryName.lowercased() {
        case "food", "restaurant", "dining":
            return "fork.knife"
        case "transport", "travel", "uber", "taxi":
            return "car.fill"
        case "shopping", "retail":
            return "bag.fill"
        case "entertainment", "movies", "games":
            return "tv.fill"
        case "health", "medical", "pharmacy":
            return "cross.fill"
        case "education", "books", "learning":
            return "book.fill"
        case "bills", "utilities":
            return "doc.fill"
        case "groceries":
            return "cart.fill"
        default:
            return "wallet.pass"
        }
    }
    
    private func colorForCategory(_ categoryName: String) -> Color {
        switch categoryName.lowercased() {
        case "food", "restaurant", "dining":
            return DesignSystem.Colors.warning
        case "transport", "travel", "uber", "taxi":
            return DesignSystem.Colors.info
        case "shopping", "retail":
            return DesignSystem.Colors.primary
        case "entertainment", "movies", "games":
            return DesignSystem.Colors.success
        case "health", "medical", "pharmacy":
            return DesignSystem.Colors.danger
        case "education", "books", "learning":
            return DesignSystem.Colors.primaryDark
        case "bills", "utilities":
            return DesignSystem.Colors.warning
        case "groceries":
            return DesignSystem.Colors.success
        default:
            return DesignSystem.Colors.gray600
        }
    }
}

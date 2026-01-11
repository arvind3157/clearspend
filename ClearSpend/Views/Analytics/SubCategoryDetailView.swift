//
//  SubCategoryDetailView.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftUI

struct SubCategoryDetailView: View {

    let subCategory: SubCategory
    let ledger: MonthLedger?
    
    private var expenses: [Expense] {
        guard let expenses = ledger?.expenses else { return [] }

        return expenses
            .filter { $0.subCategory?.id == subCategory.id }
            .sorted { $0.date > $1.date }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.md) {
                ForEach(expenses) { expense in
                    NavigationLink(destination: ExpenseDetailView(expense: expense)) {
                        HStack(spacing: DesignSystem.Spacing.md) {
                            // Category Icon with Bill Image Indicator
                            ZStack {
                                Circle()
                                    .fill(DesignSystem.Colors.surfaceVariant)
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: iconForCategory(expense.subCategory?.category?.name ?? ""))
                                    .font(DesignSystem.Typography.titleMedium)
                                    .foregroundColor(colorForCategory(expense.subCategory?.category?.name ?? ""))
                                
                                // Bill Image Indicator
                                if expense.billImage != nil {
                                    Circle()
                                        .fill(DesignSystem.Colors.info)
                                        .frame(width: 8, height: 8)
                                        .offset(x: 12, y: -12)
                                }
                            }
                            
                            // Expense Details
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                                Text(expense.merchant ?? expense.subCategory?.name ?? "Unknown")
                                    .font(DesignSystem.Typography.bodyMedium)
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                    .fontWeight(.medium)
                                
                                HStack(spacing: DesignSystem.Spacing.sm) {
                                    Text(expense.date, style: .date)
                                        .font(DesignSystem.Typography.bodySmall)
                                        .foregroundColor(DesignSystem.Colors.textSecondary)
                                    
                                    if let note = expense.note, !note.isEmpty {
                                        Text(note)
                                            .font(DesignSystem.Typography.bodySmall)
                                            .foregroundColor(DesignSystem.Colors.textTertiary)
                                            .lineLimit(1)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            // Amount
                            VStack(alignment: .trailing, spacing: DesignSystem.Spacing.xs) {
                                Text(
                                    expense.amount,
                                    format: .currency(code: Locale.current.currency?.identifier ?? "USD")
                                )
                                .font(DesignSystem.Typography.bodyMedium)
                                .fontWeight(.semibold)
                                .foregroundColor(DesignSystem.Colors.danger)
                                
                                Text(expense.paymentMethod.capitalized)
                                    .font(DesignSystem.Typography.bodySmall)
                                    .foregroundColor(DesignSystem.Colors.textTertiary)
                            }
                        }
                        .padding(DesignSystem.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                .fill(DesignSystem.Colors.cardBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                        .stroke(DesignSystem.Colors.gray200, lineWidth: 1)
                                )
                        )
                        .shadow(color: DesignSystem.Shadows.small.color, radius: DesignSystem.Shadows.small.radius, x: DesignSystem.Shadows.small.x, y: DesignSystem.Shadows.small.y)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
        .background(DesignSystem.Colors.background)
        .navigationTitle(subCategory.name)
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

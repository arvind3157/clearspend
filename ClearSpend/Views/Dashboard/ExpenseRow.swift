//
//  ExpenseRow.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftUI

struct ExpenseRow: View {
    let expense: Expense

    private var categoryName: String {
        expense.subCategory?.category?.name ?? ""
    }

    var body: some View {
        NavigationLink(destination: ExpenseDetailView(expense: expense)) {
            HStack(spacing: DesignSystem.Spacing.md) {

                // Category Icon
                ZStack {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                        .fill(colorForCategory(categoryName).opacity(0.12))
                        .frame(width: 48, height: 48)

                    Image(systemName: iconForCategory(categoryName))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(colorForCategory(categoryName))

                    if expense.billImage != nil {
                        Circle()
                            .fill(DesignSystem.Colors.info)
                            .frame(width: 8, height: 8)
                            .offset(x: 16, y: -16)
                    }
                }

                // Details
                VStack(alignment: .leading, spacing: 3) {
                    Text(expense.subCategory?.name ?? "Unknown")
                        .font(DesignSystem.Typography.titleMedium)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                        .fontWeight(.semibold)

                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Text(expense.date, style: .date)
                            .font(DesignSystem.Typography.bodySmall)
                            .foregroundColor(DesignSystem.Colors.textTertiary)

                        if let note = expense.note, !note.isEmpty {
                            Text("·")
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                            Text(note)
                                .font(DesignSystem.Typography.bodySmall)
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                                .lineLimit(1)
                        }
                    }
                }

                Spacer()

                // Amount
                Text(
                    expense.amount,
                    format: .currency(code: Locale.current.currency?.identifier ?? "USD")
                )
                .font(DesignSystem.Typography.headlineSmall)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            }
            .padding(DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .fill(DesignSystem.Colors.surface)
            )
            .shadow(color: DesignSystem.Shadows.small.color, radius: DesignSystem.Shadows.small.radius, x: DesignSystem.Shadows.small.x, y: DesignSystem.Shadows.small.y)
        }
        .buttonStyle(PlainButtonStyle())
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

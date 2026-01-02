//
//  AddExpenseView.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftUI
import SwiftData

struct AddExpenseView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Category.name)
    private var categories: [Category]

    @State private var amount: Double = 0
    @State private var selectedCategory: Category?
    @State private var selectedSubCategory: SubCategory?
    @State private var date: Date = .now
    @State private var note: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.xl) {
                    // Amount Section
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        Text("Amount")
                            .font(DesignSystem.Typography.headlineSmall)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        HStack {
                            Text(Locale.current.currencySymbol ?? "$")
                                .font(DesignSystem.Typography.displayMedium)
                                .foregroundColor(DesignSystem.Colors.primary)
                            
                            TextField("0.00", value: $amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                                .font(DesignSystem.Typography.displayMedium)
                                .fontWeight(.semibold)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(DesignSystem.Spacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                .fill(DesignSystem.Colors.surfaceVariant)
                                .overlay(
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                        .stroke(DesignSystem.Colors.primary.opacity(0.3), lineWidth: 2)
                                )
                        )
                    }
                    
                    // Category Section
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        Text("Category")
                            .font(DesignSystem.Typography.headlineSmall)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        NavigationLink {
                            CategoryPickerView(
                                categories: categories,
                                selectedCategory: $selectedCategory,
                                selectedSubCategory: $selectedSubCategory
                            )
                        } label: {
                            HStack {
                                Image(systemName: selectedCategory?.icon ?? "folder")
                                    .font(DesignSystem.Typography.titleMedium)
                                    .foregroundColor(colorForCategory(selectedCategory?.name ?? ""))
                                
                                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                                    Text(selectedCategory?.name ?? "Select Category")
                                        .font(DesignSystem.Typography.bodyMedium)
                                        .foregroundColor(selectedCategory != nil ? DesignSystem.Colors.textPrimary : DesignSystem.Colors.textTertiary)
                                    
                                    if selectedCategory != nil {
                                        Text("Tap to change")
                                            .font(DesignSystem.Typography.bodySmall)
                                            .foregroundColor(DesignSystem.Colors.textTertiary)
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(DesignSystem.Typography.titleSmall)
                                    .foregroundColor(DesignSystem.Colors.textTertiary)
                            }
                            .padding(DesignSystem.Spacing.lg)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                    .fill(DesignSystem.Colors.surfaceVariant)
                            )
                        }
                    }
                    
                    // Sub Category Section
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        Text("Sub Category")
                            .font(DesignSystem.Typography.headlineSmall)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        if let category = selectedCategory {
                            NavigationLink {
                                SubCategoryPickerView(
                                    category: category,
                                    selectedSubCategory: $selectedSubCategory
                                )
                            } label: {
                                HStack {
                                    Image(systemName: "tag")
                                        .font(DesignSystem.Typography.titleMedium)
                                        .foregroundColor(DesignSystem.Colors.primary)
                                    
                                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                                        Text(selectedSubCategory?.name ?? "Select Sub Category")
                                            .font(DesignSystem.Typography.bodyMedium)
                                            .foregroundColor(selectedSubCategory != nil ? DesignSystem.Colors.textPrimary : DesignSystem.Colors.textTertiary)
                                        
                                        if selectedSubCategory != nil {
                                            Text("Tap to change")
                                                .font(DesignSystem.Typography.bodySmall)
                                                .foregroundColor(DesignSystem.Colors.textTertiary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(DesignSystem.Typography.titleSmall)
                                        .foregroundColor(DesignSystem.Colors.textTertiary)
                                }
                                .padding(DesignSystem.Spacing.lg)
                                .background(
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                        .fill(DesignSystem.Colors.surfaceVariant)
                                )
                            }
                        } else {
                            HStack {
                                Image(systemName: "tag")
                                    .font(DesignSystem.Typography.titleMedium)
                                    .foregroundColor(DesignSystem.Colors.textTertiary)
                                
                                Text("Select category first")
                                    .font(DesignSystem.Typography.bodyMedium)
                                    .foregroundColor(DesignSystem.Colors.textTertiary)
                                
                                Spacer()
                            }
                            .padding(DesignSystem.Spacing.lg)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                    .fill(DesignSystem.Colors.gray100)
                            )
                        }
                    }
                    
                    // Details Section
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        Text("Details")
                            .font(DesignSystem.Typography.headlineSmall)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        VStack(spacing: DesignSystem.Spacing.md) {
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                                Text("Date")
                                    .font(DesignSystem.Typography.titleMedium)
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                
                                DatePicker("", selection: $date, displayedComponents: .date)
                                    .datePickerStyle(.graphical)
                                    .padding(DesignSystem.Spacing.md)
                                    .background(
                                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                            .fill(DesignSystem.Colors.surfaceVariant)
                                    )
                            }
                            
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                                Text("Note (Optional)")
                                    .font(DesignSystem.Typography.titleMedium)
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                
                                TextField("Add a note...", text: $note, axis: .vertical)
                                    .font(DesignSystem.Typography.bodyMedium)
                                    .padding(DesignSystem.Spacing.md)
                                    .background(
                                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                            .fill(DesignSystem.Colors.surfaceVariant)
                                    )
                                    .lineLimit(3...6)
                            }
                        }
                    }
                }
                .padding(DesignSystem.Spacing.lg)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .font(DesignSystem.Typography.labelLarge)
                    .foregroundColor(amount > 0 && selectedSubCategory != nil ? DesignSystem.Colors.primary : DesignSystem.Colors.textTertiary)
                    .disabled(amount <= 0 || selectedSubCategory == nil)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { 
                        dismiss() 
                    }
                    .font(DesignSystem.Typography.labelLarge)
                    .foregroundColor(DesignSystem.Colors.primary)
                }
            }
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

    private func save() {
        let ledger = MonthLedgerManager.currentMonthLedger(context: modelContext)

        let expense = Expense(
            amount: amount,
            date: date,
            paymentMethod: "cash",
            subCategory: selectedSubCategory,
            note: note.isEmpty ? nil : note
        )

        ledger.expenses.append(expense)
        modelContext.insert(expense)
    }
}

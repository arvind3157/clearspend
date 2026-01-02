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

    // MARK: - State

    @State private var amountText: String = ""

    @State private var selectedCategory: Category?
    @State private var selectedSubCategory: SubCategory?

    @State private var date: Date = Date()
    @State private var note: String = ""

    @State private var showCategoryPicker = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.xl) {

                    // MARK: - Amount
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        Text("Amount")
                            .font(DesignSystem.Typography.headlineSmall)

                        HStack {
                            Text(Locale.current.currencySymbol ?? "$")
                                .font(DesignSystem.Typography.displayMedium)
                                .foregroundColor(DesignSystem.Colors.primary)

                            TextField("0.00", text: $amountText)
                                .font(DesignSystem.Typography.displayMedium)
                                .keyboardType(.decimalPad)
                        }
                        .padding(DesignSystem.Spacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                .fill(DesignSystem.Colors.surfaceVariant)
                        )
                    }

                    // MARK: - Category + Subcategory
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        Text("Category")
                            .font(DesignSystem.Typography.headlineSmall)

                        Button {
                            showCategoryPicker = true
                        } label: {
                            HStack {
                                Image(systemName: selectedCategory?.icon ?? "folder")

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(
                                        selectedSubCategory?.name ??
                                        selectedCategory?.name ??
                                        "Select Category"
                                    )
                                    .foregroundColor(
                                        selectedCategory == nil
                                        ? DesignSystem.Colors.textTertiary
                                        : DesignSystem.Colors.textPrimary
                                    )

                                    if let category = selectedCategory {
                                        Text(category.name)
                                            .font(.caption)
                                            .foregroundColor(DesignSystem.Colors.textSecondary)
                                    }
                                }

                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(DesignSystem.Colors.textTertiary)
                            }
                            .padding(DesignSystem.Spacing.lg)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                    .fill(DesignSystem.Colors.surfaceVariant)
                            )
                        }
                    }

                    // MARK: - Details
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        Text("Details")
                            .font(DesignSystem.Typography.headlineSmall)

                        DatePicker(
                            "Date",
                            selection: $date,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)

                        TextField("Note (optional)", text: $note, axis: .vertical)
                            .padding(DesignSystem.Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                    .fill(DesignSystem.Colors.surfaceVariant)
                            )
                            .lineLimit(2...5)
                    }
                }
                .padding(DesignSystem.Spacing.lg)
            }
            .navigationTitle("Add Expense")
            .toolbar {

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .disabled(!canSave)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            // ✅ Category Picker Sheet
            .sheet(isPresented: $showCategoryPicker) {
                CategoryPickerView(
                    categories: categories,
                    selectedCategory: $selectedCategory,
                    selectedSubCategory: $selectedSubCategory
                )
            }
            // ✅ CRITICAL FIX
            .onChange(of: selectedCategory) { _, newCategory in
                if newCategory?.id != selectedSubCategory?.category?.id {
                    selectedSubCategory = nil
                }
            }
        }
    }

    // MARK: - Validation

    private var canSave: Bool {
        (Double(amountText) ?? 0) > 0 && selectedSubCategory != nil
    }

    // MARK: - Save

    private func save() {
        guard let amount = Double(amountText) else { return }

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

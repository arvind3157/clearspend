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
            Form {
                Section("Amount") {
                    TextField("Amount", value: $amount, format: .number)
                        .keyboardType(.decimalPad)
                }

                Section("Category") {
                    CategoryGridView(
                        categories: categories,
                        selectedCategory: $selectedCategory
                    )
                    .onChange(of: selectedCategory) {
                        selectedSubCategory = nil
                    }

                    if let subs = selectedCategory?.subCategories {
                        Picker("Sub Category", selection: $selectedSubCategory) {
                            Text("Select").tag(SubCategory?.none)
                            ForEach(subs) { sub in
                                Text(sub.name).tag(SubCategory?.some(sub))
                            }
                        }
                    }
                }

                Section("Details") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Note (optional)", text: $note)
                }
            }
            .navigationTitle("Add Expense")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveExpense()
                        dismiss()
                    }
                    .disabled(amount <= 0 || selectedSubCategory == nil)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func saveExpense() {
        let ledger = MonthLedgerManager.currentMonthLedger(
            context: modelContext
        )

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

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
            List {

                Section("Amount") {
                    TextField("Amount", value: $amount, format: .number)
                        .keyboardType(.decimalPad)
                }

                Section("Category") {
                    NavigationLink {
                        CategoryPickerView(
                            categories: categories,
                            selectedCategory: $selectedCategory,
                            selectedSubCategory: $selectedSubCategory
                        )
                    } label: {
                        Text(selectedCategory?.name ?? "Select Category")
                    }
                }

                Section("Sub Category") {
                    if let category = selectedCategory {
                        NavigationLink {
                            SubCategoryPickerView(
                                category: category,
                                selectedSubCategory: $selectedSubCategory
                            )
                        } label: {
                            Text(selectedSubCategory?.name ?? "Select Sub Category")
                        }
                    } else {
                        Text("Select category first")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Details") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Note", text: $note)
                }
            }
            .navigationTitle("Add Expense")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
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

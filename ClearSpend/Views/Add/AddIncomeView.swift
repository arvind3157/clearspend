//
//  AddIncomeView.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftUI
import SwiftData

struct AddIncomeView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var amount: Double = 0
    @State private var source: String = ""
    @State private var date: Date = .now
    @State private var note: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Amount") {
                    TextField("Amount", value: $amount, format: .number)
                        .keyboardType(.decimalPad)
                }

                Section("Source") {
                    TextField("Salary / Freelance / Bonus", text: $source)
                }

                Section("Details") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Note (optional)", text: $note)
                }
            }
            .navigationTitle("Add Income")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveIncome()
                        dismiss()
                    }
                    .disabled(amount <= 0 || source.isEmpty)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func saveIncome() {
        let ledger = MonthLedgerManager.currentMonthLedger(
            context: modelContext
        )

        let income = Income(
            amount: amount,
            source: source,
            date: date,
            note: note.isEmpty ? nil : note
        )

        ledger.incomes.append(income)
        modelContext.insert(income)
    }
}

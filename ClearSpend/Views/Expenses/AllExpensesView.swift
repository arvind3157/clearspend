//
//  AllExpensesView.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftUI
import SwiftData

struct AllExpensesView: View {

    @Environment(\.modelContext)
    private var modelContext

    let ledger: MonthLedger

    var body: some View {
        List {
            ForEach(expenses) { expense in
                ExpenseRow(expense: expense)
                    .contextMenu {
                        Button(role: .destructive) {
                            deleteExpense(expense)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .navigationTitle("All Expenses")
        .listStyle(.plain)
    }

    // MARK: - Data

    private var expenses: [Expense] {
        ledger.expenses.sorted { $0.date > $1.date }
    }

    // MARK: - Delete

    private func deleteExpense(_ expense: Expense) {
        withAnimation {
            modelContext.delete(expense)
            ledger.expenses.removeAll { $0.id == expense.id }
            try? modelContext.save()
        }
    }
}

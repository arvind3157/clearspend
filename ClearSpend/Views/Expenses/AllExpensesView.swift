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

    @State private var filter: ExpenseFilter = .month

    var body: some View {
        VStack(spacing: 0) {

            filterControl

            List {
                if filteredExpenses.isEmpty {
                    emptyState
                } else {
                    ForEach(filteredExpenses) { expense in
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
            }
            .listStyle(.plain)
        }
        .navigationTitle("All Expenses")
    }

    // MARK: - Filter Control

    private var filterControl: some View {
        Picker("Filter", selection: $filter) {
            ForEach(ExpenseFilter.allCases) { filter in
                Text(filter.rawValue).tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }

    // MARK: - Filtered Expenses

    private var filteredExpenses: [Expense] {
        let calendar = Calendar.current
        let now = Date()

        return ledger.expenses
            .filter { expense in
                switch filter {
                case .week:
                    return calendar.isDate(
                        expense.date,
                        equalTo: now,
                        toGranularity: .weekOfYear
                    )

                case .month:
                    return calendar.isDate(
                        expense.date,
                        equalTo: now,
                        toGranularity: .month
                    )

                case .year:
                    return calendar.isDate(
                        expense.date,
                        equalTo: now,
                        toGranularity: .year
                    )
                }
            }
            .sorted { $0.date > $1.date }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.largeTitle)
                .foregroundColor(.secondary)

            Text("No expenses for this period")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
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
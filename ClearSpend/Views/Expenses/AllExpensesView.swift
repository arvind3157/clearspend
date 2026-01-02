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

    // Custom range
    @State private var fromDate: Date = Calendar.current.date(
        from: DateComponents(
            year: Calendar.current.component(.year, from: Date()),
            month: Calendar.current.component(.month, from: Date()),
            day: 1
        )
    ) ?? .now

    @State private var toDate: Date = .now

    var body: some View {
        VStack(spacing: 0) {

            filterSection

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

    // MARK: - Filter Section

    private var filterSection: some View {
        VStack(spacing: 12) {

            Picker("Filter", selection: $filter) {
                ForEach(ExpenseFilter.allCases) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top)

            if filter == .custom {
                customDateRange
            }
        }
    }

    // MARK: - Custom Date Range UI

    private var customDateRange: some View {
        HStack(spacing: 12) {

            DatePicker(
                "From",
                selection: $fromDate,
                displayedComponents: .date
            )

            DatePicker(
                "To",
                selection: $toDate,
                in: fromDate...,
                displayedComponents: .date
            )
        }
        .padding(.horizontal)
    }

    // MARK: - Filtered Expenses Logic

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

                case .custom:
                    return expense.date >= startOfDay(fromDate)
                        && expense.date <= endOfDay(toDate)
                }
            }
            .sorted { $0.date > $1.date }
    }

    // MARK: - Helpers

    private func startOfDay(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    private func endOfDay(_ date: Date) -> Date {
        Calendar.current.date(
            byAdding: DateComponents(day: 1, second: -1),
            to: startOfDay(date)
        ) ?? date
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
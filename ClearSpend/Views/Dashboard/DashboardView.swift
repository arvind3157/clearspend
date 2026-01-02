//
//  DashboardView.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftUI
import SwiftData

struct DashboardView: View {

    @Environment(\.modelContext)
    private var modelContext

    @StateObject
    private var viewModel = DashboardViewModel()
    
    private var recentExpensesSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("Recent Spends")
                .font(.headline)

            if viewModel.recentExpenses.isEmpty {
                Text("No expenses yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.recentExpenses) { expense in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(expense.subCategory?.name ?? "Unknown")
                                .font(.subheadline)

                            Text(expense.date, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(
                            expense.amount,
                            format: .currency(code: Locale.current.currency?.identifier ?? "USD")
                        )
                        .foregroundStyle(.red)
                    }
                    .padding(.vertical, 6)
                }
            }
        }
    }
    
    private var summaryCards: some View {
        HStack(spacing: 12) {

            SummaryCard(
                title: "Income",
                amount: viewModel.totalIncome,
                color: .green
            )

            SummaryCard(
                title: "Spent",
                amount: viewModel.totalExpenses,
                color: .red
            )

            SummaryCard(
                title: "Savings",
                amount: viewModel.savings,
                color: viewModel.savings >= 0 ? .blue : .orange
            )
        }
    }
    
    private func monthTitle(for ledger: MonthLedger) -> String {
        let components = DateComponents(
            year: ledger.year,
            month: ledger.month
        )

        let date = Calendar.current.date(from: components) ?? Date()
        return date.formatted(.dateTime.month(.wide).year())
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    if let ledger = viewModel.selectedLedger {
                        Text(monthTitle(for: ledger))
                            .font(.title2)
                            .bold()
                    }

                    summaryCards

                    recentExpensesSection

                }
                .padding()
            }
            .navigationTitle("ClearSpend")
        }
        .onAppear {
            viewModel.load(context: modelContext)
        }
    }
}

//
//  DashboardViewModel.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//


import Foundation
import Combine
import SwiftData

@MainActor
final class DashboardViewModel: ObservableObject {

    @Published var selectedLedger: MonthLedger?

    // MARK: - Derived Values

    var totalExpenses: Double {
        selectedLedger?.expenses.reduce(0) { $0 + $1.amount } ?? 0
    }

    var transactionCount: Int {
        selectedLedger?.expenses.count ?? 0
    }

    var topSpendingCategories: [(name: String, amount: Double)] {
        guard let expenses = selectedLedger?.expenses else { return [] }
        
        let categoryTotals = Dictionary(grouping: expenses) { expense in
            expense.subCategory?.category?.name ?? "Uncategorized"
        }
        .mapValues { expenses in
            expenses.reduce(0) { $0 + $1.amount }
        }
        .sorted { $0.value > $1.value }
        .prefix(3)
        .map { (name: $0.key, amount: $0.value) }
        
        return Array(categoryTotals)
    }

    var averageDailySpending: Double {
        guard let ledger = selectedLedger else { return 0 }
        
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: DateComponents(year: ledger.year, month: ledger.month, day: 1)) ?? Date()
        let currentDay = calendar.component(.day, from: Date())
        let daysInMonth = calendar.range(of: .day, in: .month, for: startOfMonth)?.count ?? 30
        let daysPassed = min(currentDay, daysInMonth)
        
        return daysPassed > 0 ? totalExpenses / Double(daysPassed) : 0
    }

    var recentExpenses: [Expense] {
        guard let expenses = selectedLedger?.expenses else { return [] }
        return expenses
            .sorted { $0.date > $1.date }
            .prefix(5)
            .map { $0 }
    }

    // MARK: - Load

    func load(context: ModelContext) {
        selectedLedger = MonthLedgerManager.currentMonthLedger(
            context: context
        )
    }
}

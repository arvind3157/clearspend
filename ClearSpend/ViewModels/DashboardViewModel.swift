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

    var totalIncome: Double {
        selectedLedger?.incomes.reduce(0) { $0 + $1.amount } ?? 0
    }

    var totalExpenses: Double {
        selectedLedger?.expenses.reduce(0) { $0 + $1.amount } ?? 0
    }

    var savings: Double {
        totalIncome - totalExpenses
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

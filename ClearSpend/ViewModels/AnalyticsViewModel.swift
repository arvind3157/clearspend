//
//  AnalyticsViewModel.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import Foundation
import Combine
import SwiftData

struct CategorySpend: Identifiable {
    let id = UUID()
    let category: Category
    let amount: Double
}

@MainActor
final class AnalyticsViewModel: ObservableObject {

    @Published var selectedLedger: MonthLedger?

    func load(context: ModelContext) {
        selectedLedger = MonthLedgerManager.currentMonthLedger(
            context: context
        )
    }

    var totalSpend: Double {
        selectedLedger?.expenses.reduce(0) { $0 + $1.amount } ?? 0
    }

    var categorySpends: [CategorySpend] {
        guard let expenses = selectedLedger?.expenses else { return [] }

        let grouped = Dictionary(grouping: expenses) {
            $0.subCategory?.category
        }

        return grouped.compactMap { (category, expenses) in
            guard let category else { return nil }
            let total = expenses.reduce(0) { $0 + $1.amount }
            return CategorySpend(category: category, amount: total)
        }
        .sorted { $0.amount > $1.amount }
    }
}

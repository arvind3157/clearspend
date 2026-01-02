//
//  MonthLedgerManager.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftData
import Foundation

struct MonthLedgerManager {

    static func currentMonthLedger(
        context: ModelContext
    ) -> MonthLedger {
        let calendar = Calendar.current
        let now = Date()
        let month = calendar.component(.month, from: now)
        let year = calendar.component(.year, from: now)
        
        // Find existing ledger for current month/year
        let descriptor = FetchDescriptor<MonthLedger>(
            predicate: #Predicate {
                $0.month == month && $0.year == year
            }
        )
        
        if let existing = try? context.fetch(descriptor).first {
            print("✅ Found existing ledger for \(month)/\(year) with \(existing.expenses.count) expenses")
            return existing
        }
        
        // Create new ledger only if absolutely none exists
        print("⚠️ No existing ledger found for \(month)/\(year), creating new one")
        let newLedger = MonthLedger(month: month, year: year)
        context.insert(newLedger)
        return newLedger
    }

    static func allLedgers(
        context: ModelContext
    ) -> [MonthLedger] {

        let descriptor = FetchDescriptor<MonthLedger>(
            sortBy: [
                SortDescriptor(\.year, order: .reverse),
                SortDescriptor(\.month, order: .reverse)
            ]
        )

        return (try? context.fetch(descriptor)) ?? []
    }
}

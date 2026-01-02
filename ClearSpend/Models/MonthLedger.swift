//
//  MonthLedger.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftData
import Foundation

@Model
final class MonthLedger {

    @Attribute(.unique)
    var id: UUID

    var month: Int        // 1...12
    var year: Int         // e.g. 2026
    var createdAt: Date

    @Relationship(deleteRule: .cascade)
    var expenses: [Expense] = []

    init(month: Int, year: Int) {
        self.id = UUID()
        self.month = month
        self.year = year
        self.createdAt = Date()
    }
}

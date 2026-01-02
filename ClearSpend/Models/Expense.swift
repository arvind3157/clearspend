//
//  Expense.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftData
import Foundation

@Model
final class Expense {

    var id: UUID
    var amount: Double
    var date: Date
    var note: String?
    var merchant: String?

    /// Stored as raw string for SwiftData compatibility
    var paymentMethod: String

    @Relationship
    var subCategory: SubCategory?

    init(
        amount: Double,
        date: Date,
        paymentMethod: String,
        subCategory: SubCategory?,
        merchant: String? = nil,
        note: String? = nil
    ) {
        self.id = UUID()
        self.amount = amount
        self.date = date
        self.paymentMethod = paymentMethod
        self.subCategory = subCategory
        self.merchant = merchant
        self.note = note
    }
}

//
//  Income.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftData
import Foundation

@Model
final class Income {

    var id: UUID
    var amount: Double
    var source: String
    var date: Date
    var note: String?

    init(
        amount: Double,
        source: String,
        date: Date,
        note: String? = nil
    ) {
        self.id = UUID()
        self.amount = amount
        self.source = source
        self.date = date
        self.note = note
    }
}

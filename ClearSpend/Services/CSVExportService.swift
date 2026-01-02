//
//  CSVExportService.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import Foundation
import SwiftData

final class CSVExportService {

    static func exportExpenses(from context: ModelContext) throws -> URL {

        let ledgers = try context.fetch(FetchDescriptor<MonthLedger>())
        let expenses = ledgers.flatMap { $0.expenses }
        
        print("🔍 DEBUG: Total expenses found for export: \(expenses.count)")
        for expense in expenses {
            print("🔍 DEBUG: Expense - ID: \(expense.id), Amount: \(expense.amount), Date: \(expense.date)")
        }

        var csv = "id,date,amount,payment_method,category,subcategory,merchant,note\n"

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]

        for expense in expenses {
            let row = [
                expense.id.uuidString,
                formatter.string(from: expense.date),
                String(format: "%.2f", expense.amount),
                expense.paymentMethod,
                expense.subCategory?.category?.name ?? "",
                expense.subCategory?.name ?? "",
                expense.merchant ?? "",
                expense.note ?? ""
            ]
            .map { escape($0) }
            .joined(separator: ",")

            csv.append(row + "\n")
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("clearspend_expenses.csv")

        try csv.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    private static func escape(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") {
            return "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return value
    }
}
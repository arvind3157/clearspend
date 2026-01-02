//
//  CSVImportService.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import Foundation
import SwiftData

// MARK: - Import Error

enum ImportError: LocalizedError {
    case permissionDenied
    case fileReadFailed(Error)
    case invalidFormat

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Permission denied. Please select the file again."
        case .fileReadFailed(let error):
            return "Failed to read file: \(error.localizedDescription)"
        case .invalidFormat:
            return "Invalid CSV format."
        }
    }
}

// MARK: - CSV Import Service

final class CSVImportService {

    static func importExpenses(
        from url: URL,
        into context: ModelContext
    ) throws -> Int {

        guard url.startAccessingSecurityScopedResource() else {
            throw ImportError.permissionDenied
        }
        defer { url.stopAccessingSecurityScopedResource() }

        let content: String
        do {
            content = try String(contentsOf: url, encoding: .utf8)
        } catch {
            throw ImportError.fileReadFailed(error)
        }

        let rows = parseCSV(content)
        guard rows.count > 1 else {
            throw ImportError.invalidFormat
        }

        // Validate header
        let header = rows.first?.map { $0.lowercased() } ?? []
        guard header.count >= 8, header[0].contains("id") else {
            throw ImportError.invalidFormat
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]

        var importedCount = 0

        for row in rows.dropFirst() {

            guard row.count >= 8 else { continue }

            let idString = row[0].trimmingCharacters(in: .whitespacesAndNewlines)
            guard let id = UUID(uuidString: idString) else {
                continue
            }

            // 🔒 Deduplicate by ID
            let existing = try context.fetch(
                FetchDescriptor<Expense>(
                    predicate: #Predicate { $0.id == id }
                )
            )
            if !existing.isEmpty { continue }

            let date = formatter.date(from: row[1]) ?? Date()
            let amount = Double(row[2]) ?? 0
            let paymentMethod = row[3].isEmpty ? "Unknown" : row[3]
            let categoryName = row[4]
            let subCategoryName = row[5]
            let merchant = row[6]
            let note = row[7]

            let category = findOrCreateCategory(
                named: categoryName,
                context: context
            )

            let subCategory = category.flatMap {
                findOrCreateSubCategory(
                    named: subCategoryName,
                    in: $0,
                    context: context
                )
            }

            let expense = Expense(
                amount: amount,
                date: date,
                paymentMethod: paymentMethod,
                subCategory: subCategory,
                merchant: merchant.isEmpty ? nil : merchant,
                note: note.isEmpty ? nil : note
            )

            // Preserve original ID
            expense.id = id

            let ledger = findOrCreateLedger(
                for: date,
                context: context
            )

            ledger.expenses.append(expense)
            context.insert(expense)

            importedCount += 1        }

        try context.save()
        return importedCount
    }

    // MARK: - CSV Parser (Quoted-safe, final)

    private static func parseCSV(_ text: String) -> [[String]] {
        var rows: [[String]] = []
        var currentRow: [String] = []
        var currentField = ""
        var insideQuotes = false

        for char in text {
            switch char {
            case "\"":
                insideQuotes.toggle()

            case "," where !insideQuotes:
                currentRow.append(currentField.trimmingCharacters(in: .whitespaces))
                currentField = ""

            case "\n":
                currentRow.append(currentField.trimmingCharacters(in: .whitespaces))
                rows.append(currentRow)
                currentRow = []
                currentField = ""

            default:
                currentField.append(char)
            }
        }

        if !currentField.isEmpty || !currentRow.isEmpty {
            currentRow.append(currentField.trimmingCharacters(in: .whitespaces))
            rows.append(currentRow)
        }

        return rows
    }
    
    private static func findOrCreateLedger(
        for date: Date,
        context: ModelContext
    ) -> MonthLedger {

        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)

        let descriptor = FetchDescriptor<MonthLedger>(
            predicate: #Predicate {
                $0.year == year && $0.month == month
            }
        )

        if let existing = try? context.fetch(descriptor).first {
            return existing
        }

        let ledger = MonthLedger(month: month, year: year)
        context.insert(ledger)
        return ledger
    }

    // MARK: - Category Helpers

    private static func findOrCreateCategory(
        named name: String,
        context: ModelContext
    ) -> Category? {

        guard !name.isEmpty else { return nil }

        if let existing = try? context.fetch(
            FetchDescriptor<Category>(
                predicate: #Predicate { $0.name == name }
            )
        ).first {
            return existing
        }

        let category = Category(
            name: name,
            icon: "tag",
            colorHex: "#2563EB"
        )

        context.insert(category)
        return category
    }

    private static func findOrCreateSubCategory(
        named name: String,
        in category: Category,
        context: ModelContext
    ) -> SubCategory {

        if let existing = category.subCategories.first(
            where: { $0.name == name }
        ) {
            return existing
        }

        let sub = SubCategory(name: name, category: category)
        context.insert(sub)
        return sub
    }
}

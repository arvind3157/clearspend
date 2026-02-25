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
    @Published var userName: String = "User"

    // MARK: - Greeting

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let timeGreeting: String
        switch hour {
        case 5..<12:
            timeGreeting = "Good morning"
        case 12..<17:
            timeGreeting = "Good afternoon"
        case 17..<22:
            timeGreeting = "Good evening"
        default:
            timeGreeting = "Good night"
        }
        let firstName = userName.components(separatedBy: " ").first ?? userName
        return "\(timeGreeting), \(firstName)"
    }

    var todayDateString: String {
        Date().formatted(.dateTime.weekday(.wide).month(.wide).day())
    }

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

    var topCategoryName: String {
        topSpendingCategories.first?.name ?? "—"
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

    // MARK: - Daily Spending Data

    var dailySpending: [(day: Int, amount: Double)] {
        guard let ledger = selectedLedger else { return [] }
        let calendar = Calendar.current
        let expenses = ledger.expenses

        var dailyTotals: [Int: Double] = [:]
        for expense in expenses {
            let day = calendar.component(.day, from: expense.date)
            dailyTotals[day, default: 0] += expense.amount
        }

        let today = calendar.component(.day, from: Date())
        let startOfMonth = calendar.date(from: DateComponents(year: ledger.year, month: ledger.month, day: 1)) ?? Date()
        let daysInMonth = calendar.range(of: .day, in: .month, for: startOfMonth)?.count ?? 30
        let maxDay = min(today, daysInMonth)

        return (1...maxDay).map { day in
            (day: day, amount: dailyTotals[day] ?? 0)
        }
    }

    // MARK: - Category Breakdown

    var categoryBreakdown: [(name: String, icon: String, colorHex: String, amount: Double, percentage: Double)] {
        guard let expenses = selectedLedger?.expenses, !expenses.isEmpty else { return [] }

        let total = totalExpenses
        guard total > 0 else { return [] }

        let grouped = Dictionary(grouping: expenses) { expense in
            expense.subCategory?.category?.id.uuidString ?? "uncategorized"
        }

        var results: [(name: String, icon: String, colorHex: String, amount: Double, percentage: Double)] = []
        for (_, group) in grouped {
            let category = group.first?.subCategory?.category
            let name = category?.name ?? "Uncategorized"
            let icon = category?.icon ?? "questionmark.circle"
            let colorHex = category?.colorHex ?? "#6B7280"
            let amount = group.reduce(0) { $0 + $1.amount }
            let percentage = amount / total
            results.append((name: name, icon: icon, colorHex: colorHex, amount: amount, percentage: percentage))
        }

        return results.sorted { $0.amount > $1.amount }
    }

    // MARK: - Month Name

    var monthName: String {
        guard let ledger = selectedLedger else { return "" }
        let components = DateComponents(year: ledger.year, month: ledger.month)
        let date = Calendar.current.date(from: components) ?? Date()
        return date.formatted(.dateTime.month(.wide))
    }

    // MARK: - Load

    func load(context: ModelContext) {
        selectedLedger = MonthLedgerManager.currentMonthLedger(
            context: context
        )

        let descriptor = FetchDescriptor<UserProfile>()
        if let profile = try? context.fetch(descriptor).first {
            userName = profile.name
        }
    }
}

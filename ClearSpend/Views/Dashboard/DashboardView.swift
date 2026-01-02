//
//  DashboardView.swift
//  ClearSpend
//

import SwiftUI
import SwiftData

struct DashboardView: View {

    @Environment(\.modelContext)
    private var modelContext

    @StateObject
    private var viewModel = DashboardViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.xl) {

                    headerSection
                    summaryCards
                    recentExpensesSection

                    Color.clear
                        .frame(height: DesignSystem.Spacing.lg)
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            viewModel.load(context: modelContext)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            if let ledger = viewModel.selectedLedger {
                Text(monthTitle(for: ledger))
                    .font(DesignSystem.Typography.displaySmall)
                    .fontWeight(.bold)

                Text("Financial Overview")
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
        }
        .padding(.top, DesignSystem.Spacing.lg)
    }

    // MARK: - Summary Cards

    private var summaryCards: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            HStack(spacing: DesignSystem.Spacing.md) {
                SummaryCard(
                    title: "Income",
                    amount: viewModel.totalIncome,
                    color: DesignSystem.Colors.success
                )

                SummaryCard(
                    title: "Spent",
                    amount: viewModel.totalExpenses,
                    color: DesignSystem.Colors.danger
                )
            }

            SummaryCard(
                title: "Savings",
                amount: viewModel.savings,
                color: viewModel.savings >= 0
                    ? DesignSystem.Colors.info
                    : DesignSystem.Colors.warning
            )
        }
    }

    // MARK: - Recent Expenses

    private var recentExpensesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {

            HStack {
                Text("Recent Spends")
                    .font(DesignSystem.Typography.headlineSmall)

                Spacer()

                if let ledger = viewModel.selectedLedger {
                    NavigationLink {
                        AllExpensesView(ledger: ledger)
                    } label: {
                        Text("See All")
                            .font(DesignSystem.Typography.titleMedium)
                            .foregroundColor(DesignSystem.Colors.primary)
                    }
                }
            }

            if viewModel.recentExpenses.isEmpty {
                emptyState
            } else {
                expensesList
            }
        }
    }

    // MARK: - Expenses List (NO List)

    private var expensesList: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(viewModel.recentExpenses) { expense in
                ExpenseRow(expense: expense)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                            .fill(DesignSystem.Colors.surface)
                    )
                    .contextMenu {
                        Button(role: .destructive) {
                            deleteExpense(expense)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "wallet.pass")
                .font(.system(size: 48))
                .foregroundColor(DesignSystem.Colors.textTertiary)

            Text("No expenses yet")
                .font(DesignSystem.Typography.bodyMedium)

            Text("Tap the + button to add your first expense")
                .font(DesignSystem.Typography.bodySmall)
                .foregroundColor(DesignSystem.Colors.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(DesignSystem.Colors.surfaceVariant)
        )
    }

    // MARK: - Delete

    private func deleteExpense(_ expense: Expense) {
        withAnimation {
            print("🔍 DEBUG: Attempting to delete expense - ID: \(expense.id), Amount: \(expense.amount)")
            
            modelContext.delete(expense)

            if let ledger = viewModel.selectedLedger {
                ledger.expenses.removeAll { $0.id == expense.id }
                print("🔍 DEBUG: Removed from ledger. Ledger now has \(ledger.expenses.count) expenses")
            }

            do {
                try modelContext.save()
                print("🔍 DEBUG: Successfully saved context after deletion")
            } catch {
                print("🔍 DEBUG: Failed to save context after deletion: \(error)")
            }
        }
    }

    // MARK: - Helpers

    private func monthTitle(for ledger: MonthLedger) -> String {
        let components = DateComponents(year: ledger.year, month: ledger.month)
        let date = Calendar.current.date(from: components) ?? Date()
        return date.formatted(.dateTime.month(.wide).year())
    }
}
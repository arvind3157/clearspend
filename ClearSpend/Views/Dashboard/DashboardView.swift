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
                    title: "This Month",
                    amount: viewModel.totalExpenses,
                    color: DesignSystem.Colors.danger
                )

                SummaryCard(
                    title: "Avg. Daily",
                    amount: viewModel.averageDailySpending,
                    color: DesignSystem.Colors.info
                )
            }

            TopCategoriesCard(
                categories: viewModel.topSpendingCategories,
                color: DesignSystem.Colors.primary
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

    // MARK: - Helpers

    private func monthTitle(for ledger: MonthLedger) -> String {
        let components = DateComponents(year: ledger.year, month: ledger.month)
        let date = Calendar.current.date(from: components) ?? Date()
        return date.formatted(.dateTime.month(.wide).year())
    }
}
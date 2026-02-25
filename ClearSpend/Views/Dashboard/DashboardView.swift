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

    @State private var showAddExpense = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.lg) {

                    greetingSection
                    heroCard
                    quickStats

                    if !viewModel.dailySpending.isEmpty && viewModel.totalExpenses > 0 {
                        SpendingSparkline(data: viewModel.dailySpending)
                    }

                    if !viewModel.categoryBreakdown.isEmpty {
                        categorySection
                    }

                    recentExpensesSection

                    Color.clear
                        .frame(height: DesignSystem.Spacing.xxl)
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
            }
            .background(DesignSystem.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
        }
        .onAppear {
            viewModel.load(context: modelContext)
        }
        .sheet(isPresented: $showAddExpense) {
            AddExpenseView()
        }
    }

    // MARK: - Greeting

    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text(viewModel.greeting)
                .font(DesignSystem.Typography.displaySmall)
                .foregroundColor(DesignSystem.Colors.textPrimary)

            Text(viewModel.todayDateString)
                .font(DesignSystem.Typography.bodyMedium)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, DesignSystem.Spacing.lg)
    }

    // MARK: - Hero Card

    private var heroCard: some View {
        HeroSpendCard(
            monthName: viewModel.monthName,
            totalSpend: viewModel.totalExpenses,
            transactionCount: viewModel.transactionCount
        )
    }

    // MARK: - Quick Stats

    private var quickStats: some View {
        QuickStatsRow(
            dailyAverage: viewModel.averageDailySpending,
            transactionCount: viewModel.transactionCount,
            topCategory: viewModel.topCategoryName
        )
    }

    // MARK: - Category Breakdown

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Spending by Category")
                .font(DesignSystem.Typography.headlineSmall)
                .foregroundColor(DesignSystem.Colors.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    ForEach(viewModel.categoryBreakdown, id: \.name) { cat in
                        CategoryScrollCard(
                            name: cat.name,
                            icon: cat.icon,
                            colorHex: cat.colorHex,
                            amount: cat.amount,
                            percentage: cat.percentage
                        )
                    }
                }
            }
        }
    }

    // MARK: - Recent Expenses

    private var recentExpensesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {

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
                VStack(spacing: DesignSystem.Spacing.sm) {
                    ForEach(viewModel.recentExpenses) { expense in
                        ExpenseRow(expense: expense)
                    }
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {

            ZStack {
                Circle()
                    .fill(DesignSystem.Colors.primaryLight.opacity(0.12))
                    .frame(width: 96, height: 96)

                Image(systemName: "banknote")
                    .font(.system(size: 40))
                    .foregroundColor(DesignSystem.Colors.primary)
            }

            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("Start Tracking Your Spending")
                    .font(DesignSystem.Typography.headlineSmall)
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                Text("Add your first expense to see insights, trends, and a breakdown of where your money goes.")
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignSystem.Spacing.md)
            }

            Button {
                showAddExpense = true
            } label: {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Your First Expense")
                }
                .primaryButtonStyle()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                .fill(DesignSystem.Colors.surface)
        )
        .shadow(color: DesignSystem.Shadows.small.color, radius: DesignSystem.Shadows.small.radius, x: DesignSystem.Shadows.small.x, y: DesignSystem.Shadows.small.y)
    }
}

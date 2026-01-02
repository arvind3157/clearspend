//
//  DashboardView.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftUI
import SwiftData

struct DashboardView: View {

    @Environment(\.modelContext)
    private var modelContext

    @StateObject
    private var viewModel = DashboardViewModel()
    
    private var recentExpensesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            HStack {
                Text("Recent Spends")
                    .font(DesignSystem.Typography.headlineSmall)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Spacer()
                
                NavigationLink {
                    // TODO: Add full expenses list view
                    Text("All Expenses")
                } label: {
                    Text("See All")
                        .font(DesignSystem.Typography.titleMedium)
                        .foregroundColor(DesignSystem.Colors.primary)
                }
            }

            if viewModel.recentExpenses.isEmpty {
                VStack(spacing: DesignSystem.Spacing.md) {
                    Image(systemName: "wallet.pass")
                        .font(.system(size: 48))
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                    
                    Text("No expenses yet")
                        .font(DesignSystem.Typography.bodyMedium)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
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
            } else {
                LazyVStack(spacing: DesignSystem.Spacing.sm) {
                    ForEach(viewModel.recentExpenses) { expense in
                        ExpenseRow(expense: expense)
                    }
                }
            }
        }
    }
    
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
                color: viewModel.savings >= 0 ? DesignSystem.Colors.info : DesignSystem.Colors.warning
            )
        }
    }
    
    private func monthTitle(for ledger: MonthLedger) -> String {
        let components = DateComponents(
            year: ledger.year,
            month: ledger.month
        )

        let date = Calendar.current.date(from: components) ?? Date()
        return date.formatted(.dateTime.month(.wide).year())
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.xl) {
                    // Header Section
                    VStack(spacing: DesignSystem.Spacing.md) {
                        if let ledger = viewModel.selectedLedger {
                            Text(monthTitle(for: ledger))
                                .font(DesignSystem.Typography.displaySmall)
                                .fontWeight(.bold)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            
                            Text("Financial Overview")
                                .font(DesignSystem.Typography.bodyMedium)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                    }
                    .padding(.top, DesignSystem.Spacing.lg)

                    summaryCards

                    recentExpensesSection
                    
                    // Add some bottom padding for better scrolling
                    Color.clear
                        .frame(height: DesignSystem.Spacing.lg)
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("ClearSpend")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // TODO: Add search functionality
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(DesignSystem.Colors.primary)
                    }
                }
            }
        }
        .onAppear {
            viewModel.load(context: modelContext)
        }
    }
}

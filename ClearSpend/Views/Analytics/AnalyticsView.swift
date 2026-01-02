//
//  AnalyticsView.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftUI
import SwiftData
import Charts

struct AnalyticsView: View {

    @Environment(\.modelContext)
    private var modelContext

    @StateObject
    private var viewModel = AnalyticsViewModel()
    
    private var emptyState: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "chart.pie")
                .font(.system(size: 64))
                .foregroundColor(DesignSystem.Colors.textTertiary)

            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("No spending data yet")
                    .font(DesignSystem.Typography.headlineSmall)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                Text("Start adding expenses to see your spending analytics")
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                // TODO: Navigate to add expense
            } label: {
                Text("Add Your First Expense")
                    .font(DesignSystem.Typography.labelLarge)
                    .foregroundColor(DesignSystem.Colors.textOnPrimary)
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.vertical, DesignSystem.Spacing.md)
                    .background(DesignSystem.Colors.primary)
                    .cornerRadius(DesignSystem.CornerRadius.medium)
            }
            .padding(.top, DesignSystem.Spacing.md)
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.xxl)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                .fill(DesignSystem.Colors.surfaceVariant)
        )
        .padding(.top, DesignSystem.Spacing.xl)
    }
    
    private var categoryLegend: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            HStack {
                Text("Spending by Category")
                    .font(DesignSystem.Typography.headlineSmall)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Spacer()
                
                Text(
                    viewModel.totalSpend,
                    format: .currency(code: Locale.current.currency?.identifier ?? "USD")
                )
                .font(DesignSystem.Typography.titleMedium)
                .foregroundColor(DesignSystem.Colors.textSecondary)
            }

            LazyVStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(viewModel.categorySpends) { item in
                    NavigationLink {
                        CategoryDetailView(
                            category: item.category,
                            ledger: viewModel.selectedLedger
                        )
                    } label: {
                        CategoryLegendRow(item: item, totalAmount: viewModel.totalSpend)
                    }
                }
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .cardStyle()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.xl) {
                    if viewModel.totalSpend == 0 {
                        emptyState
                    } else {
                        // Header with total spending
                        VStack(spacing: DesignSystem.Spacing.md) {
                            Text("Total Spending")
                                .font(DesignSystem.Typography.titleMedium)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                            
                            Text(
                                viewModel.totalSpend,
                                format: .currency(code: Locale.current.currency?.identifier ?? "USD")
                            )
                            .font(DesignSystem.Typography.displayMedium)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        }
                        .padding(.top, DesignSystem.Spacing.lg)
                        
                        // Chart Section
                        VStack(spacing: DesignSystem.Spacing.lg) {
                            SpendPieChartView(
                                categorySpends: viewModel.categorySpends
                            )
                            .padding(DesignSystem.Spacing.lg)
                            .cardStyle()
                            
                            categoryLegend
                        }
                    }
                    
                    // Add bottom padding
                    Color.clear
                        .frame(height: DesignSystem.Spacing.lg)
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // TODO: Add export functionality
                    } label: {
                        Image(systemName: "square.and.arrow.up")
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

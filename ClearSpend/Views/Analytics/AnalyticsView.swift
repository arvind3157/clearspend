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
        VStack(spacing: 12) {
            Image(systemName: "chart.pie")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text("No spending data yet")
                .foregroundStyle(.secondary)
        }
        .padding(.top, 40)
    }
    
    private var categoryLegend: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("By Category")
                .font(.headline)

            ForEach(viewModel.categorySpends) { item in
                NavigationLink {
                    CategoryDetailView(
                        category: item.category,
                        ledger: viewModel.selectedLedger
                    )
                } label: {
                    HStack {
                        Circle()
                            .fill(Color(hex: item.category.colorHex))
                            .frame(width: 10, height: 10)

                        Text(item.category.name)

                        Spacer()

                        Text(
                            item.amount,
                            format: .currency(
                                code: Locale.current.currency?.identifier ?? "USD"
                            )
                        )
                    }
                }
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    if viewModel.totalSpend == 0 {
                        emptyState
                    } else {
                        SpendPieChartView(
                            categorySpends: viewModel.categorySpends
                        )

                        categoryLegend
                    }
                }
                .padding()
            }
            .navigationTitle("Analytics")
        }
        .onAppear {
            viewModel.load(context: modelContext)
        }
    }
}

//
//  AddPlaceholderView.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftUI

struct AddPlaceholderView: View {

    @State private var showAddIncome = false
    @State private var showAddExpense = false

    var body: some View {
        VStack(spacing: 24) {
            Button {
                showAddIncome = true
            } label: {
                Label("Add Income", systemImage: "arrow.down.circle.fill")
            }

            Button {
                showAddExpense = true
            } label: {
                Label("Add Expense", systemImage: "arrow.up.circle.fill")
            }
        }
        .font(.title3)
        .sheet(isPresented: $showAddIncome) {
            AddIncomeView()
        }
        .sheet(isPresented: $showAddExpense) {
            AddExpenseView()
        }
    }
}

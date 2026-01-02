//
//  SubCategoryDetailView.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftUI

struct SubCategoryDetailView: View {

    let subCategory: SubCategory
    let ledger: MonthLedger?
    
    private var expenses: [Expense] {
        guard let expenses = ledger?.expenses else { return [] }

        return expenses
            .filter { $0.subCategory?.id == subCategory.id }
            .sorted { $0.date > $1.date }
    }

    var body: some View {
        List {
            ForEach(expenses) { expense in
                HStack {
                    VStack(alignment: .leading) {
                        Text(expense.merchant ?? subCategory.name)
                            .font(.subheadline)

                        Text(expense.date, style: .date)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text(
                        expense.amount,
                        format: .currency(
                            code: Locale.current.currency?.identifier ?? "USD"
                        )
                    )
                    .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(subCategory.name)
    }
}

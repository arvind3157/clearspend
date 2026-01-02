//
//  CategoryDetailView.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftUI

struct CategoryDetailView: View {

    let category: Category
    let ledger: MonthLedger?

    var body: some View {
        List {
            ForEach(subCategorySpends, id: \.subCategory.id) { item in
                NavigationLink {
                    SubCategoryDetailView(
                        subCategory: item.subCategory,
                        ledger: ledger
                    )
                } label: {
                    HStack {
                        Text(item.subCategory.name)
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
        .navigationTitle(category.name)
    }
    
    private struct SubCategorySpend {
        let subCategory: SubCategory
        let amount: Double
    }

    private var subCategorySpends: [SubCategorySpend] {
        guard let expenses = ledger?.expenses else { return [] }

        let filtered = expenses.filter {
            $0.subCategory?.category?.id == category.id
        }

        let grouped = Dictionary(grouping: filtered) {
            $0.subCategory!
        }

        return grouped.map { (subCategory, expenses) in
            SubCategorySpend(
                subCategory: subCategory,
                amount: expenses.reduce(0) { $0 + $1.amount }
            )
        }
        .sorted { $0.amount > $1.amount }
    }
}

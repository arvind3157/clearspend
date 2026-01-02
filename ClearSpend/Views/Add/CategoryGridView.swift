//
//  CategoryGridView.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftUI

struct CategoryGridView: View {

    let categories: [Category]
    @Binding var selectedCategory: Category?

    private let columns = [
        GridItem(.adaptive(minimum: 80), spacing: 16)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(categories) { category in
                Button {
                    selectedCategory = category
                } label: {
                    CategoryCell(
                        category: category,
                        isSelected: category.id == selectedCategory?.id
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 8)
    }
}

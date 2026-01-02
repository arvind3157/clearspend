//
//  CategoryPicker.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftUI

struct CategoryPickerView: View {

    let categories: [Category]

    @Binding var selectedCategory: Category?
    @Binding var selectedSubCategory: SubCategory?

    var body: some View {
        List(categories) { category in
            Button {
                selectedCategory = category
                selectedSubCategory = nil
            } label: {
                HStack {
                    Image(systemName: category.icon)
                    Text(category.name)
                    Spacer()
                    if selectedCategory?.id == category.id {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
        .navigationTitle("Category")
    }
}

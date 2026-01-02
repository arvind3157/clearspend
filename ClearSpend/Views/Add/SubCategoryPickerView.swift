//
//  SubCategoryPickerView.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftUI

struct SubCategoryPickerView: View {

    let category: Category
    @Binding var selectedSubCategory: SubCategory?

    var body: some View {
        List(category.subCategories) { sub in
            Button {
                selectedSubCategory = sub
            } label: {
                HStack {
                    Text(sub.name)
                    Spacer()
                    if selectedSubCategory?.id == sub.id {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
        .navigationTitle(category.name)
    }
}

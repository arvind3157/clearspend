//
//  CategoryListView.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftUI

struct CategoryListView: View {

    let categories: [Category]

    var body: some View {
        List {
            ForEach(categories) { category in
                Section {
                    ForEach(category.subCategories) { sub in
                        Text(sub.name)
                    }
                } header: {
                    HStack {
                        Image(systemName: category.icon)
                        Text(category.name)
                    }
                }
            }
        }
        .navigationTitle("Categories")
    }
}

//
//  CategoryPicker.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//


import SwiftUI
import SwiftData

struct CategoryPickerView: View {

    @Environment(\.dismiss) private var dismiss

    let categories: [Category]

    @Binding var selectedCategory: Category?
    @Binding var selectedSubCategory: SubCategory?

    @State private var expandedCategoryID: PersistentIdentifier?

    var body: some View {
        NavigationStack {
            List {
                ForEach(categories) { category in
                    Section {
                        categoryRow(category)

                        // ✅ Show subcategories when expanded
                        if expandedCategoryID == category.persistentModelID {
                            ForEach(category.subCategories) { subCategory in
                                subCategoryRow(subCategory, parent: category)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Select Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Category Row

    private func categoryRow(_ category: Category) -> some View {
        Button {
            withAnimation(.easeInOut) {
                if expandedCategoryID == category.persistentModelID {
                    expandedCategoryID = nil
                } else {
                    expandedCategoryID = category.persistentModelID
                    selectedCategory = category
                    selectedSubCategory = nil // ✅ reset
                }
            }
        } label: {
            HStack {
                Image(systemName: category.icon)
                    .foregroundColor(.primary)

                Text(category.name)
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: expandedCategoryID == category.persistentModelID
                      ? "chevron.up"
                      : "chevron.down")
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - SubCategory Row

    private func subCategoryRow(
        _ subCategory: SubCategory,
        parent category: Category
    ) -> some View {
        Button {
            selectedCategory = category
            selectedSubCategory = subCategory
            dismiss() // ✅ auto close on subcategory selection
        } label: {
            HStack {
                Image(systemName: "circle.fill")
                    .font(.system(size: 6))
                    .foregroundColor(.secondary)

                Text(subCategory.name)
                    .foregroundColor(.primary)

                Spacer()

                if selectedSubCategory?.id == subCategory.id {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
            .padding(.leading, 24)
        }
    }
}

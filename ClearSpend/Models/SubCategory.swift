//
//  SubCategory.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftData
import Foundation

@Model
final class SubCategory {

    var id: UUID
    var name: String

    @Relationship(inverse: \Category.subCategories)
    var category: Category?

    init(name: String, category: Category?) {
        self.id = UUID()
        self.name = name
        self.category = category
    }
}

//
//  Category.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftData
import Foundation

@Model
final class Category {

    var id: UUID
    var name: String
    var icon: String      // SF Symbol
    var colorHex: String  // Used for charts

    @Relationship(deleteRule: .cascade)
    var subCategories: [SubCategory] = []

    init(name: String, icon: String, colorHex: String) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
    }
}

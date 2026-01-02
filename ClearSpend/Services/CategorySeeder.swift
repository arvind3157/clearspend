//
//  CategorySeeder.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftData

struct CategorySeeder {

    static func seedIfNeeded(context: ModelContext) {

        // Check if categories already exist
        let descriptor = FetchDescriptor<Category>()
        let existingCategories = (try? context.fetch(descriptor)) ?? []

        guard existingCategories.isEmpty else {
            return
        }

        // MARK: - Food & Dining
        let food = Category(
            name: "Food & Dining",
            icon: "fork.knife",
            colorHex: "#FF7043"
        )

        food.subCategories = [
            SubCategory(name: "Groceries", category: food),
            SubCategory(name: "Restaurants", category: food),
            SubCategory(name: "Coffee", category: food),
            SubCategory(name: "Fast Food", category: food)
        ]

        // MARK: - Transport
        let transport = Category(
            name: "Transport",
            icon: "car.fill",
            colorHex: "#42A5F5"
        )

        transport.subCategories = [
            SubCategory(name: "Fuel", category: transport),
            SubCategory(name: "Public Transport", category: transport),
            SubCategory(name: "Cab", category: transport),
            SubCategory(name: "Parking", category: transport)
        ]

        // MARK: - Housing
        let housing = Category(
            name: "Housing",
            icon: "house.fill",
            colorHex: "#66BB6A"
        )

        housing.subCategories = [
            SubCategory(name: "Rent", category: housing),
            SubCategory(name: "Utilities", category: housing),
            SubCategory(name: "Maintenance", category: housing),
            SubCategory(name: "Internet", category: housing)
        ]

        // MARK: - Lifestyle
        let lifestyle = Category(
            name: "Lifestyle",
            icon: "bag.fill",
            colorHex: "#AB47BC"
        )

        lifestyle.subCategories = [
            SubCategory(name: "Shopping", category: lifestyle),
            SubCategory(name: "Subscriptions", category: lifestyle),
            SubCategory(name: "Entertainment", category: lifestyle)
        ]

        // MARK: - Health
        let health = Category(
            name: "Health",
            icon: "heart.fill",
            colorHex: "#EF5350"
        )

        health.subCategories = [
            SubCategory(name: "Medical", category: health),
            SubCategory(name: "Insurance", category: health),
            SubCategory(name: "Fitness", category: health)
        ]

        // MARK: - Travel
        let travel = Category(
            name: "Travel",
            icon: "airplane",
            colorHex: "#26C6DA"
        )

        travel.subCategories = [
            SubCategory(name: "Flights", category: travel),
            SubCategory(name: "Hotels", category: travel),
            SubCategory(name: "Local Travel", category: travel)
        ]

        // MARK: - Education
        let education = Category(
            name: "Education",
            icon: "book.fill",
            colorHex: "#FFA726"
        )

        education.subCategories = [
            SubCategory(name: "Courses", category: education),
            SubCategory(name: "Books", category: education)
        ]

        // MARK: - Miscellaneous
        let misc = Category(
            name: "Miscellaneous",
            icon: "ellipsis.circle.fill",
            colorHex: "#BDBDBD"
        )

        misc.subCategories = [
            SubCategory(name: "Other", category: misc)
        ]

        let categories = [
            food,
            transport,
            housing,
            lifestyle,
            health,
            travel,
            education,
            misc
        ]

        categories.forEach { context.insert($0) }
    }
}

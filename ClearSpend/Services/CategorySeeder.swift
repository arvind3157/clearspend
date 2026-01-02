//
//  CategorySeeder.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftData

struct CategorySeeder {

    static func seedIfNeeded(context: ModelContext) {

        // 1. Check if categories already exist
        let descriptor = FetchDescriptor<Category>()
        let existing = (try? context.fetch(descriptor)) ?? []

        guard existing.isEmpty else {
            return
        }

        // MARK: - Food & Dining
        let food = Category(
            name: "Food & Dining",
            icon: "fork.knife",
            colorHex: "#FF7043"
        )
        context.insert(food)

        let foodSubs = [
            SubCategory(name: "Groceries", category: food),
            SubCategory(name: "Restaurants", category: food),
            SubCategory(name: "Coffee", category: food),
            SubCategory(name: "Fast Food", category: food)
        ]
        foodSubs.forEach { context.insert($0) }

        // MARK: - Transport
        let transport = Category(
            name: "Transport",
            icon: "car.fill",
            colorHex: "#42A5F5"
        )
        context.insert(transport)

        let transportSubs = [
            SubCategory(name: "Fuel", category: transport),
            SubCategory(name: "Public Transport", category: transport),
            SubCategory(name: "Cab", category: transport),
            SubCategory(name: "Parking", category: transport)
        ]
        transportSubs.forEach { context.insert($0) }

        // MARK: - Housing
        let housing = Category(
            name: "Housing",
            icon: "house.fill",
            colorHex: "#66BB6A"
        )
        context.insert(housing)

        let housingSubs = [
            SubCategory(name: "Rent", category: housing),
            SubCategory(name: "Utilities", category: housing),
            SubCategory(name: "Maintenance", category: housing),
            SubCategory(name: "Internet", category: housing)
        ]
        housingSubs.forEach { context.insert($0) }

        // MARK: - Lifestyle
        let lifestyle = Category(
            name: "Lifestyle",
            icon: "bag.fill",
            colorHex: "#AB47BC"
        )
        context.insert(lifestyle)

        let lifestyleSubs = [
            SubCategory(name: "Shopping", category: lifestyle),
            SubCategory(name: "Subscriptions", category: lifestyle),
            SubCategory(name: "Entertainment", category: lifestyle)
        ]
        lifestyleSubs.forEach { context.insert($0) }

        // MARK: - Health
        let health = Category(
            name: "Health",
            icon: "heart.fill",
            colorHex: "#EF5350"
        )
        context.insert(health)

        let healthSubs = [
            SubCategory(name: "Medical", category: health),
            SubCategory(name: "Insurance", category: health),
            SubCategory(name: "Fitness", category: health)
        ]
        healthSubs.forEach { context.insert($0) }

        // MARK: - Travel
        let travel = Category(
            name: "Travel",
            icon: "airplane",
            colorHex: "#26C6DA"
        )
        context.insert(travel)

        let travelSubs = [
            SubCategory(name: "Flights", category: travel),
            SubCategory(name: "Hotels", category: travel),
            SubCategory(name: "Local Travel", category: travel)
        ]
        travelSubs.forEach { context.insert($0) }

        // MARK: - Education
        let education = Category(
            name: "Education",
            icon: "book.fill",
            colorHex: "#FFA726"
        )
        context.insert(education)

        let educationSubs = [
            SubCategory(name: "Courses", category: education),
            SubCategory(name: "Books", category: education)
        ]
        educationSubs.forEach { context.insert($0) }

        // MARK: - Miscellaneous
        let misc = Category(
            name: "Miscellaneous",
            icon: "ellipsis.circle.fill",
            colorHex: "#BDBDBD"
        )
        context.insert(misc)

        let miscSubs = [
            SubCategory(name: "Other", category: misc)
        ]
        miscSubs.forEach { context.insert($0) }
    }
}

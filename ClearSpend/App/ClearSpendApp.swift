//
//  ClearSpendApp.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftUI
import SwiftData

@main
struct ClearSpendApp: App {

    var sharedModelContainer: ModelContainer = {
        let container = try! ModelContainer(
            for: MonthLedger.self,
            Income.self,
            Expense.self,
            Category.self,
            SubCategory.self
        )

        let context = ModelContext(container)
        CategorySeeder.seedIfNeeded(context: context)

        return container
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
    }
}

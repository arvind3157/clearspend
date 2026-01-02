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

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [
            MonthLedger.self,
            Income.self,
            Expense.self,
            Category.self,
            SubCategory.self
        ])
    }
}

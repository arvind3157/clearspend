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
            Expense.self,
            Category.self,
            SubCategory.self,
            UserProfile.self,
            AppSettings.self
        )

        let context = ModelContext(container)
        CategorySeeder.seedIfNeeded(context: context)

        return container
    }()

    var body: some Scene {
        WindowGroup {
            AuthenticatedAppView()
                .environment(\.modelContext, sharedModelContainer.mainContext)
        }
    }
}

struct AuthenticatedAppView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var authService = AuthenticationService.shared
    
    var body: some View {
        Group {
            if authService.isUnlocked {
                RootView()
            } else {
                LockScreenView(authService: authService)
            }
        }
        .onAppear {
            authService.setup(with: modelContext)
        }
    }
}

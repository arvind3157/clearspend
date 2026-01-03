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
            UserProfile.self
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
    @State private var isSetupComplete = false
    
    var body: some View {
        Group {
            if !isSetupComplete {
                // Loading state while setting up authentication
                ZStack {
                    DesignSystem.Colors.background.ignoresSafeArea()
                    
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        Image(systemName: "wallet.pass")
                            .font(.system(size: 48))
                            .foregroundColor(DesignSystem.Colors.primary)
                        
                        Text("ClearSpend")
                            .font(DesignSystem.Typography.displaySmall)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Text("Loading...")
                            .font(DesignSystem.Typography.bodyMedium)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
            } else if authService.isUnlocked {
                RootView()
            } else {
                LockScreenView(authService: authService)
            }
        }
        .onAppear {
            setupAuthentication()
        }
        .onChange(of: authService.isUnlocked) { oldValue, newValue in
            print("🔐 Authentication state changed: \(oldValue) -> \(newValue)")
        }
        .onChange(of: authService.isShowingLockScreen) { oldValue, newValue in
            print("🔒 Lock screen state changed: \(oldValue) -> \(newValue)")
        }
    }
    
    private func setupAuthentication() {
        print("🚀 Setting up authentication service")
        authService.setup(with: modelContext)
        
        // Mark setup as complete after a brief delay to ensure proper initialization
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isSetupComplete = true
            print("✅ Authentication setup complete")
        }
    }
}

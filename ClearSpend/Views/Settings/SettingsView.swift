//
//  SettingsView.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftUI
import SwiftData

struct SettingsView: View {

    @Environment(\.modelContext)
    private var modelContext

    @Query(sort: \Category.name)
    private var categories: [Category]

    @State private var showResetAlert = false
    
    private func resetAllData() {
        do {
            try modelContext.delete(model: MonthLedger.self)
            try modelContext.delete(model: Income.self)
            try modelContext.delete(model: Expense.self)
            try modelContext.delete(model: Category.self)
            try modelContext.delete(model: SubCategory.self)
        } catch {
            print("Failed to reset data:", error)
        }
    }
    
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.xl) {
                    // Profile Section
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        // Profile Header
                        HStack(spacing: DesignSystem.Spacing.md) {
                            ZStack {
                                Circle()
                                    .fill(DesignSystem.Colors.primaryLight.opacity(0.2))
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: "person.fill")
                                    .font(DesignSystem.Typography.headlineSmall)
                                    .foregroundColor(DesignSystem.Colors.primary)
                            }
                            
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                                Text("ClearSpend User")
                                    .font(DesignSystem.Typography.headlineSmall)
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                
                                Text("Track your finances with ease")
                                    .font(DesignSystem.Typography.bodySmall)
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                            }
                            
                            Spacer()
                        }
                        .padding(DesignSystem.Spacing.lg)
                        .cardStyle()
                        
                        // Security Section
                        VStack(spacing: DesignSystem.Spacing.md) {
                            Text("Security")
                                .font(DesignSystem.Typography.headlineSmall)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: DesignSystem.Spacing.sm) {
                                ModernSettingsRow(
                                    title: "App Lock",
                                    subtitle: "Face ID / Passcode",
                                    icon: "lock.shield",
                                    enabled: false
                                )
                                
                                ModernSettingsRow(
                                    title: "Change Passcode",
                                    subtitle: "Coming soon",
                                    icon: "key",
                                    enabled: false
                                )
                            }
                        }
                        .padding(DesignSystem.Spacing.lg)
                        .cardStyle()
                        
                        // Categories Section
                        VStack(spacing: DesignSystem.Spacing.md) {
                            Text("Categories")
                                .font(DesignSystem.Typography.headlineSmall)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            NavigationLink {
                                CategoryListView(categories: categories)
                            } label: {
                                ModernSettingsRow(
                                    title: "Manage Categories",
                                    subtitle: "Add, edit, or remove categories",
                                    icon: "folder",
                                    enabled: true,
                                    showChevron: true
                                )
                            }
                        }
                        .padding(DesignSystem.Spacing.lg)
                        .cardStyle()
                        
                        // Data Section
                        VStack(spacing: DesignSystem.Spacing.md) {
                            Text("Data Management")
                                .font(DesignSystem.Typography.headlineSmall)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Button(role: .destructive) {
                                showResetAlert = true
                            } label: {
                                ModernSettingsRow(
                                    title: "Reset All Data",
                                    subtitle: "Permanently delete all expenses and income",
                                    icon: "trash",
                                    enabled: true,
                                    isDestructive: true
                                )
                            }
                        }
                        .padding(DesignSystem.Spacing.lg)
                        .cardStyle()
                        
                        // About Section
                        VStack(spacing: DesignSystem.Spacing.md) {
                            Text("About")
                                .font(DesignSystem.Typography.headlineSmall)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: DesignSystem.Spacing.lg) {
                                HStack(spacing: DesignSystem.Spacing.md) {
                                    Image(systemName: "app.badge")
                                        .font(DesignSystem.Typography.titleMedium)
                                        .foregroundColor(DesignSystem.Colors.primary)
                                        .frame(width: 32, height: 32)
                                    
                                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                                        Text("ClearSpend")
                                            .font(DesignSystem.Typography.bodyMedium)
                                            .fontWeight(.semibold)
                                            .foregroundColor(DesignSystem.Colors.textPrimary)
                                        
                                        Text("Version \(appVersion)")
                                            .font(DesignSystem.Typography.bodySmall)
                                            .foregroundColor(DesignSystem.Colors.textSecondary)
                                    }
                                    
                                    Spacer()
                                }
                                
                                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                                    HStack {
                                        Image(systemName: "checkmark.shield.fill")
                                            .font(DesignSystem.Typography.bodySmall)
                                            .foregroundColor(DesignSystem.Colors.success)
                                        
                                        Text("All data is stored locally on your device")
                                            .font(DesignSystem.Typography.bodySmall)
                                            .foregroundColor(DesignSystem.Colors.textSecondary)
                                    }
                                    
                                    HStack {
                                        Image(systemName: "heart.fill")
                                            .font(DesignSystem.Typography.bodySmall)
                                            .foregroundColor(DesignSystem.Colors.danger)
                                        
                                        Text("Made with ❤️ for better financial health")
                                            .font(DesignSystem.Typography.bodySmall)
                                            .foregroundColor(DesignSystem.Colors.textSecondary)
                                    }
                                }
                            }
                        }
                        .padding(DesignSystem.Spacing.lg)
                        .cardStyle()
                    }
                    .padding(.top, DesignSystem.Spacing.lg)
                    .padding(.bottom, DesignSystem.Spacing.lg)
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("Reset all data?", isPresented: $showResetAlert) {
            Button("Reset", role: .destructive) {
                resetAllData()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete all your expenses and income. This action cannot be undone.")
        }
    }
}

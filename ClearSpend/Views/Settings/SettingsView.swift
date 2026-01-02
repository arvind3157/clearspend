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

    var body: some View {
        NavigationStack {
            List {

                // MARK: - Security
                Section("Security") {
                    settingsRow(
                        title: "App Lock",
                        subtitle: "Face ID / Passcode",
                        enabled: false
                    )
                }

                // MARK: - Categories
                Section("Categories") {
                    NavigationLink("View Categories") {
                        CategoryListView(categories: categories)
                    }
                }

                // MARK: - Data
                Section("Data") {
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        Text("Reset All Data")
                    }
                }

                // MARK: - About
                Section("About") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ClearSpend")
                            .font(.headline)

                        Text("Version \(appVersion)")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("All data is stored locally on your device.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Reset all data?", isPresented: $showResetAlert) {
                Button("Reset", role: .destructive) {
                    resetAllData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all your expenses and income.")
            }
        }
    }

    // MARK: - Helpers

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    private func resetAllData() {
        do {
            try modelContext.delete(model: MonthLedger.self)
            try modelContext.delete(model: Income.self)
            try modelContext.delete(model: Expense.self)
            try modelContext.delete(model: Category.self)
            try modelContext.delete(model: SubCategory.self)
        } catch {
            print("❌ Failed to reset data:", error)
        }
    }
}

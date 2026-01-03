//
//  SettingsView.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//


import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {

    @Environment(\.modelContext)
    private var modelContext

    // MARK: - Export / Import State
    @State private var isExporting = false
    @State private var exportURL: URL?
    @State private var showExporter = false
    @State private var showImporter = false

    // ✅ Import Result Feedback
    @State private var importResultMessage: String?

    // MARK: - Reset
    @State private var showResetAlert = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            List {

                // MARK: - Security
                Section("Security") {
                    Toggle("App Lock", isOn: Binding(
                        get: { AuthenticationService.shared.isAppLockEnabled },
                        set: { _ in
                            AuthenticationService.shared.toggleAppLock()
                        }
                    ))

                    Text("Use Face ID or device passcode to protect your data.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // MARK: - Backup & Restore
                Section("Backup & Restore") {

                    Button {
                        exportExpenses()
                    } label: {
                        if isExporting {
                            HStack(spacing: 8) {
                                ProgressView()
                                Text("Exporting…")
                            }
                        } else {
                            Text("Export Expenses (CSV)")
                        }
                    }
                    .disabled(isExporting)

                    Button("Import Expenses (CSV)") {
                        showImporter = true
                    }

                    Text("Export your data as a CSV file for backup or transfer between devices.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
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

            // MARK: - Reset Alert
            .alert("Reset all data?", isPresented: $showResetAlert) {
                Button("Reset", role: .destructive) {
                    resetAllData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all your expenses and categories.")
            }

            // MARK: - Import Result Alert ✅
            .alert(
                "Import Complete",
                isPresented: Binding(
                    get: { importResultMessage != nil },
                    set: { _ in importResultMessage = nil }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(importResultMessage ?? "")
            }

            // MARK: - Export Share Sheet
            .sheet(isPresented: $showExporter) {
                if let url = exportURL {
                    ShareLink(item: url) {
                        Text("Share CSV")
                            .font(.headline)
                    }
                    .padding()
                }
            }

            // MARK: - Import Picker
            .fileImporter(
                isPresented: $showImporter,
                allowedContentTypes: [.commaSeparatedText]
            ) { result in
                handleImport(result)
            }
        }
    }

    // MARK: - Export (ASYNC, NON-BLOCKING)

    private func exportExpenses() {
        isExporting = true

        Task.detached(priority: .userInitiated) {
            do {
                let url = try CSVExportService.exportExpenses(from: modelContext)

                await MainActor.run {
                    exportURL = url
                    showExporter = true
                    isExporting = false
                }
            } catch {
                await MainActor.run {
                    isExporting = false
                    importResultMessage = error.localizedDescription
                }
            }
        }
    }

    // MARK: - Import (WITH USER FEEDBACK)

    private func handleImport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            Task {
                do {
                    let count = try CSVImportService.importExpenses(
                        from: url,
                        into: modelContext
                    )

                    await MainActor.run {
                        importResultMessage = count == 0
                            ? "No new expenses were imported.\nYour data is already up to date."
                            : "Successfully imported \(count) expenses."
                    }
                } catch {
                    await MainActor.run {
                        importResultMessage = error.localizedDescription
                    }
                }
            }

        case .failure(let error):
            importResultMessage = error.localizedDescription
        }
    }

    // MARK: - Reset

    private func resetAllData() {
        do {
            try modelContext.delete(model: MonthLedger.self)
            try modelContext.delete(model: Expense.self)
            try modelContext.delete(model: Category.self)
            try modelContext.delete(model: SubCategory.self)
        } catch {
            importResultMessage = error.localizedDescription
        }
    }

    // MARK: - App Version

    private var appVersion: String {
        let version = Bundle.main
            .infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main
            .infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

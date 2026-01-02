//
//  ScanBillView.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftUI
import SwiftData

struct ScanBillView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Category.name)
    private var categories: [Category]

    @State private var showCamera = true
    @State private var isProcessing = false

    @State private var amount: Double = 0
    @State private var merchant: String = ""
    @State private var date: Date = .now
    @State private var selectedCategory: Category?
    @State private var selectedSubCategory: SubCategory?
    @State private var suggestedCategoryName: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Scanned Result") {
                    TextField("Amount", value: $amount, format: .number)
                    TextField("Merchant", text: $merchant)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                Section("Category") {
                    if let suggested = suggestedCategoryName {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.orange)
                            Text("Suggested: \(suggested)")
                                .font(DesignSystem.Typography.bodySmall)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    CategoryGridView(
                        categories: categories,
                        selectedCategory: $selectedCategory
                    )
                    .onChange(of: selectedCategory) {
                        selectedSubCategory = nil
                    }

                    if let subs = selectedCategory?.subCategories {
                        Picker("Sub Category", selection: $selectedSubCategory) {
                            Text("Select").tag(SubCategory?.none)
                            ForEach(subs) { sub in
                                Text(sub.name).tag(SubCategory?.some(sub))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Scan Bill")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveExpense()
                        dismiss()
                    }
                    .disabled(amount <= 0 || selectedSubCategory == nil)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .overlay {
                if isProcessing {
                    ProgressView("Processing...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.ultraThinMaterial)
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraView { image in
                process(image)
            }
        }
    }

    private func process(_ image: UIImage) {
        isProcessing = true

        OCRService.recognizeText(from: image) { result in
            DispatchQueue.main.async {
                self.amount = result.amount ?? 0
                self.merchant = result.merchant ?? ""
                self.date = result.date ?? .now
                self.suggestedCategoryName = result.suggestedCategory
                
                // Auto-select suggested category if found
                if let suggested = result.suggestedCategory {
                    self.selectedCategory = self.categories.first { $0.name == suggested }
                }
                
                self.isProcessing = false
            }
        }
    }

    private func saveExpense() {
        let ledger = MonthLedgerManager.currentMonthLedger(
            context: modelContext
        )

        let expense = Expense(
            amount: amount,
            date: date,
            paymentMethod: "cash",
            subCategory: selectedSubCategory,
            merchant: merchant
        )

        ledger.expenses.append(expense)
        modelContext.insert(expense)
    }
}

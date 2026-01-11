//
//  ExpenseDetailView.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftUI
import SwiftData

struct ExpenseDetailView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var isEditing = false
    @State private var showDeleteAlert = false
    @State private var showImagePicker = false
    @State private var showingFullImage = false
    @State private var showRemoveBillAlert = false

    // Editable fields (same as AddExpenseView)
    @State private var amountText: String = ""
    @State private var date: Date
    @State private var note: String = ""
    @State private var selectedCategory: Category?
    @State private var selectedSubCategory: SubCategory?
    @State private var showCategoryPicker = false

    // Original expense
    let expense: Expense

    @Query(sort: \Category.name)
    private var categories: [Category]

    init(expense: Expense) {
        self.expense = expense
        self._date = State(initialValue: expense.date)
        self._note = State(initialValue: expense.note ?? "")
        self._selectedCategory = State(initialValue: expense.subCategory?.category)
        self._selectedSubCategory = State(initialValue: expense.subCategory)
        self._amountText = State(initialValue: String(expense.amount))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.xl) {

                    if isEditing {
                        // MARK: - Amount (AddExpenseView style)
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            Text("Amount")
                                .font(DesignSystem.Typography.headlineSmall)

                            HStack {
                                Text(Locale.current.currencySymbol ?? "$")
                                    .font(DesignSystem.Typography.displayMedium)
                                    .foregroundColor(DesignSystem.Colors.primary)

                                TextField("0.00", text: $amountText)
                                    .font(DesignSystem.Typography.displayMedium)
                                    .keyboardType(.decimalPad)
                            }
                            .padding(DesignSystem.Spacing.lg)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                    .fill(DesignSystem.Colors.surfaceVariant)
                            )
                        }

                        // MARK: - Category + Subcategory (AddExpenseView style)
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            Text("Category")
                                .font(DesignSystem.Typography.headlineSmall)

                            Button {
                                showCategoryPicker = true
                            } label: {
                                HStack {
                                    Image(systemName: selectedCategory?.icon ?? "folder")

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(
                                            selectedSubCategory?.name ??
                                            selectedCategory?.name ??
                                            "Select Category"
                                        )
                                        .foregroundColor(
                                            selectedCategory == nil
                                            ? DesignSystem.Colors.textTertiary
                                            : DesignSystem.Colors.textPrimary
                                        )

                                        if let category = selectedCategory {
                                            Text(category.name)
                                                .font(.caption)
                                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                        }
                                    }

                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(DesignSystem.Colors.textTertiary)
                                }
                                .padding(DesignSystem.Spacing.lg)
                                .background(
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                        .fill(DesignSystem.Colors.surfaceVariant)
                                )
                            }
                        }

                        // MARK: - Details (AddExpenseView style)
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            Text("Details")
                                .font(DesignSystem.Typography.headlineSmall)

                            DatePicker(
                                "Date",
                                selection: $date,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.compact)

                            TextField("Note (optional)", text: $note, axis: .vertical)
                                .padding(DesignSystem.Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                        .fill(DesignSystem.Colors.surfaceVariant)
                                )
                                .lineLimit(2...5)
                        }
                    } else {
                        // MARK: - Amount Section (Display mode)
                        VStack(spacing: DesignSystem.Spacing.md) {
                            Text("Amount")
                                .font(DesignSystem.Typography.titleSmall)
                                .foregroundColor(DesignSystem.Colors.textSecondary)

                            Text(amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                                .font(DesignSystem.Typography.displaySmall)
                                .fontWeight(.bold)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                                .fill(DesignSystem.Colors.cardBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                                        .stroke(DesignSystem.Colors.primary.opacity(0.2), lineWidth: 1)
                                )
                        )

                        // MARK: - Bill Image Section
                        billImageView

                        // MARK: - Details Section (Display mode)
                        VStack(spacing: DesignSystem.Spacing.lg) {
                            detailsView
                        }
                    }

                    Color.clear
                        .frame(height: DesignSystem.Spacing.xl)
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("Expense Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(isEditing ? "Save" : "Edit") {
                            if isEditing {
                                saveChanges()
                            } else {
                                isEditing = true
                            }
                        }
                        .disabled(isEditing && !canSave)

                        if !isEditing {
                            Button("Attach Bill") {
                                showImagePicker = true
                            }
                            
                            if expense.billImage != nil {
                                Button("Remove Bill", role: .destructive) {
                                    showRemoveBillAlert = true
                                }
                            }
                            
                            Button("Delete", role: .destructive) {
                                showDeleteAlert = true
                            }
                        } else {
                            Button("Cancel", role: .cancel) {
                                resetFields()
                                isEditing = false
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker { image in
                    if let imageData = image.jpegData(compressionQuality: 0.7) {
                        expense.billImage = imageData
                        do {
                            try modelContext.save()
                        } catch {
                            print("Failed to save bill image: \(error)")
                        }
                    }
                }
            }
            .sheet(isPresented: $showCategoryPicker) {
                CategoryPickerView(
                    categories: categories,
                    selectedCategory: $selectedCategory,
                    selectedSubCategory: $selectedSubCategory
                )
            }
            .onChange(of: selectedCategory) { _, newCategory in
                if newCategory?.id != selectedSubCategory?.category?.id {
                    selectedSubCategory = nil
                }
            }
            .fullScreenCover(isPresented: $showingFullImage) {
                if let imageData = expense.billImage,
                   let uiImage = UIImage(data: imageData) {
                    FullScreenImageView(image: uiImage)
                }
            }
            .alert("Delete Expense", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    deleteExpense()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this expense? This action cannot be undone.")
            }
            .alert("Remove Bill", isPresented: $showRemoveBillAlert) {
                Button("Remove", role: .destructive) {
                    removeBillImage()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to remove the bill image? This action cannot be undone.")
            }
        }
    }

    // MARK: - Bill Image View

    private var billImageView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Bill Image")
                .font(DesignSystem.Typography.headlineSmall)
                .foregroundColor(DesignSystem.Colors.textSecondary)

            if let imageData = expense.billImage,
               let uiImage = UIImage(data: imageData) {
                ZStack {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
                        .onTapGesture {
                            showingFullImage = true
                        }

                    // Full screen indicator
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .font(DesignSystem.Typography.bodySmall)
                                .foregroundColor(DesignSystem.Colors.textOnPrimary)
                                .padding(8)
                                .background(
                                    Circle()
                                        .fill(DesignSystem.Colors.background.opacity(0.7))
                                )
                                .padding()
                        }
                        Spacer()
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .fill(DesignSystem.Colors.cardBackground)
                    .frame(height: 200)
                    .overlay(
                        VStack(spacing: DesignSystem.Spacing.md) {
                            Image(systemName: "photo")
                                .font(DesignSystem.Typography.displaySmall)
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                            
                            Text("No bill image attached")
                                .font(DesignSystem.Typography.bodyMedium)
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                        }
                    )
            }
        }
    }

    // MARK: - Details View

    private var detailsView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            DetailRow(title: "Date", value: date.formatted(date: .abbreviated, time: .omitted))
            DetailRow(title: "Merchant", value: expense.merchant ?? "Not specified")
            DetailRow(title: "Category", value: selectedCategory?.name ?? "Not specified")
            DetailRow(title: "Sub Category", value: selectedSubCategory?.name ?? "Not specified")
            DetailRow(title: "Payment Method", value: expense.paymentMethod)
            if !note.isEmpty {
                DetailRow(title: "Note", value: note)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                .fill(DesignSystem.Colors.cardBackground)
        )
    }

    // MARK: - Validation

    private var canSave: Bool {
        (Double(amountText) ?? 0) > 0 && selectedSubCategory != nil
    }

    // MARK: - Actions

    private func saveChanges() {
        guard let amount = Double(amountText) else { return }
        
        expense.amount = amount
        expense.date = date
        expense.note = note.isEmpty ? nil : note
        expense.subCategory = selectedSubCategory

        do {
            try modelContext.save()
            isEditing = false
        } catch {
            print("Failed to save expense changes: \(error)")
        }
    }

    private func resetFields() {
        amountText = String(expense.amount)
        date = expense.date
        note = expense.note ?? ""
        selectedCategory = expense.subCategory?.category
        selectedSubCategory = expense.subCategory
    }

    private var amount: Double {
        Double(amountText) ?? 0
    }

    private func deleteExpense() {
        // Remove from MonthLedger if present
        let calendar = Calendar.current
        let expenseMonth = calendar.component(.month, from: expense.date)
        let expenseYear = calendar.component(.year, from: expense.date)
        
        let descriptor = FetchDescriptor<MonthLedger>(
            predicate: #Predicate { ledger in
                ledger.month == expenseMonth && ledger.year == expenseYear
            }
        )
        
        if let ledgers = try? modelContext.fetch(descriptor),
           let ledger = ledgers.first {
            ledger.expenses.removeAll { $0.id == expense.id }
        }
        
        // Delete the expense
        modelContext.delete(expense)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to delete expense: \(error)")
        }
    }
    
    private func removeBillImage() {
        expense.billImage = nil
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to remove bill image: \(error)")
        }
    }
}

// MARK: - Supporting Views

struct DetailRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(DesignSystem.Typography.bodyMedium)
                .foregroundColor(DesignSystem.Colors.textSecondary)

            Spacer()

            Text(value)
                .font(DesignSystem.Typography.bodyMedium)
                .foregroundColor(DesignSystem.Colors.textPrimary)
        }
    }
}

struct FullScreenImageView: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .ignoresSafeArea()
            }
            .navigationTitle("Bill Image")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    let onImagePicked: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onImagePicked: onImagePicked)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onImagePicked: (UIImage) -> Void

        init(onImagePicked: @escaping (UIImage) -> Void) {
            self.onImagePicked = onImagePicked
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                onImagePicked(image)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

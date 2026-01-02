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

    // Editable fields
    @State private var amount: Double
    @State private var date: Date
    @State private var merchant: String
    @State private var note: String
    @State private var selectedCategory: Category?
    @State private var selectedSubCategory: SubCategory?

    // Original expense
    let expense: Expense

    @Query(sort: \Category.name)
    private var categories: [Category]

    init(expense: Expense) {
        self.expense = expense
        self._amount = State(initialValue: expense.amount)
        self._date = State(initialValue: expense.date)
        self._merchant = State(initialValue: expense.merchant ?? "")
        self._note = State(initialValue: expense.note ?? "")
        self._selectedCategory = State(initialValue: expense.subCategory?.category)
        self._selectedSubCategory = State(initialValue: expense.subCategory)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.xl) {

                    // MARK: - Amount Section
                    VStack(spacing: DesignSystem.Spacing.md) {
                        Text("Amount")
                            .font(DesignSystem.Typography.titleSmall)
                            .foregroundColor(DesignSystem.Colors.textSecondary)

                        if isEditing {
                            TextField("Amount", value: $amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                                .font(DesignSystem.Typography.displaySmall)
                                .fontWeight(.bold)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.center)
                        } else {
                            Text(amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                                .font(DesignSystem.Typography.displaySmall)
                                .fontWeight(.bold)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                        }
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
                    if !isEditing {
                        billImageView
                    }

                    // MARK: - Details Section
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        if isEditing {
                            editFieldsView
                        } else {
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
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(isEditing ? "Save" : "Edit") {
                            if isEditing {
                                saveChanges()
                            } else {
                                isEditing = true
                            }
                        }
                        .disabled(isEditing && amount <= 0)

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
            DetailRow(title: "Merchant", value: merchant.isEmpty ? "Not specified" : merchant)
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

    // MARK: - Edit Fields View

    private var editFieldsView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("Date")
                    .font(DesignSystem.Typography.titleSmall)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                DatePicker("Date", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.graphical)
            }

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("Merchant")
                    .font(DesignSystem.Typography.titleSmall)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                TextField("Merchant name", text: $merchant)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("Category")
                    .font(DesignSystem.Typography.titleSmall)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
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
                    .pickerStyle(.menu)
                }
            }

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("Note")
                    .font(DesignSystem.Typography.titleSmall)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                TextField("Add a note...", text: $note, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...6)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                .fill(DesignSystem.Colors.cardBackground)
        )
    }

    // MARK: - Actions

    private func saveChanges() {
        expense.amount = amount
        expense.date = date
        expense.merchant = merchant.isEmpty ? nil : merchant
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
        amount = expense.amount
        date = expense.date
        merchant = expense.merchant ?? ""
        note = expense.note ?? ""
        selectedCategory = expense.subCategory?.category
        selectedSubCategory = expense.subCategory
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

/*
 Fast expense-entry screen.

 This sheet is optimized for the app's main habit loop: recording a new expense
 with as little friction as possible.

 The intended order is:
 - choose category
 - enter title
 - enter amount
 - optionally adjust date or note

 The sheet does not talk to SwiftData directly. Instead, it validates user
 input locally and sends the result upward through the `onSave` closure.
 */

import Foundation
import SwiftUI

struct AddExpenseSheet: View {
    private enum Field: Hashable {
        case title
        case amount
        case note
    }

    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?

    let currencyCode: String
    let onSave: (String, ExpenseCategory, Double, Date, String) throws -> Void

    @State private var selectedCategory: ExpenseCategory = .food
    @State private var title = ""
    @State private var amountText = ""
    @State private var date = Date.now
    @State private var note = ""
    @State private var errorMessage: String?
    private var parsedAmount: Double? {
        Self.parseAmount(amountText)
    }

    private var isSaveDisabled: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || (parsedAmount ?? 0) <= 0
    }

    private var saveAvailabilityHint: String? {
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && (parsedAmount ?? 0) <= 0 {
            return "Enter an item and amount to enable save."
        }

        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Enter an item to enable save."
        }

        if (parsedAmount ?? 0) <= 0 {
            return "Enter an amount to enable save."
        }

        return nil
    }

    private var errorAlertBinding: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    errorMessage = nil
                }
            }
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Form {
                    Section {
                        categoryPicker
                    } header: {
                        Text("Category")
                    }

                    Section {
                        TextField("Item", text: $title)
                            .textInputAutocapitalization(.words)
                            .submitLabel(.next)
                            .focused($focusedField, equals: .title)
                            .onSubmit {
                                focusedField = .amount
                            }
                            .accessibilityIdentifier("addExpense.titleField")

                        TextField("Amount", text: $amountText)
                            .keyboardType(.decimalPad)
                            .submitLabel(.done)
                            .focused($focusedField, equals: .amount)
                            .accessibilityIdentifier("addExpense.amountField")
                    } header: {
                        Text("Expense")
                    } footer: {
                        Text("Amounts are displayed using \(currencyCode).")
                    }

                    Section {
                        DatePicker("Date", selection: $date, displayedComponents: .date)

                        TextField("Note", text: $note, axis: .vertical)
                            .lineLimit(2...4)
                            .focused($focusedField, equals: .note)
                            .accessibilityIdentifier("addExpense.noteField")
                    } header: {
                        Text("Details")
                    }
                }
                .scrollDismissesKeyboard(.interactively)

                Button {
                    saveExpense()
                } label: {
                    Text("Save Expense")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isSaveDisabled ? Color(uiColor: .systemGray4) : Color.green)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .disabled(isSaveDisabled)
                .accessibilityIdentifier("addExpense.saveButton")

                if let saveAvailabilityHint {
                    Text(saveAvailabilityHint)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 18)
                        .padding(.top, 6)
                }

                Spacer(minLength: 12)
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Couldn’t Save Expense", isPresented: errorAlertBinding) {
                Button("OK", role: .cancel) {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "Something went wrong.")
            }
            .task {
                guard focusedField == nil else {
                    return
                }

                focusedField = .title
            }
        }
    }

    private var categoryPicker: some View {
        HStack(spacing: 10) {
            ForEach(ExpenseCategory.allCases) { category in
                Button {
                    selectedCategory = category
                } label: {
                    VStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(category.color.opacity(selectedCategory == category ? 0.95 : 0.22))
                            .frame(height: 44)
                            .overlay {
                                Image(systemName: category.symbolName)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(selectedCategory == category ? .white : category.color)
                            }

                        Text(category.title)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("addExpense.category.\(category.rawValue)")
            }
        }
    }

    private func saveExpense() {
        guard let amount = parsedAmount else {
            errorMessage = BudgetStoreError.invalidExpenseAmount.localizedDescription
            return
        }

        do {
            try onSave(title, selectedCategory, amount, date, note)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private static func parseAmount(_ text: String) -> Double? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            return nil
        }

        return Double(trimmed.replacingOccurrences(of: ",", with: "."))
    }
}
private extension ExpenseCategory {
    var color: Color {
        switch self {
        case .food:
            return .green
        case .transport:
            return .blue
        case .household:
            return .orange
        case .fun:
            return .pink
        }
    }

    var symbolName: String {
        switch self {
        case .food:
            return "fork.knife"
        case .transport:
            return "tram.fill"
        case .household:
            return "house.fill"
        case .fun:
            return "sparkles"
        }
    }
}

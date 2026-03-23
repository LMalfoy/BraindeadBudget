/*
 Budget setup and budget-management screen.

 This file is used in two modes:
 - onboarding: first-time setup before the user can use the app
 - manage: later editing from Settings

 The screen lets the user define:
 - monthly income items
 - recurring monthly costs
 - the initial available budget for the currently active period

 It is one of the most important product screens because it establishes the
 financial baseline that the rest of the app relies on.
 */

import Foundation
import SwiftData
import SwiftUI

struct BudgetSettingsSheet: View {
    @AppStorage("hasCompletedBaselineSetup") private var hasCompletedSetup = false

    enum Mode {
        case onboarding
        case manage

        var title: String {
            switch self {
            case .onboarding:
                return "Set Up Budget"
            case .manage:
                return "Budget Setup"
            }
        }

        var actionTitle: String {
            switch self {
            case .onboarding:
                return "Continue"
            case .manage:
                return "Done"
            }
        }
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \IncomeItem.createdAt) private var incomeItems: [IncomeItem]
    @Query(sort: \RecurringExpenseItem.createdAt) private var recurringExpenseItems: [RecurringExpenseItem]
    @Query(sort: \BudgetSettings.updatedAt, order: .reverse) private var settings: [BudgetSettings]

    let mode: Mode

    @State private var activeEditor: BaselineItemDraft?
    @State private var errorMessage: String?
    @State private var initialAvailableBudgetText = ""
    @State private var hasCustomizedInitialAvailableBudget = false

    private var store: BudgetStore {
        BudgetStore(context: modelContext)
    }

    private var currencyCode: String {
        settings.first?.currencyCode ?? Locale.current.currency?.identifier ?? "USD"
    }

    private var totalIncome: Double {
        BudgetStore.totalIncome(for: incomeItems)
    }

    private var totalRecurringExpenses: Double {
        BudgetStore.totalRecurringExpenses(
            for: recurringExpenseItems,
            inMonthContaining: .now
        )
    }

    private var availableBudget: Double {
        BudgetStore.availableMonthlyBudget(
            incomeItems: incomeItems,
            recurringExpenseItems: recurringExpenseItems,
            referenceDate: .now
        )
    }

    private var currentRecurringExpenseItems: [RecurringExpenseItem] {
        BudgetStore.activeRecurringExpenseItems(
            from: recurringExpenseItems,
            inMonthContaining: .now
        )
    }

    private var parsedInitialAvailableBudget: Double? {
        parseDecimalAmount(initialAvailableBudgetText)
    }

    private var currentAvailableBudget: Double {
        parsedInitialAvailableBudget ?? availableBudget
    }

    private var hasValidInitialAvailableBudget: Bool {
        !hasCustomizedInitialAvailableBudget || parsedInitialAvailableBudget != nil
    }

    private var initialAvailableBudgetBinding: Binding<String> {
        Binding(
            get: {
                if hasCustomizedInitialAvailableBudget {
                    return initialAvailableBudgetText
                }

                return formattedAmountText(availableBudget)
            },
            set: { newValue in
                hasCustomizedInitialAvailableBudget = true
                initialAvailableBudgetText = newValue
            }
        )
    }

    private var canCompleteSetup: Bool {
        !incomeItems.isEmpty && (mode == .manage || hasValidInitialAvailableBudget)
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
            Form {
                summarySection
                incomeSection
                recurringExpenseSection
                personalizationSection
            }
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if mode == .manage {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(mode.actionTitle) {
                        completeFlow()
                    }
                    .disabled(mode == .onboarding && !canCompleteSetup)
                    .accessibilityIdentifier("budgetSetup.finishButton")
                }
            }
            .sheet(item: $activeEditor) { draft in
                BaselineItemEditorSheet(draft: draft, currencyCode: currencyCode) { name, amount, category in
                    switch draft.kind {
                    case .income:
                        try store.saveIncomeItem(id: draft.sourceID, name: name, amount: amount)
                    case .recurringExpense:
                        try store.saveRecurringExpenseItem(
                            id: draft.sourceID,
                            name: name,
                            amount: amount,
                            category: category ?? .housingUtilities
                        )
                    }
                }
            }
            .alert("Couldn’t Save Budget Setup", isPresented: errorAlertBinding) {
                Button("OK", role: .cancel) {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "Something went wrong.")
            }
        }
        .interactiveDismissDisabled(mode == .onboarding)
    }

    private var summarySection: some View {
        Section {
            LabeledContent("Income") {
                Text(totalIncome.formatted(.currency(code: currencyCode)))
                    .fontWeight(.medium)
            }

            LabeledContent("Recurring Costs") {
                Text(totalRecurringExpenses.formatted(.currency(code: currencyCode)))
                    .fontWeight(.medium)
            }

            LabeledContent(mode == .onboarding ? "Calculated Monthly Budget" : "Available to Spend") {
                Text(availableBudget.formatted(.currency(code: currencyCode)))
                    .fontWeight(.semibold)
                    .foregroundStyle(availableBudget < 0 ? AppTheme.warningRed : .primary)
            }
            .accessibilityIdentifier("budgetSetup.availableBudgetValue")

        } header: {
            Text(mode == .onboarding ? "Monthly Budget" : "Summary")
        } footer: {
            Text(summaryFooterText)
        }
    }

    private var incomeSection: some View {
        Section {
            if incomeItems.isEmpty {
                Text("Add at least one monthly income item to continue.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(incomeItems) { item in
                    BaselineItemRow(name: item.name, amount: item.amount, currencyCode: currencyCode) {
                        activeEditor = BaselineItemDraft(item: item)
                    }
                }
                .onDelete(perform: deleteIncomeItems)
            }

            Button {
                activeEditor = BaselineItemDraft(kind: .income)
            } label: {
                Label("Add Income", systemImage: "plus.circle.fill")
                    .foregroundStyle(AppTheme.primaryGreen)
            }
            .accessibilityIdentifier("budgetSetup.addIncomeButton")
        } header: {
            Text("Monthly Income")
        }
    }

    private var recurringExpenseSection: some View {
        Section {
            if currentRecurringExpenseItems.isEmpty {
                Text("Recurring costs include rent, subscriptions, insurance, electricity, and savings plans.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(currentRecurringExpenseItems) { item in
                    BaselineItemRow(name: item.name, amount: item.amount, currencyCode: currencyCode) {
                        activeEditor = BaselineItemDraft(item: item)
                    }
                }
                .onDelete(perform: deleteRecurringExpenseItems)
            }

            Button {
                activeEditor = BaselineItemDraft(kind: .recurringExpense)
            } label: {
                Label("Add Recurring Cost", systemImage: "plus.circle.fill")
                    .foregroundStyle(AppTheme.secondaryGreen)
            }
            .accessibilityIdentifier("budgetSetup.addRecurringButton")
        } header: {
            Text("Recurring Monthly Costs")
        } footer: {
            Text("Savings plans are treated like recurring monthly commitments.")
        }
    }

    private var personalizationSection: some View {
        Section {
            if mode == .onboarding {
                TextField("Budget Available for this Period", text: initialAvailableBudgetBinding)
                    .keyboardType(.numbersAndPunctuation)
                    .accessibilityIdentifier("budgetSetup.initialAvailableBudgetField")
            }
        } header: {
            Text("Personalization")
        } footer: {
            if mode == .onboarding {
                Text("Leave 'Budget Available for this Period' unchanged if you are starting at the beginning of a fresh budget period. Only adjust it if this period has already started and some spending already happened, so the amount left today is lower than your normal monthly budget.")
            } else {
                Text("Budget periods always follow the calendar month. The current setup applies from this month forward.")
            }
        }
    }

    private var summaryFooterText: String {
        if mode == .onboarding {
            return "This shows your calculated monthly budget automatically. In most cases, leave the personalization budget value unchanged. Only change it if you are starting mid-period and some of that budget has already been spent."
        }

        return "Update these values any time to recalculate your monthly budget."
    }

    private func completeFlow() {
        do {
            try store.saveSettings(
                currencyCode: currencyCode,
                budgetPeriodAnchorDay: nil,
                initialAvailableBudget: mode == .onboarding ? currentAvailableBudget : nil,
                initialBudgetAnchorMonth: mode == .onboarding ? Self.monthAnchor(for: .now) : nil
            )
            hasCompletedSetup = true
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func deleteIncomeItems(at offsets: IndexSet) {
        do {
            let itemsToDelete = offsets.map { incomeItems[$0] }

            for item in itemsToDelete {
                try store.deleteIncomeItem(item)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func deleteRecurringExpenseItems(at offsets: IndexSet) {
        do {
            let itemsToDelete = offsets.map { currentRecurringExpenseItems[$0] }

            for item in itemsToDelete {
                try store.deleteRecurringExpenseItem(item)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private static func monthAnchor(for date: Date, calendar: Calendar = .current) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
    }
}

private struct BaselineItemRow: View {
    let name: String
    let amount: Double
    let currencyCode: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(name)
                    .foregroundStyle(.primary)
                Spacer()
                Text(amount.formatted(.currency(code: currencyCode)))
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

private enum BaselineItemKind {
    case income
    case recurringExpense

    var title: String {
        switch self {
        case .income:
            return "Income"
        case .recurringExpense:
            return "Recurring Cost"
        }
    }

    var nameLabel: String {
        switch self {
        case .income:
            return "Name"
        case .recurringExpense:
            return "Cost"
        }
    }
}

private struct BaselineItemDraft: Identifiable {
    let id = UUID()
    let kind: BaselineItemKind
    let sourceID: UUID?
    let name: String
    let amount: Double?
    let recurringCategory: RecurringExpenseCategory?

    init(kind: BaselineItemKind) {
        self.kind = kind
        sourceID = nil
        name = ""
        amount = nil
        recurringCategory = kind == .recurringExpense ? .housingUtilities : nil
    }

    init(item: IncomeItem) {
        kind = .income
        sourceID = item.id
        name = item.name
        amount = item.amount
        recurringCategory = nil
    }

    init(item: RecurringExpenseItem) {
        kind = .recurringExpense
        sourceID = item.id
        name = item.name
        amount = item.amount
        recurringCategory = item.category
    }
}

private struct BaselineItemEditorSheet: View {
    private enum Field: Hashable {
        case name
        case amount
    }

    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?

    let draft: BaselineItemDraft
    let currencyCode: String
    let onSave: (String, Double, RecurringExpenseCategory?) throws -> Void

    @State private var name: String
    @State private var amountText: String
    @State private var recurringCategory: RecurringExpenseCategory
    @State private var errorMessage: String?
    @State private var hasRequestedInitialFocus = false

    init(
        draft: BaselineItemDraft,
        currencyCode: String,
        onSave: @escaping (String, Double, RecurringExpenseCategory?) throws -> Void
    ) {
        self.draft = draft
        self.currencyCode = currencyCode
        self.onSave = onSave
        _name = State(initialValue: draft.name)
        _amountText = State(initialValue: Self.startingText(for: draft.amount))
        _recurringCategory = State(initialValue: draft.recurringCategory ?? .housingUtilities)
    }

    private var parsedAmount: Double? {
        parseDecimalAmount(amountText)
    }

    private var isSaveDisabled: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || (parsedAmount ?? 0) <= 0
    }

    private var saveAvailabilityHint: String? {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && (parsedAmount ?? 0) <= 0 {
            return "Enter a name and amount to enable save."
        }

        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Enter a name to enable save."
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
                    if draft.kind == .recurringExpense {
                        Section {
                            recurringCategoryTiles
                        } header: {
                            Text("Category")
                        }
                    }

                    Section {
                        TextField(draft.kind.nameLabel, text: $name)
                            .textInputAutocapitalization(.words)
                            .submitLabel(.next)
                            .focused($focusedField, equals: .name)
                            .onSubmit {
                                focusedField = .amount
                            }
                            .accessibilityIdentifier("baselineItem.nameField")

                        TextField("Amount", text: $amountText)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .amount)
                            .accessibilityIdentifier("baselineItem.amountField")
                    } header: {
                        Text(draft.kind.title)
                    } footer: {
                        Text("Amounts are stored as monthly values in \(currencyCode).")
                    }
                }
                .scrollDismissesKeyboard(.interactively)

                Button {
                    saveItem()
                } label: {
                    Text("Save \(draft.kind.title)")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isSaveDisabled ? AppTheme.neutralGray : AppTheme.primaryGreen)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .disabled(isSaveDisabled)
                .accessibilityIdentifier("baselineItem.saveButton")

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
            .navigationTitle(draft.sourceID == nil ? "Add \(draft.kind.title)" : "Edit \(draft.kind.title)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    EmptyView()
                }
            }
            .alert("Couldn’t Save Item", isPresented: errorAlertBinding) {
                Button("OK", role: .cancel) {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "Something went wrong.")
            }
            .defaultFocus($focusedField, .name)
            .onAppear {
                requestInitialFocusIfNeeded()
            }
        }
    }

    private func saveItem() {
        guard let amount = parsedAmount else {
            errorMessage = draft.kind == .income
                ? BudgetStoreError.invalidIncomeAmount.localizedDescription
                : BudgetStoreError.invalidRecurringExpenseAmount.localizedDescription
            return
        }

        do {
            try onSave(
                name.trimmingCharacters(in: .whitespacesAndNewlines),
                amount,
                draft.kind == .recurringExpense ? recurringCategory : nil
            )
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private var recurringCategoryTiles: some View {
        HStack(spacing: 8) {
            ForEach(RecurringExpenseCategory.allCases) { category in
                Button {
                    recurringCategory = category
                } label: {
                    VStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(category.color.opacity(recurringCategory == category ? 0.95 : 0.22))
                            .frame(height: 42)
                            .overlay {
                                Image(systemName: category.symbolName)
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(recurringCategory == category ? .white : category.color)
                            }

                        Text(category.shortTitle)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.75)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("baselineItem.recurringCategory.\(category.rawValue)")
            }
        }
    }

    private static func parseAmount(_ text: String) -> Double? {
        parseDecimalAmount(text)
    }

    private static func startingText(for amount: Double?) -> String {
        guard let amount, amount > 0 else {
            return ""
        }

        return formattedAmountText(amount)
    }

    private func requestInitialFocusIfNeeded() {
        guard !hasRequestedInitialFocus else {
            return
        }

        hasRequestedInitialFocus = true

        Task { @MainActor in
            focusedField = .name
            try? await Task.sleep(for: .milliseconds(120))

            if focusedField == nil {
                focusedField = .name
            }
        }
    }
}

private func parseDecimalAmount(_ text: String) -> Double? {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

    guard !trimmed.isEmpty else {
        return nil
    }

    return Double(trimmed.replacingOccurrences(of: ",", with: "."))
}

private func formattedAmountText(_ amount: Double) -> String {
    String(format: "%.2f", amount)
}

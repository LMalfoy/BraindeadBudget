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
        BudgetStore.totalRecurringExpenses(for: recurringExpenseItems)
    }

    private var availableBudget: Double {
        BudgetStore.availableMonthlyBudget(
            incomeItems: incomeItems,
            recurringExpenseItems: recurringExpenseItems
        )
    }

    private var canCompleteSetup: Bool {
        !incomeItems.isEmpty
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
                BaselineItemEditorSheet(draft: draft, currencyCode: currencyCode) { name, amount in
                    switch draft.kind {
                    case .income:
                        try store.saveIncomeItem(id: draft.sourceID, name: name, amount: amount)
                    case .recurringExpense:
                        try store.saveRecurringExpenseItem(id: draft.sourceID, name: name, amount: amount)
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

            LabeledContent("Available to Spend") {
                Text(availableBudget.formatted(.currency(code: currencyCode)))
                    .fontWeight(.semibold)
                    .foregroundStyle(availableBudget < 0 ? .red : .primary)
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
            }
            .accessibilityIdentifier("budgetSetup.addIncomeButton")
        } header: {
            Text("Monthly Income")
        }
    }

    private var recurringExpenseSection: some View {
        Section {
            if recurringExpenseItems.isEmpty {
                Text("Recurring costs include rent, subscriptions, insurance, electricity, and savings plans.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(recurringExpenseItems) { item in
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
            }
            .accessibilityIdentifier("budgetSetup.addRecurringButton")
        } header: {
            Text("Recurring Monthly Costs")
        } footer: {
            Text("Savings plans are treated like recurring monthly commitments.")
        }
    }

    private var summaryFooterText: String {
        if mode == .onboarding {
            return "This budget is calculated from income minus recurring monthly costs."
        }

        return "Update these values any time to recalculate your monthly budget."
    }

    private func completeFlow() {
        do {
            try store.saveSettings(currencyCode: currencyCode)
            hasCompletedSetup = true
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func deleteIncomeItems(at offsets: IndexSet) {
        do {
            for index in offsets {
                try store.deleteIncomeItem(incomeItems[index])
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func deleteRecurringExpenseItems(at offsets: IndexSet) {
        do {
            for index in offsets {
                try store.deleteRecurringExpenseItem(recurringExpenseItems[index])
            }
        } catch {
            errorMessage = error.localizedDescription
        }
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
            }
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

    init(kind: BaselineItemKind) {
        self.kind = kind
        sourceID = nil
        name = ""
        amount = nil
    }

    init(item: IncomeItem) {
        kind = .income
        sourceID = item.id
        name = item.name
        amount = item.amount
    }

    init(item: RecurringExpenseItem) {
        kind = .recurringExpense
        sourceID = item.id
        name = item.name
        amount = item.amount
    }
}

private struct BaselineItemEditorSheet: View {
    @Environment(\.dismiss) private var dismiss

    let draft: BaselineItemDraft
    let currencyCode: String
    let onSave: (String, Double) throws -> Void

    @State private var name: String
    @State private var amountText: String
    @State private var errorMessage: String?

    init(
        draft: BaselineItemDraft,
        currencyCode: String,
        onSave: @escaping (String, Double) throws -> Void
    ) {
        self.draft = draft
        self.currencyCode = currencyCode
        self.onSave = onSave
        _name = State(initialValue: draft.name)
        _amountText = State(initialValue: Self.startingText(for: draft.amount))
    }

    private var parsedAmount: Double? {
        Self.parseAmount(amountText)
    }

    private var isSaveDisabled: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || (parsedAmount ?? 0) <= 0
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
                Section {
                    TextField(draft.kind.nameLabel, text: $name)
                        .textInputAutocapitalization(.words)
                        .accessibilityIdentifier("baselineItem.nameField")

                    TextField("Amount", text: $amountText)
                        .keyboardType(.decimalPad)
                        .accessibilityIdentifier("baselineItem.amountField")
                } header: {
                    Text(draft.kind.title)
                } footer: {
                    Text("Amounts are stored as monthly values in \(currencyCode).")
                }
            }
            .navigationTitle(draft.sourceID == nil ? "Add \(draft.kind.title)" : "Edit \(draft.kind.title)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveItem()
                    }
                    .disabled(isSaveDisabled)
                    .accessibilityIdentifier("baselineItem.saveButton")
                }
            }
            .alert("Couldn’t Save Item", isPresented: errorAlertBinding) {
                Button("OK", role: .cancel) {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "Something went wrong.")
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
            try onSave(name, amount)
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

    private static func startingText(for amount: Double?) -> String {
        guard let amount, amount > 0 else {
            return ""
        }

        return String(format: "%.2f", amount)
    }
}

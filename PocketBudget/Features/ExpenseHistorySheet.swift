/*
 Current-month view.

 This screen focuses on the structure of the active budget period:
 - how spending is distributed
 - how spending progressed through the month
 - which expenses belong to the current month
 */

import Charts
import Foundation
import SwiftData
import SwiftUI

struct ExpenseHistorySheet: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @Query(sort: \BudgetSettings.updatedAt, order: .reverse) private var budgets: [BudgetSettings]
    @Query(sort: \IncomeItem.createdAt) private var incomeItems: [IncomeItem]
    @Query(sort: \RecurringExpenseItem.createdAt) private var recurringExpenseItems: [RecurringExpenseItem]

    @State private var editingExpense: Expense?
    @State private var selectedCategoryFilter: ExpenseCategory?
    @State private var errorMessage: String?

    private var store: BudgetStore {
        BudgetStore(context: modelContext)
    }

    private var currencyCode: String {
        budgets.first?.currencyCode ?? Locale.current.currency?.identifier ?? "USD"
    }

    private var initialAvailableBudget: Double? {
        budgets.first?.initialAvailableBudget
    }

    private var initialBudgetAnchorMonth: Date? {
        budgets.first?.initialBudgetAnchorMonth
    }

    private var budgetPeriodAnchorDay: Int {
        budgets.first?.budgetPeriodAnchorDay ?? 1
    }

    private var currentMonthExpenses: [Expense] {
        BudgetStore.currentMonthExpenses(
            from: expenses,
            budgetPeriodAnchorDay: budgetPeriodAnchorDay
        )
    }

    private var monthCategorySpending: [CategorySpendingSummary] {
        BudgetStore.categorySpendingSummaries(for: currentMonthExpenses)
    }

    private var filteredMonthExpenses: [Expense] {
        guard let selectedCategoryFilter else {
            return currentMonthExpenses.sorted { $0.date > $1.date }
        }

        return currentMonthExpenses
            .filter { $0.category == selectedCategoryFilter }
            .sorted { $0.date > $1.date }
    }

    private var monthlyBudget: Double {
        BudgetStore.availableMonthlyBudget(
            incomeItems: incomeItems,
            recurringExpenseItems: recurringExpenseItems
        )
    }

    private var currentMonthDigest: MonthlyHistoryDigest {
        BudgetStore.monthlyHistoryDigest(
            monthlyBudget: monthlyBudget,
            expenses: expenses,
            budgetPeriodAnchorDay: budgetPeriodAnchorDay,
            initialAvailableBudget: initialAvailableBudget,
            initialBudgetAnchorMonth: initialBudgetAnchorMonth
        )
    }

    private var currentMonthTrajectory: [BudgetTrajectoryPoint] {
        BudgetStore.budgetTrajectory(
            monthlyBudget: monthlyBudget,
            expenses: expenses,
            budgetPeriodAnchorDay: budgetPeriodAnchorDay,
            initialAvailableBudget: initialAvailableBudget,
            initialBudgetAnchorMonth: initialBudgetAnchorMonth
        )
    }

    private var recurringSpending: Double {
        recurringExpenseItems.reduce(0) { $0 + $1.amount }
    }

    private var totalSpending: Double {
        currentMonthDigest.totalSpent + recurringSpending
    }

    private var biggestExpense: Expense? {
        currentMonthExpenses.max { $0.amount < $1.amount }
    }

    private var biggestCategoryTitle: String {
        monthCategorySpending.first?.category.title ?? "None"
    }

    private var monthLabel: String {
        Date.now.formatted(.dateTime.month(.wide).year())
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
        List {
            Section {
                monthOverviewCard
            }

            Section {
                if filteredMonthExpenses.isEmpty {
                    Text(selectedCategoryFilter == nil
                         ? "No expenses recorded for the current month."
                         : "No expenses recorded for this category in the current month.")
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 10)
                } else {
                    ForEach(filteredMonthExpenses) { expense in
                        ExpenseHistoryRowView(expense: expense, currencyCode: currencyCode)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                editingExpense = expense
                            }
                    }
                    .onDelete(perform: deleteExpenses)
                }
            } header: {
                Text("Current Month Expenses")
            }
        }
        .contentMargins(.top, 0, for: .scrollContent)
        .navigationTitle("Month")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $editingExpense) { expense in
            ExpenseEditorSheet(expense: expense, currencyCode: currencyCode) { expense, title, category, amount, date, note in
                try store.updateExpense(
                    expense,
                    title: title,
                    category: category,
                    amount: amount,
                    date: date,
                    note: note
                )
            }
        }
        .alert("Couldn’t Update Expense", isPresented: errorAlertBinding) {
            Button("OK", role: .cancel) {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "Something went wrong.")
        }
        .onReceive(NotificationCenter.default.publisher(for: .openExpenseHistoryMonth)) { _ in
            selectedCategoryFilter = nil
        }
    }

    private var monthOverviewCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(monthLabel)
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                monthMetric(title: "Variable Spending", value: currentMonthDigest.totalSpent.formatted(.currency(code: currencyCode)))
                monthMetric(title: "Recurring Spending", value: recurringSpending.formatted(.currency(code: currencyCode)))
                monthMetric(title: "Total Spending", value: totalSpending.formatted(.currency(code: currencyCode)))
                monthMetric(title: "Biggest Category", value: biggestCategoryTitle)
            }

            if !monthCategorySpending.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Spending by Category")
                        .font(.headline)

                    Chart(monthCategorySpending) { summary in
                        SectorMark(
                            angle: .value("Amount", summary.total),
                            innerRadius: .ratio(0.58),
                            angularInset: 2
                        )
                        .foregroundStyle(summary.category.color)
                    }
                    .chartLegend(.hidden)
                    .frame(height: 180)

                    historyCategoryTiles

                    VStack(spacing: 10) {
                        ForEach(monthCategorySpending) { summary in
                            HStack(spacing: 10) {
                                Circle()
                                    .fill(summary.category.color)
                                    .frame(width: 10, height: 10)

                                Text(summary.category.title)
                                    .foregroundStyle(.primary)

                                Spacer()

                                Text(summary.total.formatted(.currency(code: currencyCode)))
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Spending Trajectory")
                    .font(.headline)

                if currentMonthTrajectory.isEmpty {
                    Text("Add some expenses to see how spending has progressed through the month.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    Chart(currentMonthTrajectory) { point in
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("Remaining", point.remainingBudget)
                        )
                        .foregroundStyle(.green)

                        AreaMark(
                            x: .value("Date", point.date),
                            y: .value("Remaining", point.remainingBudget)
                        )
                        .foregroundStyle(.green.opacity(0.12))
                    }
                    .frame(height: 180)
                }
            }

            if let biggestExpense {
                Text("Biggest expense this month: \(biggestExpense.title) (\(biggestExpense.amount.formatted(.currency(code: currencyCode))))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var historyCategoryTiles: some View {
        HStack(spacing: 10) {
            ForEach(ExpenseCategory.allCases) { category in
                Button {
                    toggleCategoryFilter(category)
                } label: {
                    VStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(category.color.opacity(selectedCategoryFilter == category ? 0.95 : 0.22))
                            .frame(height: 44)
                            .overlay {
                                Image(systemName: category.symbolName)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(selectedCategoryFilter == category ? .white : category.color)
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
                .accessibilityIdentifier("month.categoryFilter.\(category.rawValue)")
            }

            Button {
                selectedCategoryFilter = nil
            } label: {
                VStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(selectedCategoryFilter == nil ? Color.accentColor.opacity(0.95) : Color(uiColor: .secondarySystemBackground))
                        .frame(height: 44)
                        .overlay {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(selectedCategoryFilter == nil ? .white : .secondary)
                        }

                    Text("All")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("month.categoryFilter.all")
        }
    }

    private func toggleCategoryFilter(_ category: ExpenseCategory) {
        if selectedCategoryFilter == category {
            selectedCategoryFilter = nil
        } else {
            selectedCategoryFilter = category
        }
    }

    @ViewBuilder
    private func monthMetric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func deleteExpenses(at offsets: IndexSet) {
        do {
            let itemsToDelete = offsets.map { filteredMonthExpenses[$0] }

            for expense in itemsToDelete {
                try store.deleteExpense(expense)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private struct ExpenseHistoryRowView: View {
    let expense: Expense
    let currencyCode: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(expense.category.color)
                .frame(width: 6)

            VStack(alignment: .leading, spacing: 4) {
                Text(expense.title)
                    .font(.body.weight(.medium))

                HStack(spacing: 8) {
                    Text(expense.category.title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(expense.category.color)

                    Text(expense.date, format: .dateTime.month(.abbreviated).day().year())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if !expense.note.isEmpty {
                    Text(expense.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 12)

            Text(expense.amount.formatted(.currency(code: currencyCode)))
                .font(.body.weight(.semibold))
        }
        .padding(.vertical, 6)
    }
}

private struct ExpenseEditorSheet: View {
    private enum Field: Hashable {
        case title
        case amount
        case note
    }

    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?

    let expense: Expense
    let currencyCode: String
    let onSave: (Expense, String, ExpenseCategory, Double, Date, String) throws -> Void

    @State private var selectedCategory: ExpenseCategory
    @State private var title: String
    @State private var amountText: String
    @State private var date: Date
    @State private var note: String
    @State private var errorMessage: String?

    init(
        expense: Expense,
        currencyCode: String,
        onSave: @escaping (Expense, String, ExpenseCategory, Double, Date, String) throws -> Void
    ) {
        self.expense = expense
        self.currencyCode = currencyCode
        self.onSave = onSave
        _selectedCategory = State(initialValue: expense.category)
        _title = State(initialValue: expense.title)
        _amountText = State(initialValue: Self.formatAmount(expense.amount))
        _date = State(initialValue: expense.date)
        _note = State(initialValue: expense.note)
    }

    private var parsedAmount: Double? {
        Self.parseAmount(amountText)
    }

    private var isSaveDisabled: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || (parsedAmount ?? 0) <= 0
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
                        .accessibilityIdentifier("editExpense.titleField")

                    TextField("Amount", text: $amountText)
                        .keyboardType(.decimalPad)
                        .submitLabel(.done)
                        .focused($focusedField, equals: .amount)
                        .onSubmit {
                            guard !isSaveDisabled else {
                                return
                            }

                            saveExpense()
                        }
                        .accessibilityIdentifier("editExpense.amountField")
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
                        .accessibilityIdentifier("editExpense.noteField")
                } header: {
                    Text("Details")
                }
            }
            .navigationTitle("Edit Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveExpense()
                    }
                    .disabled(isSaveDisabled)
                    .accessibilityIdentifier("editExpense.saveButton")
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()

                    Button("Save") {
                        saveExpense()
                    }
                    .disabled(isSaveDisabled)
                }
            }
            .defaultFocus($focusedField, .title)
            .alert("Couldn’t Save Expense", isPresented: errorAlertBinding) {
                Button("OK", role: .cancel) {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "Something went wrong.")
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
                            .frame(height: 52)
                            .overlay {
                                Image(systemName: category.symbolName)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(selectedCategory == category ? .white : category.color)
                            }

                        Text(category.title)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func saveExpense() {
        guard let amount = parsedAmount else {
            return
        }

        do {
            try onSave(
                expense,
                title.trimmingCharacters(in: .whitespacesAndNewlines),
                selectedCategory,
                amount,
                date,
                note.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private static func parseAmount(_ rawValue: String) -> Double? {
        let normalized = rawValue
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return Double(normalized)
    }

    private static func formatAmount(_ amount: Double) -> String {
        let roundedAmount = amount.rounded(.toNearestOrAwayFromZero)
        if roundedAmount == amount {
            return String(Int(amount))
        }

        return amount.formatted(.number.precision(.fractionLength(2)))
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
            return "car.fill"
        case .household:
            return "house.fill"
        case .fun:
            return "sparkles"
        }
    }
}

import Foundation
import SwiftData
import SwiftUI

struct ExpenseHistorySheet: View {
    private static let historyCalendar = Calendar.current

    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @Query(sort: \BudgetSettings.updatedAt, order: .reverse) private var budgets: [BudgetSettings]
    @Query(sort: \IncomeItem.createdAt) private var incomeItems: [IncomeItem]
    @Query(sort: \RecurringExpenseItem.createdAt) private var recurringExpenseItems: [RecurringExpenseItem]

    @State private var selectedMonth = ExpenseHistorySheet.monthAnchor(for: .now)
    @State private var editingExpense: Expense?
    @State private var showingMonthPicker = false
    @State private var errorMessage: String?

    private var store: BudgetStore {
        BudgetStore(context: modelContext)
    }

    private var currencyCode: String {
        budgets.first?.currencyCode ?? Locale.current.currency?.identifier ?? "USD"
    }

    private var monthExpenses: [Expense] {
        store.expenses(from: expenses, inMonthContaining: selectedMonth)
    }

    private var monthlyBudget: Double {
        BudgetStore.availableMonthlyBudget(
            incomeItems: incomeItems,
            recurringExpenseItems: recurringExpenseItems
        )
    }

    private var digest: MonthlyHistoryDigest {
        BudgetStore.monthlyHistoryDigest(
            monthlyBudget: monthlyBudget,
            expenses: expenses,
            referenceDate: selectedMonth
        )
    }

    private var monthLabel: String {
        selectedMonth.formatted(.dateTime.month(.wide).year())
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
                monthNavigator
            }

            Section {
                MonthlyHistoryDigestView(
                    digest: digest,
                    currencyCode: currencyCode
                )
            }

            Section {
                if monthExpenses.isEmpty {
                    Text("No expenses recorded for this month.")
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 10)
                } else {
                    ForEach(monthExpenses) { expense in
                        ExpenseHistoryRowView(expense: expense, currencyCode: currencyCode)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                editingExpense = expense
                            }
                    }
                    .onDelete(perform: deleteExpenses)
                }
            }
        }
        .contentMargins(.top, 0, for: .scrollContent)
        .navigationTitle("Expense History")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingMonthPicker) {
            MonthYearPickerSheet(selectedMonth: $selectedMonth, availableYears: availableYears)
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
        }
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
    }

    private var monthNavigator: some View {
        HStack {
            Button {
                shiftMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
            }
            .accessibilityIdentifier("history.previousMonthButton")

            Spacer()

            Button {
                showingMonthPicker = true
            } label: {
                HStack(spacing: 6) {
                    Text(monthLabel)
                        .font(.headline)
                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("history.monthLabel")

            Spacer()

            Button {
                shiftMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
            }
            .accessibilityIdentifier("history.nextMonthButton")
        }
        .buttonStyle(.plain)
        .padding(.vertical, 4)
    }

    private var availableYears: [Int] {
        let expenseYears = expenses.map { Self.historyCalendar.component(.year, from: $0.date) }
        let currentYear = Self.historyCalendar.component(.year, from: .now)
        let minimumYear = min(expenseYears.min() ?? currentYear, currentYear) - 1
        let maximumYear = max(expenseYears.max() ?? currentYear, currentYear) + 1

        return Array(minimumYear...maximumYear)
    }

    private func shiftMonth(by value: Int) {
        if let shiftedMonth = Self.historyCalendar.date(byAdding: .month, value: value, to: selectedMonth) {
            selectedMonth = Self.monthAnchor(for: shiftedMonth)
        }
    }

    private static func monthAnchor(for date: Date) -> Date {
        let components = historyCalendar.dateComponents([.year, .month], from: date)
        return historyCalendar.date(from: components) ?? date
    }

    private func deleteExpenses(at offsets: IndexSet) {
        do {
            let itemsToDelete = offsets.map { monthExpenses[$0] }

            for expense in itemsToDelete {
                try store.deleteExpense(expense)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private struct MonthlyHistoryDigestView: View {
    let digest: MonthlyHistoryDigest
    let currencyCode: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                digestItem(title: "Spent", value: digest.totalSpent)
                Spacer()
                digestItem(title: "Carryover", value: digest.carryover)
            }

            if digest.categorySpending.isEmpty {
                Text("No category totals for this month yet.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(digest.categorySpending) { summary in
                        HStack(spacing: 10) {
                            Circle()
                                .fill(summary.category.color)
                                .frame(width: 8, height: 8)

                            Text(summary.category.title)
                                .font(.footnote)

                            Spacer()

                            Text(summary.total.formatted(.currency(code: currencyCode)))
                                .font(.footnote.weight(.medium))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func digestItem(title: String, value: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value.formatted(.currency(code: currencyCode)))
                .font(.headline.weight(.semibold))
                .foregroundStyle(value < 0 ? .red : .primary)
        }
    }
}

private struct MonthYearPickerSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var selectedMonth: Date
    let availableYears: [Int]

    @State private var selectedYear: Int
    @State private var selectedMonthIndex: Int

    init(selectedMonth: Binding<Date>, availableYears: [Int]) {
        _selectedMonth = selectedMonth
        self.availableYears = availableYears

        let initialDate = selectedMonth.wrappedValue
        _selectedYear = State(initialValue: Calendar.current.component(.year, from: initialDate))
        _selectedMonthIndex = State(initialValue: Calendar.current.component(.month, from: initialDate))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Picker("Month", selection: $selectedMonthIndex) {
                        ForEach(1...12, id: \.self) { month in
                            Text(monthName(for: month)).tag(month)
                        }
                    }
                    .pickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .accessibilityIdentifier("history.monthPicker.month")

                    Picker("Year", selection: $selectedYear) {
                        ForEach(availableYears, id: \.self) { year in
                            Text(String(year)).tag(year)
                        }
                    }
                    .pickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .accessibilityIdentifier("history.monthPicker.year")
                }
                .frame(height: 180)
            }
            .navigationTitle("Select Month")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        applySelection()
                    }
                    .accessibilityIdentifier("history.monthPicker.doneButton")
                }
            }
        }
    }

    private func applySelection() {
        let components = DateComponents(year: selectedYear, month: selectedMonthIndex, day: 1)

        if let updatedDate = Calendar.current.date(from: components) {
            selectedMonth = updatedDate
        }

        dismiss()
    }

    private func monthName(for month: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = .current
        return formatter.monthSymbols[month - 1]
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
                .accessibilityIdentifier("editExpense.category.\(category.rawValue)")
            }
        }
    }

    private func saveExpense() {
        guard let amount = parsedAmount else {
            errorMessage = BudgetStoreError.invalidExpenseAmount.localizedDescription
            return
        }

        do {
            try onSave(expense, title, selectedCategory, amount, date, note)
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

    private static func formatAmount(_ amount: Double) -> String {
        if amount.rounded() == amount {
            return String(Int(amount))
        }

        return String(amount)
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

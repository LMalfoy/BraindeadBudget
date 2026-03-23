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
    @State private var selectedMonth = Self.displayMonth(for: .now)
    @State private var pendingMonthSelection = Self.displayMonth(for: .now)
    @State private var showingMonthPicker = false
    @State private var errorMessage: String?

    private var store: BudgetStore {
        BudgetStore(context: modelContext)
    }

    private var calendar: Calendar {
        .current
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

    private var selectedMonthReferenceDate: Date {
        selectedMonth
    }

    private var monthCategorySpending: [CategorySpendingSummary] {
        BudgetStore.categorySpendingSummaries(for: selectedMonthExpenses)
    }

    private var selectedMonthExpenses: [Expense] {
        BudgetStore.expenses(
            from: expenses,
            inMonthContaining: selectedMonthReferenceDate,
            calendar: calendar
        )
    }

    private var filteredSelectedMonthExpenses: [Expense] {
        guard let selectedCategoryFilter else {
            return selectedMonthExpenses.sorted { $0.date > $1.date }
        }

        return selectedMonthExpenses
            .filter { $0.category == selectedCategoryFilter }
            .sorted { $0.date > $1.date }
    }

    private var monthlyBudget: Double {
        BudgetStore.availableMonthlyBudget(
            incomeItems: incomeItems,
            recurringExpenseItems: recurringExpenseItems,
            referenceDate: selectedMonthReferenceDate,
            calendar: calendar
        )
    }

    private var selectedMonthDigest: MonthlyHistoryDigest {
        BudgetStore.monthlyHistoryDigest(
            incomeItems: incomeItems,
            recurringExpenseItems: recurringExpenseItems,
            expenses: expenses,
            initialAvailableBudget: initialAvailableBudget,
            initialBudgetAnchorMonth: initialBudgetAnchorMonth,
            calendar: calendar,
            referenceDate: selectedMonthReferenceDate
        )
    }

    private var selectedMonthTrajectory: [BudgetTrajectoryPoint] {
        BudgetStore.budgetTrajectory(
            incomeItems: incomeItems,
            recurringExpenseItems: recurringExpenseItems,
            expenses: expenses,
            initialAvailableBudget: initialAvailableBudget,
            initialBudgetAnchorMonth: initialBudgetAnchorMonth,
            calendar: calendar,
            referenceDate: selectedMonthReferenceDate
        )
    }

    private var recurringSpending: Double {
        BudgetStore.totalRecurringExpenses(
            for: recurringExpenseItems,
            inMonthContaining: selectedMonthReferenceDate,
            calendar: calendar
        )
    }

    private var totalSpending: Double {
        selectedMonthDigest.totalSpent + recurringSpending
    }

    private var biggestExpense: Expense? {
        selectedMonthExpenses.max { $0.amount < $1.amount }
    }

    private var selectedMonthLabel: String {
        selectedMonth.formatted(.dateTime.month(.wide).year())
    }

    private var variableCategorySlices: [MonthCategorySlice] {
        monthCategorySpending.map {
            MonthCategorySlice(title: $0.category.title, total: $0.total, color: $0.category.color)
        }
    }

    private var recurringCategorySlices: [MonthCategorySlice] {
        BudgetStore.fixedCostDistribution(
            for: recurringExpenseItems,
            referenceDate: selectedMonthReferenceDate,
            calendar: calendar
        ).map {
            MonthCategorySlice(title: $0.category.title, total: $0.total, color: $0.category.color)
        }
    }

    private var totalCategorySlices: [MonthCategorySlice] {
        (variableCategorySlices + recurringCategorySlices)
            .sorted { lhs, rhs in
                if lhs.total == rhs.total {
                    return lhs.title < rhs.title
                }

                return lhs.total > rhs.total
            }
    }

    private var recurringBreakdownSections: [MonthRecurringBreakdownSection] {
        [
            recurringBreakdownSection(for: .subscriptions, title: "Subscriptions"),
            recurringBreakdownSection(for: .insurance, title: "Insurance")
        ]
    }

    private var trajectoryAxisDates: [Date] {
        guard
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonthReferenceDate)),
            let monthRange = calendar.range(of: .day, in: .month, for: monthStart)
        else {
            return []
        }

        let axisDays = [1, 8, 15, 22, 29].filter { monthRange.contains($0) }
        return axisDays.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: monthStart)
        }
    }

    private var selectedMonthYear: Int {
        calendar.component(.year, from: selectedMonth)
    }

    private var yearOptions: [Int] {
        let currentYear = calendar.component(.year, from: .now)
        let lowerBound = min(currentYear - 5, selectedMonthYear - 5)
        let upperBound = max(currentYear + 5, selectedMonthYear + 5)
        return Array(lowerBound...upperBound)
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
                monthNavigationHeader
                    .padding(.vertical, 4)
            }

            Section {
                monthSummaryCard
            }

            Section {
                monthCategoryCard
            }

            Section {
                budgetTrajectoryCard
            }

            Section {
                recurringBreakdownCard
            } header: {
                Text("Recurring Breakdown")
            }

            Section {
                transactionFilterBar
                    .padding(.vertical, 4)

                if filteredSelectedMonthExpenses.isEmpty {
                    Text(selectedCategoryFilter == nil
                         ? "No transactions recorded for this month."
                         : "No transactions recorded for this category in this month.")
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 10)
                } else {
                    ForEach(filteredSelectedMonthExpenses) { expense in
                        ExpenseHistoryRowView(expense: expense, currencyCode: currencyCode)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                editingExpense = expense
                            }
                    }
                    .onDelete(perform: deleteExpenses)
                }
            } header: {
                Text("Transactions")
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
        .sheet(isPresented: $showingMonthPicker) {
            MonthPickerSheet(
                selectedMonth: $pendingMonthSelection,
                yearOptions: yearOptions
            ) {
                selectedMonth = Self.displayMonth(for: pendingMonthSelection)
                showingMonthPicker = false
            } onCancel: {
                pendingMonthSelection = selectedMonth
                showingMonthPicker = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .openExpenseHistoryMonth)) { notification in
            selectedCategoryFilter = nil

            if let monthDate = notification.object as? Date {
                let normalizedMonth = Self.displayMonth(for: monthDate)
                selectedMonth = normalizedMonth
                pendingMonthSelection = normalizedMonth
            }
        }
    }

    private var monthNavigationHeader: some View {
        HStack {
            Button {
                shiftSelectedMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline.weight(.semibold))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("month.previousButton")

            Spacer()

            Button {
                pendingMonthSelection = selectedMonth
                showingMonthPicker = true
            } label: {
                HStack(spacing: 6) {
                    Text(selectedMonthLabel)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.primary)

                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("month.pickerButton")

            Spacer()

            Button {
                shiftSelectedMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.headline.weight(.semibold))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("month.nextButton")
        }
    }

    private var monthSummaryCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                monthMetric(title: "Variable Spending", value: selectedMonthDigest.totalSpent.formatted(.currency(code: currencyCode)))
                monthMetric(title: "Recurring Spending", value: recurringSpending.formatted(.currency(code: currencyCode)))
                monthMetric(title: "Total Spending", value: totalSpending.formatted(.currency(code: currencyCode)))
                monthMetric(
                    title: "Biggest Expense",
                    value: biggestExpense.map { "\($0.title) (\($0.amount.formatted(.currency(code: currencyCode))))" } ?? "None"
                )
            }
        }
        .padding(.vertical, 4)
    }

    private var monthCategoryCard: some View {
        ChartPanelCard {
            SwipeableChartCard(height: 470, showsInteractiveBackground: true) {
                MonthCategoryChartPage(
                    title: "Spending by Category",
                    subtitle: "Variable Spending",
                    slices: variableCategorySlices,
                    currencyCode: currencyCode,
                    emptyStateText: "No variable spending recorded for this month."
                )

                MonthCategoryChartPage(
                    title: "Spending by Category",
                    subtitle: "Recurring Spending",
                    slices: recurringCategorySlices,
                    currencyCode: currencyCode,
                    emptyStateText: "No recurring costs configured."
                )

                MonthCategoryChartPage(
                    title: "Spending by Category",
                    subtitle: "Total Spending",
                    slices: totalCategorySlices,
                    currencyCode: currencyCode,
                    emptyStateText: "No spending data available for this month."
                )
            }
        }
    }

    private var budgetTrajectoryCard: some View {
        ChartPanelCard {
            VStack(alignment: .leading, spacing: ChartPanelMetrics.contentSpacing) {
                ChartPanelHeader(title: "Budget Trajectory")

                Chart {
                    ForEach(selectedMonthTrajectory) { point in
                        AreaMark(
                            x: .value("Date", point.date),
                            yStart: .value("Budget", 0),
                            yEnd: .value("Budget", point.remainingBudget)
                        )
                        .foregroundStyle(point.remainingBudget >= 0 ? AppTheme.primaryGreen.opacity(0.18) : AppTheme.warningRed.opacity(0.2))

                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("Budget", point.remainingBudget)
                        )
                        .foregroundStyle(point.remainingBudget >= 0 ? AppTheme.primaryGreen : AppTheme.warningRed)
                        .lineStyle(.init(lineWidth: 2.5))
                    }
                }
                .chartXAxis {
                    AxisMarks(values: trajectoryAxisDates) { value in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.day())
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: value.as(Double.self) == 0 ? 1.5 : 0.75, dash: value.as(Double.self) == 0 ? [5, 4] : []))
                            .foregroundStyle(value.as(Double.self) == 0 ? Color.secondary : Color.secondary.opacity(0.35))
                        AxisValueLabel {
                            if let amount = value.as(Double.self) {
                                Text(chartCurrencyLabel(amount, currencyCode: currencyCode))
                            }
                        }
                    }
                }
                .frame(height: 220)
                .padding(.horizontal, 8)
                .padding(.vertical, 10)
            }
        }
        .padding(.vertical, 4)
    }

    private var recurringBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(recurringBreakdownSections) { section in
                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(section.title)
                            .font(.headline)

                        Text("\(section.totalLabel): \(section.total.formatted(.currency(code: currencyCode)))")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)

                        Text(section.activeItemSummary)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    if section.items.isEmpty {
                        Text("No \(section.title.lowercased()) recorded.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(Array(section.items.enumerated()), id: \.element.id) { index, item in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("\(index + 1).")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.secondary)
                                        .frame(width: 20, alignment: .leading)

                                    Text(item.name)
                                        .font(.subheadline)
                                        .foregroundStyle(.primary)

                                    Spacer(minLength: 12)

                                    Text(item.amount.formatted(.currency(code: currencyCode)))
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(.top, 2)
                    }
                }
                .padding(16)
                .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
        .padding(.vertical, 4)
    }

    private var transactionFilterBar: some View {
        HStack(spacing: 10) {
            transactionFilterButton(
                title: "All",
                symbolName: "line.3.horizontal.decrease.circle",
                isSelected: selectedCategoryFilter == nil,
                tint: .accentColor
            ) {
                selectedCategoryFilter = nil
            }

            ForEach(ExpenseCategory.allCases) { category in
                transactionFilterButton(
                    title: category.title,
                    symbolName: category.symbolName,
                    isSelected: selectedCategoryFilter == category,
                    tint: category.color
                ) {
                    toggleCategoryFilter(category)
                }
            }
        }
    }

    private func toggleCategoryFilter(_ category: ExpenseCategory) {
        if selectedCategoryFilter == category {
            selectedCategoryFilter = nil
        } else {
            selectedCategoryFilter = category
        }
    }

    private func shiftSelectedMonth(by value: Int) {
        guard let shiftedMonth = calendar.date(byAdding: .month, value: value, to: selectedMonth) else {
            return
        }

        selectedMonth = Self.displayMonth(for: shiftedMonth)
        pendingMonthSelection = selectedMonth
        selectedCategoryFilter = nil
    }

    private func recurringBreakdownSection(
        for category: RecurringExpenseCategory,
        title: String
    ) -> MonthRecurringBreakdownSection {
        let items = BudgetStore.recurringItems(
            for: recurringExpenseItems,
            category: category,
            referenceDate: selectedMonthReferenceDate,
            calendar: calendar
        )
        return MonthRecurringBreakdownSection(
            title: title,
            total: items.reduce(0) { $0 + $1.amount },
            items: items
        )
    }

    @ViewBuilder
    private func transactionFilterButton(
        title: String,
        symbolName: String,
        isSelected: Bool,
        tint: Color = .accentColor,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? tint.opacity(0.95) : tint.opacity(0.22))
                    .frame(height: 40)
                    .overlay {
                        Image(systemName: symbolName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(isSelected ? .white : tint)
                    }

                Text(title)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("month.categoryFilter.\(title.lowercased())")
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
            let itemsToDelete = offsets.map { filteredSelectedMonthExpenses[$0] }

            for expense in itemsToDelete {
                try store.deleteExpense(expense)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private static func displayMonth(for date: Date, calendar: Calendar = .current) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
    }
}

private struct MonthCategorySlice: Identifiable, Equatable {
    let title: String
    let total: Double
    let color: Color

    var id: String { title }
}

private struct MonthRecurringBreakdownSection: Identifiable, Equatable {
    let title: String
    let total: Double
    let items: [RecurringItemSummary]

    var id: String { title }

    var totalLabel: String {
        title == "Insurance" ? "Monthly Insurance Cost" : "Monthly Subscription Cost"
    }

    var activeItemSummary: String {
        let count = items.count
        let label = title == "Insurance" ? "active policies" : "active subscriptions"
        let singularLabel = title == "Insurance" ? "active policy" : "active subscription"

        if count == 1 {
            return "1 \(singularLabel)"
        }

        return "\(count) \(label)"
    }
}

private struct MonthCategoryChartPage: View {
    let title: String
    let subtitle: String
    let slices: [MonthCategorySlice]
    let currencyCode: String
    let emptyStateText: String

    var body: some View {
        DonutChartPanel(
            title: title,
            subtitle: subtitle,
            slices: slices.map {
                DonutChartDatum(
                    id: $0.id,
                    title: $0.title,
                    total: $0.total,
                    color: $0.color,
                    valueLabel: $0.total.formatted(.currency(code: currencyCode))
                )
            },
            emptyStateText: emptyStateText,
            chartHeight: 190,
            legendHeight: ChartPanelMetrics.legendHeight
        )
    }
}

private struct MonthPickerSheet: View {
    @Binding var selectedMonth: Date

    let yearOptions: [Int]
    let onDone: () -> Void
    let onCancel: () -> Void

    private let calendar = Calendar.current

    private var selectedMonthNumber: Binding<Int> {
        Binding(
            get: { calendar.component(.month, from: selectedMonth) },
            set: { month in
                updateSelectedMonth(month: month, year: calendar.component(.year, from: selectedMonth))
            }
        )
    }

    private var selectedYearNumber: Binding<Int> {
        Binding(
            get: { calendar.component(.year, from: selectedMonth) },
            set: { year in
                updateSelectedMonth(month: calendar.component(.month, from: selectedMonth), year: year)
            }
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                HStack(spacing: 0) {
                    Picker("Month", selection: selectedMonthNumber) {
                        ForEach(1...12, id: \.self) { month in
                            Text(monthName(for: month)).tag(month)
                        }
                    }
                    .pickerStyle(.wheel)

                    Picker("Year", selection: selectedYearNumber) {
                        ForEach(yearOptions, id: \.self) { year in
                            Text("\(year)").tag(year)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                .frame(height: 180)

                Spacer()
            }
            .padding(.top, 12)
            .navigationTitle("Select Month")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        onDone()
                    }
                }
            }
        }
        .presentationDetents([.height(300)])
        .presentationDragIndicator(.visible)
    }

    private func updateSelectedMonth(month: Int, year: Int) {
        let components = DateComponents(year: year, month: month, day: 1)
        selectedMonth = calendar.date(from: components) ?? selectedMonth
    }

    private func monthName(for month: Int) -> String {
        let components = DateComponents(year: 2024, month: month, day: 1)
        let date = calendar.date(from: components) ?? .now
        return date.formatted(.dateTime.month(.wide))
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

    private enum EntryKind: String, CaseIterable, Identifiable {
        case expense
        case income

        var id: String { rawValue }

        var title: String {
            switch self {
            case .expense:
                return "Expense"
            case .income:
                return "Income"
            }
        }
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
    @State private var entryKind: EntryKind
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
        _amountText = State(initialValue: Self.formatAmount(abs(expense.amount)))
        _date = State(initialValue: expense.date)
        _note = State(initialValue: expense.note)
        _entryKind = State(initialValue: expense.amount < 0 ? .income : .expense)
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

                    Picker("Entry Type", selection: $entryKind) {
                        ForEach(EntryKind.allCases) { kind in
                            Text(kind.title).tag(kind)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("editExpense.entryTypePicker")
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
                signedAmount(from: amount),
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

    private func signedAmount(from amount: Double) -> Double {
        entryKind == .income ? -abs(amount) : abs(amount)
    }
}

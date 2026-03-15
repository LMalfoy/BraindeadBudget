import Foundation
import SwiftData

struct CategorySpendingSummary: Identifiable, Equatable {
    let category: ExpenseCategory
    let total: Double

    var id: ExpenseCategory { category }
}

enum BudgetStoreError: LocalizedError {
    case invalidExpenseCategory
    case invalidExpenseTitle
    case invalidExpenseAmount
    case invalidIncomeName
    case invalidIncomeAmount
    case invalidRecurringExpenseName
    case invalidRecurringExpenseAmount

    var errorDescription: String? {
        switch self {
        case .invalidExpenseCategory:
            return "Choose a category for the expense."
        case .invalidExpenseTitle:
            return "Enter a title for the expense."
        case .invalidExpenseAmount:
            return "Enter an expense amount greater than zero."
        case .invalidIncomeName:
            return "Enter a name for the income item."
        case .invalidIncomeAmount:
            return "Enter an income amount greater than zero."
        case .invalidRecurringExpenseName:
            return "Enter a name for the recurring cost."
        case .invalidRecurringExpenseAmount:
            return "Enter a recurring cost amount greater than zero."
        }
    }
}

@MainActor
struct BudgetStore {
    private let context: ModelContext
    private let calendar: Calendar

    init(context: ModelContext, calendar: Calendar = .current) {
        self.context = context
        self.calendar = calendar
    }

    func saveSettings(currencyCode: String) throws {
        let budgets = try context.fetch(FetchDescriptor<BudgetSettings>())

        if let settings = budgets.first {
            settings.currencyCode = currencyCode
            settings.updatedAt = .now

            for duplicate in budgets.dropFirst() {
                context.delete(duplicate)
            }
        } else {
            context.insert(BudgetSettings(currencyCode: currencyCode))
        }

        try context.save()
    }

    func addExpense(
        title: String,
        category: ExpenseCategory,
        amount: Double,
        date: Date = .now,
        note: String = ""
    ) throws {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)

        guard ExpenseCategory.allCases.contains(category) else {
            throw BudgetStoreError.invalidExpenseCategory
        }

        guard !trimmedTitle.isEmpty else {
            throw BudgetStoreError.invalidExpenseTitle
        }

        guard amount > 0 else {
            throw BudgetStoreError.invalidExpenseAmount
        }

        context.insert(Expense(
            title: trimmedTitle,
            category: category,
            amount: amount,
            date: date,
            note: trimmedNote
        ))
        try context.save()
    }

    func deleteExpense(_ expense: Expense) throws {
        context.delete(expense)
        try context.save()
    }

    func incomeItems() throws -> [IncomeItem] {
        try context.fetch(FetchDescriptor<IncomeItem>(sortBy: [SortDescriptor(\.createdAt)]))
    }

    func recurringExpenseItems() throws -> [RecurringExpenseItem] {
        try context.fetch(FetchDescriptor<RecurringExpenseItem>(sortBy: [SortDescriptor(\.createdAt)]))
    }

    func saveIncomeItem(id: UUID? = nil, name: String, amount: Double) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw BudgetStoreError.invalidIncomeName
        }

        guard amount > 0 else {
            throw BudgetStoreError.invalidIncomeAmount
        }

        if let id {
            let descriptor = FetchDescriptor<IncomeItem>(predicate: #Predicate { $0.id == id })
            if let item = try context.fetch(descriptor).first {
                item.name = trimmedName
                item.amount = amount
            } else {
                context.insert(IncomeItem(id: id, name: trimmedName, amount: amount))
            }
        } else {
            context.insert(IncomeItem(name: trimmedName, amount: amount))
        }

        try context.save()
    }

    func deleteIncomeItem(_ item: IncomeItem) throws {
        context.delete(item)
        try context.save()
    }

    func saveRecurringExpenseItem(id: UUID? = nil, name: String, amount: Double) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw BudgetStoreError.invalidRecurringExpenseName
        }

        guard amount > 0 else {
            throw BudgetStoreError.invalidRecurringExpenseAmount
        }

        if let id {
            let descriptor = FetchDescriptor<RecurringExpenseItem>(predicate: #Predicate { $0.id == id })
            if let item = try context.fetch(descriptor).first {
                item.name = trimmedName
                item.amount = amount
            } else {
                context.insert(RecurringExpenseItem(id: id, name: trimmedName, amount: amount))
            }
        } else {
            context.insert(RecurringExpenseItem(name: trimmedName, amount: amount))
        }

        try context.save()
    }

    func deleteRecurringExpenseItem(_ item: RecurringExpenseItem) throws {
        context.delete(item)
        try context.save()
    }

    static func currentMonthExpenses(
        from expenses: [Expense],
        calendar: Calendar = .current,
        referenceDate: Date = .now
    ) -> [Expense] {
        expenses.filter {
            calendar.isDate($0.date, equalTo: referenceDate, toGranularity: .month)
        }
    }

    static func totalSpent(for expenses: [Expense]) -> Double {
        expenses.reduce(0) { partialResult, expense in
            partialResult + expense.amount
        }
    }

    static func totalIncome(for incomeItems: [IncomeItem]) -> Double {
        incomeItems.reduce(0) { $0 + $1.amount }
    }

    static func totalRecurringExpenses(for recurringExpenseItems: [RecurringExpenseItem]) -> Double {
        recurringExpenseItems.reduce(0) { $0 + $1.amount }
    }

    static func availableMonthlyBudget(
        incomeItems: [IncomeItem],
        recurringExpenseItems: [RecurringExpenseItem]
    ) -> Double {
        totalIncome(for: incomeItems) - totalRecurringExpenses(for: recurringExpenseItems)
    }

    static func categorySpending(
        for expenses: [Expense],
        calendar: Calendar = .current,
        referenceDate: Date = .now
    ) -> [CategorySpendingSummary] {
        let currentMonthExpenses = currentMonthExpenses(
            from: expenses,
            calendar: calendar,
            referenceDate: referenceDate
        )

        return ExpenseCategory.allCases.compactMap { category in
            let total = currentMonthExpenses
                .filter { $0.category == category }
                .reduce(0) { $0 + $1.amount }

            guard total > 0 else {
                return nil
            }

            return CategorySpendingSummary(category: category, total: total)
        }
        .sorted { lhs, rhs in
            if lhs.total == rhs.total {
                return lhs.category.title < rhs.category.title
            }

            return lhs.total > rhs.total
        }
    }

    static func topSpendingCategory(
        for expenses: [Expense],
        calendar: Calendar = .current,
        referenceDate: Date = .now
    ) -> CategorySpendingSummary? {
        categorySpending(
            for: expenses,
            calendar: calendar,
            referenceDate: referenceDate
        ).first
    }

    static func remainingBudget(
        monthlyBudget: Double,
        expenses: [Expense],
        calendar: Calendar = .current,
        referenceDate: Date = .now
    ) -> Double {
        monthlyBudget - totalSpent(
            for: currentMonthExpenses(
                from: expenses,
                calendar: calendar,
                referenceDate: referenceDate
            )
        )
    }

    func currentMonthExpenses(from expenses: [Expense], referenceDate: Date = .now) -> [Expense] {
        Self.currentMonthExpenses(from: expenses, calendar: calendar, referenceDate: referenceDate)
    }
}

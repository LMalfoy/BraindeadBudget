import Foundation
import SwiftData

struct CategorySpendingSummary: Identifiable, Equatable {
    let category: ExpenseCategory
    let total: Double

    var id: ExpenseCategory { category }
}

struct MonthlyHistoryDigest: Equatable {
    let totalSpent: Double
    let carryover: Double
    let categorySpending: [CategorySpendingSummary]
}

struct BudgetTrajectoryPoint: Identifiable, Equatable {
    let date: Date
    let remainingBudget: Double

    var id: Date { date }
}

struct TemporalSpendingSummary: Identifiable, Equatable {
    enum Segment: String, CaseIterable, Identifiable {
        case early
        case mid
        case late

        var id: String { rawValue }

        var title: String {
            switch self {
            case .early:
                return "Early"
            case .mid:
                return "Mid"
            case .late:
                return "Late"
            }
        }
    }

    let segment: Segment
    let total: Double

    var id: Segment { segment }
}

struct TemporalSpendingBucket: Identifiable, Equatable {
    let index: Int
    let title: String
    let total: Double

    var id: Int { index }
}

struct MonthComparisonSummary: Equatable {
    let currentMonthTotal: Double
    let previousMonthTotal: Double

    var difference: Double {
        currentMonthTotal - previousMonthTotal
    }
}

struct CarryoverHistoryPoint: Identifiable, Equatable {
    let month: Date
    let amount: Double

    var id: Date { month }
}

struct MonthlySpendingPoint: Identifiable, Equatable {
    let month: Date
    let total: Double

    var id: Date { month }
}

struct FixedCostCategorySummary: Identifiable, Equatable {
    let category: RecurringExpenseCategory
    let total: Double

    var id: RecurringExpenseCategory { category }
}

struct FixedCostRatioSummary: Equatable {
    let monthlyIncome: Double
    let recurringTotal: Double

    var recurringShare: Double {
        guard monthlyIncome > 0 else { return 0 }
        return recurringTotal / monthlyIncome
    }
}

struct SubscriptionLoadSummary: Equatable {
    let count: Int
    let totalMonthlyCost: Double
}

struct SavingsStabilitySummary: Equatable {
    let monthlyIncome: Double
    let savingsAmount: Double

    var savingsShare: Double {
        guard monthlyIncome > 0 else { return 0 }
        return savingsAmount / monthlyIncome
    }
}

enum BudgetSignalStrength: Equatable {
    case strong
    case neutral
    case weak
}

enum BudgetReasonTone: Equatable {
    case positive
    case neutral
    case warning
}

struct BudgetDisciplineReason: Identifiable, Equatable {
    let message: String
    let tone: BudgetReasonTone

    var id: String { message }
}

enum BudgetDisciplineRank: Int, CaseIterable, Equatable {
    case pawn
    case knight
    case bishop
    case rook
    case queen
    case king

    var title: String {
        switch self {
        case .pawn:
            return "Pawn"
        case .knight:
            return "Knight"
        case .bishop:
            return "Bishop"
        case .rook:
            return "Rook"
        case .queen:
            return "Queen"
        case .king:
            return "King"
        }
    }

    var summary: String {
        switch self {
        case .pawn:
            return "Your budget needs tighter control this month."
        case .knight:
            return "Your budgeting pattern is still settling."
        case .bishop:
            return "Your budgeting behavior is fairly balanced."
        case .rook:
            return "Your budgeting behavior is stable this month."
        case .queen:
            return "Your budgeting discipline is strong this month."
        case .king:
            return "Your budgeting discipline is exceptional right now."
        }
    }

    func advanced(by step: Int) -> BudgetDisciplineRank {
        let nextValue = min(max(rawValue + step, Self.pawn.rawValue), Self.king.rawValue)
        return Self(rawValue: nextValue) ?? self
    }
}

struct BudgetDisciplineEvaluation: Equatable {
    let rank: BudgetDisciplineRank
    let summary: String
    let reasons: [BudgetDisciplineReason]
    let isSparseData: Bool
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

    func updateExpense(
        _ expense: Expense,
        title: String,
        category: ExpenseCategory,
        amount: Double,
        date: Date,
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

        expense.title = trimmedTitle
        expense.category = category
        expense.amount = amount
        expense.date = date
        expense.note = trimmedNote

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

    func saveRecurringExpenseItem(
        id: UUID? = nil,
        name: String,
        amount: Double,
        category: RecurringExpenseCategory = .housingUtilities
    ) throws {
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
                item.category = category
            } else {
                context.insert(RecurringExpenseItem(id: id, name: trimmedName, amount: amount, category: category))
            }
        } else {
            context.insert(RecurringExpenseItem(name: trimmedName, amount: amount, category: category))
        }

        try context.save()
    }

    func deleteRecurringExpenseItem(_ item: RecurringExpenseItem) throws {
        context.delete(item)
        try context.save()
    }

    static func expenses(
        from expenses: [Expense],
        inMonthContaining referenceDate: Date,
        calendar: Calendar = .current
    ) -> [Expense] {
        expenses.filter {
            calendar.isDate($0.date, equalTo: referenceDate, toGranularity: .month)
        }
    }

    static func currentMonthExpenses(
        from expenses: [Expense],
        calendar: Calendar = .current,
        referenceDate: Date = .now
    ) -> [Expense] {
        self.expenses(from: expenses, inMonthContaining: referenceDate, calendar: calendar)
    }

    static func previousMonthExpenses(
        from expenses: [Expense],
        calendar: Calendar = .current,
        referenceDate: Date = .now
    ) -> [Expense] {
        guard let previousMonthReferenceDate = calendar.date(byAdding: .month, value: -1, to: referenceDate) else {
            return []
        }

        return currentMonthExpenses(
            from: expenses,
            calendar: calendar,
            referenceDate: previousMonthReferenceDate
        )
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

    static func fixedCostRatio(
        incomeItems: [IncomeItem],
        recurringExpenseItems: [RecurringExpenseItem]
    ) -> FixedCostRatioSummary {
        FixedCostRatioSummary(
            monthlyIncome: totalIncome(for: incomeItems),
            recurringTotal: totalRecurringExpenses(for: recurringExpenseItems)
        )
    }

    static func fixedCostDistribution(
        for recurringExpenseItems: [RecurringExpenseItem]
    ) -> [FixedCostCategorySummary] {
        RecurringExpenseCategory.allCases.compactMap { category in
            let total = recurringExpenseItems
                .filter { $0.category == category }
                .reduce(0) { $0 + $1.amount }

            guard total > 0 else { return nil }

            return FixedCostCategorySummary(category: category, total: total)
        }
        .sorted { lhs, rhs in
            if lhs.total == rhs.total {
                return lhs.category.title < rhs.category.title
            }

            return lhs.total > rhs.total
        }
    }

    static func subscriptionLoad(
        for recurringExpenseItems: [RecurringExpenseItem]
    ) -> SubscriptionLoadSummary {
        let subscriptionItems = recurringExpenseItems.filter { $0.category == .subscriptions }
        return SubscriptionLoadSummary(
            count: subscriptionItems.count,
            totalMonthlyCost: subscriptionItems.reduce(0) { $0 + $1.amount }
        )
    }

    static func savingsStability(
        incomeItems: [IncomeItem],
        recurringExpenseItems: [RecurringExpenseItem]
    ) -> SavingsStabilitySummary {
        let savingsAmount = recurringExpenseItems
            .filter { $0.category == .savings }
            .reduce(0) { $0 + $1.amount }

        return SavingsStabilitySummary(
            monthlyIncome: totalIncome(for: incomeItems),
            savingsAmount: savingsAmount
        )
    }

    static func availableMonthlyBudget(
        incomeItems: [IncomeItem],
        recurringExpenseItems: [RecurringExpenseItem]
    ) -> Double {
        totalIncome(for: incomeItems) - totalRecurringExpenses(for: recurringExpenseItems)
    }

    static func previousMonthCarryover(
        monthlyBudget: Double,
        expenses: [Expense],
        calendar: Calendar = .current,
        referenceDate: Date = .now
    ) -> Double {
        let previousMonthExpenses = previousMonthExpenses(
            from: expenses,
            calendar: calendar,
            referenceDate: referenceDate
        )

        guard !previousMonthExpenses.isEmpty else {
            return 0
        }

        return monthlyBudget - totalSpent(
            for: previousMonthExpenses
        )
    }

    static func adjustedMonthlyBudget(
        monthlyBudget: Double,
        expenses: [Expense],
        calendar: Calendar = .current,
        referenceDate: Date = .now
    ) -> Double {
        monthlyBudget + previousMonthCarryover(
            monthlyBudget: monthlyBudget,
            expenses: expenses,
            calendar: calendar,
            referenceDate: referenceDate
        )
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
        adjustedMonthlyBudget(
            monthlyBudget: monthlyBudget,
            expenses: expenses,
            calendar: calendar,
            referenceDate: referenceDate
        ) - totalSpent(
            for: currentMonthExpenses(
                from: expenses,
                calendar: calendar,
                referenceDate: referenceDate
            )
        )
    }

    static func monthlyHistoryDigest(
        monthlyBudget: Double,
        expenses: [Expense],
        calendar: Calendar = .current,
        referenceDate: Date = .now
    ) -> MonthlyHistoryDigest {
        let selectedMonthExpenses = currentMonthExpenses(
            from: expenses,
            calendar: calendar,
            referenceDate: referenceDate
        )

        return MonthlyHistoryDigest(
            totalSpent: totalSpent(for: selectedMonthExpenses),
            carryover: previousMonthCarryover(
                monthlyBudget: monthlyBudget,
                expenses: expenses,
                calendar: calendar,
                referenceDate: referenceDate
            ),
            categorySpending: categorySpending(
                for: expenses,
                calendar: calendar,
                referenceDate: referenceDate
            )
        )
    }

    static func budgetTrajectory(
        monthlyBudget: Double,
        expenses: [Expense],
        calendar: Calendar = .current,
        referenceDate: Date = .now
    ) -> [BudgetTrajectoryPoint] {
        let currentMonthExpenses = currentMonthExpenses(
            from: expenses,
            calendar: calendar,
            referenceDate: referenceDate
        )
        .sorted { $0.date < $1.date }

        let startingBudget = adjustedMonthlyBudget(
            monthlyBudget: monthlyBudget,
            expenses: expenses,
            calendar: calendar,
            referenceDate: referenceDate
        )

        guard !currentMonthExpenses.isEmpty else {
            return []
        }

        var runningSpent = 0.0

        return currentMonthExpenses.map { expense in
            runningSpent += expense.amount
            return BudgetTrajectoryPoint(
                date: expense.date,
                remainingBudget: startingBudget - runningSpent
            )
        }
    }

    static func temporalSpending(
        for expenses: [Expense],
        calendar: Calendar = .current,
        referenceDate: Date = .now
    ) -> [TemporalSpendingSummary] {
        let currentMonthExpenses = currentMonthExpenses(
            from: expenses,
            calendar: calendar,
            referenceDate: referenceDate
        )

        let totals = Dictionary(grouping: currentMonthExpenses) { expense in
            temporalSegment(for: expense.date, calendar: calendar)
        }
        .mapValues { expenses in
            expenses.reduce(0) { $0 + $1.amount }
        }

        return TemporalSpendingSummary.Segment.allCases.compactMap { segment in
            guard let total = totals[segment], total > 0 else {
                return nil
            }

            return TemporalSpendingSummary(segment: segment, total: total)
        }
    }

    static func temporalSpendingBuckets(
        for expenses: [Expense],
        bucketCount: Int = 10,
        calendar: Calendar = .current,
        referenceDate: Date = .now
    ) -> [TemporalSpendingBucket] {
        guard bucketCount > 0 else {
            return []
        }

        let currentMonthExpenses = currentMonthExpenses(
            from: expenses,
            calendar: calendar,
            referenceDate: referenceDate
        )
        guard let daysInMonth = calendar.range(of: .day, in: .month, for: referenceDate)?.count else {
            return []
        }

        let totals = Dictionary(grouping: currentMonthExpenses) { expense in
            temporalBucketIndex(
                for: expense.date,
                bucketCount: bucketCount,
                calendar: calendar,
                daysInMonth: daysInMonth
            )
        }
        .mapValues { groupedExpenses in
            groupedExpenses.reduce(0) { $0 + $1.amount }
        }

        return (0..<bucketCount).compactMap { index in
            guard let total = totals[index], total > 0 else {
                return nil
            }

            return TemporalSpendingBucket(
                index: index,
                title: temporalBucketTitle(
                    index: index,
                    bucketCount: bucketCount,
                    daysInMonth: daysInMonth
                ),
                total: total
            )
        }
    }

    static func temporalSegment(
        for date: Date,
        calendar: Calendar = .current
    ) -> TemporalSpendingSummary.Segment {
        let day = calendar.component(.day, from: date)

        switch day {
        case 1...10:
            return .early
        case 11...20:
            return .mid
        default:
            return .late
        }
    }

    static func temporalBucketIndex(
        for date: Date,
        bucketCount: Int,
        calendar: Calendar = .current,
        daysInMonth: Int? = nil
    ) -> Int {
        let resolvedDaysInMonth = daysInMonth ?? calendar.range(of: .day, in: .month, for: date)?.count ?? 30
        let day = max(calendar.component(.day, from: date) - 1, 0)
        let fraction = Double(day) / Double(max(resolvedDaysInMonth, 1))
        return min(Int(fraction * Double(bucketCount)), bucketCount - 1)
    }

    static func temporalBucketTitle(
        index: Int,
        bucketCount: Int,
        daysInMonth: Int
    ) -> String {
        let startDay = Int((Double(index) / Double(bucketCount)) * Double(daysInMonth)) + 1
        let endDay = Int((Double(index + 1) / Double(bucketCount)) * Double(daysInMonth))
        return "\(startDay)-\(max(startDay, endDay))"
    }

    static func monthComparison(
        for expenses: [Expense],
        calendar: Calendar = .current,
        referenceDate: Date = .now
    ) -> MonthComparisonSummary {
        let currentTotal = totalSpent(
            for: currentMonthExpenses(
                from: expenses,
                calendar: calendar,
                referenceDate: referenceDate
            )
        )
        let previousTotal = totalSpent(
            for: previousMonthExpenses(
                from: expenses,
                calendar: calendar,
                referenceDate: referenceDate
            )
        )

        return MonthComparisonSummary(
            currentMonthTotal: currentTotal,
            previousMonthTotal: previousTotal
        )
    }

    static func monthComparisonHistory(
        for expenses: [Expense],
        months: Int = 6,
        calendar: Calendar = .current,
        referenceDate: Date = .now
    ) -> [MonthlySpendingPoint] {
        guard months > 0 else {
            return []
        }

        let referenceMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: referenceDate)) ?? referenceDate

        return (0..<months).compactMap { offset in
            guard let month = calendar.date(byAdding: .month, value: offset - (months - 1), to: referenceMonth) else {
                return nil
            }

            return MonthlySpendingPoint(
                month: month,
                total: totalSpent(
                    for: currentMonthExpenses(
                        from: expenses,
                        calendar: calendar,
                        referenceDate: month
                    )
                )
            )
        }
    }

    static func carryoverHistory(
        monthlyBudget: Double,
        expenses: [Expense],
        months: Int = 6,
        calendar: Calendar = .current,
        referenceDate: Date = .now
    ) -> [CarryoverHistoryPoint] {
        guard months > 0 else {
            return []
        }

        let referenceMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: referenceDate)) ?? referenceDate

        return (0..<months).compactMap { offset in
            guard let month = calendar.date(byAdding: .month, value: offset - (months - 1), to: referenceMonth) else {
                return nil
            }

            return CarryoverHistoryPoint(
                month: month,
                amount: previousMonthCarryover(
                    monthlyBudget: monthlyBudget,
                    expenses: expenses,
                    calendar: calendar,
                    referenceDate: month
                )
            )
        }
    }

    static func evaluateBudgetDiscipline(
        monthlyBudget: Double,
        expenses: [Expense],
        calendar: Calendar = .current,
        referenceDate: Date = .now
    ) -> BudgetDisciplineEvaluation {
        let currentMonthExpenses = currentMonthExpenses(
            from: expenses,
            calendar: calendar,
            referenceDate: referenceDate
        )
        let comparison = monthComparison(
            for: expenses,
            calendar: calendar,
            referenceDate: referenceDate
        )
        let categorySpending = categorySpending(
            for: expenses,
            calendar: calendar,
            referenceDate: referenceDate
        )
        let temporalSpendingBuckets = temporalSpendingBuckets(
            for: expenses,
            calendar: calendar,
            referenceDate: referenceDate
        )
        let trajectory = budgetTrajectory(
            monthlyBudget: monthlyBudget,
            expenses: expenses,
            calendar: calendar,
            referenceDate: referenceDate
        )
        let carryover = previousMonthCarryover(
            monthlyBudget: monthlyBudget,
            expenses: expenses,
            calendar: calendar,
            referenceDate: referenceDate
        )
        let adjustedBudget = adjustedMonthlyBudget(
            monthlyBudget: monthlyBudget,
            expenses: expenses,
            calendar: calendar,
            referenceDate: referenceDate
        )
        let remaining = remainingBudget(
            monthlyBudget: monthlyBudget,
            expenses: expenses,
            calendar: calendar,
            referenceDate: referenceDate
        )

        if currentMonthExpenses.count < 3 {
            var reasons = [
                BudgetDisciplineReason(
                    message: "Not enough current-month data is available for a stable rank yet.",
                    tone: .neutral
                )
            ]

            if carryover > 0 {
                reasons.append(BudgetDisciplineReason(
                    message: "Carryover remains healthy.",
                    tone: .positive
                ))
            } else if carryover < 0 {
                reasons.append(BudgetDisciplineReason(
                    message: "Carryover is reducing this month's room.",
                    tone: .warning
                ))
            }

            return BudgetDisciplineEvaluation(
                rank: .knight,
                summary: "Still learning your spending pattern.",
                reasons: reasons,
                isSparseData: true
            )
        }

        let trajectoryStrength = disciplineTrajectoryStrength(
            monthlyBudget: adjustedBudget,
            currentMonthExpenses: currentMonthExpenses,
            trajectory: trajectory,
            calendar: calendar,
            referenceDate: referenceDate
        )
        let categoryStrength = disciplineCategoryStrength(
            currentMonthExpenses: currentMonthExpenses,
            categorySpending: categorySpending
        )
        let temporalStrength = disciplineTemporalStrength(
            currentMonthExpenses: currentMonthExpenses,
            temporalSpendingBuckets: temporalSpendingBuckets
        )
        let comparisonStrength = disciplineComparisonStrength(comparison)
        let carryoverStrength = disciplineCarryoverStrength(
            carryover: carryover,
            monthlyBudget: monthlyBudget
        )
        let leftoverStrength = disciplineLeftoverStrength(
            adjustedBudget: adjustedBudget,
            remaining: remaining
        )

        let baseRank = resolveBaseRank(
            strengths: [
                trajectoryStrength,
                categoryStrength,
                temporalStrength,
                comparisonStrength
            ]
        )
        let finalRank = resolveModifiedRank(
            baseRank: baseRank,
            carryoverStrength: carryoverStrength,
            leftoverStrength: leftoverStrength
        )

        let reasons = [
            disciplineReason(
                for: trajectoryStrength,
                strong: "Spending pace is close to plan.",
                neutral: "Spending pace is not far from plan.",
                weak: "Spending pace is running ahead of plan."
            ),
            disciplineReason(
                for: categoryStrength,
                strong: "Category distribution is balanced.",
                neutral: "One category is starting to dominate.",
                weak: "One category dominates spending heavily."
            ),
            disciplineReason(
                for: temporalStrength,
                strong: "Spending pattern is stable across the month.",
                neutral: "Spending is somewhat clustered.",
                weak: "Spending is heavily concentrated in one part of the month."
            ),
            disciplineReason(
                for: comparisonStrength,
                strong: "Spending is lower than last month.",
                neutral: "Spending is close to last month.",
                weak: "Spending is higher than last month."
            ),
            disciplineReason(
                for: carryoverStrength,
                strong: "Carryover remains healthy.",
                neutral: "Carryover is neutral.",
                weak: "Carryover is reducing this month's room."
            ),
            disciplineReason(
                for: leftoverStrength,
                strong: "You still have meaningful budget room left.",
                neutral: "You still have some room left this month.",
                weak: "You have exhausted this month's budget."
            )
        ]

        return BudgetDisciplineEvaluation(
            rank: finalRank,
            summary: finalRank.summary,
            reasons: reasons,
            isSparseData: false
        )
    }

    private static func disciplineTrajectoryStrength(
        monthlyBudget: Double,
        currentMonthExpenses: [Expense],
        trajectory: [BudgetTrajectoryPoint],
        calendar: Calendar,
        referenceDate: Date
    ) -> BudgetSignalStrength {
        guard monthlyBudget > 0, !currentMonthExpenses.isEmpty, !trajectory.isEmpty else {
            return .neutral
        }

        let day = calendar.component(.day, from: referenceDate)
        let daysInMonth = calendar.range(of: .day, in: .month, for: referenceDate)?.count ?? 30
        let monthProgress = Double(day) / Double(max(daysInMonth, 1))
        let spentRatio = totalSpent(for: currentMonthExpenses) / max(monthlyBudget, 1)
        let pacingGap = spentRatio - monthProgress

        if pacingGap <= 0.05 {
            return .strong
        }

        if pacingGap <= 0.18 {
            return .neutral
        }

        return .weak
    }

    private static func disciplineCategoryStrength(
        currentMonthExpenses: [Expense],
        categorySpending: [CategorySpendingSummary]
    ) -> BudgetSignalStrength {
        let total = totalSpent(for: currentMonthExpenses)
        guard total > 0, let topCategory = categorySpending.first else {
            return .neutral
        }

        let dominance = topCategory.total / total

        if dominance <= 0.45 {
            return .strong
        }

        if dominance <= 0.65 {
            return .neutral
        }

        return .weak
    }

    private static func disciplineTemporalStrength(
        currentMonthExpenses: [Expense],
        temporalSpendingBuckets: [TemporalSpendingBucket]
    ) -> BudgetSignalStrength {
        let total = totalSpent(for: currentMonthExpenses)
        guard total > 0,
              temporalSpendingBuckets.count >= 2,
              let strongestBucket = temporalSpendingBuckets.max(by: { $0.total < $1.total }) else {
            return .neutral
        }

        let concentration = strongestBucket.total / total

        if concentration <= 0.22 {
            return .strong
        }

        if concentration <= 0.35 {
            return .neutral
        }

        return .weak
    }

    private static func disciplineComparisonStrength(_ comparison: MonthComparisonSummary) -> BudgetSignalStrength {
        guard comparison.previousMonthTotal > 0 else {
            return .neutral
        }

        let relativeChange = comparison.difference / max(comparison.previousMonthTotal, 1)

        if relativeChange <= -0.1 {
            return .strong
        }

        if relativeChange < 0.1 {
            return .neutral
        }

        return .weak
    }

    private static func disciplineCarryoverStrength(
        carryover: Double,
        monthlyBudget: Double
    ) -> BudgetSignalStrength {
        let threshold = max(abs(monthlyBudget) * 0.05, 1)

        if carryover > threshold {
            return .strong
        }

        if carryover < -threshold {
            return .weak
        }

        return .neutral
    }

    private static func disciplineLeftoverStrength(
        adjustedBudget: Double,
        remaining: Double
    ) -> BudgetSignalStrength {
        guard adjustedBudget > 0 else {
            return remaining >= 0 ? .neutral : .weak
        }

        let leftoverRatio = remaining / adjustedBudget

        if leftoverRatio >= 0.2 {
            return .strong
        }

        if leftoverRatio >= 0 {
            return .neutral
        }

        return .weak
    }

    private static func resolveBaseRank(strengths: [BudgetSignalStrength]) -> BudgetDisciplineRank {
        let strongCount = strengths.filter { $0 == .strong }.count
        let weakCount = strengths.filter { $0 == .weak }.count

        if weakCount >= 2 {
            return .pawn
        }

        if strongCount == 4 {
            return .queen
        }

        if strongCount == 3 && weakCount == 0 {
            return .rook
        }

        if strongCount >= 1 && weakCount == 0 {
            return .bishop
        }

        return .knight
    }

    private static func resolveModifiedRank(
        baseRank: BudgetDisciplineRank,
        carryoverStrength: BudgetSignalStrength,
        leftoverStrength: BudgetSignalStrength
    ) -> BudgetDisciplineRank {
        let positiveModifiers = [carryoverStrength, leftoverStrength].filter { $0 == .strong }.count
        let negativeModifiers = [carryoverStrength, leftoverStrength].filter { $0 == .weak }.count

        if positiveModifiers >= 2 && baseRank == .queen {
            return .king
        }

        if positiveModifiers >= 1 && negativeModifiers == 0 {
            return baseRank.advanced(by: 1)
        }

        if negativeModifiers >= 1 && positiveModifiers == 0 {
            return baseRank.advanced(by: -1)
        }

        return baseRank
    }

    private static func disciplineReason(
        for strength: BudgetSignalStrength,
        strong: String,
        neutral: String,
        weak: String
    ) -> BudgetDisciplineReason {
        switch strength {
        case .strong:
            return BudgetDisciplineReason(message: strong, tone: .positive)
        case .neutral:
            return BudgetDisciplineReason(message: neutral, tone: .neutral)
        case .weak:
            return BudgetDisciplineReason(message: weak, tone: .warning)
        }
    }

    func currentMonthExpenses(from expenses: [Expense], referenceDate: Date = .now) -> [Expense] {
        Self.currentMonthExpenses(from: expenses, calendar: calendar, referenceDate: referenceDate)
    }

    func expenses(from expenses: [Expense], inMonthContaining referenceDate: Date) -> [Expense] {
        Self.expenses(from: expenses, inMonthContaining: referenceDate, calendar: calendar)
    }
}

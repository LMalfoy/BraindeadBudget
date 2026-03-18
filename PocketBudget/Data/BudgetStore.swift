/*
 Core budget logic and persistence helper.

 This is the most important non-UI file in the project.

 It has two jobs:
 1. write, update, and delete SwiftData records
 2. calculate all derived budgeting and statistics values

 Examples of calculations handled here:
 - available monthly budget
 - carryover between budget periods
 - remaining budget
 - category summaries
 - statistics series for charts
 - savings-based chess progression

 If you want to understand how the app "thinks", this is the primary file.
 */

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

struct DashboardSnapshot: Equatable {
    let monthlyBudget: Double
    let previousMonthCarryover: Double
    let remainingBudget: Double
    let totalSpent: Double
    let dailySafeSpend: Double
    let daysRemainingInCurrentPeriod: Int
    let safeSpendStreak: Int
    let categorySpending: [CategorySpendingSummary]
    let topCategory: CategorySpendingSummary?
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

struct SubscriptionItemSummary: Identifiable, Equatable {
    let id: UUID
    let name: String
    let amount: Double
}

struct SavingsStabilitySummary: Equatable {
    let monthlyIncome: Double
    let savingsAmount: Double

    var savingsShare: Double {
        guard monthlyIncome > 0 else { return 0 }
        return savingsAmount / monthlyIncome
    }
}

struct SavingsStabilityPoint: Identifiable, Equatable {
    let month: Date
    let savingsAmount: Double

    var id: Date { month }
}

enum ChessProgressionPiece: Int, CaseIterable, Equatable {
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

    var assetName: String {
        switch self {
        case .pawn:
            return "ChessPawn"
        case .knight:
            return "ChessKnight"
        case .bishop:
            return "ChessBishop"
        case .rook:
            return "ChessRook"
        case .queen:
            return "ChessQueen"
        case .king:
            return "ChessKing"
        }
    }
}

struct ChessProgressionLevel: Equatable {
    let piece: ChessProgressionPiece
    let sublevel: Int?
    let title: String
    let quote: String
    let author: String
    let thresholdXP: Int

    var displayTitle: String {
        guard let sublevel else {
            return piece.title
        }

        return "\(piece.title) \(romanNumeral(for: sublevel))"
    }

    private func romanNumeral(for value: Int) -> String {
        switch value {
        case 1: return "I"
        case 2: return "II"
        case 3: return "III"
        case 4: return "IV"
        case 5: return "V"
        default: return "\(value)"
        }
    }
}

struct SavingsProgressMonth: Identifiable, Equatable {
    let month: Date
    let savedPercentage: Double
    let earnedXP: Int

    var id: Date { month }
}

struct BudgetProgressionEvaluation: Equatable {
    let level: ChessProgressionLevel
    let totalXP: Int
    let progressXP: Int
    let xpToNextLevel: Int?
    let xpRequiredForNextLevel: Int?
    let completedTrackedMonths: Int
    let summary: String
    let periodNote: String
}

enum BudgetAchievementID: String, CaseIterable, Codable, Identifiable {
    case architectOfOrder
    case firstStep
    case habitBuilder
    case steadyHand
    case surgicalPrecision
    case roomToBreathe
    case financialCushion
    case spartanMode
    case courseCorrection
    case checkmate

    var id: String { rawValue }
}

struct BudgetAchievementDefinition: Identifiable, Equatable {
    let id: BudgetAchievementID
    let title: String
    let description: String
    let unlockCondition: String
    let symbolName: String
}

struct BudgetAchievementStatus: Identifiable, Equatable {
    let definition: BudgetAchievementDefinition
    let unlockedAt: Date?

    var id: BudgetAchievementID { definition.id }
    var isUnlocked: Bool { unlockedAt != nil }
}

struct AchievementUnlockBanner: Equatable {
    let title: String
}

private struct CompletedBudgetPeriodSummary: Equatable {
    let startDate: Date
    let adjustedBudget: Double
    let totalSpent: Double
    let remainingBudget: Double
    let expenseCount: Int

    var remainingShare: Double {
        guard adjustedBudget > 0 else { return 0 }
        return remainingBudget / adjustedBudget
    }
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
        try saveSettings(
            currencyCode: currencyCode,
            budgetPeriodAnchorDay: nil,
            initialAvailableBudget: nil,
            initialBudgetAnchorMonth: nil
        )
    }

    func saveSettings(
        currencyCode: String,
        budgetPeriodAnchorDay: Int?,
        initialAvailableBudget: Double?,
        initialBudgetAnchorMonth: Date?
    ) throws {
        let budgets = try context.fetch(FetchDescriptor<BudgetSettings>())

        if let settings = budgets.first {
            settings.currencyCode = currencyCode
            if let budgetPeriodAnchorDay {
                settings.budgetPeriodAnchorDay = max(1, min(30, budgetPeriodAnchorDay))
            }
            if let initialAvailableBudget {
                settings.initialAvailableBudget = initialAvailableBudget
            }
            if let initialBudgetAnchorMonth {
                settings.initialBudgetAnchorMonth = initialBudgetAnchorMonth
            }
            settings.updatedAt = .now

            for duplicate in budgets.dropFirst() {
                context.delete(duplicate)
            }
        } else {
            context.insert(BudgetSettings(
                currencyCode: currencyCode,
                budgetPeriodAnchorDay: min(max(budgetPeriodAnchorDay ?? 1, 1), 30),
                initialAvailableBudget: initialAvailableBudget,
                initialBudgetAnchorMonth: initialBudgetAnchorMonth
            ))
        }

        try context.save()
    }

    func saveBudgetPeriodAnchorDay(_ day: Int) throws {
        let budgets = try context.fetch(FetchDescriptor<BudgetSettings>())
        let normalizedDay = max(1, min(30, day))

        if let settings = budgets.first {
            settings.budgetPeriodAnchorDay = normalizedDay
            settings.updatedAt = .now

            for duplicate in budgets.dropFirst() {
                context.delete(duplicate)
            }
        } else {
            context.insert(BudgetSettings(budgetPeriodAnchorDay: normalizedDay))
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

    func eraseAllData() throws {
        try context.fetch(FetchDescriptor<Expense>()).forEach { context.delete($0) }
        try context.fetch(FetchDescriptor<IncomeItem>()).forEach { context.delete($0) }
        try context.fetch(FetchDescriptor<RecurringExpenseItem>()).forEach { context.delete($0) }
        try context.fetch(FetchDescriptor<BudgetSettings>()).forEach { context.delete($0) }
        try context.fetch(FetchDescriptor<AchievementUnlock>()).forEach { context.delete($0) }
        try context.save()
    }

    @discardableResult
    func syncAchievements(
        hasCompletedSetup: Bool,
        incomeItems: [IncomeItem],
        recurringExpenseItems: [RecurringExpenseItem],
        expenses: [Expense],
        budgetPeriodAnchorDay: Int = 1,
        initialAvailableBudget: Double? = nil,
        initialBudgetAnchorMonth: Date? = nil,
        referenceDate: Date = .now
    ) throws -> [AchievementUnlock] {
        let unlockedIDs = Self.evaluateAchievementIDs(
            hasCompletedSetup: hasCompletedSetup,
            incomeItems: incomeItems,
            recurringExpenseItems: recurringExpenseItems,
            expenses: expenses,
            budgetPeriodAnchorDay: budgetPeriodAnchorDay,
            initialAvailableBudget: initialAvailableBudget,
            initialBudgetAnchorMonth: initialBudgetAnchorMonth,
            calendar: calendar,
            referenceDate: referenceDate
        )
        let existingUnlocks = try context.fetch(FetchDescriptor<AchievementUnlock>())
        let existingIDs = Set(existingUnlocks.map(\.achievementID))
        var newUnlocks: [AchievementUnlock] = []

        for achievementID in unlockedIDs where !existingIDs.contains(achievementID.rawValue) {
            let unlock = AchievementUnlock(achievementID: achievementID.rawValue)
            context.insert(unlock)
            newUnlocks.append(unlock)
        }

        if !newUnlocks.isEmpty {
            try context.save()
        }

        return newUnlocks
    }

    static func expenses(
        from expenses: [Expense],
        inMonthContaining referenceDate: Date,
        budgetPeriodAnchorDay: Int = 1,
        calendar: Calendar = .current
    ) -> [Expense] {
        let periodStart = periodStart(containing: referenceDate, budgetPeriodAnchorDay: budgetPeriodAnchorDay, calendar: calendar)
        let nextPeriodStart = nextPeriodStart(after: periodStart, budgetPeriodAnchorDay: budgetPeriodAnchorDay, calendar: calendar)

        return expenses.filter {
            $0.date >= periodStart && $0.date < nextPeriodStart
        }
    }

    static func currentMonthExpenses(
        from expenses: [Expense],
        budgetPeriodAnchorDay: Int = 1,
        calendar: Calendar = .current,
        referenceDate: Date = .now
    ) -> [Expense] {
        self.expenses(
            from: expenses,
            inMonthContaining: referenceDate,
            budgetPeriodAnchorDay: budgetPeriodAnchorDay,
            calendar: calendar
        )
    }

    static func previousMonthExpenses(
        from expenses: [Expense],
        budgetPeriodAnchorDay: Int = 1,
        calendar: Calendar = .current,
        referenceDate: Date = .now
    ) -> [Expense] {
        let currentPeriodStart = periodStart(containing: referenceDate, budgetPeriodAnchorDay: budgetPeriodAnchorDay, calendar: calendar)
        guard let previousPeriodReferenceDate = calendar.date(byAdding: .day, value: -1, to: currentPeriodStart) else {
            return []
        }

        return currentMonthExpenses(
            from: expenses,
            budgetPeriodAnchorDay: budgetPeriodAnchorDay,
            calendar: calendar,
            referenceDate: previousPeriodReferenceDate
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

    static func dashboardSnapshot(
        incomeItems: [IncomeItem],
        recurringExpenseItems: [RecurringExpenseItem],
        expenses: [Expense],
        budgetPeriodAnchorDay: Int = 1,
        initialAvailableBudget: Double? = nil,
        initialBudgetAnchorMonth: Date? = nil,
        calendar: Calendar = .current,
        referenceDate: Date = .now
    ) -> DashboardSnapshot {
        let monthlyBudget = availableMonthlyBudget(
            incomeItems: incomeItems,
            recurringExpenseItems: recurringExpenseItems
        )
        let currentPeriodExpenses = currentMonthExpenses(
            from: expenses,
            budgetPeriodAnchorDay: budgetPeriodAnchorDay,
            calendar: calendar,
            referenceDate: referenceDate
        )
        let totalSpent = totalSpent(for: currentPeriodExpenses)
        let previousMonthCarryover = previousMonthCarryover(
            monthlyBudget: monthlyBudget,
            expenses: expenses,
            budgetPeriodAnchorDay: budgetPeriodAnchorDay,
            initialAvailableBudget: initialAvailableBudget,
            initialBudgetAnchorMonth: initialBudgetAnchorMonth,
            calendar: calendar,
            referenceDate: referenceDate
        )
        let remainingBudget = remainingBudget(
            monthlyBudget: monthlyBudget,
            expenses: expenses,
            budgetPeriodAnchorDay: budgetPeriodAnchorDay,
            initialAvailableBudget: initialAvailableBudget,
            initialBudgetAnchorMonth: initialBudgetAnchorMonth,
            calendar: calendar,
            referenceDate: referenceDate
        )
        let categorySpending = categorySpending(
            for: expenses,
            budgetPeriodAnchorDay: budgetPeriodAnchorDay,
            calendar: calendar,
            referenceDate: referenceDate
        )
        let safeSpendStreak = safeSpendStreak(
            monthlyBudget: monthlyBudget,
            expenses: expenses,
            budgetPeriodAnchorDay: budgetPeriodAnchorDay,
            initialAvailableBudget: initialAvailableBudget,
            initialBudgetAnchorMonth: initialBudgetAnchorMonth,
            calendar: calendar,
            referenceDate: referenceDate
        )
        let daysRemaining = daysRemainingInCurrentPeriod(
            referenceDate: referenceDate,
            budgetPeriodAnchorDay: budgetPeriodAnchorDay,
            calendar: calendar,
        )

        return DashboardSnapshot(
            monthlyBudget: monthlyBudget,
            previousMonthCarryover: previousMonthCarryover,
            remainingBudget: remainingBudget,
            totalSpent: totalSpent,
            dailySafeSpend: max(0, remainingBudget) / Double(daysRemaining),
            daysRemainingInCurrentPeriod: daysRemaining,
            safeSpendStreak: safeSpendStreak,
            categorySpending: categorySpending,
            topCategory: categorySpending.first
        )
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

    static func subscriptionItems(
        for recurringExpenseItems: [RecurringExpenseItem]
    ) -> [SubscriptionItemSummary] {
        recurringExpenseItems
            .filter { $0.category == .subscriptions }
            .map { SubscriptionItemSummary(id: $0.id, name: $0.name, amount: $0.amount) }
            .sorted { lhs, rhs in
                if lhs.amount == rhs.amount {
                    return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
                }

                return lhs.amount > rhs.amount
            }
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

    static func savingsStabilityHistory(
        recurringExpenseItems: [RecurringExpenseItem],
        months: Int = 6,
        calendar: Calendar = .current,
        referenceDate: Date = .now
    ) -> [SavingsStabilityPoint] {
        guard months > 0 else {
            return []
        }

        let referenceMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: referenceDate)) ?? referenceDate
        let savingsAmount = recurringExpenseItems
            .filter { $0.category == .savings }
            .reduce(0) { $0 + $1.amount }

        return (0..<months).compactMap { offset in
            guard let month = calendar.date(byAdding: .month, value: offset - (months - 1), to: referenceMonth) else {
                return nil
            }

            return SavingsStabilityPoint(month: month, savingsAmount: savingsAmount)
        }
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
        budgetPeriodAnchorDay: Int = 1,
        initialAvailableBudget: Double? = nil,
        initialBudgetAnchorMonth: Date? = nil,
        calendar: Calendar = .current,
        referenceDate: Date = .now
    ) -> Double {
        let previousMonthExpenses = previousMonthExpenses(
            from: expenses,
            budgetPeriodAnchorDay: budgetPeriodAnchorDay,
            calendar: calendar,
            referenceDate: referenceDate
        )

        // The first tracked period is anchored by user-entered reality, not by a synthetic
        // backfilled spend history. Carryover from that initial period must therefore start
        // from the initial available budget instead of the calculated monthly baseline.
        if let previousMonthReferenceDate = calendar.date(byAdding: .month, value: -1, to: referenceDate),
           let initialAvailableBudget,
           isInitialAnchorMonth(
               previousMonthReferenceDate,
               initialBudgetAnchorMonth: initialBudgetAnchorMonth,
               calendar: calendar
           ) {
            return initialAvailableBudget - totalSpent(for: previousMonthExpenses)
        }

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
        budgetPeriodAnchorDay: Int = 1,
        initialAvailableBudget: Double? = nil,
        initialBudgetAnchorMonth: Date? = nil,
        calendar: Calendar = .current,
        referenceDate: Date = .now
    ) -> Double {
        if let initialAvailableBudget,
           isInitialAnchorMonth(
               referenceDate,
               initialBudgetAnchorMonth: initialBudgetAnchorMonth,
               calendar: calendar
           ) {
            return initialAvailableBudget
        }

        return monthlyBudget + previousMonthCarryover(
            monthlyBudget: monthlyBudget,
            expenses: expenses,
            budgetPeriodAnchorDay: budgetPeriodAnchorDay,
            initialAvailableBudget: initialAvailableBudget,
            initialBudgetAnchorMonth: initialBudgetAnchorMonth,
            calendar: calendar,
            referenceDate: referenceDate
        )
    }

    static func categorySpending(
        for expenses: [Expense],
        budgetPeriodAnchorDay: Int = 1,
        calendar: Calendar = .current,
        referenceDate: Date = .now
    ) -> [CategorySpendingSummary] {
        let currentMonthExpenses = currentMonthExpenses(
            from: expenses,
            budgetPeriodAnchorDay: budgetPeriodAnchorDay,
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
        budgetPeriodAnchorDay: Int = 1,
        calendar: Calendar = .current,
        referenceDate: Date = .now
    ) -> CategorySpendingSummary? {
        categorySpending(
            for: expenses,
            budgetPeriodAnchorDay: budgetPeriodAnchorDay,
            calendar: calendar,
            referenceDate: referenceDate
        ).first
    }

    static func remainingBudget(
        monthlyBudget: Double,
        expenses: [Expense],
        budgetPeriodAnchorDay: Int = 1,
        initialAvailableBudget: Double? = nil,
        initialBudgetAnchorMonth: Date? = nil,
        calendar: Calendar = .current,
        referenceDate: Date = .now
    ) -> Double {
        adjustedMonthlyBudget(
            monthlyBudget: monthlyBudget,
            expenses: expenses,
            budgetPeriodAnchorDay: budgetPeriodAnchorDay,
            initialAvailableBudget: initialAvailableBudget,
            initialBudgetAnchorMonth: initialBudgetAnchorMonth,
            calendar: calendar,
            referenceDate: referenceDate
        ) - totalSpent(
            for: currentMonthExpenses(
                from: expenses,
                budgetPeriodAnchorDay: budgetPeriodAnchorDay,
                calendar: calendar,
                referenceDate: referenceDate
            )
        )
    }

    static func daysRemainingInCurrentPeriod(
        referenceDate: Date = .now,
        budgetPeriodAnchorDay: Int = 1,
        calendar: Calendar = .current
    ) -> Int {
        let start = periodStart(containing: referenceDate, budgetPeriodAnchorDay: budgetPeriodAnchorDay, calendar: calendar)
        let end = nextPeriodStart(after: start, budgetPeriodAnchorDay: budgetPeriodAnchorDay, calendar: calendar)
        let startOfToday = calendar.startOfDay(for: referenceDate)
        let startOfPeriodEnd = calendar.startOfDay(for: end)
        let days = calendar.dateComponents([.day], from: startOfToday, to: startOfPeriodEnd).day ?? 0
        return max(1, days)
    }

    static func monthlyHistoryDigest(
        monthlyBudget: Double,
        expenses: [Expense],
        budgetPeriodAnchorDay: Int = 1,
        initialAvailableBudget: Double? = nil,
        initialBudgetAnchorMonth: Date? = nil,
        calendar: Calendar = .current,
        referenceDate: Date = .now
    ) -> MonthlyHistoryDigest {
        let selectedMonthExpenses = currentMonthExpenses(
            from: expenses,
            budgetPeriodAnchorDay: budgetPeriodAnchorDay,
            calendar: calendar,
            referenceDate: referenceDate
        )

        return MonthlyHistoryDigest(
            totalSpent: totalSpent(for: selectedMonthExpenses),
            carryover: previousMonthCarryover(
                monthlyBudget: monthlyBudget,
                expenses: expenses,
                budgetPeriodAnchorDay: budgetPeriodAnchorDay,
                initialAvailableBudget: initialAvailableBudget,
                initialBudgetAnchorMonth: initialBudgetAnchorMonth,
                calendar: calendar,
                referenceDate: referenceDate
            ),
            categorySpending: categorySpending(
                for: expenses,
                budgetPeriodAnchorDay: budgetPeriodAnchorDay,
                calendar: calendar,
                referenceDate: referenceDate
            )
        )
    }

    static func budgetTrajectory(
        monthlyBudget: Double,
        expenses: [Expense],
        budgetPeriodAnchorDay: Int = 1,
        initialAvailableBudget: Double? = nil,
        initialBudgetAnchorMonth: Date? = nil,
        calendar: Calendar = .current,
        referenceDate: Date = .now
    ) -> [BudgetTrajectoryPoint] {
        let currentMonthExpenses = currentMonthExpenses(
            from: expenses,
            budgetPeriodAnchorDay: budgetPeriodAnchorDay,
            calendar: calendar,
            referenceDate: referenceDate
        )
        .sorted { $0.date < $1.date }

        let startingBudget = adjustedMonthlyBudget(
            monthlyBudget: monthlyBudget,
            expenses: expenses,
            budgetPeriodAnchorDay: budgetPeriodAnchorDay,
            initialAvailableBudget: initialAvailableBudget,
            initialBudgetAnchorMonth: initialBudgetAnchorMonth,
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
        budgetPeriodAnchorDay: Int = 1,
        calendar: Calendar = .current,
        referenceDate: Date = .now
    ) -> [TemporalSpendingSummary] {
        let currentMonthExpenses = currentMonthExpenses(
            from: expenses,
            budgetPeriodAnchorDay: budgetPeriodAnchorDay,
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
        budgetPeriodAnchorDay: Int = 1,
        calendar: Calendar = .current,
        referenceDate: Date = .now
    ) -> [TemporalSpendingBucket] {
        guard bucketCount > 0 else {
            return []
        }

        let currentMonthExpenses = currentMonthExpenses(
            from: expenses,
            budgetPeriodAnchorDay: budgetPeriodAnchorDay,
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
        budgetPeriodAnchorDay: Int = 1,
        calendar: Calendar = .current,
        referenceDate: Date = .now
    ) -> MonthComparisonSummary {
        let currentTotal = totalSpent(
            for: currentMonthExpenses(
                from: expenses,
                budgetPeriodAnchorDay: budgetPeriodAnchorDay,
                calendar: calendar,
                referenceDate: referenceDate
            )
        )
        let previousTotal = totalSpent(
            for: previousMonthExpenses(
                from: expenses,
                budgetPeriodAnchorDay: budgetPeriodAnchorDay,
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
        budgetPeriodAnchorDay: Int = 1,
        calendar: Calendar = .current,
        referenceDate: Date = .now
    ) -> [MonthlySpendingPoint] {
        guard months > 0 else {
            return []
        }

        let referenceMonth = periodStart(containing: referenceDate, budgetPeriodAnchorDay: budgetPeriodAnchorDay, calendar: calendar)

        return (0..<months).compactMap { offset in
            guard let month = calendar.date(byAdding: .month, value: offset - (months - 1), to: referenceMonth) else {
                return nil
            }

            return MonthlySpendingPoint(
                month: month,
                total: totalSpent(
                    for: currentMonthExpenses(
                        from: expenses,
                        budgetPeriodAnchorDay: budgetPeriodAnchorDay,
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
        budgetPeriodAnchorDay: Int = 1,
        initialAvailableBudget: Double? = nil,
        initialBudgetAnchorMonth: Date? = nil,
        months: Int = 6,
        calendar: Calendar = .current,
        referenceDate: Date = .now
    ) -> [CarryoverHistoryPoint] {
        guard months > 0 else {
            return []
        }

        let referenceMonth = periodStart(containing: referenceDate, budgetPeriodAnchorDay: budgetPeriodAnchorDay, calendar: calendar)

        return (0..<months).compactMap { offset in
            guard let month = calendar.date(byAdding: .month, value: offset - (months - 1), to: referenceMonth) else {
                return nil
            }

            return CarryoverHistoryPoint(
                month: month,
                amount: previousMonthCarryover(
                    monthlyBudget: monthlyBudget,
                    expenses: expenses,
                    budgetPeriodAnchorDay: budgetPeriodAnchorDay,
                    initialAvailableBudget: initialAvailableBudget,
                    initialBudgetAnchorMonth: initialBudgetAnchorMonth,
                    calendar: calendar,
                    referenceDate: month
                )
            )
        }
    }

    static func evaluateBudgetProgression(
        monthlyBudget: Double,
        expenses: [Expense],
        budgetPeriodAnchorDay: Int = 1,
        initialAvailableBudget: Double? = nil,
        initialBudgetAnchorMonth: Date? = nil,
        calendar: Calendar = .current,
        referenceDate: Date = .now
    ) -> BudgetProgressionEvaluation {
        let progressMonths = completedSavingsProgressMonths(
            monthlyBudget: monthlyBudget,
            expenses: expenses,
            budgetPeriodAnchorDay: budgetPeriodAnchorDay,
            initialAvailableBudget: initialAvailableBudget,
            initialBudgetAnchorMonth: initialBudgetAnchorMonth,
            calendar: calendar,
            referenceDate: referenceDate
        )
        let levels = chessProgressionLevels()
        let totalXP = progressMonths.reduce(0) { $0 + $1.earnedXP }
        let level = currentProgressionLevel(for: totalXP, levels: levels)
        let nextLevel = nextProgressionLevel(after: level, levels: levels)
        let progressXP = totalXP - level.thresholdXP
        let xpToNextLevel = nextLevel.map { max($0.thresholdXP - totalXP, 0) }
        let xpRequiredForNextLevel = nextLevel.map { max($0.thresholdXP - level.thresholdXP, 0) }

        let summary: String
        let periodNote: String

        if progressMonths.isEmpty {
            summary = "Complete a full tracked period to start your chess progression."
            periodNote = "Progress is awarded from completed periods only."
        } else if let lastMonth = progressMonths.last, lastMonth.earnedXP > 0 {
            summary = "Strong savings are steadily advancing your chess progression."
            periodNote = "Your last completed period earned \(lastMonth.earnedXP) XP."
        } else {
            summary = "Progress grows when a completed period finishes with budget left over."
            periodNote = "Your last completed period did not earn progression XP."
        }

        return BudgetProgressionEvaluation(
            level: level,
            totalXP: totalXP,
            progressXP: progressXP,
            xpToNextLevel: xpToNextLevel,
            xpRequiredForNextLevel: xpRequiredForNextLevel,
            completedTrackedMonths: progressMonths.count,
            summary: summary,
            periodNote: periodNote
        )
    }

    static func achievementDefinitions() -> [BudgetAchievementDefinition] {
        [
            BudgetAchievementDefinition(
                id: .architectOfOrder,
                title: "Architect of Order",
                description: "You set up your financial system.",
                unlockCondition: "Complete initial budget setup with income, recurring costs, and a starting budget anchor.",
                symbolName: "building.columns.fill"
            ),
            BudgetAchievementDefinition(
                id: .firstStep,
                title: "First Step",
                description: "The journey begins.",
                unlockCondition: "Log your first expense.",
                symbolName: "figure.walk"
            ),
            BudgetAchievementDefinition(
                id: .habitBuilder,
                title: "Habit Builder",
                description: "Tracking is becoming a habit.",
                unlockCondition: "Log 100 expenses.",
                symbolName: "calendar.badge.checkmark"
            ),
            BudgetAchievementDefinition(
                id: .steadyHand,
                title: "Steady Hand",
                description: "Seven days of disciplined spending.",
                unlockCondition: "Reach a safe-spending streak of 7 days.",
                symbolName: "hand.raised.fill"
            ),
            BudgetAchievementDefinition(
                id: .surgicalPrecision,
                title: "Surgical Precision",
                description: "You planned your budget with impressive accuracy.",
                unlockCondition: "Finish a completed period within ±5% of the available budget.",
                symbolName: "scope"
            ),
            BudgetAchievementDefinition(
                id: .roomToBreathe,
                title: "Room to Breathe",
                description: "You finished the period comfortably below budget.",
                unlockCondition: "Finish a completed period with at least 10% of the budget left.",
                symbolName: "wind"
            ),
            BudgetAchievementDefinition(
                id: .financialCushion,
                title: "Financial Cushion",
                description: "A healthy buffer at the end of the period.",
                unlockCondition: "Finish a completed period with at least 30% of the budget left.",
                symbolName: "pill.fill"
            ),
            BudgetAchievementDefinition(
                id: .spartanMode,
                title: "Spartan Mode",
                description: "Extreme restraint. Impressive discipline.",
                unlockCondition: "Finish a completed period with at least 50% of the budget left.",
                symbolName: "shield.lefthalf.filled"
            ),
            BudgetAchievementDefinition(
                id: .courseCorrection,
                title: "Course Correction",
                description: "Three periods in a row of improving spending.",
                unlockCondition: "Complete three consecutive spending decreases compared to the previous period.",
                symbolName: "arrow.trianglehead.turn.up.right.circle.fill"
            ),
            BudgetAchievementDefinition(
                id: .checkmate,
                title: "Checkmate",
                description: "You reached the highest progression rank.",
                unlockCondition: "Reach King rank in budget progression.",
                symbolName: "crown.fill"
            )
        ]
    }

    static func achievementStatuses(from unlocks: [AchievementUnlock]) -> [BudgetAchievementStatus] {
        let unlockDates = Dictionary(uniqueKeysWithValues: unlocks.map { ($0.achievementID, $0.unlockedAt) })
        return achievementDefinitions().map { definition in
            BudgetAchievementStatus(
                definition: definition,
                unlockedAt: unlockDates[definition.id.rawValue]
            )
        }
    }

    static func safeSpendStreak(
        monthlyBudget: Double,
        expenses: [Expense],
        budgetPeriodAnchorDay: Int = 1,
        initialAvailableBudget: Double? = nil,
        initialBudgetAnchorMonth: Date? = nil,
        calendar: Calendar = .current,
        referenceDate: Date = .now
    ) -> Int {
        let periodStartDate = periodStart(containing: referenceDate, budgetPeriodAnchorDay: budgetPeriodAnchorDay, calendar: calendar)
        let periodEndDate = nextPeriodStart(after: periodStartDate, budgetPeriodAnchorDay: budgetPeriodAnchorDay, calendar: calendar)
        let today = calendar.startOfDay(for: min(referenceDate, calendar.date(byAdding: .day, value: -1, to: periodEndDate) ?? referenceDate))
        var streak = 0
        var runningRemaining = remainingBudget(
            monthlyBudget: monthlyBudget,
            expenses: expenses,
            budgetPeriodAnchorDay: budgetPeriodAnchorDay,
            initialAvailableBudget: initialAvailableBudget,
            initialBudgetAnchorMonth: initialBudgetAnchorMonth,
            calendar: calendar,
            referenceDate: referenceDate
        )
        let currentPeriodExpenses = Self.expenses(
            from: expenses,
            inMonthContaining: referenceDate,
            budgetPeriodAnchorDay: budgetPeriodAnchorDay,
            calendar: calendar
        )
        let groupedExpenses = Dictionary(grouping: currentPeriodExpenses) { calendar.startOfDay(for: $0.date) }
        var cursor = today

        while cursor >= periodStartDate {
            let nextDay = calendar.date(byAdding: .day, value: 1, to: cursor) ?? cursor
            let dayExpenses = groupedExpenses[cursor, default: []]
            let dayTotal = totalSpent(for: dayExpenses)
            let daysRemaining = max(calendar.dateComponents([.day], from: cursor, to: periodEndDate).day ?? 0, 1)
            let safeSpend = max(0, runningRemaining) / Double(daysRemaining)

            if dayTotal <= safeSpend + 0.001 {
                streak += 1
            } else {
                break
            }

            runningRemaining += dayTotal
            cursor = calendar.date(byAdding: .day, value: -1, to: cursor) ?? periodStartDate

            if nextDay == cursor {
                break
            }
        }

        return streak
    }

    static func evaluateAchievementIDs(
        hasCompletedSetup: Bool,
        incomeItems: [IncomeItem],
        recurringExpenseItems: [RecurringExpenseItem],
        expenses: [Expense],
        budgetPeriodAnchorDay: Int = 1,
        initialAvailableBudget: Double? = nil,
        initialBudgetAnchorMonth: Date? = nil,
        calendar: Calendar = .current,
        referenceDate: Date = .now
    ) -> Set<BudgetAchievementID> {
        let monthlyBudget = availableMonthlyBudget(
            incomeItems: incomeItems,
            recurringExpenseItems: recurringExpenseItems
        )
        let progression = evaluateBudgetProgression(
            monthlyBudget: monthlyBudget,
            expenses: expenses,
            budgetPeriodAnchorDay: budgetPeriodAnchorDay,
            initialAvailableBudget: initialAvailableBudget,
            initialBudgetAnchorMonth: initialBudgetAnchorMonth,
            calendar: calendar,
            referenceDate: referenceDate
        )
        let completedPeriods = completedBudgetPeriods(
            monthlyBudget: monthlyBudget,
            expenses: expenses,
            budgetPeriodAnchorDay: budgetPeriodAnchorDay,
            initialAvailableBudget: initialAvailableBudget,
            initialBudgetAnchorMonth: initialBudgetAnchorMonth,
            calendar: calendar,
            referenceDate: referenceDate
        )
        let streak = safeSpendStreak(
            monthlyBudget: monthlyBudget,
            expenses: expenses,
            budgetPeriodAnchorDay: budgetPeriodAnchorDay,
            initialAvailableBudget: initialAvailableBudget,
            initialBudgetAnchorMonth: initialBudgetAnchorMonth,
            calendar: calendar,
            referenceDate: referenceDate
        )

        var unlocked: Set<BudgetAchievementID> = []

        if hasCompletedSetup, !incomeItems.isEmpty, !recurringExpenseItems.isEmpty, initialAvailableBudget != nil {
            unlocked.insert(.architectOfOrder)
        }

        if !expenses.isEmpty {
            unlocked.insert(.firstStep)
        }

        if expenses.count >= 100 {
            unlocked.insert(.habitBuilder)
        }

        if streak >= 7 {
            unlocked.insert(.steadyHand)
        }

        if completedPeriods.contains(where: { $0.expenseCount > 0 && $0.adjustedBudget > 0 && abs($0.remainingShare) <= 0.05 }) {
            unlocked.insert(.surgicalPrecision)
        }

        if completedPeriods.contains(where: { $0.expenseCount > 0 && $0.remainingShare >= 0.10 }) {
            unlocked.insert(.roomToBreathe)
        }

        if completedPeriods.contains(where: { $0.expenseCount > 0 && $0.remainingShare >= 0.30 }) {
            unlocked.insert(.financialCushion)
        }

        if completedPeriods.contains(where: { $0.expenseCount > 0 && $0.remainingShare >= 0.50 }) {
            unlocked.insert(.spartanMode)
        }

        if hasThreePeriodSpendingDecline(completedPeriods) {
            unlocked.insert(.courseCorrection)
        }

        if progression.level.piece == .king {
            unlocked.insert(.checkmate)
        }

        return unlocked
    }

    private static func completedSavingsProgressMonths(
        monthlyBudget: Double,
        expenses: [Expense],
        budgetPeriodAnchorDay: Int,
        initialAvailableBudget: Double?,
        initialBudgetAnchorMonth: Date?,
        calendar: Calendar,
        referenceDate: Date
    ) -> [SavingsProgressMonth] {
        let currentMonth = periodStart(containing: referenceDate, budgetPeriodAnchorDay: budgetPeriodAnchorDay, calendar: calendar)
        let startMonth: Date?

        if let initialBudgetAnchorMonth {
            startMonth = periodStart(containing: initialBudgetAnchorMonth, budgetPeriodAnchorDay: budgetPeriodAnchorDay, calendar: calendar)
        } else if let earliestExpense = expenses.map(\.date).min() {
            startMonth = periodStart(containing: earliestExpense, budgetPeriodAnchorDay: budgetPeriodAnchorDay, calendar: calendar)
        } else {
            startMonth = nil
        }

        guard let startMonth else {
            return []
        }

        var progressMonths: [SavingsProgressMonth] = []
        var month = startMonth

        // Progression is awarded only from fully completed budget periods so the current
        // in-flight month cannot prematurely inflate XP.
        while month < currentMonth {
            let monthExpenses = Self.expenses(
                from: expenses,
                inMonthContaining: month,
                budgetPeriodAnchorDay: budgetPeriodAnchorDay,
                calendar: calendar
            )
            let adjustedBudget = adjustedMonthlyBudget(
                monthlyBudget: monthlyBudget,
                expenses: expenses,
                budgetPeriodAnchorDay: budgetPeriodAnchorDay,
                initialAvailableBudget: initialAvailableBudget,
                initialBudgetAnchorMonth: initialBudgetAnchorMonth,
                calendar: calendar,
                referenceDate: month
            )
            let remaining = remainingBudget(
                monthlyBudget: monthlyBudget,
                expenses: expenses,
                budgetPeriodAnchorDay: budgetPeriodAnchorDay,
                initialAvailableBudget: initialAvailableBudget,
                initialBudgetAnchorMonth: initialBudgetAnchorMonth,
                calendar: calendar,
                referenceDate: month
            )

            let savedPercentage: Double
            if monthExpenses.isEmpty || adjustedBudget <= 0 || remaining <= 0 {
                savedPercentage = 0
            } else {
                savedPercentage = (remaining / adjustedBudget) * 100
            }

            progressMonths.append(
                SavingsProgressMonth(
                    month: month,
                    savedPercentage: max(savedPercentage, 0),
                    earnedXP: max(Int(floor(savedPercentage)), 0)
                )
            )

            month = nextPeriodStart(
                after: month,
                budgetPeriodAnchorDay: budgetPeriodAnchorDay,
                calendar: calendar
            )
        }

        return progressMonths
    }

    private static func completedBudgetPeriods(
        monthlyBudget: Double,
        expenses: [Expense],
        budgetPeriodAnchorDay: Int,
        initialAvailableBudget: Double?,
        initialBudgetAnchorMonth: Date?,
        calendar: Calendar,
        referenceDate: Date
    ) -> [CompletedBudgetPeriodSummary] {
        let currentPeriod = periodStart(containing: referenceDate, budgetPeriodAnchorDay: budgetPeriodAnchorDay, calendar: calendar)
        let startPeriod: Date?

        if let initialBudgetAnchorMonth {
            startPeriod = periodStart(containing: initialBudgetAnchorMonth, budgetPeriodAnchorDay: budgetPeriodAnchorDay, calendar: calendar)
        } else if let earliestExpense = expenses.map(\.date).min() {
            startPeriod = periodStart(containing: earliestExpense, budgetPeriodAnchorDay: budgetPeriodAnchorDay, calendar: calendar)
        } else {
            startPeriod = nil
        }

        guard let startPeriod else {
            return []
        }

        var summaries: [CompletedBudgetPeriodSummary] = []
        var period = startPeriod

        while period < currentPeriod {
            let periodExpenses = Self.expenses(
                from: expenses,
                inMonthContaining: period,
                budgetPeriodAnchorDay: budgetPeriodAnchorDay,
                calendar: calendar
            )
            let adjustedBudget = adjustedMonthlyBudget(
                monthlyBudget: monthlyBudget,
                expenses: expenses,
                budgetPeriodAnchorDay: budgetPeriodAnchorDay,
                initialAvailableBudget: initialAvailableBudget,
                initialBudgetAnchorMonth: initialBudgetAnchorMonth,
                calendar: calendar,
                referenceDate: period
            )
            let spent = totalSpent(for: periodExpenses)
            let remaining = remainingBudget(
                monthlyBudget: monthlyBudget,
                expenses: expenses,
                budgetPeriodAnchorDay: budgetPeriodAnchorDay,
                initialAvailableBudget: initialAvailableBudget,
                initialBudgetAnchorMonth: initialBudgetAnchorMonth,
                calendar: calendar,
                referenceDate: period
            )

            summaries.append(
                CompletedBudgetPeriodSummary(
                    startDate: period,
                    adjustedBudget: adjustedBudget,
                    totalSpent: spent,
                    remainingBudget: remaining,
                    expenseCount: periodExpenses.count
                )
            )

            period = nextPeriodStart(after: period, budgetPeriodAnchorDay: budgetPeriodAnchorDay, calendar: calendar)
        }

        return summaries
    }

    private static func hasThreePeriodSpendingDecline(_ periods: [CompletedBudgetPeriodSummary]) -> Bool {
        guard periods.count >= 4 else {
            return false
        }

        for windowStart in 0...(periods.count - 4) {
            let window = Array(periods[windowStart..<(windowStart + 4)])
            if zip(window, window.dropFirst()).allSatisfy({ next in next.1.totalSpent < next.0.totalSpent }) {
                return true
            }
        }

        return false
    }

    private static func chessProgressionLevels() -> [ChessProgressionLevel] {
        var thresholdXP = 0
        var levels: [ChessProgressionLevel] = []

        func appendLevel(
            piece: ChessProgressionPiece,
            sublevel: Int?,
            title: String,
            quote: String,
            author: String,
            nextCost: Int?
        ) {
            levels.append(
                ChessProgressionLevel(
                    piece: piece,
                    sublevel: sublevel,
                    title: title,
                    quote: quote,
                    author: author,
                    thresholdXP: thresholdXP
                )
            )

            if let nextCost {
                thresholdXP += nextCost
            }
        }

        appendLevel(piece: .pawn, sublevel: 1, title: "Isolated Pawn", quote: "The isolated pawn is a weakness — but also a source of dynamic play.", author: "Garry Kasparov", nextCost: 5)
        appendLevel(piece: .pawn, sublevel: 2, title: "Doubled Pawn", quote: "Doubled pawns are often weak, but they may open important files.", author: "Siegbert Tarrasch", nextCost: 5)
        appendLevel(piece: .pawn, sublevel: 3, title: "Connected Pawn", quote: "Connected pawns support each other like soldiers in formation.", author: "Aron Nimzowitsch", nextCost: 5)
        appendLevel(piece: .pawn, sublevel: 4, title: "Passed Pawn", quote: "A passed pawn must be pushed.", author: "Aron Nimzowitsch", nextCost: 5)
        appendLevel(piece: .pawn, sublevel: 5, title: "Pawn on the Sixth Rank", quote: "A pawn on the sixth rank is stronger than a knight.", author: "Aaron Nimzowitsch", nextCost: 5)

        appendLevel(piece: .knight, sublevel: 1, title: "Corner Knight", quote: "A knight on the rim is dim.", author: "Reuben Fine", nextCost: 6)
        appendLevel(piece: .knight, sublevel: 2, title: "Developing Knight", quote: "Develop your knights before the bishops.", author: "Chess Opening Principle", nextCost: 6)
        appendLevel(piece: .knight, sublevel: 3, title: "Central Knight", quote: "A knight in the center is a powerful piece.", author: "Jose Raul Capablanca", nextCost: 6)
        appendLevel(piece: .knight, sublevel: 4, title: "Outpost Knight", quote: "A knight firmly posted in the enemy camp is a bone in the throat.", author: "Aron Nimzowitsch", nextCost: 6)
        appendLevel(piece: .knight, sublevel: 5, title: "Royal Forking Knight", quote: "The knight is the most cunning piece.", author: "Savielly Tartakower", nextCost: 6)

        appendLevel(piece: .bishop, sublevel: 1, title: "Locked Bishop", quote: "Bad bishops defend good pawns.", author: "Chess Proverb", nextCost: 7)
        appendLevel(piece: .bishop, sublevel: 2, title: "Bishop Outside Pawn Chain", quote: "A bishop outside the pawn chain breathes freely.", author: "Chess Strategy Principle", nextCost: 7)
        appendLevel(piece: .bishop, sublevel: 3, title: "Fianchetto Bishop", quote: "The fianchettoed bishop is a powerful defender and attacker.", author: "Bobby Fischer", nextCost: 7)
        appendLevel(piece: .bishop, sublevel: 4, title: "Long Diagonal Bishop", quote: "A bishop on the long diagonal controls the board.", author: "Chess Strategy Principle", nextCost: 7)
        appendLevel(piece: .bishop, sublevel: 5, title: "Bishop Pair", quote: "The two bishops are a formidable force.", author: "Wilhelm Steinitz", nextCost: 7)

        appendLevel(piece: .rook, sublevel: 1, title: "Sleeping Rook", quote: "Rooks belong behind passed pawns.", author: "Siegbert Tarrasch", nextCost: 8)
        appendLevel(piece: .rook, sublevel: 2, title: "Connected Rooks", quote: "Connected rooks double their strength.", author: "Chess Principle", nextCost: 8)
        appendLevel(piece: .rook, sublevel: 3, title: "Open File Rook", quote: "Place your rooks on open files.", author: "Jose Raul Capablanca", nextCost: 8)
        appendLevel(piece: .rook, sublevel: 4, title: "Seventh Rank Rook", quote: "A rook on the seventh rank is worth a pawn.", author: "Chess Maxim", nextCost: 8)
        appendLevel(piece: .rook, sublevel: 5, title: "Rook Battery", quote: "Doubling rooks creates irresistible pressure.", author: "Chess Strategy Principle", nextCost: 8)

        appendLevel(piece: .queen, sublevel: 1, title: "Undeveloped Queen", quote: "Do not bring your queen out too early.", author: "Chess Opening Principle", nextCost: 9)
        appendLevel(piece: .queen, sublevel: 2, title: "Developed Queen", quote: "The queen is strongest when supported by the army.", author: "Emanuel Lasker", nextCost: 9)
        appendLevel(piece: .queen, sublevel: 3, title: "Centralized Queen", quote: "A centralized queen commands the board.", author: "Chess Strategy Principle", nextCost: 9)
        appendLevel(piece: .queen, sublevel: 4, title: "Dominant Queen", quote: "The queen combines the power of rook and bishop.", author: "Chess Maxim", nextCost: 9)
        appendLevel(piece: .queen, sublevel: 5, title: "Forking Queen", quote: "A queen fork can decide the game instantly.", author: "Chess Tactic Principle", nextCost: 10)

        appendLevel(piece: .king, sublevel: nil, title: "Crowned King", quote: "The king is a fighting piece.", author: "Jose Raul Capablanca", nextCost: nil)

        return levels
    }

    private static func currentProgressionLevel(
        for totalXP: Int,
        levels: [ChessProgressionLevel]
    ) -> ChessProgressionLevel {
        levels.last(where: { totalXP >= $0.thresholdXP }) ?? levels[0]
    }

    private static func nextProgressionLevel(
        after currentLevel: ChessProgressionLevel,
        levels: [ChessProgressionLevel]
    ) -> ChessProgressionLevel? {
        guard let currentIndex = levels.firstIndex(of: currentLevel), currentIndex + 1 < levels.count else {
            return nil
        }

        return levels[currentIndex + 1]
    }

    private static func monthAnchor(for date: Date, calendar: Calendar) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
    }

    private static func periodStart(
        containing date: Date,
        budgetPeriodAnchorDay: Int,
        calendar: Calendar
    ) -> Date {
        // Budget periods are anchored to an arbitrary day of the month rather than always
        // starting on day 1, so dates before the current month's anchor belong to the
        // previous anchored period.
        let monthStart = monthAnchor(for: date, calendar: calendar)
        let normalizedDay = normalizedAnchorDay(budgetPeriodAnchorDay, forMonthContaining: monthStart, calendar: calendar)
        let currentMonthAnchor = calendar.date(byAdding: .day, value: normalizedDay - 1, to: monthStart) ?? monthStart

        if date >= currentMonthAnchor {
            return currentMonthAnchor
        }

        guard let previousMonth = calendar.date(byAdding: .month, value: -1, to: monthStart) else {
            return currentMonthAnchor
        }

        let previousMonthStart = monthAnchor(for: previousMonth, calendar: calendar)
        let previousNormalizedDay = normalizedAnchorDay(budgetPeriodAnchorDay, forMonthContaining: previousMonthStart, calendar: calendar)
        return calendar.date(byAdding: .day, value: previousNormalizedDay - 1, to: previousMonthStart) ?? previousMonthStart
    }

    private static func nextPeriodStart(
        after periodStart: Date,
        budgetPeriodAnchorDay: Int,
        calendar: Calendar
    ) -> Date {
        let currentMonthStart = monthAnchor(for: periodStart, calendar: calendar)
        guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentMonthStart) else {
            return periodStart
        }

        let nextMonthStart = monthAnchor(for: nextMonth, calendar: calendar)
        let normalizedDay = normalizedAnchorDay(budgetPeriodAnchorDay, forMonthContaining: nextMonthStart, calendar: calendar)
        return calendar.date(byAdding: .day, value: normalizedDay - 1, to: nextMonthStart) ?? nextMonthStart
    }

    private static func normalizedAnchorDay(
        _ budgetPeriodAnchorDay: Int,
        forMonthContaining date: Date,
        calendar: Calendar
    ) -> Int {
        let maxDay = calendar.range(of: .day, in: .month, for: date)?.count ?? 28
        return max(1, min(maxDay, budgetPeriodAnchorDay))
    }

    func currentMonthExpenses(from expenses: [Expense], referenceDate: Date = .now) -> [Expense] {
        Self.currentMonthExpenses(from: expenses, calendar: calendar, referenceDate: referenceDate)
    }

    func expenses(from expenses: [Expense], inMonthContaining referenceDate: Date) -> [Expense] {
        Self.expenses(from: expenses, inMonthContaining: referenceDate, calendar: calendar)
    }

    private static func isInitialAnchorMonth(
        _ referenceDate: Date,
        initialBudgetAnchorMonth: Date?,
        calendar: Calendar
    ) -> Bool {
        guard let initialBudgetAnchorMonth else {
            return false
        }

        return calendar.isDate(referenceDate, equalTo: initialBudgetAnchorMonth, toGranularity: .month)
    }
}

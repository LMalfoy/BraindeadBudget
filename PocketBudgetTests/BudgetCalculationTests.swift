import Foundation
import XCTest
@testable import PocketBudget

@MainActor
final class BudgetCalculationTests: XCTestCase {
    func testAvailableMonthlyBudgetSubtractsRecurringCostsFromIncome() {
        let incomeItems = [
            IncomeItem(name: "Salary", amount: 3000),
            IncomeItem(name: "Freelance", amount: 500)
        ]
        let recurringExpenseItems = [
            RecurringExpenseItem(name: "Rent", amount: 1200),
            RecurringExpenseItem(name: "Savings", amount: 300)
        ]

        let availableBudget = BudgetStore.availableMonthlyBudget(
            incomeItems: incomeItems,
            recurringExpenseItems: recurringExpenseItems
        )

        XCTAssertEqual(availableBudget, 2000, accuracy: 0.001)
    }

    func testAvailableMonthlyBudgetAllowsNegativeValues() {
        let incomeItems = [IncomeItem(name: "Salary", amount: 1500)]
        let recurringExpenseItems = [RecurringExpenseItem(name: "Rent", amount: 1800)]

        let availableBudget = BudgetStore.availableMonthlyBudget(
            incomeItems: incomeItems,
            recurringExpenseItems: recurringExpenseItems
        )

        XCTAssertEqual(availableBudget, -300, accuracy: 0.001)
    }

    func testPreviousMonthCarryoverUsesPositiveRemainder() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let referenceDate = makeDate(year: 2026, month: 3, day: 14, calendar: calendar)
        let expenses = [
            Expense(title: "Dinner", category: .food, amount: 60, date: makeDate(year: 2026, month: 2, day: 10, calendar: calendar))
        ]

        let carryover = BudgetStore.previousMonthCarryover(
            monthlyBudget: 100,
            expenses: expenses,
            calendar: calendar,
            referenceDate: referenceDate
        )

        XCTAssertEqual(carryover, 40, accuracy: 0.001)
    }

    func testPreviousMonthCarryoverUsesNegativeRemainder() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let referenceDate = makeDate(year: 2026, month: 3, day: 14, calendar: calendar)
        let expenses = [
            Expense(title: "Trip", category: .fun, amount: 180, date: makeDate(year: 2026, month: 2, day: 18, calendar: calendar))
        ]

        let carryover = BudgetStore.previousMonthCarryover(
            monthlyBudget: 100,
            expenses: expenses,
            calendar: calendar,
            referenceDate: referenceDate
        )

        XCTAssertEqual(carryover, -80, accuracy: 0.001)
    }

    func testPreviousMonthCarryoverIsZeroWhenPreviousMonthHasNoExpenses() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let referenceDate = makeDate(year: 2026, month: 3, day: 14, calendar: calendar)
        let expenses = [
            Expense(title: "Old", category: .food, amount: 30, date: makeDate(year: 2026, month: 1, day: 10, calendar: calendar))
        ]

        let carryover = BudgetStore.previousMonthCarryover(
            monthlyBudget: 100,
            expenses: expenses,
            calendar: calendar,
            referenceDate: referenceDate
        )

        XCTAssertEqual(carryover, 0, accuracy: 0.001)
    }

    func testRemainingBudgetIncludesPreviousMonthCarryover() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let referenceDate = makeDate(year: 2026, month: 3, day: 14, calendar: calendar)
        let previousMonthExpense = Expense(
            title: "Groceries",
            category: .food,
            amount: 60,
            date: makeDate(year: 2026, month: 2, day: 10, calendar: calendar)
        )
        let currentMonthExpense = Expense(
            title: "Train",
            category: .transport,
            amount: 20,
            date: makeDate(year: 2026, month: 3, day: 12, calendar: calendar)
        )

        let remaining = BudgetStore.remainingBudget(
            monthlyBudget: 100,
            expenses: [previousMonthExpense, currentMonthExpense],
            calendar: calendar,
            referenceDate: referenceDate
        )

        XCTAssertEqual(remaining, 120, accuracy: 0.001)
    }

    func testCategorySpendingAggregatesCurrentMonthExpensesByCategory() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let referenceDate = makeDate(year: 2026, month: 3, day: 14, calendar: calendar)
        let expenses = [
            Expense(title: "Coffee", category: .food, amount: 5, date: makeDate(year: 2026, month: 3, day: 10, calendar: calendar)),
            Expense(title: "Lunch", category: .food, amount: 12, date: makeDate(year: 2026, month: 3, day: 11, calendar: calendar)),
            Expense(title: "Train", category: .transport, amount: 20, date: makeDate(year: 2026, month: 3, day: 12, calendar: calendar)),
            Expense(title: "Old", category: .fun, amount: 50, date: makeDate(year: 2026, month: 2, day: 28, calendar: calendar))
        ]

        let summaries = BudgetStore.categorySpending(
            for: expenses,
            calendar: calendar,
            referenceDate: referenceDate
        )

        XCTAssertEqual(summaries.count, 2)
        XCTAssertEqual(summaries[0], CategorySpendingSummary(category: .transport, total: 20))
        XCTAssertEqual(summaries[1], CategorySpendingSummary(category: .food, total: 17))
    }

    func testTopSpendingCategoryReturnsHighestCategoryForCurrentMonth() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let referenceDate = makeDate(year: 2026, month: 3, day: 14, calendar: calendar)
        let expenses = [
            Expense(title: "Movie", category: .fun, amount: 18, date: makeDate(year: 2026, month: 3, day: 8, calendar: calendar)),
            Expense(title: "Dinner", category: .food, amount: 30, date: makeDate(year: 2026, month: 3, day: 9, calendar: calendar))
        ]

        let topCategory = BudgetStore.topSpendingCategory(
            for: expenses,
            calendar: calendar,
            referenceDate: referenceDate
        )

        XCTAssertEqual(topCategory, CategorySpendingSummary(category: .food, total: 30))
    }

    func testCategorySpendingReturnsEmptyOverviewWhenNoCurrentMonthExpensesExist() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let referenceDate = makeDate(year: 2026, month: 3, day: 14, calendar: calendar)
        let expenses = [
            Expense(title: "Old", category: .food, amount: 10, date: makeDate(year: 2026, month: 2, day: 14, calendar: calendar))
        ]

        let summaries = BudgetStore.categorySpending(
            for: expenses,
            calendar: calendar,
            referenceDate: referenceDate
        )

        XCTAssertTrue(summaries.isEmpty)
        XCTAssertNil(BudgetStore.topSpendingCategory(
            for: expenses,
            calendar: calendar,
            referenceDate: referenceDate
        ))
    }

    func testRemainingBudgetUpdatesAfterDeletingExpenseFromInputSet() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let referenceDate = makeDate(year: 2026, month: 3, day: 14, calendar: calendar)
        let keptExpense = Expense(
            title: "Lunch",
            category: .food,
            amount: 12.5,
            date: makeDate(year: 2026, month: 3, day: 11, calendar: calendar)
        )
        let deletedExpense = Expense(
            title: "Train",
            category: .transport,
            amount: 20,
            date: makeDate(year: 2026, month: 3, day: 12, calendar: calendar)
        )

        let remainingBeforeDelete = BudgetStore.remainingBudget(
            monthlyBudget: 100,
            expenses: [keptExpense, deletedExpense],
            calendar: calendar,
            referenceDate: referenceDate
        )
        let remainingAfterDelete = BudgetStore.remainingBudget(
            monthlyBudget: 100,
            expenses: [keptExpense],
            calendar: calendar,
            referenceDate: referenceDate
        )

        XCTAssertEqual(remainingBeforeDelete, 67.5, accuracy: 0.001)
        XCTAssertEqual(remainingAfterDelete, 87.5, accuracy: 0.001)
    }

    func testCategoryOverviewUpdatesAfterDeletingExpenseFromInputSet() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let referenceDate = makeDate(year: 2026, month: 3, day: 14, calendar: calendar)
        let keptExpense = Expense(
            title: "Dinner",
            category: .food,
            amount: 22,
            date: makeDate(year: 2026, month: 3, day: 10, calendar: calendar)
        )
        let deletedExpense = Expense(
            title: "Cinema",
            category: .fun,
            amount: 18,
            date: makeDate(year: 2026, month: 3, day: 12, calendar: calendar)
        )

        let categorySpendingBeforeDelete = BudgetStore.categorySpending(
            for: [keptExpense, deletedExpense],
            calendar: calendar,
            referenceDate: referenceDate
        )
        let categorySpendingAfterDelete = BudgetStore.categorySpending(
            for: [keptExpense],
            calendar: calendar,
            referenceDate: referenceDate
        )

        XCTAssertEqual(categorySpendingBeforeDelete.count, 2)
        XCTAssertEqual(categorySpendingAfterDelete, [
            CategorySpendingSummary(category: .food, total: 22)
        ])
    }

    func testCurrentMonthExpensesOnlyIncludeMatchingMonth() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let referenceDate = makeDate(year: 2026, month: 3, day: 14, calendar: calendar)
        let marchExpense = Expense(title: "Coffee", amount: 5.5, date: makeDate(year: 2026, month: 3, day: 10, calendar: calendar))
        let februaryExpense = Expense(title: "Rent", amount: 700, date: makeDate(year: 2026, month: 2, day: 28, calendar: calendar))

        let filtered = BudgetStore.currentMonthExpenses(
            from: [marchExpense, februaryExpense],
            calendar: calendar,
            referenceDate: referenceDate
        )

        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.title, "Coffee")
    }

    func testExpensesForMonthContainingReturnsOnlySelectedMonth() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let referenceDate = makeDate(year: 2026, month: 2, day: 14, calendar: calendar)
        let februaryExpense = Expense(title: "Rent", amount: 700, date: makeDate(year: 2026, month: 2, day: 1, calendar: calendar))
        let marchExpense = Expense(title: "Coffee", amount: 5.5, date: makeDate(year: 2026, month: 3, day: 10, calendar: calendar))

        let filtered = BudgetStore.expenses(
            from: [februaryExpense, marchExpense],
            inMonthContaining: referenceDate,
            calendar: calendar
        )

        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.title, "Rent")
    }

    func testRemainingBudgetIncludesPreviousMonthCarryoverWhileIgnoringOlderMonths() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let referenceDate = makeDate(year: 2026, month: 3, day: 14, calendar: calendar)
        let currentMonthExpense = Expense(title: "Lunch", amount: 12.5, date: makeDate(year: 2026, month: 3, day: 11, calendar: calendar))
        let previousMonthExpense = Expense(title: "Shoes", amount: 80, date: makeDate(year: 2026, month: 2, day: 25, calendar: calendar))

        let remaining = BudgetStore.remainingBudget(
            monthlyBudget: 250,
            expenses: [currentMonthExpense, previousMonthExpense],
            calendar: calendar,
            referenceDate: referenceDate
        )

        XCTAssertEqual(remaining, 407.5, accuracy: 0.001)
    }

    func testMonthlyHistoryDigestSummarizesSelectedMonth() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let referenceDate = makeDate(year: 2026, month: 3, day: 14, calendar: calendar)
        let previousMonthExpense = Expense(
            title: "Train Pass",
            category: .transport,
            amount: 40,
            date: makeDate(year: 2026, month: 2, day: 8, calendar: calendar)
        )
        let currentMonthExpense = Expense(
            title: "Groceries",
            category: .food,
            amount: 25,
            date: makeDate(year: 2026, month: 3, day: 9, calendar: calendar)
        )

        let digest = BudgetStore.monthlyHistoryDigest(
            monthlyBudget: 100,
            expenses: [previousMonthExpense, currentMonthExpense],
            calendar: calendar,
            referenceDate: referenceDate
        )

        XCTAssertEqual(digest.totalSpent, 25, accuracy: 0.001)
        XCTAssertEqual(digest.carryover, 60, accuracy: 0.001)
        XCTAssertEqual(digest.categorySpending, [
            CategorySpendingSummary(category: .food, total: 25)
        ])
    }

    func testBudgetTrajectoryBuildsRunningRemainingBudgetForCurrentMonth() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let referenceDate = makeDate(year: 2026, month: 3, day: 20, calendar: calendar)
        let firstExpense = Expense(
            title: "Coffee",
            category: .food,
            amount: 10,
            date: makeDate(year: 2026, month: 3, day: 5, calendar: calendar)
        )
        let secondExpense = Expense(
            title: "Train",
            category: .transport,
            amount: 15,
            date: makeDate(year: 2026, month: 3, day: 12, calendar: calendar)
        )

        let trajectory = BudgetStore.budgetTrajectory(
            monthlyBudget: 100,
            expenses: [secondExpense, firstExpense],
            calendar: calendar,
            referenceDate: referenceDate
        )

        XCTAssertEqual(trajectory.count, 2)
        XCTAssertEqual(trajectory[0].remainingBudget, 90, accuracy: 0.001)
        XCTAssertEqual(trajectory[1].remainingBudget, 75, accuracy: 0.001)
    }

    func testTemporalSpendingGroupsExpensesIntoEarlyMidLateMonth() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let referenceDate = makeDate(year: 2026, month: 3, day: 20, calendar: calendar)
        let expenses = [
            Expense(title: "Coffee", category: .food, amount: 10, date: makeDate(year: 2026, month: 3, day: 3, calendar: calendar)),
            Expense(title: "Lunch", category: .food, amount: 15, date: makeDate(year: 2026, month: 3, day: 15, calendar: calendar)),
            Expense(title: "Cinema", category: .fun, amount: 20, date: makeDate(year: 2026, month: 3, day: 24, calendar: calendar)),
            Expense(title: "Old", category: .transport, amount: 50, date: makeDate(year: 2026, month: 2, day: 24, calendar: calendar))
        ]

        let summaries = BudgetStore.temporalSpending(
            for: expenses,
            calendar: calendar,
            referenceDate: referenceDate
        )

        XCTAssertEqual(summaries, [
            TemporalSpendingSummary(segment: .early, total: 10),
            TemporalSpendingSummary(segment: .mid, total: 15),
            TemporalSpendingSummary(segment: .late, total: 20)
        ])
    }

    func testMonthComparisonUsesCurrentAndPreviousMonthTotals() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let referenceDate = makeDate(year: 2026, month: 3, day: 20, calendar: calendar)
        let expenses = [
            Expense(title: "Coffee", category: .food, amount: 10, date: makeDate(year: 2026, month: 3, day: 3, calendar: calendar)),
            Expense(title: "Lunch", category: .food, amount: 15, date: makeDate(year: 2026, month: 3, day: 15, calendar: calendar)),
            Expense(title: "Cinema", category: .fun, amount: 20, date: makeDate(year: 2026, month: 2, day: 24, calendar: calendar))
        ]

        let comparison = BudgetStore.monthComparison(
            for: expenses,
            calendar: calendar,
            referenceDate: referenceDate
        )

        XCTAssertEqual(comparison.currentMonthTotal, 25, accuracy: 0.001)
        XCTAssertEqual(comparison.previousMonthTotal, 20, accuracy: 0.001)
        XCTAssertEqual(comparison.difference, 5, accuracy: 0.001)
    }

    func testCarryoverHistoryBuildsTrailingSixMonthSeries() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let referenceDate = makeDate(year: 2026, month: 6, day: 20, calendar: calendar)
        let expenses = [
            Expense(title: "Jan", category: .food, amount: 80, date: makeDate(year: 2026, month: 1, day: 10, calendar: calendar)),
            Expense(title: "Feb", category: .food, amount: 120, date: makeDate(year: 2026, month: 2, day: 10, calendar: calendar)),
            Expense(title: "Apr", category: .food, amount: 60, date: makeDate(year: 2026, month: 4, day: 10, calendar: calendar)),
            Expense(title: "May", category: .food, amount: 110, date: makeDate(year: 2026, month: 5, day: 10, calendar: calendar))
        ]

        let history = BudgetStore.carryoverHistory(
            monthlyBudget: 100,
            expenses: expenses,
            months: 6,
            calendar: calendar,
            referenceDate: referenceDate
        )

        XCTAssertEqual(history.count, 6)
        let expectedAmounts = [0.0, 20.0, -20.0, 0.0, 40.0, -10.0]
        for (actual, expected) in zip(history.map(\.amount), expectedAmounts) {
            XCTAssertEqual(actual, expected, accuracy: 0.001)
        }
    }

    func testBudgetDisciplineFallsBackToKnightWhenDataIsSparse() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let referenceDate = makeDate(year: 2026, month: 6, day: 20, calendar: calendar)
        let expenses = [
            Expense(title: "Coffee", category: .food, amount: 12, date: makeDate(year: 2026, month: 6, day: 4, calendar: calendar))
        ]

        let evaluation = BudgetStore.evaluateBudgetDiscipline(
            monthlyBudget: 100,
            expenses: expenses,
            calendar: calendar,
            referenceDate: referenceDate
        )

        XCTAssertEqual(evaluation.rank, .knight)
        XCTAssertTrue(evaluation.isSparseData)
        XCTAssertEqual(evaluation.summary, "Still learning your spending pattern.")
    }

    func testBudgetDisciplineCanReachKingForStrongStableBehavior() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let referenceDate = makeDate(year: 2026, month: 6, day: 26, calendar: calendar)
        let expenses = [
            Expense(title: "May Groceries", category: .food, amount: 80, date: makeDate(year: 2026, month: 5, day: 10, calendar: calendar)),
            Expense(title: "Coffee", category: .food, amount: 10, date: makeDate(year: 2026, month: 6, day: 5, calendar: calendar)),
            Expense(title: "Train", category: .transport, amount: 15, date: makeDate(year: 2026, month: 6, day: 15, calendar: calendar)),
            Expense(title: "Soap", category: .household, amount: 20, date: makeDate(year: 2026, month: 6, day: 25, calendar: calendar))
        ]

        let evaluation = BudgetStore.evaluateBudgetDiscipline(
            monthlyBudget: 100,
            expenses: expenses,
            calendar: calendar,
            referenceDate: referenceDate
        )

        XCTAssertEqual(evaluation.rank, .king)
        XCTAssertFalse(evaluation.isSparseData)
    }

    func testBudgetDisciplineDropsToPawnForUnhealthyPattern() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let referenceDate = makeDate(year: 2026, month: 6, day: 8, calendar: calendar)
        let expenses = [
            Expense(title: "May Dinner", category: .food, amount: 90, date: makeDate(year: 2026, month: 5, day: 12, calendar: calendar)),
            Expense(title: "Concert", category: .fun, amount: 70, date: makeDate(year: 2026, month: 6, day: 2, calendar: calendar)),
            Expense(title: "Games", category: .fun, amount: 60, date: makeDate(year: 2026, month: 6, day: 3, calendar: calendar)),
            Expense(title: "Bar", category: .fun, amount: 50, date: makeDate(year: 2026, month: 6, day: 4, calendar: calendar))
        ]

        let evaluation = BudgetStore.evaluateBudgetDiscipline(
            monthlyBudget: 100,
            expenses: expenses,
            calendar: calendar,
            referenceDate: referenceDate
        )

        XCTAssertEqual(evaluation.rank, .pawn)
        XCTAssertFalse(evaluation.isSparseData)
    }

    private func makeDate(year: Int, month: Int, day: Int, calendar: Calendar) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }
}

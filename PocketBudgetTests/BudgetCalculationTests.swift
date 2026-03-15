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

    func testRemainingBudgetSubtractsOnlyCurrentMonthExpenses() {
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

        XCTAssertEqual(remaining, 237.5, accuracy: 0.001)
    }

    private func makeDate(year: Int, month: Int, day: Int, calendar: Calendar) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }
}

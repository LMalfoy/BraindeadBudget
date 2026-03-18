/*
 Unit tests for persistence-oriented store behavior.

 These tests check that `BudgetStore` correctly creates, updates, and deletes
 SwiftData records for settings, income, recurring costs, and expenses.

 Compared to `BudgetCalculationTests`, these tests are more about storage and
 side effects than about pure numeric calculation.
 */

import SwiftData
import XCTest
@testable import PocketBudget

@MainActor
final class BudgetStoreTests: XCTestCase {
    func testSaveSettingsKeepsSingleSettingsRecord() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let store = BudgetStore(context: context)

        try store.saveSettings(
            currencyCode: "USD",
            budgetPeriodAnchorDay: nil,
            initialAvailableBudget: 400,
            initialBudgetAnchorMonth: Date(timeIntervalSince1970: 0)
        )
        try store.saveSettings(currencyCode: "EUR")

        let budgets = try context.fetch(FetchDescriptor<BudgetSettings>())

        XCTAssertEqual(budgets.count, 1)
        XCTAssertEqual(budgets.first?.currencyCode, "EUR")
        XCTAssertEqual(budgets.first?.initialAvailableBudget, 400)
    }

    func testSaveIncomeItemUpdatesExistingRecord() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let store = BudgetStore(context: context)

        try store.saveIncomeItem(name: "Salary", amount: 3000)

        let original = try XCTUnwrap(context.fetch(FetchDescriptor<IncomeItem>()).first)

        try store.saveIncomeItem(id: original.id, name: "Main Salary", amount: 3200)

        let incomeItems = try context.fetch(FetchDescriptor<IncomeItem>())

        XCTAssertEqual(incomeItems.count, 1)
        XCTAssertEqual(incomeItems.first?.name, "Main Salary")
        XCTAssertEqual(incomeItems.first?.amount, 3200)
    }

    func testDeleteRecurringExpenseItemRemovesRecord() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let store = BudgetStore(context: context)

        try store.saveRecurringExpenseItem(name: "Rent", amount: 1200)

        let recurringItem = try XCTUnwrap(context.fetch(FetchDescriptor<RecurringExpenseItem>()).first)

        try store.deleteRecurringExpenseItem(recurringItem)

        let recurringItems = try context.fetch(FetchDescriptor<RecurringExpenseItem>())

        XCTAssertTrue(recurringItems.isEmpty)
    }

    func testSaveRecurringExpenseItemPersistsCategory() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let store = BudgetStore(context: context)

        try store.saveRecurringExpenseItem(
            name: "Rent",
            amount: 1200,
            category: .housingUtilities
        )

        let recurringItem = try XCTUnwrap(context.fetch(FetchDescriptor<RecurringExpenseItem>()).first)

        XCTAssertEqual(recurringItem.category, .housingUtilities)
    }

    func testAddExpensePersistsExpense() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let store = BudgetStore(context: context)

        try store.addExpense(
            title: "Groceries",
            category: .food,
            amount: 42.5,
            date: .now,
            note: "Weekly shop"
        )

        let expenses = try context.fetch(FetchDescriptor<Expense>())

        XCTAssertEqual(expenses.count, 1)
        XCTAssertEqual(expenses.first?.title, "Groceries")
        XCTAssertEqual(expenses.first?.category, .food)
        XCTAssertEqual(expenses.first?.amount, 42.5)
        XCTAssertEqual(expenses.first?.note, "Weekly shop")
    }

    func testEraseAllDataClearsPersistedModels() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let store = BudgetStore(context: context)

        try store.saveSettings(currencyCode: "USD")
        try store.saveIncomeItem(name: "Salary", amount: 3000)
        try store.saveRecurringExpenseItem(name: "Rent", amount: 1200)
        try store.addExpense(title: "Coffee", category: .food, amount: 5.5)
        context.insert(AchievementUnlock(achievementID: BudgetAchievementID.firstStep.rawValue))
        try context.save()

        try store.eraseAllData()

        XCTAssertTrue(try context.fetch(FetchDescriptor<BudgetSettings>()).isEmpty)
        XCTAssertTrue(try context.fetch(FetchDescriptor<IncomeItem>()).isEmpty)
        XCTAssertTrue(try context.fetch(FetchDescriptor<RecurringExpenseItem>()).isEmpty)
        XCTAssertTrue(try context.fetch(FetchDescriptor<Expense>()).isEmpty)
        XCTAssertTrue(try context.fetch(FetchDescriptor<AchievementUnlock>()).isEmpty)
    }

    func testDeleteExpenseRemovesRecord() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let store = BudgetStore(context: context)

        try store.addExpense(
            title: "Coffee",
            category: .food,
            amount: 5.5,
            date: .now,
            note: ""
        )

        let expense = try XCTUnwrap(context.fetch(FetchDescriptor<Expense>()).first)

        try store.deleteExpense(expense)

        let expenses = try context.fetch(FetchDescriptor<Expense>())

        XCTAssertTrue(expenses.isEmpty)
    }

    func testUpdateExpensePersistsEditedValues() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let store = BudgetStore(context: context)

        try store.addExpense(
            title: "Coffee",
            category: .food,
            amount: 5.5,
            date: .now,
            note: ""
        )

        let expense = try XCTUnwrap(context.fetch(FetchDescriptor<Expense>()).first)

        try store.updateExpense(
            expense,
            title: "Train Ticket",
            category: .transport,
            amount: 14,
            date: .now.addingTimeInterval(-86400),
            note: "Edited"
        )

        let updatedExpense = try XCTUnwrap(context.fetch(FetchDescriptor<Expense>()).first)

        XCTAssertEqual(updatedExpense.title, "Train Ticket")
        XCTAssertEqual(updatedExpense.category, .transport)
        XCTAssertEqual(updatedExpense.amount, 14)
        XCTAssertEqual(updatedExpense.note, "Edited")
    }

    func testSyncAchievementsDoesNotCreateDuplicateUnlocks() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let store = BudgetStore(context: context)

        try store.saveSettings(
            currencyCode: "USD",
            budgetPeriodAnchorDay: nil,
            initialAvailableBudget: 1800,
            initialBudgetAnchorMonth: Date(timeIntervalSince1970: 0)
        )
        try store.saveIncomeItem(name: "Salary", amount: 3000)
        try store.saveRecurringExpenseItem(name: "Rent", amount: 1200)
        try store.addExpense(title: "Coffee", category: .food, amount: 5.5)

        let incomes = try context.fetch(FetchDescriptor<IncomeItem>())
        let recurring = try context.fetch(FetchDescriptor<RecurringExpenseItem>())
        let expenses = try context.fetch(FetchDescriptor<Expense>())

        let firstRunUnlocks = try store.syncAchievements(
            hasCompletedSetup: true,
            incomeItems: incomes,
            recurringExpenseItems: recurring,
            expenses: expenses,
            initialAvailableBudget: 1800,
            initialBudgetAnchorMonth: Date(timeIntervalSince1970: 0)
        )
        let secondRunUnlocks = try store.syncAchievements(
            hasCompletedSetup: true,
            incomeItems: incomes,
            recurringExpenseItems: recurring,
            expenses: expenses,
            initialAvailableBudget: 1800,
            initialBudgetAnchorMonth: Date(timeIntervalSince1970: 0)
        )

        XCTAssertFalse(firstRunUnlocks.isEmpty)
        XCTAssertTrue(secondRunUnlocks.isEmpty)
        XCTAssertEqual(try context.fetch(FetchDescriptor<AchievementUnlock>()).count, firstRunUnlocks.count)
    }

    private func makeContainer() throws -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: BudgetSettings.self,
            Expense.self,
            IncomeItem.self,
            RecurringExpenseItem.self,
            AchievementUnlock.self,
            configurations: configuration
        )
    }
}

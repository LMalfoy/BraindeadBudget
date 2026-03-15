import SwiftData
import XCTest
@testable import PocketBudget

@MainActor
final class BudgetStoreTests: XCTestCase {
    func testSaveSettingsKeepsSingleSettingsRecord() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let store = BudgetStore(context: context)

        try store.saveSettings(currencyCode: "USD")
        try store.saveSettings(currencyCode: "EUR")

        let budgets = try context.fetch(FetchDescriptor<BudgetSettings>())

        XCTAssertEqual(budgets.count, 1)
        XCTAssertEqual(budgets.first?.currencyCode, "EUR")
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

    private func makeContainer() throws -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: BudgetSettings.self,
            Expense.self,
            IncomeItem.self,
            RecurringExpenseItem.self,
            configurations: configuration
        )
    }
}

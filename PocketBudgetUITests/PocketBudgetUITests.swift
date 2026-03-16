import XCTest

final class PocketBudgetUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testUserCanCompleteSetupAndAddExpense() throws {
        let app = XCUIApplication()
        launchAndCompleteBudgetSetup(in: app)
        addExpense(named: "Coffee", amount: "5.50", categoryIdentifier: "food", in: app)

        XCTAssertTrue(app.staticTexts["Coffee"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["dashboard.remainingBudgetValue"].waitForExistence(timeout: 2))
    }

    func testUserCanDeleteExpenseFromDashboard() throws {
        let app = XCUIApplication()
        launchAndCompleteBudgetSetup(in: app)
        addExpense(named: "Coffee", amount: "5.50", categoryIdentifier: "food", in: app)

        let coffeeText = app.staticTexts["Coffee"]
        XCTAssertTrue(coffeeText.waitForExistence(timeout: 2))

        coffeeText.swipeLeft()
        app.buttons["Delete"].tap()

        XCTAssertFalse(coffeeText.waitForExistence(timeout: 1))
    }

    func testUserCanOpenSettingsAndManageBudget() throws {
        let app = XCUIApplication()
        launchAndCompleteBudgetSetup(in: app)

        let settingsButton = app.buttons["dashboard.settingsButton"].firstMatch
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
        settingsButton.tap()

        let manageBudgetButton = app.buttons["settings.manageBudgetButton"].firstMatch
        XCTAssertTrue(manageBudgetButton.waitForExistence(timeout: 5))
        manageBudgetButton.tap()

        let finishButton = app.buttons["budgetSetup.finishButton"].firstMatch
        XCTAssertTrue(finishButton.waitForExistence(timeout: 5))
    }

    func testUserCanOpenExpenseHistory() throws {
        let app = XCUIApplication()
        launchAndCompleteBudgetSetup(in: app)
        addExpense(named: "Coffee", amount: "5.50", categoryIdentifier: "food", in: app)

        let historyButton = app.buttons["dashboard.expenseHistoryButton"].firstMatch
        XCTAssertTrue(historyButton.waitForExistence(timeout: 5))
        historyButton.tap()

        let monthLabel = app.staticTexts["history.monthLabel"].firstMatch
        XCTAssertTrue(monthLabel.waitForExistence(timeout: 5))

        let previousMonthButton = app.buttons["history.previousMonthButton"].firstMatch
        XCTAssertTrue(previousMonthButton.waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["history.nextMonthButton"].firstMatch.waitForExistence(timeout: 5))
    }

    private func launchAndCompleteBudgetSetup(in app: XCUIApplication) {
        app.launchArguments.append("-ui-testing")
        app.launch()

        let addIncomeButton = app.buttons["budgetSetup.addIncomeButton"].firstMatch
        XCTAssertTrue(addIncomeButton.waitForExistence(timeout: 5))
        addIncomeButton.tap()

        let nameField = app.textFields["baselineItem.nameField"].firstMatch
        XCTAssertTrue(nameField.waitForExistence(timeout: 5))
        nameField.tap()
        nameField.typeText("Salary")

        let amountField = app.textFields["baselineItem.amountField"].firstMatch
        XCTAssertTrue(amountField.waitForExistence(timeout: 5))
        amountField.tap()
        amountField.typeText("1000")

        let saveButton = app.buttons["baselineItem.saveButton"].firstMatch
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5))
        saveButton.tap()

        let finishButton = app.buttons["budgetSetup.finishButton"].firstMatch
        XCTAssertTrue(finishButton.waitForExistence(timeout: 5))
        finishButton.tap()
    }

    private func addExpense(
        named title: String,
        amount: String,
        categoryIdentifier: String,
        in app: XCUIApplication
    ) {
        let addExpenseButton = app.buttons["dashboard.addExpenseButton"].firstMatch
        XCTAssertTrue(addExpenseButton.waitForExistence(timeout: 5))
        addExpenseButton.tap()

        let categoryButton = app.buttons["addExpense.category.\(categoryIdentifier)"].firstMatch
        XCTAssertTrue(categoryButton.waitForExistence(timeout: 5))
        categoryButton.tap()

        let titleField = app.textFields["addExpense.titleField"].firstMatch
        XCTAssertTrue(titleField.waitForExistence(timeout: 5))
        titleField.tap()
        titleField.typeText(title)

        let amountField = app.textFields["addExpense.amountField"].firstMatch
        XCTAssertTrue(amountField.waitForExistence(timeout: 5))
        amountField.tap()
        amountField.typeText(amount)

        let saveButton = app.buttons["addExpense.saveButton"].firstMatch
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5))
        saveButton.tap()
    }
}

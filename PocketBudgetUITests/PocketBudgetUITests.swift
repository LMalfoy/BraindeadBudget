import XCTest

final class PocketBudgetUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testUserCanCompleteSetupAndAddExpense() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-ui-testing")
        app.launch()

        let addIncomeButton = app.buttons["budgetSetup.addIncomeButton"]
        XCTAssertTrue(addIncomeButton.waitForExistence(timeout: 2))
        addIncomeButton.tap()

        let nameField = app.textFields["baselineItem.nameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("Salary")

        let setupAmountField = app.textFields["baselineItem.amountField"]
        setupAmountField.tap()
        setupAmountField.typeText("1000")
        app.buttons["baselineItem.saveButton"].tap()

        app.buttons["budgetSetup.finishButton"].tap()

        app.buttons["dashboard.addExpenseButton"].tap()

        let categoryButton = app.buttons["addExpense.category.food"]
        XCTAssertTrue(categoryButton.waitForExistence(timeout: 2))
        categoryButton.tap()

        let titleField = app.textFields["addExpense.titleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("Coffee")

        let amountField = app.textFields["addExpense.amountField"]
        amountField.tap()
        amountField.typeText("5.50")

        app.buttons["addExpense.saveButton"].tap()

        XCTAssertTrue(app.staticTexts["Coffee"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["dashboard.remainingBudgetValue"].waitForExistence(timeout: 2))
    }
}

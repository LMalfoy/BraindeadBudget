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

    func testUserCanDeleteExpenseFromHistory() throws {
        let app = XCUIApplication()
        launchAndCompleteBudgetSetup(in: app)
        addExpense(named: "Coffee", amount: "5.50", categoryIdentifier: "food", in: app)

        app.tabBars.buttons["History"].tap()

        let coffeeText = app.staticTexts["Coffee"]
        XCTAssertTrue(coffeeText.waitForExistence(timeout: 2))

        coffeeText.swipeLeft()
        app.buttons["Delete"].tap()

        XCTAssertFalse(coffeeText.waitForExistence(timeout: 1))
    }

    func testUserCanOpenSettingsAndManageBudget() throws {
        let app = XCUIApplication()
        launchAndCompleteBudgetSetup(in: app)

        let settingsButton = app.tabBars.buttons["Settings"].firstMatch
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
        settingsButton.tap()

        let manageBudgetButton = app.buttons["settings.manageBudgetButton"].firstMatch
        XCTAssertTrue(manageBudgetButton.waitForExistence(timeout: 5))
        manageBudgetButton.tap()

        let finishButton = app.buttons["budgetSetup.finishButton"].firstMatch
        XCTAssertTrue(finishButton.waitForExistence(timeout: 5))
    }

    func testUserCanOpenStatsArea() throws {
        let app = XCUIApplication()
        launchAndCompleteBudgetSetup(in: app)
        addExpense(named: "Coffee", amount: "5.50", categoryIdentifier: "food", in: app)

        let statsButton = app.tabBars.buttons["Stats"].firstMatch
        XCTAssertTrue(statsButton.waitForExistence(timeout: 5))
        statsButton.tap()

        XCTAssertTrue(app.staticTexts["Total Spending"].firstMatch.waitForExistence(timeout: 5))
    }

    func testStatsAreaShowsBudgetTrajectory() throws {
        let app = XCUIApplication()
        launchAndCompleteBudgetSetup(in: app)
        addExpense(named: "Coffee", amount: "5.50", categoryIdentifier: "food", in: app)

        let statsButton = app.tabBars.buttons["Stats"].firstMatch
        XCTAssertTrue(statsButton.waitForExistence(timeout: 5))
        statsButton.tap()
        app.buttons["Budget Spending"].firstMatch.tap()

        XCTAssertTrue(app.otherElements["stats.trajectoryModule"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["You still have strong budget room for the rest of the month."].firstMatch.waitForExistence(timeout: 5))
    }

    func testStatsAreaShowsTemporalPattern() throws {
        let app = XCUIApplication()
        launchAndCompleteBudgetSetup(in: app)
        addExpense(named: "Coffee", amount: "5.50", categoryIdentifier: "food", in: app)

        let statsButton = app.tabBars.buttons["Stats"].firstMatch
        XCTAssertTrue(statsButton.waitForExistence(timeout: 5))
        statsButton.tap()
        app.buttons["Budget Spending"].firstMatch.tap()
        app.swipeUp()
        app.swipeUp()

        XCTAssertTrue(app.staticTexts["Spending Pattern"].firstMatch.waitForExistence(timeout: 5))
    }

    func testStatsAreaShowsMonthComparison() throws {
        let app = XCUIApplication()
        launchAndCompleteBudgetSetup(in: app)
        addExpense(named: "Coffee", amount: "5.50", categoryIdentifier: "food", in: app)

        let statsButton = app.tabBars.buttons["Stats"].firstMatch
        XCTAssertTrue(statsButton.waitForExistence(timeout: 5))
        statsButton.tap()
        app.buttons["Budget Spending"].firstMatch.tap()
        app.swipeUp()
        app.swipeUp()

        XCTAssertTrue(app.staticTexts["Month Comparison"].firstMatch.waitForExistence(timeout: 5))
    }

    func testStatsAreaShowsCarryoverModule() throws {
        let app = XCUIApplication()
        launchAndCompleteBudgetSetup(in: app)
        addExpense(named: "Coffee", amount: "5.50", categoryIdentifier: "food", in: app)

        let statsButton = app.tabBars.buttons["Stats"].firstMatch
        XCTAssertTrue(statsButton.waitForExistence(timeout: 5))
        statsButton.tap()
        app.buttons["Budget Spending"].firstMatch.tap()

        XCTAssertTrue(app.staticTexts["Carryover"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.otherElements["stats.carryoverModule"].firstMatch.waitForExistence(timeout: 5))
    }

    func testStatsAreaShowsBudgetProgression() throws {
        let app = XCUIApplication()
        launchAndCompleteBudgetSetup(in: app)
        addExpense(named: "Coffee", amount: "5.50", categoryIdentifier: "food", in: app)

        let statsButton = app.tabBars.buttons["Stats"].firstMatch
        XCTAssertTrue(statsButton.waitForExistence(timeout: 5))
        statsButton.tap()

        XCTAssertTrue(app.staticTexts["Budget Progression"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Pawn I"].firstMatch.waitForExistence(timeout: 5))
    }

    func testUserCanSwitchStatsPerspective() throws {
        let app = XCUIApplication()
        launchAndCompleteBudgetSetup(in: app)

        let statsButton = app.tabBars.buttons["Stats"].firstMatch
        XCTAssertTrue(statsButton.waitForExistence(timeout: 5))
        statsButton.tap()

        let recurringSpendingButton = app.buttons["Recurring Spending"].firstMatch
        XCTAssertTrue(recurringSpendingButton.waitForExistence(timeout: 5))
        recurringSpendingButton.tap()

        XCTAssertTrue(app.staticTexts["Fixed Cost Ratio"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Fixed Cost Distribution"].firstMatch.waitForExistence(timeout: 5))
    }

    func testTotalSpendingShowsFixedCostModules() throws {
        let app = XCUIApplication()
        launchAndCompleteBudgetSetup(in: app)

        app.tabBars.buttons["Settings"].tap()
        let manageBudgetButton = app.buttons["settings.manageBudgetButton"].firstMatch
        XCTAssertTrue(manageBudgetButton.waitForExistence(timeout: 5))
        manageBudgetButton.tap()

        let addRecurringButton = app.buttons["budgetSetup.addRecurringButton"].firstMatch
        XCTAssertTrue(addRecurringButton.waitForExistence(timeout: 5))
        addRecurringButton.tap()

        let nameField = app.textFields["baselineItem.nameField"].firstMatch
        XCTAssertTrue(nameField.waitForExistence(timeout: 5))
        nameField.tap()
        nameField.typeText("Rent")

        let housingTile = app.buttons["baselineItem.recurringCategory.housingUtilities"].firstMatch
        XCTAssertTrue(housingTile.waitForExistence(timeout: 5))
        housingTile.tap()

        let amountField = app.textFields["baselineItem.amountField"].firstMatch
        XCTAssertTrue(amountField.waitForExistence(timeout: 5))
        amountField.tap()
        amountField.typeText("1200")

        let saveButton = app.buttons["baselineItem.saveButton"].firstMatch
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5))
        saveButton.tap()

        app.buttons["Close"].tap()

        app.tabBars.buttons["Stats"].tap()
        app.buttons["Recurring Spending"].firstMatch.tap()

        XCTAssertTrue(app.staticTexts["Fixed Cost Ratio"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Fixed Cost Distribution"].firstMatch.waitForExistence(timeout: 5))
    }

    func testTotalSpendingShowsSubscriptionAndSavingsModules() throws {
        let app = XCUIApplication()
        launchAndCompleteBudgetSetup(in: app)

        app.tabBars.buttons["Settings"].tap()
        let manageBudgetButton = app.buttons["settings.manageBudgetButton"].firstMatch
        XCTAssertTrue(manageBudgetButton.waitForExistence(timeout: 5))
        manageBudgetButton.tap()

        addRecurringCost(named: "Netflix", amount: "20", categoryIdentifier: "subscriptions", in: app)
        addRecurringCost(named: "Savings", amount: "300", categoryIdentifier: "savings", in: app)

        app.buttons["Close"].tap()

        app.tabBars.buttons["Stats"].tap()
        app.buttons["Recurring Spending"].firstMatch.tap()
        app.swipeUp()

        XCTAssertTrue(app.staticTexts["Subscription Load"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Savings Stability"].firstMatch.waitForExistence(timeout: 5))
    }

    func testUserCanOpenExpenseHistory() throws {
        let app = XCUIApplication()
        launchAndCompleteBudgetSetup(in: app)
        addExpense(named: "Coffee", amount: "5.50", categoryIdentifier: "food", in: app)

        let historyButton = app.tabBars.buttons["History"].firstMatch
        XCTAssertTrue(historyButton.waitForExistence(timeout: 5))
        historyButton.tap()

        let monthLabel = app.buttons["history.monthLabel"].firstMatch
        XCTAssertTrue(monthLabel.waitForExistence(timeout: 5))

        let previousMonthButton = app.buttons["history.previousMonthButton"].firstMatch
        XCTAssertTrue(previousMonthButton.waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["history.nextMonthButton"].firstMatch.waitForExistence(timeout: 5))
    }

    func testUserCanSelectMonthFromHistoryHeader() throws {
        let app = XCUIApplication()
        launchAndCompleteBudgetSetup(in: app)
        app.tabBars.buttons["History"].tap()

        let monthLabelButton = app.buttons["history.monthLabel"].firstMatch
        XCTAssertTrue(monthLabelButton.waitForExistence(timeout: 5))
        monthLabelButton.tap()

        let doneButton = app.buttons["history.monthPicker.doneButton"].firstMatch
        XCTAssertTrue(doneButton.waitForExistence(timeout: 5))
        XCTAssertTrue(app.navigationBars["Select Month"].firstMatch.waitForExistence(timeout: 5))
        doneButton.tap()

        XCTAssertTrue(monthLabelButton.waitForExistence(timeout: 5))
    }

    func testHistoryMonthNavigationWorksForEmptyMonths() throws {
        let app = XCUIApplication()
        launchAndCompleteBudgetSetup(in: app)
        app.tabBars.buttons["History"].tap()

        let monthLabelButton = app.buttons["history.monthLabel"].firstMatch
        XCTAssertTrue(monthLabelButton.waitForExistence(timeout: 5))
        let initialLabel = monthLabelButton.label

        let nextMonthButton = app.buttons["history.nextMonthButton"].firstMatch
        XCTAssertTrue(nextMonthButton.waitForExistence(timeout: 5))
        nextMonthButton.tap()

        XCTAssertNotEqual(monthLabelButton.label, initialLabel)
    }

    func testUserCanSubmitExpenseFromAmountField() throws {
        let app = XCUIApplication()
        launchAndCompleteBudgetSetup(in: app)

        let addExpenseButton = app.buttons["dashboard.addExpenseButton"].firstMatch
        XCTAssertTrue(addExpenseButton.waitForExistence(timeout: 5))
        addExpenseButton.tap()

        let titleField = app.textFields["addExpense.titleField"].firstMatch
        XCTAssertTrue(titleField.waitForExistence(timeout: 5))
        titleField.tap()
        titleField.typeText("Tea")

        let amountField = app.textFields["addExpense.amountField"].firstMatch
        XCTAssertTrue(amountField.waitForExistence(timeout: 5))
        amountField.tap()
        amountField.typeText("3.50\n")

        XCTAssertTrue(app.staticTexts["Tea"].waitForExistence(timeout: 5))
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

        let initialAvailableBudgetField = app.textFields["budgetSetup.initialAvailableBudgetField"].firstMatch
        XCTAssertTrue(initialAvailableBudgetField.waitForExistence(timeout: 5))
        initialAvailableBudgetField.tap()
        initialAvailableBudgetField.typeText("500")

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

    private func addRecurringCost(
        named title: String,
        amount: String,
        categoryIdentifier: String,
        in app: XCUIApplication
    ) {
        let addRecurringButton = app.buttons["budgetSetup.addRecurringButton"].firstMatch
        XCTAssertTrue(addRecurringButton.waitForExistence(timeout: 5))
        addRecurringButton.tap()

        let nameField = app.textFields["baselineItem.nameField"].firstMatch
        XCTAssertTrue(nameField.waitForExistence(timeout: 5))
        nameField.tap()
        nameField.typeText(title)

        let categoryButton = app.buttons["baselineItem.recurringCategory.\(categoryIdentifier)"].firstMatch
        XCTAssertTrue(categoryButton.waitForExistence(timeout: 5))
        categoryButton.tap()

        let amountField = app.textFields["baselineItem.amountField"].firstMatch
        XCTAssertTrue(amountField.waitForExistence(timeout: 5))
        amountField.tap()
        amountField.typeText(amount)

        let saveButton = app.buttons["baselineItem.saveButton"].firstMatch
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5))
        saveButton.tap()
    }
}

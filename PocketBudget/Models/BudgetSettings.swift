/*
 Persistent app-wide budgeting settings.

 This model stores the "global state" for budgeting, for example:
 - selected currency
 - chosen budget period anchor day
 - the initial available budget entered during first onboarding
 - the month/period that initial budget anchor belongs to

 The app keeps only one logical settings record and updates it over time.
 That is why many screens query `budgets.first`.
 */

import Foundation
import SwiftData

@Model
final class BudgetSettings {
    @Attribute(.unique) var id: UUID
    var monthlyBudget: Double
    var currencyCode: String
    var budgetPeriodAnchorDay: Int?
    var initialAvailableBudget: Double?
    var initialBudgetAnchorMonth: Date?
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        monthlyBudget: Double = 0,
        currencyCode: String = Locale.current.currency?.identifier ?? "USD",
        budgetPeriodAnchorDay: Int? = nil,
        initialAvailableBudget: Double? = nil,
        initialBudgetAnchorMonth: Date? = nil,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.monthlyBudget = monthlyBudget
        self.currencyCode = currencyCode
        self.budgetPeriodAnchorDay = budgetPeriodAnchorDay
        self.initialAvailableBudget = initialAvailableBudget
        self.initialBudgetAnchorMonth = initialBudgetAnchorMonth
        self.updatedAt = updatedAt
    }
}

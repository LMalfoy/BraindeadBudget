import Foundation
import SwiftData

@Model
final class BudgetSettings {
    @Attribute(.unique) var id: UUID
    var monthlyBudget: Double
    var currencyCode: String
    var initialAvailableBudget: Double?
    var initialBudgetAnchorMonth: Date?
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        monthlyBudget: Double = 0,
        currencyCode: String = Locale.current.currency?.identifier ?? "USD",
        initialAvailableBudget: Double? = nil,
        initialBudgetAnchorMonth: Date? = nil,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.monthlyBudget = monthlyBudget
        self.currencyCode = currencyCode
        self.initialAvailableBudget = initialAvailableBudget
        self.initialBudgetAnchorMonth = initialBudgetAnchorMonth
        self.updatedAt = updatedAt
    }
}

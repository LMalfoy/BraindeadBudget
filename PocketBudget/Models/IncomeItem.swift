/*
 Monthly income model.

 Income is intentionally stored as one or more separate items instead of a
 single number. That keeps the setup flexible for users with multiple sources
 such as salary, freelance work, or benefits.

 `BudgetStore` later sums these items to build the monthly spending baseline.
 */

import Foundation
import SwiftData

@Model
final class IncomeItem {
    @Attribute(.unique) var id: UUID
    var name: String
    var amount: Double
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        amount: Double,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.createdAt = createdAt
    }
}

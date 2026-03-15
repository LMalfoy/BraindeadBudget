import Foundation
import SwiftData

@Model
final class RecurringExpenseItem {
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

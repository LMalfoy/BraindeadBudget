/*
 Variable day-to-day spending model.

 `Expense` represents the purchases the user records during normal usage:
 groceries, transport, fun, household spending, and so on.

 Important detail:
 - expenses are the only records that represent flexible spending behavior
 - recurring costs are stored separately in `RecurringExpenseItem`
 - statistics such as category spending, trajectory, and month comparison
   are built from these records
 */

import Foundation
import SwiftData

enum ExpenseCategory: String, CaseIterable, Codable, Identifiable {
    case food
    case transport
    case household
    case fun

    var id: String { rawValue }

    var title: String {
        switch self {
        case .food:
            return "Food"
        case .transport:
            return "Transport"
        case .household:
            return "Household"
        case .fun:
            return "Fun"
        }
    }

}

@Model
final class Expense {
    @Attribute(.unique) var id: UUID
    var title: String
    var categoryRawValue: String?
    var amount: Double
    var date: Date
    var note: String
    var createdAt: Date

    var category: ExpenseCategory {
        get { ExpenseCategory(rawValue: categoryRawValue ?? "") ?? .food }
        set { categoryRawValue = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        title: String,
        category: ExpenseCategory = .food,
        amount: Double,
        date: Date = .now,
        note: String = "",
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        categoryRawValue = category.rawValue
        self.amount = amount
        self.date = date
        self.note = note
        self.createdAt = createdAt
    }
}

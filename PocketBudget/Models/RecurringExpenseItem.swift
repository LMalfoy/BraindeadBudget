import Foundation
import SwiftData

enum RecurringExpenseCategory: String, CaseIterable, Codable, Identifiable {
    case housingUtilities
    case subscriptions
    case insurance
    case savings
    case debt

    var id: String { rawValue }

    var title: String {
        switch self {
        case .housingUtilities:
            return "Housing / Utilities"
        case .subscriptions:
            return "Abos"
        case .insurance:
            return "Insurance"
        case .savings:
            return "Savings"
        case .debt:
            return "Debt"
        }
    }
}

@Model
final class RecurringExpenseItem {
    @Attribute(.unique) var id: UUID
    var name: String
    var amount: Double
    var categoryRawValue: String?
    var createdAt: Date

    var category: RecurringExpenseCategory {
        get { RecurringExpenseCategory(rawValue: categoryRawValue ?? "") ?? .housingUtilities }
        set { categoryRawValue = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        name: String,
        amount: Double,
        category: RecurringExpenseCategory = .housingUtilities,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        categoryRawValue = category.rawValue
        self.createdAt = createdAt
    }
}

/*
 Recurring monthly cost model.

 This file represents fixed or repeating commitments such as:
 - housing / utilities
 - subscriptions
 - insurance
 - savings
 - debt

 These records are intentionally separate from normal expenses so the app can
 distinguish structural recurring costs from variable day-to-day spending.
 */

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
    var seriesID: UUID
    var name: String
    var amount: Double
    var categoryRawValue: String?
    var effectiveMonth: Date
    var isActive: Bool
    var createdAt: Date

    var category: RecurringExpenseCategory {
        get { RecurringExpenseCategory(rawValue: categoryRawValue ?? "") ?? .housingUtilities }
        set { categoryRawValue = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        seriesID: UUID? = nil,
        name: String,
        amount: Double,
        category: RecurringExpenseCategory = .housingUtilities,
        effectiveMonth: Date? = nil,
        isActive: Bool = true,
        createdAt: Date = .now
    ) {
        self.id = id
        self.seriesID = seriesID ?? id
        self.name = name
        self.amount = amount
        categoryRawValue = category.rawValue
        self.effectiveMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: effectiveMonth ?? createdAt)) ?? createdAt
        self.isActive = isActive
        self.createdAt = createdAt
    }
}

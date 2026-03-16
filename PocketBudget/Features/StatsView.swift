import Charts
import Foundation
import SwiftData
import SwiftUI

struct StatsView: View {
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @Query(sort: \BudgetSettings.updatedAt, order: .reverse) private var budgets: [BudgetSettings]

    private var currencyCode: String {
        budgets.first?.currencyCode ?? Locale.current.currency?.identifier ?? "USD"
    }

    private var categorySpending: [CategorySpendingSummary] {
        BudgetStore.categorySpending(for: expenses)
    }

    private var topCategory: CategorySpendingSummary? {
        BudgetStore.topSpendingCategory(for: expenses)
    }

    private var interpretation: String {
        guard let topCategory else {
            return "Add a few expenses to start seeing your spending behavior."
        }

        return "\(topCategory.category.title) is your largest spending category this month."
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Spending by Category")
                        .font(.headline)

                    if categorySpending.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("No category data yet for this month.")
                                .foregroundStyle(.secondary)

                            Text(interpretation)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .accessibilityIdentifier("stats.categoryInterpretation")
                        }
                    } else {
                        Chart(categorySpending) { summary in
                            SectorMark(
                                angle: .value("Amount", summary.total),
                                innerRadius: .ratio(0.58),
                                angularInset: 2
                            )
                            .foregroundStyle(summary.category.color)
                        }
                        .chartLegend(.hidden)
                        .frame(height: 220)
                        .accessibilityIdentifier("stats.categoryChart")

                        Text(interpretation)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                            .accessibilityIdentifier("stats.categoryInterpretation")

                        VStack(spacing: 10) {
                            ForEach(categorySpending) { summary in
                                HStack(spacing: 10) {
                                    Circle()
                                        .fill(summary.category.color)
                                        .frame(width: 10, height: 10)

                                    Text(summary.category.title)
                                        .foregroundStyle(.primary)

                                    Spacer()

                                    Text(summary.total.formatted(.currency(code: currencyCode)))
                                        .fontWeight(.medium)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                .statsCardStyle()
                .accessibilityIdentifier("stats.categoryModule")
            }
        }
        .navigationTitle("Stats")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension ExpenseCategory {
    var color: Color {
        switch self {
        case .food:
            return .green
        case .transport:
            return .blue
        case .household:
            return .orange
        case .fun:
            return .pink
        }
    }
}

private extension View {
    func statsCardStyle() -> some View {
        padding(18)
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

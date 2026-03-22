/*
 Long-term trends view.

 This screen stays intentionally focused on recent multi-month movement rather
 than current-month detail.
 */

import Charts
import Foundation
import SwiftData
import SwiftUI

struct StatsView: View {
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @Query(sort: \BudgetSettings.updatedAt, order: .reverse) private var budgets: [BudgetSettings]
    @Query(sort: \IncomeItem.createdAt) private var incomeItems: [IncomeItem]
    @Query(sort: \RecurringExpenseItem.createdAt) private var recurringExpenseItems: [RecurringExpenseItem]

    private let monthWindow = 6

    private var currencyCode: String {
        budgets.first?.currencyCode ?? Locale.current.currency?.identifier ?? "USD"
    }

    private var initialAvailableBudget: Double? {
        budgets.first?.initialAvailableBudget
    }

    private var initialBudgetAnchorMonth: Date? {
        budgets.first?.initialBudgetAnchorMonth
    }

    private var budgetPeriodAnchorDay: Int {
        budgets.first?.budgetPeriodAnchorDay ?? 1
    }

    private var monthlyBudget: Double {
        BudgetStore.availableMonthlyBudget(
            incomeItems: incomeItems,
            recurringExpenseItems: recurringExpenseItems
        )
    }

    private var monthlySpendingHistory: [MonthlySpendingPoint] {
        BudgetStore.monthComparisonHistory(
            for: expenses,
            months: monthWindow,
            budgetPeriodAnchorDay: budgetPeriodAnchorDay
        )
    }

    private var carryoverHistory: [CarryoverHistoryPoint] {
        BudgetStore.carryoverHistory(
            monthlyBudget: monthlyBudget,
            expenses: expenses,
            budgetPeriodAnchorDay: budgetPeriodAnchorDay,
            initialAvailableBudget: initialAvailableBudget,
            initialBudgetAnchorMonth: initialBudgetAnchorMonth,
            months: monthWindow
        )
    }

    private var categoryTrendHistory: [CategoryTrendPoint] {
        BudgetStore.categoryTrendHistory(
            for: expenses,
            months: monthWindow,
            budgetPeriodAnchorDay: budgetPeriodAnchorDay
        )
    }

    private var recurringTotal: Double {
        recurringExpenseItems.reduce(0) { $0 + $1.amount }
    }

    private var subscriptionLoad: SubscriptionLoadSummary {
        BudgetStore.subscriptionLoad(for: recurringExpenseItems)
    }

    private var fixedCostRatio: FixedCostRatioSummary {
        BudgetStore.fixedCostRatio(
            incomeItems: incomeItems,
            recurringExpenseItems: recurringExpenseItems
        )
    }

    var body: some View {
        List {
            Section {
                monthlySpendingCard
            }

            Section {
                carryoverCard
            }

            if !categoryTrendHistory.isEmpty {
                Section {
                    categoryTrendCard
                }
            }

            Section {
                recurringLoadCard
            }
        }
        .contentMargins(.top, 0, for: .scrollContent)
        .navigationTitle("Trends")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var monthlySpendingCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Monthly Spending")
                .font(.headline)

            if monthlySpendingHistory.allSatisfy({ $0.total == 0 }) {
                Text("Add more monthly history to see spending trends over time.")
                    .foregroundStyle(.secondary)
            } else {
                Chart(monthlySpendingHistory) { point in
                    BarMark(
                        x: .value("Month", point.month, unit: .month),
                        y: .value("Spent", point.total)
                    )
                    .foregroundStyle(.blue.gradient)
                }
                .frame(height: 220)

                Text("Last \(monthWindow) months of total monthly spending.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .trendsCardStyle()
    }

    private var carryoverCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Remaining Budget / Carryover")
                .font(.headline)

            if carryoverHistory.allSatisfy({ $0.amount == 0 }) {
                Text("Carryover appears here once previous months start ending above or below budget.")
                    .foregroundStyle(.secondary)
            } else {
                Chart(carryoverHistory) { point in
                    LineMark(
                        x: .value("Month", point.month, unit: .month),
                        y: .value("Carryover", point.amount)
                    )
                    .foregroundStyle(.green)

                    AreaMark(
                        x: .value("Month", point.month, unit: .month),
                        y: .value("Carryover", point.amount)
                    )
                    .foregroundStyle(.green.opacity(0.12))
                }
                .frame(height: 220)

                Text("Positive values mean budget room carried into the next month.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .trendsCardStyle()
    }

    private var categoryTrendCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category Trends")
                .font(.headline)

            Chart(categoryTrendHistory) { point in
                LineMark(
                    x: .value("Month", point.month, unit: .month),
                    y: .value("Amount", point.total),
                    series: .value("Category", point.category.title)
                )
                .foregroundStyle(point.category.color)
            }
            .frame(height: 220)

            VStack(spacing: 10) {
                ForEach(ExpenseCategory.allCases) { category in
                    HStack(spacing: 10) {
                        Circle()
                            .fill(category.color)
                            .frame(width: 10, height: 10)

                        Text(category.title)
                            .foregroundStyle(.primary)

                        Spacer()
                    }
                }
            }
        }
        .trendsCardStyle()
    }

    private var recurringLoadCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recurring Load")
                .font(.headline)

            VStack(spacing: 10) {
                recurringRow(title: "Current Monthly Recurring", value: recurringTotal.formatted(.currency(code: currencyCode)))
                recurringRow(title: "Subscriptions", value: "\(subscriptionLoad.count)")
                recurringRow(title: "Subscription Cost", value: subscriptionLoad.totalMonthlyCost.formatted(.currency(code: currencyCode)))
                recurringRow(
                    title: "Recurring Share of Income",
                    value: fixedCostRatio.recurringShare.formatted(.percent.precision(.fractionLength(0)))
                )
            }

            Text("Recurring items are structural costs. Historical recurring-load tracking is kept lightweight until the data model supports true change history.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .trendsCardStyle()
    }

    @ViewBuilder
    private func recurringRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
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
    func trendsCardStyle() -> some View {
        padding(18)
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

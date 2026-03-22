/*
 Long-term trends view.

 This screen answers one question:
 how has financial behavior changed across the last six months?
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

    private var variableSpendingHistory: [MonthlySpendingPoint] {
        BudgetStore.spendingHistory(
            for: expenses,
            recurringExpenseItems: recurringExpenseItems,
            kind: .variable,
            months: monthWindow,
            budgetPeriodAnchorDay: budgetPeriodAnchorDay
        )
    }

    private var recurringSpendingHistory: [MonthlySpendingPoint] {
        BudgetStore.spendingHistory(
            for: expenses,
            recurringExpenseItems: recurringExpenseItems,
            kind: .recurring,
            months: monthWindow,
            budgetPeriodAnchorDay: budgetPeriodAnchorDay
        )
    }

    private var totalSpendingHistory: [MonthlySpendingPoint] {
        BudgetStore.spendingHistory(
            for: expenses,
            recurringExpenseItems: recurringExpenseItems,
            kind: .total,
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

    private var variableCategoryTrendHistory: [NamedCategoryTrendPoint] {
        BudgetStore.categoryTrendHistory(
            for: expenses,
            months: monthWindow,
            budgetPeriodAnchorDay: budgetPeriodAnchorDay
        ).map {
            NamedCategoryTrendPoint(
                month: $0.month,
                categoryKey: $0.category.rawValue,
                categoryTitle: $0.category.title,
                colorName: $0.category.rawValue,
                total: $0.total
            )
        }
    }

    private var recurringCategoryTrendHistory: [NamedCategoryTrendPoint] {
        BudgetStore.recurringCategoryTrendHistory(
            recurringExpenseItems: recurringExpenseItems,
            months: monthWindow,
            budgetPeriodAnchorDay: budgetPeriodAnchorDay
        )
    }

    private var totalCategoryTrendHistory: [NamedCategoryTrendPoint] {
        BudgetStore.totalCategoryTrendHistory(
            expenses: expenses,
            recurringExpenseItems: recurringExpenseItems,
            months: monthWindow,
            budgetPeriodAnchorDay: budgetPeriodAnchorDay
        )
    }

    var body: some View {
        List {
            Section {
                MonthlySpendingSwipeCard(
                    variableHistory: variableSpendingHistory,
                    recurringHistory: recurringSpendingHistory,
                    totalHistory: totalSpendingHistory,
                    currencyCode: currencyCode
                )
            }

            Section {
                CategoryTrendSwipeCard(
                    variableHistory: variableCategoryTrendHistory,
                    recurringHistory: recurringCategoryTrendHistory,
                    totalHistory: totalCategoryTrendHistory,
                    currencyCode: currencyCode
                )
            }

            Section {
                carryoverCard
            }
        }
        .contentMargins(.top, 0, for: .scrollContent)
        .navigationTitle("Trends")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var carryoverCard: some View {
        ChartPanelCard {
            VStack(alignment: .leading, spacing: ChartPanelMetrics.contentSpacing) {
                ChartPanelHeader(title: "Remaining Budget / Carryover")

                if carryoverHistory.allSatisfy({ $0.amount == 0 }) {
                    ChartEmptyState(
                        text: "Carryover appears here once previous months start ending above or below budget.",
                        height: ChartPanelMetrics.lineChartHeight
                    )
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
                    .frame(height: ChartPanelMetrics.lineChartHeight)

                    Text("Positive values mean budget room carried into the next month.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

private struct MonthlySpendingSwipeCard: View {
    @State private var selectedPage = 0

    let variableHistory: [MonthlySpendingPoint]
    let recurringHistory: [MonthlySpendingPoint]
    let totalHistory: [MonthlySpendingPoint]
    let currencyCode: String

    private var selectedTitle: String {
        switch selectedPage {
        case 1:
            return "Recurring Spending"
        case 2:
            return "Total Spending"
        default:
            return "Variable Spending"
        }
    }

    var body: some View {
        ChartPanelCard {
            VStack(alignment: .leading, spacing: ChartPanelMetrics.contentSpacing) {
                ChartPanelHeader(title: "Monthly Trends", subtitle: selectedTitle)

                SwipeableChartCard(height: 310, selection: $selectedPage) {
                    MonthlySpendingTrendPage(
                        history: variableHistory,
                        currencyCode: currencyCode,
                        tint: .blue
                    )
                    .tag(0)

                    MonthlySpendingTrendPage(
                        history: recurringHistory,
                        currencyCode: currencyCode,
                        tint: .teal
                    )
                    .tag(1)

                    MonthlySpendingTrendPage(
                        history: totalHistory,
                        currencyCode: currencyCode,
                        tint: .purple
                    )
                    .tag(2)
                }
            }
        }
    }
}

private struct MonthlySpendingTrendPage: View {
    let history: [MonthlySpendingPoint]
    let currencyCode: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if history.allSatisfy({ $0.total == 0 }) {
                ChartEmptyState(
                    text: "No spending history available in the last six months.",
                    height: ChartPanelMetrics.lineChartHeight
                )
            } else {
                Chart {
                    ForEach(history) { point in
                        BarMark(
                            x: .value("Month", point.month, unit: .month),
                            y: .value("Spent", point.total)
                        )
                        .foregroundStyle(tint.gradient)
                    }

                    if let trendLine {
                        ForEach(trendLine) { point in
                            LineMark(
                                x: .value("Month", point.month, unit: .month),
                                y: .value("Trend", point.total)
                            )
                            .foregroundStyle(.primary.opacity(0.5))
                            .lineStyle(.init(lineWidth: 2, dash: [5, 4]))
                        }
                    }
                }
                .frame(height: ChartPanelMetrics.lineChartHeight)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var trendLine: [MonthlySpendingPoint]? {
        guard history.count >= 2 else { return nil }

        let start = history.first?.total ?? 0
        let end = history.last?.total ?? 0
        let step = (end - start) / Double(max(history.count - 1, 1))

        return history.enumerated().map { index, point in
            MonthlySpendingPoint(
                month: point.month,
                total: start + (Double(index) * step)
            )
        }
    }
}

private struct CategoryTrendSwipeCard: View {
    @State private var selectedPage = 0

    let variableHistory: [NamedCategoryTrendPoint]
    let recurringHistory: [NamedCategoryTrendPoint]
    let totalHistory: [NamedCategoryTrendPoint]
    let currencyCode: String

    private var selectedTitle: String {
        switch selectedPage {
        case 1:
            return "Recurring Spending"
        case 2:
            return "Total Spending"
        default:
            return "Variable Spending"
        }
    }

    var body: some View {
        ChartPanelCard {
            VStack(alignment: .leading, spacing: ChartPanelMetrics.contentSpacing) {
                ChartPanelHeader(title: "Category Trends", subtitle: selectedTitle)

                SwipeableChartCard(height: 410, selection: $selectedPage) {
                    CategoryTrendPage(
                        history: variableHistory,
                        currencyCode: currencyCode
                    )
                    .tag(0)

                    CategoryTrendPage(
                        history: recurringHistory,
                        currencyCode: currencyCode
                    )
                    .tag(1)

                    CategoryTrendPage(
                        history: totalHistory,
                        currencyCode: currencyCode
                    )
                    .tag(2)
                }
            }
        }
    }
}

private struct CategoryTrendPage: View {
    let history: [NamedCategoryTrendPoint]
    let currencyCode: String

    private var legendItems: [NamedCategoryLegendItem] {
        Dictionary(grouping: history, by: \.categoryKey)
            .values
            .compactMap { points in
                guard let first = points.first else { return nil }
                return NamedCategoryLegendItem(
                    categoryKey: first.categoryKey,
                    categoryTitle: first.categoryTitle,
                    colorName: first.colorName
                )
            }
            .sorted { $0.categoryTitle < $1.categoryTitle }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: ChartPanelMetrics.contentSpacing) {
            if history.isEmpty || history.allSatisfy({ $0.total == 0 }) {
                ChartEmptyState(
                    text: "No category history available in the last six months.",
                    height: ChartPanelMetrics.lineChartHeight
                )

                Color.clear
                    .frame(height: ChartPanelMetrics.legendHeight)
            } else {
                Chart(history) { point in
                    LineMark(
                        x: .value("Month", point.month, unit: .month),
                        y: .value("Amount", point.total),
                        series: .value("Category", point.categoryTitle)
                    )
                    .foregroundStyle(color(for: point.colorName))
                }
                .frame(height: ChartPanelMetrics.lineChartHeight)

                ChartLegendList(
                    entries: legendItems.map {
                        ChartLegendEntry(
                            id: $0.categoryKey,
                            title: $0.categoryTitle,
                            value: nil,
                            color: color(for: $0.colorName)
                        )
                    },
                    minHeight: ChartPanelMetrics.legendHeight
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func color(for colorName: String) -> Color {
        switch colorName {
        case ExpenseCategory.food.rawValue:
            return .green
        case ExpenseCategory.transport.rawValue:
            return .blue
        case ExpenseCategory.household.rawValue:
            return .orange
        case ExpenseCategory.fun.rawValue:
            return .pink
        case RecurringExpenseCategory.housingUtilities.rawValue:
            return .indigo
        case RecurringExpenseCategory.subscriptions.rawValue:
            return .teal
        case RecurringExpenseCategory.insurance.rawValue:
            return .cyan
        case RecurringExpenseCategory.savings.rawValue:
            return .mint
        case RecurringExpenseCategory.debt.rawValue:
            return .red
        default:
            return .gray
        }
    }
}

private struct NamedCategoryLegendItem: Identifiable {
    let categoryKey: String
    let categoryTitle: String
    let colorName: String

    var id: String { categoryKey }
}

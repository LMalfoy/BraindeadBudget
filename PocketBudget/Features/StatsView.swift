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

    private var monthlyBudget: Double {
        BudgetStore.availableMonthlyBudget(
            incomeItems: incomeItems,
            recurringExpenseItems: recurringExpenseItems,
            referenceDate: .now
        )
    }

    private var variableSpendingHistory: [MonthlySpendingPoint] {
        BudgetStore.spendingHistory(
            for: expenses,
            recurringExpenseItems: recurringExpenseItems,
            kind: .variable,
            months: monthWindow,
            referenceDate: .now
        )
    }

    private var recurringSpendingHistory: [MonthlySpendingPoint] {
        BudgetStore.spendingHistory(
            for: expenses,
            recurringExpenseItems: recurringExpenseItems,
            kind: .recurring,
            months: monthWindow,
            referenceDate: .now
        )
    }

    private var totalSpendingHistory: [MonthlySpendingPoint] {
        BudgetStore.spendingHistory(
            for: expenses,
            recurringExpenseItems: recurringExpenseItems,
            kind: .total,
            months: monthWindow,
            referenceDate: .now
        )
    }

    private var carryoverHistory: [CarryoverHistoryPoint] {
        BudgetStore.carryoverHistory(
            incomeItems: incomeItems,
            recurringExpenseItems: recurringExpenseItems,
            expenses: expenses,
            initialAvailableBudget: initialAvailableBudget,
            initialBudgetAnchorMonth: initialBudgetAnchorMonth,
            months: monthWindow
        )
    }

    private var variableCategoryTrendHistory: [NamedCategoryTrendPoint] {
        BudgetStore.categoryTrendHistory(
            for: expenses,
            months: monthWindow,
            referenceDate: .now
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
            referenceDate: .now
        )
    }

    private var totalCategoryTrendHistory: [NamedCategoryTrendPoint] {
        BudgetStore.totalCategoryTrendHistory(
            expenses: expenses,
            recurringExpenseItems: recurringExpenseItems,
            months: monthWindow,
            referenceDate: .now
        )
    }

    var body: some View {
        List {
            Section {
                MonthlySpendingComparisonCard(
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
                        .foregroundStyle(AppTheme.primaryGreen)

                        AreaMark(
                            x: .value("Month", point.month, unit: .month),
                            y: .value("Carryover", point.amount)
                        )
                        .foregroundStyle(AppTheme.primaryGreen.opacity(0.12))
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel {
                                if let amount = value.as(Double.self) {
                                    Text(chartCurrencyLabel(amount, currencyCode: currencyCode))
                                }
                            }
                        }
                    }
                    .frame(height: ChartPanelMetrics.lineChartHeight)

                    Text("Positive values mean budget room carried into the next month.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, ChartPanelMetrics.sectionVerticalInset)
        }
    }
}

private struct MonthlySpendingComparisonCard: View {
    let variableHistory: [MonthlySpendingPoint]
    let recurringHistory: [MonthlySpendingPoint]
    let totalHistory: [MonthlySpendingPoint]
    let currencyCode: String

    private var comparisonPoints: [MonthlyTrendBarPoint] {
        variableHistory.enumerated().flatMap { index, variablePoint in
            let recurringPoint = recurringHistory[safe: index]
            let totalPoint = totalHistory[safe: index]

            return [
                MonthlyTrendBarPoint(month: variablePoint.month, kind: .variable, total: variablePoint.total),
                MonthlyTrendBarPoint(month: variablePoint.month, kind: .recurring, total: recurringPoint?.total ?? 0),
                MonthlyTrendBarPoint(month: variablePoint.month, kind: .total, total: totalPoint?.total ?? 0)
            ]
        }
    }

    private var yAxisDomain: ClosedRange<Double> {
        0...roundedChartUpperBound(for: comparisonPoints.map(\.total))
    }

    var body: some View {
        ChartPanelCard {
            VStack(alignment: .leading, spacing: ChartPanelMetrics.contentSpacing) {
                ChartPanelHeader(title: "Monthly Trends")

                if comparisonPoints.allSatisfy({ $0.total == 0 }) {
                    ChartEmptyState(
                        text: "No spending history available in the last six months.",
                        height: ChartPanelMetrics.lineChartHeight
                    )
                } else {
                    Chart(comparisonPoints) { point in
                        BarMark(
                            x: .value("Month", point.month, unit: .month),
                            y: .value("Spent", point.total),
                            width: .fixed(12)
                        )
                        .foregroundStyle(AppTheme.trendColor(for: point.kind))
                        .position(by: .value("Series", point.kind.title))
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel {
                                if let amount = value.as(Double.self) {
                                    Text(chartCurrencyLabel(amount, currencyCode: currencyCode))
                                }
                            }
                        }
                    }
                    .chartYScale(domain: yAxisDomain)
                    .frame(height: ChartPanelMetrics.lineChartHeight)

                    ChartLegendList(
                        entries: TrendSeriesKind.allCases.map { kind in
                            ChartLegendEntry(
                                id: kind.rawValue,
                                title: kind.title,
                                value: nil,
                                color: AppTheme.trendColor(for: kind)
                            )
                        },
                        minHeight: 86
                    )
                }
            }
        }
    }
}

private struct CategoryTrendSwipeCard: View {
    @State private var selectedPage = 0

    let variableHistory: [NamedCategoryTrendPoint]
    let recurringHistory: [NamedCategoryTrendPoint]
    let totalHistory: [NamedCategoryTrendPoint]
    let currencyCode: String

    private var sharedYAxisDomain: ClosedRange<Double> {
        0...roundedChartUpperBound(for: (variableHistory + recurringHistory + totalHistory).map(\.total))
    }

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

                SwipeableChartCard(height: 442, selection: $selectedPage) {
                    CategoryTrendPage(
                        history: variableHistory,
                        currencyCode: currencyCode,
                        yAxisDomain: sharedYAxisDomain
                    )
                    .tag(0)

                    CategoryTrendPage(
                        history: recurringHistory,
                        currencyCode: currencyCode,
                        yAxisDomain: sharedYAxisDomain
                    )
                    .tag(1)

                    CategoryTrendPage(
                        history: totalHistory,
                        currencyCode: currencyCode,
                        yAxisDomain: sharedYAxisDomain
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
    let yAxisDomain: ClosedRange<Double>

    private var legendItems: [NamedCategoryLegendItem] {
        Dictionary(grouping: history, by: \.categoryKey)
            .values
            .compactMap { points in
                guard let first = points.first else { return nil }
                return NamedCategoryLegendItem(
                    categoryKey: first.categoryKey,
                    categoryTitle: first.categoryTitle,
                    colorName: first.colorName,
                    total: points.reduce(0) { $0 + $1.total }
                )
            }
            .sorted { lhs, rhs in
                if lhs.total == rhs.total {
                    return lhs.categoryTitle < rhs.categoryTitle
                }

                return lhs.total > rhs.total
            }
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
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                            AxisTick()
                            AxisValueLabel {
                                if let amount = value.as(Double.self) {
                                    Text(chartCurrencyLabel(amount, currencyCode: currencyCode))
                                }
                            }
                        }
                    }
                .chartYScale(domain: yAxisDomain)
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
        .padding(.vertical, ChartPanelMetrics.sectionVerticalInset)
        .padding(.bottom, 28)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func color(for colorName: String) -> Color {
        AppTheme.categoryColor(for: colorName)
    }
}

private struct NamedCategoryLegendItem: Identifiable {
    let categoryKey: String
    let categoryTitle: String
    let colorName: String
    let total: Double

    var id: String { categoryKey }
}

private struct MonthlyTrendBarPoint: Identifiable {
    let month: Date
    let kind: TrendSeriesKind
    let total: Double

    var id: String {
        "\(kind.rawValue)-\(month.timeIntervalSinceReferenceDate)"
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}

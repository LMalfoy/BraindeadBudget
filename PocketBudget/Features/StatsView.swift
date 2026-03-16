import Charts
import Foundation
import SwiftData
import SwiftUI

struct StatsView: View {
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @Query(sort: \BudgetSettings.updatedAt, order: .reverse) private var budgets: [BudgetSettings]
    @Query(sort: \IncomeItem.createdAt) private var incomeItems: [IncomeItem]
    @Query(sort: \RecurringExpenseItem.createdAt) private var recurringExpenseItems: [RecurringExpenseItem]

    private var currencyCode: String {
        budgets.first?.currencyCode ?? Locale.current.currency?.identifier ?? "USD"
    }

    private var categorySpending: [CategorySpendingSummary] {
        BudgetStore.categorySpending(for: expenses)
    }

    private var monthlyBudget: Double {
        BudgetStore.availableMonthlyBudget(
            incomeItems: incomeItems,
            recurringExpenseItems: recurringExpenseItems
        )
    }

    private var topCategory: CategorySpendingSummary? {
        BudgetStore.topSpendingCategory(for: expenses)
    }

    private var categoryInterpretation: String {
        guard let topCategory else {
            return "Add a few expenses to start seeing your spending behavior."
        }

        return "\(topCategory.category.title) is your largest spending category this month."
    }

    private var trajectory: [BudgetTrajectoryPoint] {
        BudgetStore.budgetTrajectory(
            monthlyBudget: monthlyBudget,
            expenses: expenses
        )
    }

    private var temporalSpending: [TemporalSpendingSummary] {
        BudgetStore.temporalSpending(for: expenses)
    }

    private var monthComparison: MonthComparisonSummary {
        BudgetStore.monthComparison(for: expenses)
    }

    private var carryoverAmount: Double {
        BudgetStore.previousMonthCarryover(
            monthlyBudget: monthlyBudget,
            expenses: expenses
        )
    }

    private var carryoverHistory: [CarryoverHistoryPoint] {
        BudgetStore.carryoverHistory(
            monthlyBudget: monthlyBudget,
            expenses: expenses
        )
    }

    private var disciplineEvaluation: BudgetDisciplineEvaluation {
        BudgetStore.evaluateBudgetDiscipline(
            monthlyBudget: monthlyBudget,
            expenses: expenses
        )
    }

    private var trajectoryInterpretation: String {
        guard let firstPoint = trajectory.first, let lastPoint = trajectory.last else {
            return "Add a few expenses to see how your budget pace changes through the month."
        }

        let drop = firstPoint.remainingBudget - lastPoint.remainingBudget
        let ratio = monthlyBudget == 0 ? 0 : drop / max(abs(monthlyBudget), 1)

        if ratio >= 0.65 {
            return "You are spending faster than planned this month."
        }

        if ratio >= 0.35 {
            return "Your spending pace is currently steady."
        }

        return "You still have strong budget room for the rest of the month."
    }

    private var temporalInterpretation: String {
        guard !temporalSpending.isEmpty else {
            return "Add a few expenses to see when your spending tends to happen."
        }

        let sortedTotals = temporalSpending.map(\.total).sorted(by: >)

        if let first = sortedTotals.first, let last = sortedTotals.last, temporalSpending.count == 3, first - last < 0.15 * first {
            return "Your spending is spread fairly evenly across the month."
        }

        guard let topSegment = temporalSpending.max(by: { $0.total < $1.total })?.segment else {
            return "Add a few expenses to see when your spending tends to happen."
        }

        switch topSegment {
        case .early:
            return "Your spending is concentrated at the beginning of the month."
        case .mid:
            return "Most of your spending happens in the middle of the month."
        case .late:
            return "Most of your spending happens later in the month."
        }
    }

    private var comparisonInterpretation: String {
        if monthComparison.currentMonthTotal == 0, monthComparison.previousMonthTotal == 0 {
            return "Add some history to compare this month against the previous one."
        }

        if monthComparison.previousMonthTotal == 0 {
            return "You have no spending recorded last month to compare against yet."
        }

        let difference = monthComparison.difference
        let threshold = max(monthComparison.previousMonthTotal * 0.1, 1)

        if difference <= -threshold {
            return "You are doing better than last month."
        }

        if abs(difference) < threshold {
            return "Your spending is close to last month."
        }

        return "You are spending more than last month."
    }

    private var carryoverInterpretation: String {
        if monthComparison.previousMonthTotal == 0 {
            return "You have no previous-month spending yet to generate carryover."
        }

        if carryoverAmount > 0 {
            return "You carried money forward from last month."
        }

        if carryoverAmount < 0 {
            return "Last month reduced this month’s available budget."
        }

        return "You started this month with no carryover."
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Budget Discipline")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(disciplineEvaluation.rank.title)
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(rankColor(for: disciplineEvaluation.rank))
                            .accessibilityIdentifier("stats.rankValue")

                        Text(disciplineEvaluation.summary)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                            .accessibilityIdentifier("stats.rankSummary")
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Why")
                            .font(.subheadline.weight(.semibold))

                        ForEach(disciplineEvaluation.reasons) { reason in
                            HStack(alignment: .top, spacing: 10) {
                                Text(symbol(for: reason.tone))
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(reasonColor(for: reason.tone))

                                Text(reason.message)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .statsCardStyle()
                .accessibilityIdentifier("stats.rankModule")
            }

            Section {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Budget Trajectory")
                        .font(.headline)

                    if trajectory.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("No trajectory data yet for this month.")
                                .foregroundStyle(.secondary)

                            Text(trajectoryInterpretation)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .accessibilityIdentifier("stats.trajectoryInterpretation")
                        }
                    } else {
                        Chart(trajectory) { point in
                            LineMark(
                                x: .value("Date", point.date),
                                y: .value("Remaining", point.remainingBudget)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(Color.accentColor)

                            AreaMark(
                                x: .value("Date", point.date),
                                y: .value("Remaining", point.remainingBudget)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(
                                .linearGradient(
                                    colors: [Color.accentColor.opacity(0.22), Color.accentColor.opacity(0.02)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        }
                        .frame(height: 220)
                        .accessibilityIdentifier("stats.trajectoryChart")

                        Text(trajectoryInterpretation)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                            .accessibilityIdentifier("stats.trajectoryInterpretation")
                    }
                }
                .statsCardStyle()
                .accessibilityIdentifier("stats.trajectoryModule")
            }

            Section {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Carryover")
                        .font(.headline)

                    if carryoverHistory.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("No carryover history yet.")
                                .foregroundStyle(.secondary)

                            Text(carryoverInterpretation)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .accessibilityIdentifier("stats.carryoverInterpretation")
                        }
                    } else {
                        Chart(carryoverHistory) { point in
                            BarMark(
                                x: .value("Month", point.month, unit: .month),
                                y: .value("Carryover", point.amount)
                            )
                            .foregroundStyle(point.amount >= 0 ? Color.green.gradient : Color.red.gradient)
                            .cornerRadius(6)
                        }
                        .frame(height: 220)
                        .accessibilityIdentifier("stats.carryoverChart")

                        HStack {
                            Text("Current Carryover")
                                .foregroundStyle(.secondary)

                            Spacer()

                            Text(carryoverAmount.formatted(.currency(code: currencyCode)))
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(carryoverColor)
                        }

                        Text("Last 6 months")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Text(carryoverInterpretation)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("stats.carryoverInterpretation")
                }
                .statsCardStyle()
                .accessibilityIdentifier("stats.carryoverModule")
            }

            Section {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Month Comparison")
                        .font(.headline)

                    if monthComparison.currentMonthTotal == 0, monthComparison.previousMonthTotal == 0 {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("No comparison data yet.")
                                .foregroundStyle(.secondary)

                            Text(comparisonInterpretation)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .accessibilityIdentifier("stats.comparisonInterpretation")
                        }
                    } else {
                        Chart([
                            MonthComparisonBar(label: "Previous", amount: monthComparison.previousMonthTotal),
                            MonthComparisonBar(label: "Current", amount: monthComparison.currentMonthTotal)
                        ]) { bar in
                            BarMark(
                                x: .value("Month", bar.label),
                                y: .value("Amount", bar.amount)
                            )
                            .foregroundStyle(bar.color)
                            .cornerRadius(8)
                        }
                        .frame(height: 220)
                        .accessibilityIdentifier("stats.comparisonChart")

                        VStack(alignment: .leading, spacing: 6) {
                            comparisonRow(title: "Current Month", amount: monthComparison.currentMonthTotal)
                            comparisonRow(title: "Previous Month", amount: monthComparison.previousMonthTotal)
                            comparisonRow(title: "Difference", amount: monthComparison.difference)
                        }

                        Text(comparisonInterpretation)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                            .accessibilityIdentifier("stats.comparisonInterpretation")
                    }
                }
                .statsCardStyle()
                .accessibilityIdentifier("stats.comparisonModule")
            }

            Section {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Spending Pattern")
                        .font(.headline)

                    if temporalSpending.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("No temporal spending pattern yet for this month.")
                                .foregroundStyle(.secondary)

                            Text(temporalInterpretation)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .accessibilityIdentifier("stats.temporalInterpretation")
                        }
                    } else {
                        Chart(temporalSpending) { summary in
                            BarMark(
                                x: .value("Segment", summary.segment.title),
                                y: .value("Amount", summary.total)
                            )
                            .foregroundStyle(Color.accentColor.gradient)
                            .cornerRadius(8)
                        }
                        .frame(height: 220)
                        .accessibilityIdentifier("stats.temporalChart")

                        Text(temporalInterpretation)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                            .accessibilityIdentifier("stats.temporalInterpretation")
                    }
                }
                .statsCardStyle()
                .accessibilityIdentifier("stats.temporalModule")
            }

            Section {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Spending by Category")
                        .font(.headline)

                    if categorySpending.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("No category data yet for this month.")
                                .foregroundStyle(.secondary)

                            Text(categoryInterpretation)
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

                        Text(categoryInterpretation)
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
        .contentMargins(.top, 0, for: .scrollContent)
        .navigationTitle("Stats")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var carryoverColor: Color {
        if carryoverAmount > 0 {
            return .green
        }

        if carryoverAmount < 0 {
            return .red
        }

        return .primary
    }

    private func rankColor(for rank: BudgetDisciplineRank) -> Color {
        switch rank {
        case .pawn:
            return .secondary
        case .knight:
            return .blue
        case .bishop:
            return .teal
        case .rook:
            return .indigo
        case .queen:
            return .purple
        case .king:
            return .orange
        }
    }

    private func reasonColor(for tone: BudgetReasonTone) -> Color {
        switch tone {
        case .positive:
            return .green
        case .neutral:
            return .secondary
        case .warning:
            return .orange
        }
    }

    private func symbol(for tone: BudgetReasonTone) -> String {
        switch tone {
        case .positive:
            return "✓"
        case .neutral:
            return "•"
        case .warning:
            return "!"
        }
    }

    @ViewBuilder
    private func comparisonRow(title: String, amount: Double) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)

            Spacer()

            Text(amount.formatted(.currency(code: currencyCode)))
                .fontWeight(.medium)
                .foregroundStyle(title == "Difference" && amount > 0 ? .red : .primary)
        }
    }
}

private struct MonthComparisonBar: Identifiable {
    let label: String
    let amount: Double

    var id: String { label }

    var color: Color {
        label == "Current" ? .accentColor : Color.secondary.opacity(0.45)
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

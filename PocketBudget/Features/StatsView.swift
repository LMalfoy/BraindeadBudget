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

    var body: some View {
        List {
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

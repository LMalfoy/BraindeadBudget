/*
 Main dashboard for the current budget period.
 */

import Charts
import Foundation
import SwiftData
import SwiftUI

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedBaselineSetup") private var hasCompletedSetup = false
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @Query(sort: \BudgetSettings.updatedAt, order: .reverse) private var budgets: [BudgetSettings]
    @Query(sort: \IncomeItem.createdAt) private var incomeItems: [IncomeItem]
    @Query(sort: \RecurringExpenseItem.createdAt) private var recurringExpenseItems: [RecurringExpenseItem]

    @State private var showingAddExpense = false

    private var store: BudgetStore {
        BudgetStore(context: modelContext)
    }

    private var budgetSettings: BudgetSettings? {
        budgets.first
    }

    private var initialAvailableBudget: Double? {
        budgetSettings?.initialAvailableBudget
    }

    private var initialBudgetAnchorMonth: Date? {
        budgetSettings?.initialBudgetAnchorMonth
    }

    private var budgetPeriodAnchorDay: Int {
        budgetSettings?.budgetPeriodAnchorDay ?? 1
    }

    private var hasBaselineData: Bool {
        !incomeItems.isEmpty
    }

    private func makeDashboardSnapshot(referenceDate: Date = .now) -> DashboardSnapshot {
        BudgetStore.dashboardSnapshot(
            incomeItems: incomeItems,
            recurringExpenseItems: recurringExpenseItems,
            expenses: expenses,
            budgetPeriodAnchorDay: budgetPeriodAnchorDay,
            initialAvailableBudget: initialAvailableBudget,
            initialBudgetAnchorMonth: initialBudgetAnchorMonth,
            referenceDate: referenceDate
        )
    }

    private var currentMonthExpenses: [Expense] {
        BudgetStore.currentMonthExpenses(
            from: expenses,
            budgetPeriodAnchorDay: budgetPeriodAnchorDay
        )
    }

    private var recentExpenses: [Expense] {
        Array(currentMonthExpenses.sorted { $0.date > $1.date }.prefix(8))
    }

    private var currencyCode: String {
        budgetSettings?.currencyCode ?? Locale.current.currency?.identifier ?? "USD"
    }

    private var setupCoverBinding: Binding<Bool> {
        Binding(
            get: { !hasCompletedSetup },
            set: { _ in }
        )
    }

    var body: some View {
        let snapshot = makeDashboardSnapshot()

        ZStack(alignment: .bottomTrailing) {
            List {
                Section {
                    SummaryCardView(
                        monthLabel: Date.now.formatted(.dateTime.month(.wide).year()),
                        availableThisMonth: snapshot.availableThisMonth,
                        monthlyBudget: snapshot.monthlyBudget,
                        carryover: snapshot.previousMonthCarryover,
                        totalSpent: snapshot.totalSpent,
                        remainingBudget: snapshot.remainingBudget,
                        currencyCode: currencyCode,
                        hasCompletedSetup: hasBaselineData
                    )
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 12, trailing: 16))
                }

                Section {
                    DashboardInsightCardView(
                        categorySpending: snapshot.categorySpending,
                        trajectory: BudgetStore.budgetTrajectory(
                            monthlyBudget: snapshot.monthlyBudget,
                            expenses: expenses,
                            budgetPeriodAnchorDay: budgetPeriodAnchorDay,
                            initialAvailableBudget: initialAvailableBudget,
                            initialBudgetAnchorMonth: initialBudgetAnchorMonth
                        ),
                        currencyCode: currencyCode
                    )
                    .listRowInsets(Self.cardInsets)
                }

                Section {
                    if recentExpenses.isEmpty {
                        Text(hasBaselineData
                             ? "No expenses logged in the current month yet."
                             : "Complete your budget setup first, then start logging expenses.")
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 10)
                    } else {
                        ForEach(recentExpenses) { expense in
                            Button {
                                NotificationCenter.default.post(
                                    name: .openExpenseHistoryMonth,
                                    object: expense.date
                                )
                            } label: {
                                ExpenseRowView(expense: expense, currencyCode: currencyCode)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } header: {
                    Text("Recent Expenses")
                }
            }
            .contentMargins(.top, 0, for: .scrollContent)

            Button {
                showingAddExpense = true
            } label: {
                Label("Add Expense", systemImage: "plus")
                    .font(.headline)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 16)
                    .background(hasBaselineData ? Color.green : Color(uiColor: .systemGray4))
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
            }
            .disabled(!hasBaselineData)
            .padding(.trailing, 20)
            .padding(.bottom, 20)
            .accessibilityIdentifier("dashboard.addExpenseButton")
        }
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseSheet(currencyCode: currencyCode) { title, category, amount, date, note in
                try store.addExpense(
                    title: title,
                    category: category,
                    amount: amount,
                    date: date,
                    note: note
                )
            }
        }
        .fullScreenCover(isPresented: setupCoverBinding) {
            InitialSetupFlowView()
        }
        .onReceive(NotificationCenter.default.publisher(for: .openQuickAddExpense)) { _ in
            guard hasBaselineData, hasCompletedSetup else {
                return
            }

            showingAddExpense = true
        }
    }

    private static let cardInsets = EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
}

private struct InitialSetupFlowView: View {
    @State private var hasAcceptedIntro = false

    var body: some View {
        if hasAcceptedIntro {
            BudgetSettingsSheet(mode: .onboarding)
        } else {
            OnboardingIntroView {
                hasAcceptedIntro = true
            }
        }
    }
}

private struct OnboardingIntroView: View {
    let onContinue: () -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                Spacer(minLength: 0)

                VStack(alignment: .leading, spacing: 14) {
                    Text("How BudgetRook Works")
                        .font(.system(size: 32, weight: .bold, design: .rounded))

                    Text("BudgetRook starts from your monthly income and recurring costs to calculate what is available to spend.")
                        .font(.body)
                        .foregroundStyle(.secondary)

                    Text("You then log day-to-day expenses and can see the current month at a glance, with deeper monthly and trend views available when needed.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)

                Button("Continue to Setup") {
                    onContinue()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity, alignment: .center)
                .accessibilityIdentifier("onboardingIntro.continueButton")
            }
            .padding(24)
            .navigationTitle("Welcome")
            .navigationBarTitleDisplayMode(.inline)
        }
        .interactiveDismissDisabled(true)
    }
}

private struct SummaryCardView: View {
    let monthLabel: String
    let availableThisMonth: Double
    let monthlyBudget: Double
    let carryover: Double
    let totalSpent: Double
    let remainingBudget: Double
    let currencyCode: String
    let hasCompletedSetup: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if hasCompletedSetup {
                Text(monthLabel)
                    .font(.headline.weight(.semibold))

                VStack(alignment: .leading, spacing: 4) {
                    Text(remainingBudget < 0 ? "Over Budget" : "Remaining Budget")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(formatted(remainingBudget))
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(remainingBudget < 0 ? .red : .green)
                        .accessibilityIdentifier("dashboard.remainingBudgetValue")
                }

                VStack(spacing: 10) {
                    summaryRow(title: "Baseline Budget", value: formatted(monthlyBudget))
                    summaryRow(title: "Carryover", value: formatted(carryover))
                    summaryRow(title: "Available This Month", value: formatted(availableThisMonth))
                    summaryRow(title: "Spent So Far", value: formatted(totalSpent))
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Set up your income and recurring monthly costs to calculate what is available to spend.")
                        .foregroundStyle(.secondary)
                    Text("Once setup is complete, the dashboard shows your budget, spending, and remaining room for the current month.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .dashboardCardStyle()
    }

    @ViewBuilder
    private func summaryRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }

    private func formatted(_ amount: Double) -> String {
        amount.formatted(.currency(code: currencyCode))
    }
}

private struct DashboardInsightCardView: View {
    let categorySpending: [CategorySpendingSummary]
    let trajectory: [BudgetTrajectoryPoint]
    let currencyCode: String

    var body: some View {
        TabView {
                categoryInsight

                trajectoryInsight
            }
            .frame(height: 400)
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .dashboardCardStyle()
    }

    private var categoryInsight: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spending by Category")
                .font(.headline.weight(.semibold))

            if categorySpending.isEmpty {
                Text("Add a few expenses to see where this month is going.")
                    .foregroundStyle(.secondary)
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
                .frame(height: 210)

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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.bottom, 6)
        .accessibilityIdentifier("dashboard.categoryInsight")
    }

    private var trajectoryInsight: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Budget Trajectory")
                .font(.headline.weight(.semibold))

            if trajectory.isEmpty {
                Text("Add a few expenses to see how spending has moved through the month.")
                    .foregroundStyle(.secondary)
                    .padding(.top, 12)
            } else {
                Spacer(minLength: 0)

                Chart {
                    ForEach(trajectory) { point in
                        let isNegativeState = (trajectory.last?.remainingBudget ?? 0) < 0

                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("Remaining", point.remainingBudget)
                        )
                        .foregroundStyle((trajectory.last?.remainingBudget ?? 0) < 0 ? .red : .green)
                        .interpolationMethod(.linear)

                        AreaMark(
                            x: .value("Date", point.date),
                            yStart: .value(
                                "Baseline",
                                isNegativeState ? yAxisDomain.upperBound : 0
                            ),
                            yEnd: .value("Remaining", point.remainingBudget)
                        )
                        .foregroundStyle(
                            isNegativeState
                                ? .red.opacity(0.12)
                                : .green.opacity(0.12)
                        )
                    }
                }
                .chartXAxis {
                    AxisMarks(values: xAxisMarks) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(date, format: .dateTime.day().month(.abbreviated))
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        if let amount = value.as(Double.self), abs(amount) < 0.0001 {
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                                .foregroundStyle(.secondary.opacity(0.65))
                        } else {
                            AxisGridLine()
                        }
                        AxisTick()
                        AxisValueLabel {
                            if let amount = value.as(Double.self) {
                                Text(amount, format: .currency(code: currencyCode).precision(.fractionLength(0)))
                            }
                        }
                    }
                }
                .chartPlotStyle { plotArea in
                    plotArea
                        .padding(.top, 12)
                }
                .chartYScale(domain: yAxisDomain)
                .frame(height: 270)
                .clipped()

                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .accessibilityIdentifier("dashboard.trajectoryInsight")
    }

    private var yAxisDomain: ClosedRange<Double> {
        let values = trajectory.map(\.remainingBudget)
        let minimum = values.min() ?? 0
        let maximum = values.max() ?? 0
        let lowerBound = min(minimum < 0 ? roundedFloor(minimum) : 0, 0)
        let upperBound: Double

        if maximum <= 0 {
            let referenceMagnitude = max(abs(minimum), 1)
            upperBound = roundedCeiling(referenceMagnitude * 0.12)
        } else {
            upperBound = max(roundedCeiling(maximum), 0)
        }

        return lowerBound...max(upperBound, lowerBound + 1)
    }

    private var xAxisMarks: [Date] {
        guard let start = trajectory.first?.date, let end = trajectory.last?.date else {
            return []
        }

        let calendar = Calendar.current
        let totalDays = max(calendar.dateComponents([.day], from: start, to: end).day ?? 0, 0)
        let step = max(totalDays / 3, 1)

        var marks = [calendar.startOfDay(for: start)]
        var cursor = calendar.startOfDay(for: start)

        while let next = calendar.date(byAdding: .day, value: step, to: cursor), next < end {
            marks.append(next)
            cursor = next
        }

        let endOfDay = calendar.startOfDay(for: end)
        if marks.last != endOfDay {
            marks.append(endOfDay)
        }

        return marks
    }

    private func roundedCeiling(_ value: Double) -> Double {
        guard value != 0 else { return 100 }
        let magnitude = pow(10.0, floor(log10(abs(value))))
        let step = max(magnitude / 2, 1)
        return ceil(value / step) * step
    }

    private func roundedFloor(_ value: Double) -> Double {
        guard value != 0 else { return 0 }
        let magnitude = pow(10.0, floor(log10(abs(value))))
        let step = max(magnitude / 2, 1)
        return floor(value / step) * step
    }
}

private struct ExpenseRowView: View {
    let expense: Expense
    let currencyCode: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(expense.category.color)
                .frame(width: 5)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(expense.title)
                        .font(.subheadline.weight(.medium))
                        .lineLimit(1)

                    Text(expense.category.title)
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(expense.category.color.opacity(0.12))
                        .foregroundStyle(expense.category.color)
                        .clipShape(Capsule())
                }

                Text(expense.date, format: .dateTime.month(.abbreviated).day().year())
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if !expense.note.isEmpty {
                    Text(expense.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 12)

            Text(expense.amount.formatted(.currency(code: currencyCode)))
                .font(.subheadline.weight(.semibold))

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
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
    func dashboardCardStyle() -> some View {
        padding(18)
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

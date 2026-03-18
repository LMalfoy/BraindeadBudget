/*
 Main home screen.

 The dashboard answers the app's most important question:
 "How much money is still available in the current budget period?"

 It combines:
 - the calculated monthly baseline
 - carryover from the previous period
 - real recorded expenses for the current period
 - a quick category overview
 - recent expense activity

 This file is also responsible for showing first-run onboarding when setup has
 not yet been completed.
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

    private var recentExpenses: [Expense] {
        Array(expenses.prefix(10))
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
                        monthLabel: Date.now.formatted(.dateTime.month(.wide)),
                        baselineMonthlyBudget: snapshot.monthlyBudget,
                        carryoverAmount: snapshot.previousMonthCarryover,
                        totalSpent: snapshot.totalSpent,
                        remainingBudget: snapshot.remainingBudget,
                        dailySafeSpend: snapshot.dailySafeSpend,
                        daysRemainingInCurrentPeriod: snapshot.daysRemainingInCurrentPeriod,
                        currencyCode: currencyCode,
                        hasCompletedSetup: hasBaselineData
                    )
                    .listRowInsets(Self.cardInsets)
                }

                Section {
                    CategoryOverviewCardView(
                        categorySpending: snapshot.categorySpending,
                        topCategory: snapshot.topCategory,
                        currencyCode: currencyCode
                    )
                    .listRowInsets(Self.cardInsets)
                }

                Section {
                    if recentExpenses.isEmpty {
                        Text(hasBaselineData
                             ? "No expenses yet. Tap Add Expense to log your first purchase."
                             : "Complete your budget setup first, then start logging daily expenses.")
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
                let unlocks = try store.syncAchievements(
                    hasCompletedSetup: hasCompletedSetup,
                    incomeItems: incomeItems,
                    recurringExpenseItems: recurringExpenseItems,
                    expenses: expenses,
                    budgetPeriodAnchorDay: budgetPeriodAnchorDay,
                    initialAvailableBudget: initialAvailableBudget,
                    initialBudgetAnchorMonth: initialBudgetAnchorMonth
                )
                AchievementNotificationDispatcher.postUnlocks(unlocks)
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
        .task {
            do {
                let unlocks = try store.syncAchievements(
                    hasCompletedSetup: hasCompletedSetup,
                    incomeItems: incomeItems,
                    recurringExpenseItems: recurringExpenseItems,
                    expenses: expenses,
                    budgetPeriodAnchorDay: budgetPeriodAnchorDay,
                    initialAvailableBudget: initialAvailableBudget,
                    initialBudgetAnchorMonth: initialBudgetAnchorMonth
                )
                AchievementNotificationDispatcher.postUnlocks(unlocks)
            } catch {
                // Dashboard should stay usable even if achievement syncing fails.
            }
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

                    Text("You then track daily spending against that budget, while Statistics separates total spending, budget spending, and recurring spending.")
                        .font(.body)
                        .foregroundStyle(.secondary)

                    Text("Chess progression rewards money saved at the end of completed budget periods.")
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
    let baselineMonthlyBudget: Double
    let carryoverAmount: Double
    let totalSpent: Double
    let remainingBudget: Double
    let dailySafeSpend: Double
    let daysRemainingInCurrentPeriod: Int
    let currencyCode: String
    let hasCompletedSetup: Bool

    @State private var showingInfo = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if hasCompletedSetup {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        Text("Budget Overview")
                            .font(.headline.weight(.semibold))

                        Spacer()

                        Button {
                            showingInfo = true
                        } label: {
                            Image(systemName: "info.circle")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("dashboard.summaryInfoButton")
                    }

                    summaryRow(title: "Baseline Budget", value: formatted(baselineMonthlyBudget))
                    summaryRow(title: "Carryover", value: formatted(carryoverAmount))
                    summaryRow(title: "Spent in \(monthLabel)", value: formatted(totalSpent))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Remaining")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text(formatted(remainingBudget))
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(remainingBudget < 0 ? .red : .green)
                            .accessibilityIdentifier("dashboard.remainingBudgetValue")
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Daily Safe Spend")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text(formatted(dailySafeSpend))
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(dailySafeSpend < 0 ? .red : .green)

                        Text("\(daysRemainingInCurrentPeriod) day\(daysRemainingInCurrentPeriod == 1 ? "" : "s") left in this budget period")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Set up your income and recurring monthly costs to calculate what is available to spend.")
                        .foregroundStyle(.secondary)
                    Text("Once setup is complete, PocketBudget subtracts this month's expenses from that calculated budget.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .dashboardCardStyle()
        .sheet(isPresented: $showingInfo) {
            DashboardSummaryInfoSheet()
        }
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

private struct DashboardSummaryInfoSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Remaining")
                        .font(.headline)
                    Text("Amount left in the current budget period after your baseline budget, carryover, and recorded expenses are taken into account.")
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Daily Safe Spend")
                        .font(.headline)
                    Text("A simple per-day guideline based on your remaining budget and the number of days left in the current budget period.")
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(24)
            .navigationTitle("Budget Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
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

private struct CategoryOverviewCardView: View {
    let categorySpending: [CategorySpendingSummary]
    let topCategory: CategorySpendingSummary?
    let currencyCode: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if categorySpending.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("No category data yet for this month.")
                        .foregroundStyle(.secondary)

                    Text("Add a few expenses to see where your money is going.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
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
                .frame(height: 180)

                if let topCategory {
                    Text(
                        "Top category: \(topCategory.category.title) (\(topCategory.total.formatted(.currency(code: currencyCode))))"
                    )
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                }

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
        .dashboardCardStyle()
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

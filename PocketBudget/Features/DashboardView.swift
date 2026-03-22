/*
 Main dashboard for the current budget period.

 This screen is intentionally short and answers one question quickly:
 where does the current month stand right now?
 */

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
                        currentBudget: snapshot.monthlyBudget + snapshot.previousMonthCarryover,
                        baselineBudget: snapshot.monthlyBudget,
                        carryover: snapshot.previousMonthCarryover,
                        totalSpent: snapshot.totalSpent,
                        remainingBudget: snapshot.remainingBudget,
                        currencyCode: currencyCode,
                        hasCompletedSetup: hasBaselineData
                    )
                    .listRowInsets(Self.cardInsets)
                }

                Section {
                    RecurringLoadCardView(
                        recurringTotal: recurringExpenseItems.reduce(0) { $0 + $1.amount },
                        subscriptionLoad: BudgetStore.subscriptionLoad(for: recurringExpenseItems),
                        currencyCode: currencyCode,
                        hasCompletedSetup: hasBaselineData
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
    let currentBudget: Double
    let baselineBudget: Double
    let carryover: Double
    let totalSpent: Double
    let remainingBudget: Double
    let currencyCode: String
    let hasCompletedSetup: Bool

    private var budgetProgressTotal: Double {
        max(currentBudget, 0)
    }

    private var budgetProgressValue: Double {
        min(max(totalSpent, 0), max(budgetProgressTotal, 0))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if hasCompletedSetup {
                Text("Current Month")
                    .font(.headline.weight(.semibold))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Remaining Budget")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(formatted(remainingBudget))
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(remainingBudget < 0 ? .red : .green)
                        .accessibilityIdentifier("dashboard.remainingBudgetValue")
                }

                VStack(spacing: 10) {
                    summaryRow(title: "Budget", value: formatted(currentBudget))
                    summaryRow(title: "Spent", value: formatted(totalSpent))
                    summaryRow(title: "Baseline", value: formatted(baselineBudget))
                    summaryRow(title: "Carryover", value: formatted(carryover))
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Budget vs Actual")
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Text(progressText)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                    }

                    ProgressView(value: budgetProgressValue, total: max(budgetProgressTotal, 1))
                        .tint(remainingBudget < 0 ? .red : .green)
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

    private var progressText: String {
        guard budgetProgressTotal > 0 else {
            return "No budget available"
        }

        let share = budgetProgressValue / budgetProgressTotal
        return share.formatted(.percent.precision(.fractionLength(0)))
    }

    private func formatted(_ amount: Double) -> String {
        amount.formatted(.currency(code: currencyCode))
    }
}

private struct RecurringLoadCardView: View {
    let recurringTotal: Double
    let subscriptionLoad: SubscriptionLoadSummary
    let currencyCode: String
    let hasCompletedSetup: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Recurring Load")
                .font(.headline.weight(.semibold))

            if hasCompletedSetup {
                HStack {
                    overviewItem(title: "Recurring", value: recurringTotal.formatted(.currency(code: currencyCode)))
                    Spacer()
                    overviewItem(title: "Subscriptions", value: "\(subscriptionLoad.count)")
                    Spacer()
                    overviewItem(title: "Subscription Cost", value: subscriptionLoad.totalMonthlyCost.formatted(.currency(code: currencyCode)))
                }
            } else {
                Text("Recurring costs and subscriptions appear here once your budget is configured.")
                    .foregroundStyle(.secondary)
            }
        }
        .dashboardCardStyle()
    }

    @ViewBuilder
    private func overviewItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.primary)
        }
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

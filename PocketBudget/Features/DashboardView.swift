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
    @State private var showingSettings = false
    @State private var errorMessage: String?

    private var store: BudgetStore {
        BudgetStore(context: modelContext)
    }

    private var budgetSettings: BudgetSettings? {
        budgets.first
    }

    private var hasBaselineData: Bool {
        !incomeItems.isEmpty
    }

    private var currentMonthExpenses: [Expense] {
        store.currentMonthExpenses(from: expenses)
    }

    private var totalSpent: Double {
        BudgetStore.totalSpent(for: currentMonthExpenses)
    }

    private var monthlyBudget: Double {
        BudgetStore.availableMonthlyBudget(
            incomeItems: incomeItems,
            recurringExpenseItems: recurringExpenseItems
        )
    }

    private var previousMonthCarryover: Double {
        BudgetStore.previousMonthCarryover(
            monthlyBudget: monthlyBudget,
            expenses: expenses
        )
    }

    private var adjustedMonthlyBudget: Double {
        BudgetStore.adjustedMonthlyBudget(
            monthlyBudget: monthlyBudget,
            expenses: expenses
        )
    }

    private var remainingBudget: Double {
        BudgetStore.remainingBudget(
            monthlyBudget: monthlyBudget,
            expenses: expenses
        )
    }

    private var categorySpending: [CategorySpendingSummary] {
        BudgetStore.categorySpending(for: expenses)
    }

    private var topCategory: CategorySpendingSummary? {
        categorySpending.first
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

    private var errorAlertBinding: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    errorMessage = nil
                }
            }
        )
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            List {
                Section {
                    SummaryCardView(
                        monthLabel: Date.now.formatted(.dateTime.month(.wide)),
                        baselineMonthlyBudget: monthlyBudget,
                        carryoverAmount: previousMonthCarryover,
                        adjustedMonthlyBudget: adjustedMonthlyBudget,
                        totalSpent: totalSpent,
                        remainingBudget: remainingBudget,
                        currencyCode: currencyCode,
                        hasCompletedSetup: hasBaselineData
                    )
                    .listRowInsets(Self.cardInsets)
                }

                Section {
                    CategoryOverviewCardView(
                        categorySpending: categorySpending,
                        topCategory: topCategory,
                        currencyCode: currencyCode
                    )
                    .listRowInsets(Self.cardInsets)
                }

                Section {
                    if expenses.isEmpty {
                        Text(hasBaselineData
                             ? "No expenses yet. Tap Add Expense to log your first purchase."
                             : "Complete your budget setup first, then start logging daily expenses.")
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 10)
                    } else {
                        ForEach(expenses) { expense in
                            ExpenseRowView(expense: expense, currencyCode: currencyCode)
                        }
                        .onDelete(perform: deleteExpenses)
                    }
                } header: {
                    Text("Expenses")
                }
            }

            Button {
                showingAddExpense = true
            } label: {
                Label("Add Expense", systemImage: "plus")
                    .font(.headline)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 16)
                    .background(hasBaselineData ? Color.accentColor : Color(uiColor: .systemGray4))
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "gearshape")
                }
                .accessibilityLabel("Settings")
                .accessibilityIdentifier("dashboard.settingsButton")
            }
        }
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
        .sheet(isPresented: $showingSettings) {
            SettingsSheet()
        }
        .fullScreenCover(isPresented: setupCoverBinding) {
            BudgetSettingsSheet(mode: .onboarding)
        }
        .alert("Couldn’t Delete Expense", isPresented: errorAlertBinding) {
            Button("OK", role: .cancel) {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "Something went wrong.")
        }
    }

    private func deleteExpenses(at offsets: IndexSet) {
        do {
            let itemsToDelete = offsets.map { expenses[$0] }

            for expense in itemsToDelete {
                try store.deleteExpense(expense)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private static let cardInsets = EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
}

private struct SummaryCardView: View {
    let monthLabel: String
    let baselineMonthlyBudget: Double
    let carryoverAmount: Double
    let adjustedMonthlyBudget: Double
    let totalSpent: Double
    let remainingBudget: Double
    let currencyCode: String
    let hasCompletedSetup: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if hasCompletedSetup {
                VStack(alignment: .leading, spacing: 12) {
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

                    summaryRow(title: "Available This Month", value: formatted(adjustedMonthlyBudget))
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

private struct ExpenseRowView: View {
    let expense: Expense
    let currencyCode: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(expense.category.color)
                .frame(width: 6)

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Text(expense.title)
                        .font(.body.weight(.medium))
                        .lineLimit(1)

                    Text(expense.category.title)
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
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
                .font(.body.weight(.semibold))
        }
        .padding(.vertical, 6)
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

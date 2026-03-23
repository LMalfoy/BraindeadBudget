/*
 Main tab container for the consolidated product.

 The app is intentionally organized around three time horizons:
 - Dashboard: where do I stand right now?
 - Month: how is the current month distributed?
 - Trends: how are finances changing over time?
 */

import SwiftUI

enum AppTheme {
    static let primaryGreen = Color(red: 0.1294, green: 0.7098, blue: 0.2039)
    static let secondaryGreen = Color(red: 0.5647, green: 0.7373, blue: 0.1020)
    static let warningRed = Color(red: 0.8784, green: 0.2078, blue: 0.1412)
    static let neutralGray = Color(uiColor: .systemGray4)
    static let panelBackground = Color(uiColor: .secondarySystemBackground)

    static let foodCategory = primaryGreen
    static let transportCategory = Color(red: 0.1216, green: 0.3922, blue: 0.6784)
    static let householdCategory = Color(red: 0.9412, green: 0.4863, blue: 0.0706)
    static let funCategory = Color(red: 0.5647, green: 0.2039, blue: 0.5961)

    static let housingCategory = Color(red: 0.0000, green: 0.5843, blue: 0.6745)
    static let subscriptionsCategory = Color(red: 1.0000, green: 0.7608, blue: 0.0000)
    static let insuranceCategory = Color(red: 0.2510, green: 0.2510, blue: 0.6275)
    static let savingsCategory = secondaryGreen
    static let debtCategory = warningRed

    static let variableTrend = foodCategory
    static let recurringTrend = housingCategory
    static let totalTrend = insuranceCategory

    static func categoryColor(for key: String) -> Color {
        switch key {
        case ExpenseCategory.food.rawValue:
            return foodCategory
        case ExpenseCategory.transport.rawValue:
            return transportCategory
        case ExpenseCategory.household.rawValue:
            return householdCategory
        case ExpenseCategory.fun.rawValue:
            return funCategory
        case RecurringExpenseCategory.housingUtilities.rawValue:
            return housingCategory
        case RecurringExpenseCategory.subscriptions.rawValue:
            return subscriptionsCategory
        case RecurringExpenseCategory.insurance.rawValue:
            return insuranceCategory
        case RecurringExpenseCategory.savings.rawValue:
            return savingsCategory
        case RecurringExpenseCategory.debt.rawValue:
            return debtCategory
        default:
            return neutralGray
        }
    }

    static func trendColor(for kind: TrendSeriesKind) -> Color {
        switch kind {
        case .variable:
            return variableTrend
        case .recurring:
            return recurringTrend
        case .total:
            return totalTrend
        }
    }
}

extension ExpenseCategory {
    var color: Color {
        switch self {
        case .food:
            return AppTheme.foodCategory
        case .transport:
            return AppTheme.transportCategory
        case .household:
            return AppTheme.householdCategory
        case .fun:
            return AppTheme.funCategory
        }
    }

    var symbolName: String {
        switch self {
        case .food:
            return "fork.knife"
        case .transport:
            return "car.fill"
        case .household:
            return "house.fill"
        case .fun:
            return "sparkles"
        }
    }
}

extension RecurringExpenseCategory {
    var color: Color {
        switch self {
        case .housingUtilities:
            return AppTheme.housingCategory
        case .subscriptions:
            return AppTheme.subscriptionsCategory
        case .insurance:
            return AppTheme.insuranceCategory
        case .savings:
            return AppTheme.savingsCategory
        case .debt:
            return AppTheme.debtCategory
        }
    }

    var shortTitle: String {
        switch self {
        case .housingUtilities:
            return "Housing"
        case .subscriptions:
            return "Abos"
        case .insurance:
            return "Insurance"
        case .savings:
            return "Savings"
        case .debt:
            return "Debt"
        }
    }

    var symbolName: String {
        switch self {
        case .housingUtilities:
            return "house.fill"
        case .subscriptions:
            return "play.rectangle.fill"
        case .insurance:
            return "shield.fill"
        case .savings:
            return "banknote.fill"
        case .debt:
            return "creditcard.fill"
        }
    }
}

struct ContentView: View {
    private enum Tab: Hashable {
        case dashboard
        case month
        case trends
    }

    @State private var selectedTab: Tab = .dashboard

    var body: some View {
        TabView(selection: $selectedTab) {
            RootTabView {
                DashboardView()
            }
            .tag(Tab.dashboard)
            .tabItem {
                Label("Dashboard", systemImage: "house")
            }

            RootTabView {
                ExpenseHistorySheet()
            }
            .tag(Tab.month)
            .tabItem {
                Label("Month", systemImage: "calendar")
            }

            RootTabView {
                StatsView()
            }
            .tag(Tab.trends)
            .tabItem {
                Label("Trends", systemImage: "chart.line.uptrend.xyaxis")
            }
        }
        .onOpenURL { url in
            guard url.scheme == "budgetrook" else {
                return
            }

            if url.host == "add-expense" {
                selectedTab = .dashboard
                NotificationCenter.default.post(name: .openQuickAddExpense, object: nil)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .openExpenseHistoryMonth)) { _ in
            selectedTab = .month
        }
    }
}

private struct RootTabView<Content: View>: View {
    @State private var showingSettings = false

    @ViewBuilder let content: () -> Content

    var body: some View {
        NavigationStack {
            content()
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                        }
                        .accessibilityIdentifier("root.settingsButton")
                    }
                }
        }
        .sheet(isPresented: $showingSettings) {
            NavigationStack {
                SettingsSheet()
            }
        }
    }
}

extension Notification.Name {
    static let openQuickAddExpense = Notification.Name("openQuickAddExpense")
    static let openExpenseHistoryMonth = Notification.Name("openExpenseHistoryMonth")
}

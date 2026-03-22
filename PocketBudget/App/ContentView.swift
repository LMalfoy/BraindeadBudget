/*
 Main tab container for the consolidated product.

 The app is intentionally organized around three time horizons:
 - Dashboard: where do I stand right now?
 - Month: how is the current month distributed?
 - Trends: how are finances changing over time?
 */

import SwiftUI

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

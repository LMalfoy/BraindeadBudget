/*
 Main tab container for the app.

 This file does not contain business logic. Its job is only to wire the four
 top-level user areas together:
 - Home dashboard
 - Expense history
 - Statistics
 - Settings

 If you want to understand how the app is structured from a user perspective,
 this is the first file to read after `PocketBudgetApp.swift`.
 */

import SwiftUI

struct ContentView: View {
    private enum Tab: Hashable {
        case home
        case history
        case stats
        case settings
    }

    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                DashboardView()
            }
            .tag(Tab.home)
            .tabItem {
                Label("Home", systemImage: "house")
            }

            NavigationStack {
                ExpenseHistorySheet()
            }
            .tag(Tab.history)
            .tabItem {
                Label("History", systemImage: "list.bullet.rectangle")
            }

            NavigationStack {
                StatsView()
            }
            .tag(Tab.stats)
            .tabItem {
                Label("Stats", systemImage: "chart.pie")
            }

            NavigationStack {
                SettingsSheet()
            }
            .tag(Tab.settings)
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
        }
        .onOpenURL { url in
            guard url.scheme == "budgetrook" else {
                return
            }

            if url.host == "add-expense" {
                selectedTab = .home
                NotificationCenter.default.post(name: .openQuickAddExpense, object: nil)
            }
        }
    }
}

extension Notification.Name {
    static let openQuickAddExpense = Notification.Name("openQuickAddExpense")
}

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
    var body: some View {
        TabView {
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }

            NavigationStack {
                ExpenseHistorySheet()
            }
            .tabItem {
                Label("History", systemImage: "list.bullet.rectangle")
            }

            NavigationStack {
                StatsView()
            }
            .tabItem {
                Label("Stats", systemImage: "chart.pie")
            }

            NavigationStack {
                SettingsSheet()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
        }
    }
}

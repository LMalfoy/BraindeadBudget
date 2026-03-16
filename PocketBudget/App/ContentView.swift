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

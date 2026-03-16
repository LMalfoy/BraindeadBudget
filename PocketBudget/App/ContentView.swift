import SwiftUI

struct ContentView: View {
    private enum Tab: Hashable {
        case home
        case history
        case settings
    }

    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(Tab.home)

            NavigationStack {
                ExpenseHistorySheet()
            }
            .tabItem {
                Label("History", systemImage: "list.bullet.rectangle")
            }
            .tag(Tab.history)

            NavigationStack {
                SettingsSheet()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
            .tag(Tab.settings)
        }
    }
}

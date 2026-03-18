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
    @State private var achievementBanner: AchievementUnlockBanner?

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
        .onReceive(NotificationCenter.default.publisher(for: .openExpenseHistoryMonth)) { _ in
            selectedTab = .history
        }
        .overlay(alignment: .top) {
            if let achievementBanner {
                AchievementUnlockToastView(banner: achievementBanner)
                    .padding(.top, 12)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.32, dampingFraction: 0.9), value: achievementBanner)
        .onReceive(NotificationCenter.default.publisher(for: .achievementUnlocked)) { notification in
            guard let title = notification.object as? String else {
                return
            }

            achievementBanner = AchievementUnlockBanner(title: title)

            Task {
                try? await Task.sleep(for: .seconds(2.4))
                await MainActor.run {
                    if achievementBanner?.title == title {
                        achievementBanner = nil
                    }
                }
            }
        }
    }
}

extension Notification.Name {
    static let openQuickAddExpense = Notification.Name("openQuickAddExpense")
    static let openExpenseHistoryMonth = Notification.Name("openExpenseHistoryMonth")
    static let achievementUnlocked = Notification.Name("achievementUnlocked")
}

private struct AchievementUnlockToastView: View {
    let banner: AchievementUnlockBanner

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "rosette")
                .foregroundStyle(.yellow)

            VStack(alignment: .leading, spacing: 2) {
                Text("Achievement unlocked")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(banner.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.primary)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(.regularMaterial, in: Capsule())
        .shadow(color: .black.opacity(0.14), radius: 10, y: 6)
        .padding(.horizontal, 16)
    }
}

/*
 App entry point and global app setup.

 This file is responsible for:
 - launching the SwiftUI app
 - creating the shared SwiftData model container
 - switching between system, light, and dark appearance
 - resetting selected user defaults during UI testing

 If the app fails very early during launch, this is one of the first files to
 inspect, because the SwiftData container is created here.
 */

import Foundation
import SwiftData
import SwiftUI

enum AppAppearanceOption: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system:
            return "System"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

@main
struct PocketBudgetApp: App {
    @AppStorage("appAppearance") private var appAppearance = AppAppearanceOption.system.rawValue

    init() {
        if ProcessInfo.processInfo.arguments.contains("-ui-testing") {
            UserDefaults.standard.removeObject(forKey: "hasCompletedBaselineSetup")
            UserDefaults.standard.removeObject(forKey: "appAppearance")
        }
    }

    private let sharedModelContainer: ModelContainer = {
        let isUITesting = ProcessInfo.processInfo.arguments.contains("-ui-testing")
        let configuration = ModelConfiguration(isStoredInMemoryOnly: isUITesting)

        do {
            return try ModelContainer(
                for: BudgetSettings.self,
                Expense.self,
                IncomeItem.self,
                RecurringExpenseItem.self,
                configurations: configuration
            )
        } catch {
            fatalError("Could not create model container: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(AppAppearanceOption(rawValue: appAppearance)?.colorScheme)
        }
        .modelContainer(sharedModelContainer)
    }
}

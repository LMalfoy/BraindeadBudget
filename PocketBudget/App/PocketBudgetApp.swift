import Foundation
import SwiftData
import SwiftUI

@main
struct PocketBudgetApp: App {
    init() {
        if ProcessInfo.processInfo.arguments.contains("-ui-testing") {
            UserDefaults.standard.removeObject(forKey: "hasCompletedBaselineSetup")
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
        }
        .modelContainer(sharedModelContainer)
    }
}

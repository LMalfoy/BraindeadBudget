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

    private let sharedModelContainer = Self.makeSharedModelContainer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(AppAppearanceOption(rawValue: appAppearance)?.colorScheme)
        }
        .modelContainer(sharedModelContainer)
    }
}
private extension PocketBudgetApp {
    static func makeSharedModelContainer() -> ModelContainer {
        let isUITesting = ProcessInfo.processInfo.arguments.contains("-ui-testing")
        let configuration = makeModelConfiguration(isUITesting: isUITesting)

        do {
            return try makeModelContainer(configuration: configuration)
        } catch {
            guard !isUITesting else {
                fatalError("Could not create model container: \(error)")
            }

            do {
                try resetPersistentStore(at: configuration.url)
                return try makeModelContainer(configuration: configuration)
            } catch {
                fatalError("Could not create model container: \(error)")
            }
        }
    }

    static func makeModelContainer(configuration: ModelConfiguration) throws -> ModelContainer {
        try ModelContainer(
            for: BudgetSettings.self,
            AchievementUnlock.self,
            Expense.self,
            IncomeItem.self,
            RecurringExpenseItem.self,
            configurations: configuration
        )
    }

    static func makeModelConfiguration(isUITesting: Bool) -> ModelConfiguration {
        if isUITesting {
            return ModelConfiguration(isStoredInMemoryOnly: true)
        }

        return ModelConfiguration(url: persistentStoreURL)
    }

    static var persistentStoreURL: URL {
        let applicationSupportURL = URL.applicationSupportDirectory
        let directoryURL = applicationSupportURL.appendingPathComponent("PocketBudget", isDirectory: true)

        try? FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)

        return directoryURL.appendingPathComponent("PocketBudget.store")
    }

    static func resetPersistentStore(at url: URL) throws {
        let fileManager = FileManager.default
        let relatedURLs = [
            url,
            url.appendingPathExtension("shm"),
            url.appendingPathExtension("wal")
        ]

        for relatedURL in relatedURLs where fileManager.fileExists(atPath: relatedURL.path) {
            try fileManager.removeItem(at: relatedURL)
        }
    }
}


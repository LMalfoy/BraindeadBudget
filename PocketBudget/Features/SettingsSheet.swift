import Foundation
import SwiftUI

struct SettingsSheet: View {
    @State private var showingBudgetSettings = false

    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String

        guard let build, build != version else {
            return version
        }

        return "\(version) (\(build))"
    }

    var body: some View {
        Form {
            Section("Budget") {
                Button("Manage Budget") {
                    showingBudgetSettings = true
                }
                .accessibilityIdentifier("settings.manageBudgetButton")
            }

            Section("About") {
                LabeledContent("Version", value: appVersion)
                    .accessibilityIdentifier("settings.versionValue")

                VStack(alignment: .leading, spacing: 6) {
                    Text("Authors")
                        .foregroundStyle(.secondary)

                    Text("Dr. Kevin Sicking")
                    Text("Codex (GPT-5)")
                }
                .accessibilityIdentifier("settings.authorSection")
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingBudgetSettings) {
            BudgetSettingsSheet(mode: .manage)
        }
    }
}

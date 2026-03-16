import SwiftData
import SwiftUI

struct SettingsSheet: View {
    @AppStorage("appAppearance") private var appAppearance = AppAppearanceOption.system.rawValue
    @AppStorage("hasCompletedBaselineSetup") private var hasCompletedSetup = false
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BudgetSettings.updatedAt, order: .reverse) private var budgets: [BudgetSettings]

    @State private var showingBudgetSettings = false
    @State private var showingResetConfirmation = false
    @State private var errorMessage: String?

    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String

        guard let build, build != version else {
            return version
        }

        return "\(version) (\(build))"
    }

    private var store: BudgetStore {
        BudgetStore(context: modelContext)
    }

    private var selectedCurrencyCode: Binding<String> {
        Binding(
            get: { budgets.first?.currencyCode ?? Locale.current.currency?.identifier ?? "USD" },
            set: { newValue in
                do {
                    try store.saveSettings(currencyCode: newValue)
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        )
    }

    private var selectedBudgetPeriodAnchorDay: Binding<Int> {
        Binding(
            get: { budgets.first?.budgetPeriodAnchorDay ?? 1 },
            set: { newValue in
                do {
                    try store.saveBudgetPeriodAnchorDay(newValue)
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        )
    }

    private var availableCurrencies: [String] {
        Locale.commonISOCurrencyCodes.sorted()
    }

    var body: some View {
        Form {
            Section("Preferences") {
                Picker("Appearance", selection: $appAppearance) {
                    ForEach(AppAppearanceOption.allCases) { option in
                        Text(option.title).tag(option.rawValue)
                    }
                }
                .accessibilityIdentifier("settings.appearancePicker")

                Picker("Currency", selection: selectedCurrencyCode) {
                    ForEach(availableCurrencies, id: \.self) { code in
                        Text(currencyLabel(for: code)).tag(code)
                    }
                }
                .accessibilityIdentifier("settings.currencyPicker")
            }

            Section("Budget") {
                Stepper(value: selectedBudgetPeriodAnchorDay, in: 1...28) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Budget Period Starts")
                        Text("Day \(selectedBudgetPeriodAnchorDay.wrappedValue) of each month")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .accessibilityIdentifier("settings.budgetPeriodAnchorStepper")

                Button("Manage Budget") {
                    showingBudgetSettings = true
                }
                .accessibilityIdentifier("settings.manageBudgetButton")
            }

            Section("Danger Zone") {
                VStack(alignment: .leading, spacing: 8) {
                    Button("Erase All Data", role: .destructive) {
                        showingResetConfirmation = true
                    }
                    .accessibilityIdentifier("settings.eraseAllDataButton")

                    Text("This permanently removes your budget setup, expenses, recurring costs, and statistics history.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
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
        .alert("Erase All Data?", isPresented: $showingResetConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Erase All Data", role: .destructive) {
                eraseAllData()
            }
        } message: {
            Text("This will permanently reset BudgetRook and return you to onboarding.")
        }
        .alert("Settings Error", isPresented: Binding(
            get: { errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    errorMessage = nil
                }
            }
        )) {
            Button("OK", role: .cancel) {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "Something went wrong.")
        }
    }

    private func currencyLabel(for code: String) -> String {
        let name = Locale.current.localizedString(forCurrencyCode: code) ?? code
        return "\(code) - \(name)"
    }

    private func eraseAllData() {
        do {
            try store.eraseAllData()
            hasCompletedSetup = false
            appAppearance = AppAppearanceOption.system.rawValue
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

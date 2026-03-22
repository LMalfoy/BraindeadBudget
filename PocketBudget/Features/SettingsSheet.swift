/*
 App-level settings screen.

 This view collects controls that do not belong on the dashboard:
 - budget management entry point
 - currency
 - budget-period anchor day
 - appearance
 - erase-all-data reset
 - app/about information

 It is intentionally kept practical and small so the app stays easy to use.
 */

import SwiftData
import SwiftUI

struct SettingsSheet: View {
    private let budgetPeriodColumns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 7)

    @AppStorage("appAppearance") private var appAppearance = AppAppearanceOption.system.rawValue
    @AppStorage("hasCompletedBaselineSetup") private var hasCompletedSetup = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BudgetSettings.updatedAt, order: .reverse) private var budgets: [BudgetSettings]

    @State private var showingBudgetSettings = false
    @State private var showingBudgetPeriodAnchorPicker = false
    @State private var showingAboutInfo = false
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
            Section("Budget") {
                Button {
                    showingBudgetSettings = true
                } label: {
                    HStack {
                        Text("Manage Budget")

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("settings.manageBudgetButton")

                Picker("Currency", selection: selectedCurrencyCode) {
                    ForEach(availableCurrencies, id: \.self) { code in
                        Text(currencyLabel(for: code)).tag(code)
                    }
                }
                .accessibilityIdentifier("settings.currencyPicker")

                Button {
                    showingBudgetPeriodAnchorPicker = true
                } label: {
                    HStack {
                        Text("Budget Period Starts")

                        Spacer()

                        Text("Day \(selectedBudgetPeriodAnchorDay.wrappedValue)")
                            .foregroundStyle(.secondary)

                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("settings.budgetPeriodAnchorButton")
            }

            Section("Appearance") {
                Picker("Appearance", selection: $appAppearance) {
                    ForEach(AppAppearanceOption.allCases) { option in
                        Text(option.title).tag(option.rawValue)
                    }
                }
                .accessibilityIdentifier("settings.appearancePicker")
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

            Section {
                LabeledContent("Version", value: appVersion)
                    .accessibilityIdentifier("settings.versionValue")

                VStack(alignment: .leading, spacing: 6) {
                    Text("Authors")
                        .foregroundStyle(.secondary)

                    Text("Dr. Kevin Sicking")
                    Text("Codex (GPT-5)")
                }
                .accessibilityIdentifier("settings.authorSection")

            } header: {
                HStack {
                    Text("About")

                    Spacer()

                    Button {
                        showingAboutInfo = true
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("settings.aboutInfoButton")
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showingBudgetSettings) {
            BudgetSettingsSheet(mode: .manage)
        }
        .sheet(isPresented: $showingAboutInfo) {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("BudgetRook is a simple personal budgeting app built around one core question: how much money is left in the current month?")
                            .foregroundStyle(.secondary)

                        Text("Dashboard shows the current month instantly, Month explains how the current month is distributed, and Trends shows how recent months are changing.")
                            .foregroundStyle(.secondary)

                        Text("The app is designed to stay lightweight, clear, and focused on monthly financial awareness.")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                }
                .navigationTitle("About BudgetRook")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            showingAboutInfo = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingBudgetPeriodAnchorPicker) {
            NavigationStack {
                ScrollView {
                    LazyVGrid(columns: budgetPeriodColumns, spacing: 10) {
                        ForEach(1..<31) { day in
                            Button {
                                selectedBudgetPeriodAnchorDay.wrappedValue = day
                                showingBudgetPeriodAnchorPicker = false
                            } label: {
                                Text("\(day)")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 42)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(selectedBudgetPeriodAnchorDay.wrappedValue == day ? Color.accentColor : Color(uiColor: .secondarySystemBackground))
                                    )
                                    .foregroundStyle(selectedBudgetPeriodAnchorDay.wrappedValue == day ? Color.white : Color.primary)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("settings.budgetPeriodAnchorDay.\(day)")
                        }
                    }
                    .padding(20)
                }
                .navigationTitle("Budget Period")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            showingBudgetPeriodAnchorPicker = false
                        }
                    }
                }
            }
            .presentationDetents([.height(320)])
            .presentationDragIndicator(.visible)
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

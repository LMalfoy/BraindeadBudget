import SwiftData
import SwiftUI

struct SettingsSheet: View {
    private let budgetPeriodColumns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 7)

    @AppStorage("appAppearance") private var appAppearance = AppAppearanceOption.system.rawValue
    @AppStorage("hasCompletedBaselineSetup") private var hasCompletedSetup = false
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BudgetSettings.updatedAt, order: .reverse) private var budgets: [BudgetSettings]

    @State private var showingBudgetSettings = false
    @State private var showingBudgetPeriodAnchorPicker = false
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

                VStack(alignment: .leading, spacing: 6) {
                    Text("Chess Icons")
                        .foregroundStyle(.secondary)

                    Text("Cburnett chess set via Wikimedia Commons / Wikipedia")
                    Text("Transparent light and dark piece variants used in-app")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .accessibilityIdentifier("settings.chessIconsSection")
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingBudgetSettings) {
            BudgetSettingsSheet(mode: .manage)
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

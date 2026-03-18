import SwiftUI
import WidgetKit

struct QuickAddWidgetEntry: TimelineEntry {
    let date: Date
}

struct QuickAddWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuickAddWidgetEntry {
        QuickAddWidgetEntry(date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (QuickAddWidgetEntry) -> Void) {
        completion(QuickAddWidgetEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuickAddWidgetEntry>) -> Void) {
        let entry = QuickAddWidgetEntry(date: .now)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct QuickAddWidgetEntryView: View {
    var entry: QuickAddWidgetEntry

    var body: some View {
        Link(destination: URL(string: "budgetrook://add-expense")!) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.green)

                Spacer()

                Text("Quick Add Expense")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text("Tap to add")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(16)
            .containerBackground(for: .widget) {
                Color(uiColor: .systemBackground)
            }
        }
    }
}

struct QuickAddExpenseWidget: Widget {
    let kind = "QuickAddExpenseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuickAddWidgetProvider()) { entry in
            QuickAddWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Quick Add Expense")
        .description("Open BudgetRook directly in the expense entry flow.")
        .supportedFamilies([.systemSmall])
    }
}

@main
struct QuickAddWidgetBundle: WidgetBundle {
    var body: some Widget {
        QuickAddExpenseWidget()
    }
}

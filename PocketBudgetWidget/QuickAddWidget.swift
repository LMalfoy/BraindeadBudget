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
            VStack(spacing: 12) {
                Spacer(minLength: 0)

                Text("Add Expense")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.7)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(red: 0.1294, green: 0.7098, blue: 0.2039))
            )
            .padding(10)
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

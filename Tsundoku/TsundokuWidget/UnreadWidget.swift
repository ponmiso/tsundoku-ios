import SwiftUI
import WidgetKit

struct UnreadProvider: TimelineProvider {
    func placeholder(in context: Context) -> UnreadWidgetEntry {
        UnreadWidgetEntry(date: .now, configuration: "placeholder")
    }

    func getSnapshot(in context: Context, completion: @escaping (UnreadWidgetEntry) -> Void) {
        // TODO: 実際のデータを注入する
        let entry = UnreadWidgetEntry(date: .now, configuration: "getSnapshot")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<UnreadWidgetEntry>) -> Void) {
        // TODO: 実際のデータを注入する
        let entry = UnreadWidgetEntry(date: .now, configuration: "getTimeline")
        let next = Calendar.current.date(byAdding: .hour, value: 6, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct UnreadWidgetEntry: TimelineEntry {
    let date: Date
    let configuration: String  // TODO: 実際のデータにする
}

// TODO: 実際のデータにする
// TODO: サイズに合わせてViewを変更する
struct UnreadWidgetEntryView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: UnreadProvider.Entry

    var body: some View {
        VStack {
            Text("Time:")
            Text(entry.date, style: .time)

            Text("func:")
            Text(entry.configuration)
        }
    }
}

struct UnreadWidget: Widget {
    let kind: String = "UnreadWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: UnreadProvider()) { entry in
            UnreadWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName(.trackingUnreadBooks)
        .description(.youCanCheckTheProgressOfYourUnreadBooks)
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemSmall) {
    UnreadWidget()
} timeline: {
    UnreadWidgetEntry(date: .now, configuration: "hoge")
}

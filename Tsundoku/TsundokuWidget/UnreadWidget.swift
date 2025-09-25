import SwiftUI
import WidgetKit

struct UnreadWidget: Widget {
    let kind: String = "UnreadWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: UnreadProvider()) { entry in
            UnreadWidgetView(entry: entry)
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
    let books = [
        CodableBook(title: "Harry Potter", currentPage: 10, maxPage: 100),
        CodableBook(title: "ONE PIECE 1"),
        CodableBook(title: "パンどろぼう"),
    ]
    UnreadWidgetEntry(date: .now, books: books)
    UnreadWidgetEntry(date: .now, books: [])
}

//
//  DateWidget.swift
//  DateWidget
//
//  Created by Khoren Katklian on 05/04/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import WidgetKit
import SwiftUI
import KurozoraKit

struct Provider: IntentTimelineProvider {
	func placeholder(in context: Context) -> DateEntry {
		return DateEntry(
			date: Date(),
			banner: Banner(
				image: UIImage(named: "starry_sky"),
				url: nil,
				height: 1080,
				width: 1920,
				backgroundColor: UIColor(hexString: "#1e1731")?.color,
				textColor1: UIColor(hexString: "#140f29")?.color,
				textColor2: UIColor(hexString: "#c06145")?.color,
				textColor3: UIColor(hexString: "#69353e")?.color,
				textColor4: UIColor(hexString: "#232d51")?.color
			),
			showDate: true
		)
    }

	func getSnapshot(for configuration: ToggleDateIntent, in context: Context, completion: @escaping (DateEntry) -> Void) {
		Task {
			// Fetch a random anime image from server
			let date = Date()
			guard let mediaResponse = try? await KService.getRandomImages(of: configuration.kind.kkMediaKind, from: configuration.collection.kkMediaCollection).value else { return }
			guard let media = mediaResponse.data.first else { return }
			let entry: DateEntry

			if context.isPreview {
				entry = DateEntry(date: date, banner: await media.asBanner(), showDate: configuration.showDate == true)
			} else {
				entry = DateEntry(date: date, banner: await media.asBanner(), showDate: configuration.showDate == true)
			}

			completion(entry)
		}
	}

	func getTimeline(for configuration: ToggleDateIntent, in context: Context, completion: @escaping (Timeline<DateEntry>) -> Void) {
		Task {
			// Fetch a random anime images from server
			let limit = 3
			guard let mediaResponse = try? await KService.getRandomImages(of: configuration.kind.kkMediaKind, from: configuration.collection.kkMediaCollection, limit: limit).value else { return }
			let date = Date()
			var entries: [DateEntry] = []

			for (index, media) in mediaResponse.data.enumerated() {
				entries.append(DateEntry(date: date.adding(.hour, value: index), banner: await media.asBanner(), showDate: configuration.showDate == true))
			}

			// Next fetch happens 1 hour later
			let nextUpdate = Calendar.current.date(byAdding: DateComponents(hour: limit), to: date)!
			let timeline = Timeline(entries: entries, policy: .after(nextUpdate))

			completion(timeline)
		}
	}
}

struct DateEntry: TimelineEntry {
    let date: Date
    let banner: Banner
	let showDate: Bool
}

struct Banner {
	/// The image of the media.
	public let image: UIImage?

	/// The url of the media.
	public let url: URL?

	/// The height of the media.
	public let height: Int?

	/// The width of the media.
	public let width: Int?

	/// The background color of the media.
	public let backgroundColor: Color?

	/// The primary text color of the media.
	public let textColor1: Color?

	/// The secondary text color of the media.
	public let textColor2: Color?

	/// The tertiary text color of the media.
	public let textColor3: Color?

	/// The quaternary text color of the media.
	public let textColor4: Color?
}

struct DateWidgetEntryView: View {
	@Environment(\.widgetFamily) var family: WidgetFamily
	@Environment(\.widgetContentMarginsWithFallback) var margins

    var entry: Provider.Entry

    var body: some View {
		switch family {
		default:
			ZStack {
				if let image = self.entry.banner.image {
					GeometryReader { geometry in
						Image(uiImage: image)
							.resizable()
							.scaledToFill()
							.overlay {
								self.entry.banner.backgroundColor?.opacity(0.25)
							}
							.frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
					}
				} else if let url = self.entry.banner.url, let image = try? UIImage(url: url) {
					GeometryReader { geometry in
						Image(uiImage: image)
							.resizable()
							.scaledToFill()
							.overlay {
								self.entry.banner.backgroundColor?.opacity(0.25)
							}
							.frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
					}
				}

				if self.entry.showDate {
					VStack(spacing: .zero) {
						VStack(spacing: .zero) {
							Text(self.entry.date, format: .dateTime.weekday(.wide))
								.font(.headline)
								.fontWeight(.bold)
								.foregroundColor(.white)
								.frame(maxWidth: .infinity, alignment: .leading)

							Text(self.entry.date, format: .dateTime.day())
								.font(.largeTitle)
								.fontWeight(.bold)
								.foregroundColor(.white)
								.frame(maxWidth: .infinity, alignment: .leading)
						}

						Spacer()
					}
					.padding(self.margins)
				}
			}
		}
    }
}

struct DateWidget: Widget {
    let kind: String = "DateWidget"

    var body: some WidgetConfiguration {
		IntentConfiguration(kind: self.kind, intent: ToggleDateIntent.self, provider: Provider()) { entry in
			if #available(macOS 14.0, iOS 17.0, *) {
				DateWidgetEntryView(entry: entry)
					.containerBackground(.fill.secondary, for: .widget)
			} else {
				DateWidgetEntryView(entry: entry)
					.background()
			}
		}
        .configurationDisplayName("Anime Date")
        .description("Track the current date with a random anime image every hour.")
		.contentMarginsDisabled()
    }
}

#if DEBUG
@available(iOS 17, macOS 14, *)
#Preview("System Small", as: .systemSmall) {
	DateWidget()
} timeline: {
	let date: Date = .now

	DateEntry(date: date, banner: Banner(image: UIImage(named: "starry_sky"), url: nil, height: nil, width: nil, backgroundColor: nil, textColor1: nil, textColor2: nil, textColor3: nil, textColor4: nil), showDate: true)
	DateEntry(date: date.adding(.second, value: 5), banner: Banner(image: UIImage(named: "starry_sky"), url: nil, height: nil, width: nil, backgroundColor: nil, textColor1: nil, textColor2: nil, textColor3: nil, textColor4: nil), showDate: true)
	DateEntry(date: date.adding(.second, value: 10), banner: Banner(image: UIImage(named: "starry_sky"), url: nil, height: nil, width: nil, backgroundColor: nil, textColor1: nil, textColor2: nil, textColor3: nil, textColor4: nil), showDate: true)
}

@available(iOS 17, macOS 14, *)
#Preview("System Extra Large", as: .systemExtraLarge) {
	DateWidget()
} timeline: {
	let date: Date = .now

	DateEntry(date: date, banner: Banner(image: UIImage(named: "starry_sky"), url: nil, height: nil, width: nil, backgroundColor: nil, textColor1: nil, textColor2: nil, textColor3: nil, textColor4: nil), showDate: false)
	DateEntry(date: date.adding(.second, value: 5), banner: Banner(image: UIImage(named: "starry_sky"), url: nil, height: nil, width: nil, backgroundColor: nil, textColor1: nil, textColor2: nil, textColor3: nil, textColor4: nil), showDate: false)
	DateEntry(date: date.adding(.second, value: 10), banner: Banner(image: UIImage(named: "starry_sky"), url: nil, height: nil, width: nil, backgroundColor: nil, textColor1: nil, textColor2: nil, textColor3: nil, textColor4: nil), showDate: false)
}
#endif

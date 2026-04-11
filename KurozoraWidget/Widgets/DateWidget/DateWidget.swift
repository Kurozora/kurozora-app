//
//  DateWidget.swift
//  DateWidget
//
//  Created by Khoren Katklian on 05/04/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import KurozoraKit
import SwiftUI
import WidgetKit

struct Provider: IntentTimelineProvider {
	func placeholder(in context: Context) -> DateEntry {
		let image = ImageFetcher.shared.fetchRandomImage() ?? UIImage(named: "starry_sky")

		return DateEntry(
			date: Date(),
			banner: Banner(
				image: image?.resized(toWidth: context.displaySize.width),
				height: Int(image?.size.height ?? 1080),
				width: Int(image?.size.width ?? 1920),
				deeplinkURL: nil
			),
			isDimmed: true,
			isAdaptive: true,
			isDateShown: true,
			fontStyle: .defaultStyle,
			fontWeight: .bold,
			fontWidth: .standard
		)
	}

	func getSnapshot(for configuration: ToggleDateIntent, in context: Context, completion: @escaping (DateEntry) -> Void) {
		Task {
			// Fetch a random anime image from server
			let date = Date()
			guard let mediaResponse = try? await KService.getRandomImages(of: configuration.kind.kkMediaKind, from: configuration.collection.kkMediaCollection).value else {
				completion(self.placeholder(in: context))
				return
			}
			guard let media = mediaResponse.data.first else {
				completion(self.placeholder(in: context))
				return
			}
			let entry: DateEntry

			if context.isPreview {
				entry = self.placeholder(in: context)
			} else {
				entry = DateEntry(
					date: date,
					banner: await media.asBanner(),
					isDimmed: configuration.isDimmed == true,
					isAdaptive: configuration.isAdaptive == true,
					isDateShown: configuration.isDateShown == true,
					fontStyle: configuration.font,
					fontWeight: configuration.fontWeight,
					fontWidth: configuration.fontWidth
				)
			}

			completion(entry)
		}
	}

	func getTimeline(for configuration: ToggleDateIntent, in context: Context, completion: @escaping (Timeline<DateEntry>) -> Void) {
		Task {
			// Fetch a random anime images from server
			let limit = 3
			guard let mediaResponse = try? await KService.getRandomImages(of: configuration.kind.kkMediaKind, from: configuration.collection.kkMediaCollection, limit: limit).value else {
				let date = Date()
				let nextUpdate = Calendar.current.date(byAdding: DateComponents(hour: 1), to: date)!
				let entry = self.placeholder(in: context)
				let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
				completion(timeline)
				return
			}
			let date = Date()
			var entries: [DateEntry] = []
			let calendar = Calendar.current

			for (index, media) in mediaResponse.data.enumerated() {
				let entryDate = calendar.date(byAdding: .hour, value: index, to: date) ?? date

				entries.append(
					DateEntry(
						date: entryDate,
						banner: await media.asBanner(),
						isDimmed: configuration.isDimmed == true,
						isAdaptive: configuration.isAdaptive == true,
						isDateShown: configuration.isDateShown == true,
						fontStyle: configuration.font,
						fontWeight: configuration.fontWeight,
						fontWidth: configuration.fontWidth
					)
				)
			}

			// Next fetch after last entry
			let timeline = Timeline(entries: entries, policy: .atEnd)
			completion(timeline)
		}
	}
}

struct DateEntry: TimelineEntry {
	let date: Date

	/// The banner to display.
	let banner: Banner

	/// Specifies whether to dim the image.
	let isDimmed: Bool

	/// Specifies whether to adapt to `accent` and `vibrant` modes.
	let isAdaptive: Bool

	/// Specifies whether to show the date.
	let isDateShown: Bool

	/// The font style.
	let fontStyle: IntentFont

	/// The font weight.
	let fontWeight: IntentFontWeight

	/// The font width.
	let fontWidth: IntentFontWidth
}

struct Banner {
	/// The image of the media.
	let image: UIImage?

	/// The height of the media.
	let height: Int?

	/// The width of the media.
	let width: Int?

	/// The deeplink URL of the media.
	let deeplinkURL: URL?
}

struct DateWidget: Widget {
	let kind: String = "app.kurozora.tracker.dateWidget"

	var body: some WidgetConfiguration {
		IntentConfiguration(
			kind: self.kind,
			intent: ToggleDateIntent.self,
			provider: Provider()
		) { entry in
			if #available(iOS 17.0, tvOS 17.0, macOS 14.0, watchOS 10.0, *) {
				DateWidgetEntryView16(entry: entry)
					.containerBackground(.fill.secondary, for: .widget)
			} else if #available(iOS 16.0, tvOS 16.0, macOS 13.0, watchOS 9.0, *) {
				DateWidgetEntryView16(entry: entry)
					.background()
			} else {
				DateWidgetEntryView(entry: entry)
					.background()
			}
		}
		.configurationDisplayName("Date")
		.description("Track the current date with random anime, manga or game images every hour.")
		.contentMarginsDisabled()
	}
}

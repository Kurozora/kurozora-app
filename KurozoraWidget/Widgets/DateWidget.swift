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
			fontStyle: .system
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
					fontStyle: configuration.font
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
						fontStyle: configuration.font
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

	/// Specify font style
	let fontStyle: IntentFont
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

@available(iOS 16.0, watchOS 9.0, macOS 13.0, *)
struct DateWidgetEntryView16: View, LocationAwareWidget {
	@Environment(\.widgetFamily) var widgetFamily
	@Environment(\.widgetRenderingMode) var widgetRenderingMode
	@Environment(\.showsWidgetContainerBackground) var showsWidgetContainerBackground

	var entry: Provider.Entry

	var body: some View {
		if self.entry.isAdaptive && (self.widgetRenderingMode == .accented) {
			self.widgetView
				.widgetAccentable()
		} else {
			self.widgetView
		}
	}

	@ViewBuilder
	var widgetView: some View {
		DateWidgetEntryContentView(
			entry: self.entry,
			isPhoneStandByWidget: self.isPhoneStandByWidget,
			isVibrant: self.widgetRenderingMode == .vibrant,
			isAccented: self.widgetRenderingMode == .accented
		)
	}
}

struct DateWidgetEntryView: View {
	var entry: Provider.Entry

	var body: some View {
		DateWidgetEntryContentView(
			entry: self.entry,
			isPhoneStandByWidget: false,
			isVibrant: false,
			isAccented: false
		)
	}
}

struct DateWidgetEntryContentView: View {
	@Environment(\.widgetFamily) var family
	@Environment(\.widgetContentMarginsWithFallback) var margins
	@Environment(\.showsWidgetContainerBackground) var showsContainerBackground

	var entry: Provider.Entry
	var isPhoneStandByWidget: Bool
	var isVibrant: Bool
	var isAccented: Bool

	var body: some View {
		if !self.isPhoneStandByWidget, self.isVibrant || self.isAccented, self.entry.isAdaptive, self.showsContainerBackground {
			self.widgetView
				.luminanceToAlpha()
		} else {
			self.widgetView
		}
	}

	@ViewBuilder
	var widgetView: some View {
		ZStack {
			GeometryReader { geometry in
				if #available(iOS 18.0, watchOS 11.0, macOS 15.0, *), self.showsContainerBackground {
					self.imageView(geometry: geometry)
						.widgetAccentedRenderingMode(.fullColor)
						.scaledToFill()
						.overlay {
							if self.entry.isDimmed {
								Color.black.opacity(0.20)
							}
						}
						.frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
				} else {
					self.imageView(geometry: geometry)
						.scaledToFill()
						.overlay {
							if self.entry.isDimmed {
								Color.black.opacity(0.20)
							}
						}
						.frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
						.clipShape(ContainerRelativeShape())
				}
			}

			if self.entry.isDateShown {
				self.dateView
			}
		}
		.widgetURL(self.entry.banner.deeplinkURL)
	}

	@ViewBuilder
	var dateView: some View {
		let isAdaptive = self.entry.isAdaptive && (self.isVibrant || self.isAccented)

		VStack(spacing: .zero) {
			VStack(spacing: .zero) {
				ZStack {
					self.weekDayView(isAdaptive: isAdaptive)
				}
				.background {
					self.weekDayView(isAdaptive: isAdaptive)
				}

				ZStack {
					self.dayView(isAdaptive: isAdaptive)
				}
				.background {
					self.dayView(isAdaptive: isAdaptive)
				}
			}
			.frame(maxWidth: .infinity, alignment: .leading)

			Spacer()
		}
		.padding(self.margins)
		.padding(self.isPhoneStandByWidget || self.showsContainerBackground ? .zero : 8)
	}

	func weekDayView(isAdaptive: Bool) -> some View {
		Text(self.entry.date, format: .dateTime.weekday(.wide))
			.font(self.entry.fontStyle.toFontStyle(.caption).weight(.black))
			.fontWeight(.black)
			.foregroundStyle(.white)
//			.stroke(.black, lineWidth: isAdaptive ? 1 : 0)
			.shadow(color: .black.opacity(0.35), radius: 2)
	}

	func dayView(isAdaptive: Bool) -> some View {
		Text(self.entry.date, format: .dateTime.day())
			.font(self.entry.fontStyle.toFontStyle(.title).weight(.black))
			.fontWeight(.black)
			.foregroundStyle(.white)
//			.stroke(.black, lineWidth: isAdaptive ? 1 : 0)
			.shadow(color: .black.opacity(0.35), radius: 2)
	}

	func imageView(geometry: GeometryProxy) -> Image {
		if let image = self.entry.banner.image?.resized(toWidth: geometry.size.width) {
			return Image(uiImage: image)
				.resizable()
		}
		return Image("starry_sky")
			.resizable()
	}
}

#if DEBUG
@available(iOS 17.0, macOS 14.0, *)
#Preview("System Medium", as: .systemMedium) {
	DateWidget()
} timeline: {
	DateEntry(
		date: Date(),
		banner: Banner(
			image: UIImage(named: "starry_sky"),
			height: 1080,
			width: 1920,
			deeplinkURL: nil
		),
		isDimmed: false,
		isAdaptive: false,
		isDateShown: true,
		fontStyle: .system
	)
}

@available(iOS 17, macOS 14, *)
#Preview("System Extra Large", as: .systemExtraLarge) {
	DateWidget()
} timeline: {
	DateEntry(
		date: Date(),
		banner: Banner(
			image: UIImage(named: "starry_sky"),
			height: 1080,
			width: 1920,
			deeplinkURL: nil
		),
		isDimmed: false,
		isAdaptive: false,
		isDateShown: false,
		fontStyle: .system
	)
}
#endif

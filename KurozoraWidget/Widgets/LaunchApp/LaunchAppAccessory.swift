//
//  LaunchAppAccessory.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/07/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import SwiftUI
import WidgetKit

@available(iOS 17.0, macOS 26.0, watchOS 9.0, visionOS 26.0, *)
@available(tvOS, unavailable)
struct LaunchAppAccessory: Widget {
	static let kind: String = "app.kurozora.tracker.launchAppAccessory"

	var body: some WidgetConfiguration {
		AppIntentConfiguration(
			kind: Self.kind,
			intent: LaunchAppIntent.self,
			provider: LaunchAppProvider()
		) { entry in
			LaunchAppAccessoryView(entry: entry)
		}
		.supportedFamilies([
			.accessoryCircular,
			.accessoryRectangular,
		])
		.configurationDisplayName("Kurozora")
		.description("Quikly launch the Kurozora app")
		.contentMarginsDisabled()
	}
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
@available(tvOS, unavailable)
struct AccessoryCircularView: View {
	var body: some View {
		Image("Symbols/kurozora")
			.resizable()
			.scaledToFit()
			.frame(height: 52)
			.widgetAccentable()
			.widgetBackground(AccessoryWidgetBackground())
	}
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
@available(tvOS, unavailable)
struct AccessoryRectangularWidget: View {
	let entry: LaunchAppProvider.Entry

	var body: some View {
		HStack {
			Image("Symbols/kurozora")
				.resizable()
				.scaledToFit()
				.frame(height: 36)

			Text(self.entry.screen.name)
				.font(.headline)
				.frame(maxWidth: .infinity, alignment: .leading)
		}
		.widgetAccentable()
		.widgetBackground(AccessoryWidgetBackground())
	}
}

// MARK: - Models
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
@available(tvOS, unavailable)
struct LaunchAppAccessoryView: View {
	@Environment(\.widgetFamily) var widgetFamily

	let entry: LaunchAppProvider.Entry

	var body: some View {
		switch self.widgetFamily {
		case .accessoryCircular:
			AccessoryCircularView()
		case .accessoryRectangular:
			AccessoryRectangularWidget(entry: self.entry)
		default:
			AccessoryCircularView()
		}
	}
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
struct LaunchAppEntry: TimelineEntry {
	let date: Date
	let screen: LaunchAppEnum
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
struct LaunchAppProvider: AppIntentTimelineProvider {
	func placeholder(in context: Context) -> LaunchAppEntry {
		return LaunchAppEntry(
			date: Date(),
			screen: .home
		)
	}

	func snapshot(for configuration: LaunchAppIntent, in context: Context) async -> LaunchAppEntry {
		let entry: LaunchAppEntry

		if context.isPreview {
			entry = self.placeholder(in: context)
		} else {
			entry = LaunchAppEntry(date: Date(), screen: configuration.target)
		}

		return entry
	}

	func timeline(for configuration: LaunchAppIntent, in context: Context) async -> Timeline<LaunchAppEntry> {
		return Timeline(
			entries: [
				LaunchAppEntry(
					date: Date(),
					screen: configuration.target
				),
			],
			policy: .never
		)
	}
}

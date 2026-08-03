//
//  DateWidgetViews.swift
//  KurozoraWidgetExtension
//
//  Created by Khoren Katklian on 05/04/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import SwiftUI
import WidgetKit

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
			.font(self.entry.fontStyle.toFont(.caption))
			.modifier(self.fontTraitsModifier)
			.foregroundStyle(.white)
//			.stroke(.black, lineWidth: isAdaptive ? 1 : 0)
			.shadow(color: .black.opacity(0.35), radius: 2)
	}

	func dayView(isAdaptive: Bool) -> some View {
		Text(self.entry.date, format: .dateTime.day())
			.font(self.entry.fontStyle.toFont(.title))
			.modifier(self.fontTraitsModifier)
			.foregroundStyle(.white)
//			.stroke(.black, lineWidth: isAdaptive ? 1 : 0)
			.shadow(color: .black.opacity(0.35), radius: 2)
	}

	private var fontTraitsModifier: FontTraitsModifier {
		FontTraitsModifier(
			fontStyle: self.entry.fontStyle,
			fontWeight: self.entry.fontWeight,
			fontWidth: self.entry.fontWidth
		)
	}

	func imageView(geometry: GeometryProxy) -> Image {
		if let image = self.entry.banner.image?.resized(toWidth: geometry.size.width) {
			return Image(uiImage: image)
				.resizable()
		}
		return Image(.starrySky)
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
			image: .starrySky,
			height: 1080,
			width: 1920,
			deeplinkURL: nil
		),
		isDimmed: false,
		isAdaptive: false,
		isDateShown: true,
		fontStyle: .defaultStyle,
		fontWeight: .bold,
		fontWidth: .standard
	)
}

@available(iOS 17, macOS 14, *)
#Preview("System Extra Large", as: .systemExtraLarge) {
	DateWidget()
} timeline: {
	DateEntry(
		date: Date(),
		banner: Banner(
			image: .starrySky,
			height: 1080,
			width: 1920,
			deeplinkURL: nil
		),
		isDimmed: false,
		isAdaptive: false,
		isDateShown: false,
		fontStyle: .defaultStyle,
		fontWeight: .bold,
		fontWidth: .standard
	)
}
#endif

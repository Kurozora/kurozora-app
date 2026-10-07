//
//  UpNextSharedViews.swift
//  KurozoraWidgetExtension
//
//  Created by Khoren Katklian on 13/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import AppIntents
import SwiftUI
import WidgetKit

// MARK: - Banner Image
struct UpNextBannerImage: View {
	let image: UIImage?
	let backgroundColorHex: String?

	var body: some View {
		if let image = self.image {
			if #available(iOS 18.0, *) {
				Image(uiImage: image)
					.resizable()
					.widgetAccentedRenderingMode(.fullColor)
					.scaledToFill()
			} else {
				Image(uiImage: image)
					.resizable()
					.scaledToFill()
			}
		} else if let hex = self.backgroundColorHex {
			Color(hex: hex)
		} else {
			Color.gray
				.opacity(0.3)
		}
	}
}

// MARK: - Checkmark Button
@available(iOS 17.0, macOS 14.0, *)
struct UpNextCheckmarkButton: View {
	@Environment(\.redactionReasons) private var redactionReasons
	@Environment(\.widgetRenderingMode) private var widgetRenderingMode

	let episodeID: String
	var font: Font = .body

	var body: some View {
		if self.redactionReasons.contains(.placeholder) {
			Circle()
				.fill(Color(.accent).opacity(0.3))
				.frame(width: self.glyphDiameter, height: self.glyphDiameter)
		} else if PendingWatchedStore.isPending(self.episodeID) {
			Image(systemName: "checkmark.circle.fill")
				.font(self.font)
				.foregroundStyle(Color(.accent).opacity(0.3))
		} else {
			Button(intent: MarkEpisodeWatchedIntent(episodeID: self.episodeID)) {
				Image(systemName: "checkmark.circle.fill")
					.font(self.font)
					.symbolRenderingMode(self.isFullColor ? .palette : .monochrome)
					.foregroundStyle(self.isFullColor ? .white : Color(.accent), Color(.accent))
			}
			.buttonStyle(.plain)
			.mask(Circle())
		}
	}

	/// Whether the widget renders in full color.
	private var isFullColor: Bool {
		return self.widgetRenderingMode == .fullColor
	}

	/// The approximate diameter of the checkmark glyph at the current font.
	private var glyphDiameter: CGFloat {
		switch self.font {
		case .title3: return 22
		case .title2: return 26
		case .title: return 30
		default: return 18
		}
	}
}

// MARK: - Color Hex Extension
extension Color {
	init(hex: String) {
		let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
		let scanner = Scanner(string: hex)
		var rgbValue: UInt64 = 0
		scanner.scanHexInt64(&rgbValue)

		let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
		let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
		let blue = Double(rgbValue & 0x0000FF) / 255.0

		self.init(red: red, green: green, blue: blue)
	}
}

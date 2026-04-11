//
//  Intents+KurozoraWidget.swift
//  KurozoraWidgetExtension
//
//  Created by Khoren Katklian on 07/04/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import KurozoraKit
import SwiftUI

// MARK: - IntentFont
extension IntentFont {
	/// The `Font.Design` corresponding to this font style.
	var fontDesign: Font.Design {
		switch self {
		case .rounded:
			return .rounded
		case .serif:
			return .serif
		case .defaultStyle, .compressed, .unknown:
			return .default
		@unknown default:
			return .default
		}
	}

	/// Whether this style implies compressed width, overriding the user's width selection.
	var isCompressedStyle: Bool {
		return self == .compressed
	}

	/// Returns a `Font` with only the text style and design applied.
	///
	/// Weight and width are applied separately via View modifiers (`.fontWeight()`,
	/// `.fontWidth()`) because setting them on `Font` is unreliable — traits can
	/// be silently dropped when combined with design or text style parameters.
	func toFont(_ textStyle: Font.TextStyle) -> Font {
		return Font.system(textStyle, design: self.fontDesign)
	}

	/// The effective `Font.Width` for this style and the user's width selection.
	@available(iOS 16.0, *)
	func effectiveWidth(for intentWidth: IntentFontWidth) -> Font.Width {
		return self.isCompressedStyle ? .compressed : intentWidth.toFontWidth
	}
}

// MARK: - IntentFontWeight
extension IntentFontWeight {
	/// The SwiftUI `Font.Weight` corresponding to this intent value.
	var toFontWeight: Font.Weight {
		switch self {
		case .regular:
			return .regular
		case .medium:
			return .medium
		case .semibold:
			return .semibold
		case .bold:
			return .bold
		case .heavy:
			return .heavy
		case .black:
			return .black
		case .unknown:
			return .bold
		@unknown default:
			return .bold
		}
	}
}

// MARK: - IntentFontWidth
extension IntentFontWidth {
	/// The SwiftUI `Font.Width` corresponding to this intent value.
	@available(iOS 16.0, *)
	var toFontWidth: Font.Width {
		switch self {
		case .compressed:
			return .compressed
		case .condensed:
			return .condensed
		case .standard:
			return .standard
		case .expanded:
			return .expanded
		case .unknown:
			return .standard
		@unknown default:
			return .standard
		}
	}
}

// MARK: - IntentMediaCollection
extension IntentMediaCollection {
	/// The `MediaCollection` equivalent of `IntentMediaCollection`.
	var kkMediaCollection: MediaCollection {
		switch self {
		case .unknown:
			return .banner
		case .banner:
			return .banner
		case .poster:
			return .poster
		}
	}
}

// MARK: - IntentMediaKind
extension IntentMediaKind {
	/// The `MediaKind` equivalent of `IntentMediaKind`.
	var kkMediaKind: MediaKind {
		switch self {
		case .unknown:
			return .shows
		case .episodes:
			return .episodes
		case .games:
			return .games
		case .literatures:
			return .literatures
		case .shows:
			return .shows
		}
	}
}

// MARK: - Media
extension Media {
	/// Converts `Media` to `Banner`.
	func asBanner() async -> Banner {
		return Banner(
			image: try? await ImageFetcher.shared.fetchImage(from: URL(string: self.url)),
			height: self.height,
			width: self.width,
			deeplinkURL: self.deeplinkURL
		)
	}

	/// The deeplink URL to the relationship of the media.
	var deeplinkURL: URL? {
		if let relationships = self.relationships {
			if let episodes = relationships.episodes?.data.first {
				return URL(string: "kurozora://episodes/\(episodes.id)")
			}
			if let shows = relationships.shows?.data.first {
				return URL(string: "kurozora://shows/\(shows.id)")
			}
			if let games = relationships.games?.data.first {
				return URL(string: "kurozora://games/\(games.id)")
			}
			if let literatures = relationships.literatures?.data.first {
				return URL(string: "kurozora://literatures/\(literatures.id)")
			}
		}

		return nil
	}
}

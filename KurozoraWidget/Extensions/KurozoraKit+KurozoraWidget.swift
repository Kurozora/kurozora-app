//
//  IntentMediaCollection+KurozoraWidget.swift
//  KurozoraWidgetExtension
//
//  Created by Khoren Katklian on 07/04/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import KurozoraKit

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

extension Media {
	/// Converts `Media` to `Banner`.
	func asBanner() async -> Banner {
		return Banner(
			image: nil,
			url: await ImageFetcher.fetchImage(from: URL(string: self.url)),
			height: self.height,
			width: self.width,
			backgroundColor: UIColor(hexString: self.backgroundColor ?? "")?.color
		)
	}
}

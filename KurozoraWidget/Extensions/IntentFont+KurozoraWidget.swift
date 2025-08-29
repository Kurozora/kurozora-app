//
//  IntentFont+KurozoraWidget.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/09/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import SwiftUI

extension IntentFont {
	func toFontStyle(_ textStyle: Font.TextStyle) -> Font {
		switch self {
		case .book:
			return .system(textStyle, design: .rounded)
		case .engraved:
			return .custom("Academy Engraved LET", size: UIFont.preferredFont(forTextStyle: textStyle.toUIFontTextStyle).pointSize)
		case .typewriter:
			return .custom("American Typewriter", size: UIFont.preferredFont(forTextStyle: textStyle.toUIFontTextStyle).pointSize)
		case .system, .unknown:
			return .system(textStyle)
		@unknown default:
			return .system(textStyle)
		}
	}
}

private extension Font.TextStyle {
	var toUIFontTextStyle: UIFont.TextStyle {
		switch self {
		case .largeTitle:
			return .largeTitle
		case .title:
			return .title1
		case .title2:
			return .title2
		case .title3:
			return .title3
		case .headline:
			return .headline
		case .subheadline:
			return .subheadline
		case .body:
			return .body
		case .callout:
			return .callout
		case .footnote:
			return .footnote
		case .caption:
			return .caption1
		case .caption2:
			return .caption2
		case .extraLargeTitle:
			if #available(iOS 17.0, *) {
				return .extraLargeTitle
			}
			return .largeTitle
		case .extraLargeTitle2:
			if #available(iOS 17.0, *) {
				return .extraLargeTitle2
			}
			return .largeTitle
		@unknown default:
			return .body
		}
	}
}

//
//  ProfileImageSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

enum ProfileImageSource: Int, CaseIterable {
	case photos
	case emoji
	case kaomoji
	case monogram
	case characters

	var icon: UIImage? {
		switch self {
		case .photos:
			return UIImage(systemName: "photo.on.rectangle.angled")
		case .emoji:
			return UIImage(systemName: "face.smiling")
		case .kaomoji:
			return UIImage(systemName: "ellipsis.curlybraces")
		case .monogram:
			return UIImage(systemName: "textformat")
		case .characters:
			return UIImage(systemName: "person.2.fill")
		}
	}

	var title: String {
		switch self {
		case .photos:
			return String(localized: "Photos")
		case .emoji:
			return String(localized: "Emoji")
		case .kaomoji:
			return String(localized: "Kaomoji")
		case .monogram:
			return String(localized: "Monogram")
		case .characters:
			return L10n.characters
		}
	}
}

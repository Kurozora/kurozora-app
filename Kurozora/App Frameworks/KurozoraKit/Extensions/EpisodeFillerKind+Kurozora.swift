//
//  EpisodeFillerKind+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/10/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension EpisodeFillerKind {
	// MARK: - Properties
	/// The localized name of a filler kind.
	var stringValue: String {
		switch self {
		case .mangaCanon:
			return L10n.mangaCanon
		case .animeCanon:
			return L10n.animeCanon
		case .mixedCanonFiller:
			return L10n.mixedCanonFiller
		case .filler:
			return L10n.filler
		}
	}

	/// The symbol name of a filler kind.
	var symbolName: String {
		switch self {
		case .mangaCanon:
			return "book.closed"
		case .animeCanon:
			return "tv"
		case .mixedCanonFiller:
			return "circle.lefthalf.filled"
		case .filler:
			return "nosign"
		}
	}

	/// The symbol of a filler kind.
	var image: UIImage? {
		return UIImage(systemName: self.symbolName)
	}
}

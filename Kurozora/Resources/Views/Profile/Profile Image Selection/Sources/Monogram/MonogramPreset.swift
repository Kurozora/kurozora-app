//
//  MonogramPreset.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

enum MonogramFontStyle: Int, CaseIterable {
	case defaultStyle = 0
	case rounded = 1
	case serif = 2
	case compressed = 3

	var title: String {
		switch self {
		case .defaultStyle: return "SF Pro"
		case .rounded: return "Rounded"
		case .serif: return "Serif"
		case .compressed: return "Compressed"
		}
	}
}

struct MonogramPreset: Hashable {
	let id: Int
	let fontStyle: MonogramFontStyle
	let fontWeight: UIFont.Weight
	let backgroundColor: UIColor

	func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}

	static func == (lhs: MonogramPreset, rhs: MonogramPreset) -> Bool {
		return lhs.id == rhs.id
	}
}

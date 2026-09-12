//
//  ShowType.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

enum ShowType: Int, CaseIterable {
	// MARK: - Cases
	case unknown = 1
	case tv = 2
	case movie = 4
	case ova = 3
	case ona = 6
	case tvSpecial = 20
	case special = 5
	case music = 7
	case pv = 22
	case cm = 21

	// MARK: - Properties
	/// The name value of a show type.
	var name: String {
		switch self {
		case .unknown:
			return L10n.unknown
		case .tv:
			return L10n.tv
		case .movie:
			return L10n.movie
		case .ova:
			return L10n.ova
		case .ona:
			return L10n.ona
		case .tvSpecial:
			return L10n.tvSpecial
		case .special:
			return L10n.special
		case .music:
			return L10n.music
		case .pv:
			return L10n.pv
		case .cm:
			return L10n.cm
		}
	}
}

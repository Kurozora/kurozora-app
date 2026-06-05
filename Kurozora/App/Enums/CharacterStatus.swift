//
//  CharacterStatus.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/04/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

enum CharacterStatus: Int, CaseIterable {
	// MARK: - Cases
	case unknown = 0
	case alive = 1
	case deceased = 2
	case missing = 3

	// MARK: - Properties
	/// The title of an astrological sign.
	var title: String {
		switch self {
		case .unknown:
			return L10n.unknown
		case .alive:
			return L10n.alive
		case .deceased:
			return L10n.deceased
		case .missing:
			return L10n.missing
		}
	}
}

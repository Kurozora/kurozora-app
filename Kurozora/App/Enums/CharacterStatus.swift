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

	// MARK: - Propreties
	/// The title of an astrological sign.
	var title: String {
		switch self {
		case .unknown:
			return "Unknown"
		case .alive:
			return "Alive"
		case .deceased:
			return "Deceased"
		case .missing:
			return "Missing"
		}
	}
}

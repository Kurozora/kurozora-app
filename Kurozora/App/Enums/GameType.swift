//
//  GameType.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

enum GameType: Int, CaseIterable {
	// MARK: - Cases
	case fullGame = 19
	case season = 24
	case episode = 23
	case dlc = 17
	case mod = 18

	// MARK: - Properties
	/// The name value of a game type.
	var name: String {
		switch self {
		case .fullGame:
			return L10n.fullGame
		case .season:
			return L10n.season
		case .episode:
			return L10n.episode
		case .dlc:
			return L10n.dlc
		case .mod:
			return L10n.mod
		}
	}
}

//
//  GameType.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

enum GameType: Int, CaseIterable {
	// MARK: - Cases
	case dlc = 17
	case mod = 18
	case fullGame = 19

	// MARK: - Properties
	/// The name value of a game type.
	var name: String {
		switch self {
		case .dlc:
			return L10n.dlc
		case .mod:
			return L10n.mod
		case .fullGame:
			return L10n.fullGame
		}
	}
}

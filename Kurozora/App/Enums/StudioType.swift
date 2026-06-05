//
//  GameType.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

enum StudioType: Int, CaseIterable {
	// MARK: - Cases
	case anime = 0
	case manga = 1
	case game = 2
	case act = 3
	case record = 4

	// MARK: - Properties
	/// The name value of a studio type.
	var name: String {
		switch self {
		case .anime:
			return L10n.anime
		case .manga:
			return L10n.manga
		case .game:
			return L10n.game
		case .act:
			return L10n.act
		case .record:
			return L10n.record
		}
	}
}

//
//  GameStatus.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

enum GameStatus: Int, CaseIterable {
	// MARK: - Cases
	case toBeAnnounced = 12
	case notPublishedYet = 13
	case currentlyPublishing = 14
	case finishedPublishing = 15
	case onHiatus = 16
	case discontinued = 17

	// MARK: - Properties
	/// The name value of a game status.
	var name: String {
		switch self {
		case .toBeAnnounced:
			return "To Be Announced"
		case .notPublishedYet:
			return "Not Published Yet"
		case .currentlyPublishing:
			return "Currently Publishing"
		case .finishedPublishing:
			return "Finished Publishing"
		case .onHiatus:
			return "On Hiatus"
		case .discontinued:
			return "Discontinued"
		}
	}
}

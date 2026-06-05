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
			return L10n.toBeAnnounced
		case .notPublishedYet:
			return L10n.notPublishedYet
		case .currentlyPublishing:
			return L10n.currentlyPublishing
		case .finishedPublishing:
			return L10n.finishedPublishing
		case .onHiatus:
			return L10n.onHiatus
		case .discontinued:
			return L10n.discontinued
		}
	}
}

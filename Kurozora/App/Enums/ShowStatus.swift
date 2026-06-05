//
//  ShowStatus.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

enum ShowStatus: Int, CaseIterable {
	// MARK: - Cases
	case toBeAnnounced = 1
	case notAiringYet = 2
	case currentlyAiring = 3
	case finishedAiring = 4
	case onHiatus = 5
	case discontinued = 18

	// MARK: - Properties
	/// The name value of a show status.
	var name: String {
		switch self {
		case .toBeAnnounced:
			return L10n.toBeAnnounced
		case .notAiringYet:
			return L10n.notAiringYet
		case .currentlyAiring:
			return L10n.currentlyAiring
		case .finishedAiring:
			return L10n.finishedAiring
		case .onHiatus:
			return L10n.onHiatus
		case .discontinued:
			return L10n.discontinued
		}
	}
}

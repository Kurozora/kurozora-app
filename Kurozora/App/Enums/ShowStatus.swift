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
			return "To Be Announced"
		case .notAiringYet:
			return "Not Airing Yet"
		case .currentlyAiring:
			return "Currently Airing"
		case .finishedAiring:
			return "Finished Airing"
		case .onHiatus:
			return "On Hiatus"
		case .discontinued:
			return "Discontinued"
		}
	}
}

//
//  LiteratureStatus.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

enum LiteratureStatus: Int, CaseIterable {
	// MARK: - Cases
	case toBeAnnounced = 6
	case notPublishedYet = 7
	case currentlyPublishing = 8
	case finishedPublishing = 9
	case onHiatus = 10
	case discontinued = 11

	// MARK: - Properties
	/// The name value of a literature status.
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

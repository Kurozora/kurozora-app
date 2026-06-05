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

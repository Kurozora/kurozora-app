//
//  TVRating.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

enum TVRating: Int, CaseIterable {
	// MARK: - Cases
	case notRated = 1
	case allAges = 2
	case pg12 = 3
	case r15 = 4
	case r18 = 5

	// MARK: - Properties
	/// The name of a TV rating.
	var name: String {
		switch self {
		case .notRated:
			return "NR"
		case .allAges:
			return "G"
		case .pg12:
			return "PG-12"
		case .r15:
			return "R15+"
		case .r18:
			return "R18+"
		}
	}

	/// The description of a TV rating.
	var description: String {
		switch self {
		case .notRated:
			return "Not Rated"
		case .allAges:
			return "All Ages"
		case .pg12:
			return "Parental Guidance Suggested"
		case .r15:
			return "Violence & Profanity"
		case .r18:
			return "Adults Only"
		}
	}

	/// Whether a TV rating is not safe for work.
	var isNSFW: Bool {
		switch self {
		case .notRated:
			return false
		case .allAges:
			return false
		case .pg12:
			return false
		case .r15:
			return true
		case .r18:
			return true
		}
	}
}

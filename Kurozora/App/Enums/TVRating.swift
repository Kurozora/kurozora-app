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
			return L10n.tvRatingNotRated
		case .allAges:
			return L10n.tvRatingAllAges
		case .pg12:
			return L10n.tvRatingParentalGuidance
		case .r15:
			return L10n.tvRatingViolenceProfanity
		case .r18:
			return L10n.tvRatingAdultsOnly
		}
	}

	/// The preferred TV rating that leaves everything unrestricted.
	static let unrestricted = -1

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

	// MARK: - Functions
	/// Whether the given preferred TV rating reaches NSFW content.
	///
	/// - Parameter preferredTVRating: The rating the user picked.
	///
	/// - Returns: `true` when the rating reaches NSFW content.
	static func includesNSFW(_ preferredTVRating: Int) -> Bool {
		if preferredTVRating == Self.unrestricted {
			return true
		}

		return TVRating(rawValue: preferredTVRating)?.isNSFW == true
	}
}

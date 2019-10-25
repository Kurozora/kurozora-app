//
//  ShowSections.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/04/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

/**
	List of show sections.

	```
	case synopsis = 0
	case information = 1
	case rating = 2
	case seasons = 3
	case cast = 4
	case related = 5
	```
*/
enum ShowSections: Int {
	case synopsis
	case information
	case rating
	case seasons
	case cast
	case related

	/// An array containing all show sections.
	static let all: [ShowSections] = [.synopsis, .information, .rating, .seasons, .cast, .related]

	/// The string value of a show section.
	var stringValue: String {
		switch self {
		case .synopsis:
			return "Synopsis"
		case .information:
			return "Information"
		case .rating:
			return "Ratings"
		case .seasons:
			return "Seasons"
		case .cast:
			return "Cast"
		case .related:
			return "Related"
		}
	}

	/// The string value of a show section segue identifier.
	var segueIdentifier: String {
		switch self {
		case .synopsis:
			return "SynopsisSegue"
		case .information:
			return "InformationSegue"
		case .rating:
			return "RatingsSegue"
		case .seasons:
			return "SeasonsSegue"
		case .cast:
			return "CastSegue"
		case .related:
			return "RelatedSegue"
		}
	}
}

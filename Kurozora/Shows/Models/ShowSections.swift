//
//  ShowSections.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/04/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class ShowDetail {
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
	enum Section: Int {
		case synopsis = 0
		case information = 1
		case rating = 2
		case seasons = 3
		case cast = 4
		case related = 5

		/// An array containing all show sections.
		static let all: [Section] = [.synopsis, .information, .rating, .seasons, .cast, .related]

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

	/**
		List of airing statuses.

		```
		case toBeAnnounced = "Tba"
		case currentlyAiring = "Continuing"
		case finishedAiring = "Ended"
		```
	*/
	enum AiringStatus: String {
		/// No airing date has been announced.
		case toBeAnnounced = "Tba"

		/// The show is currently airing its episodes.
		case currentlyAiring = "Continuing"

		/// The show finished airing all of its episodes.
		case finishedAiring = "Ended"

		/// An array containing all airing statuses.
		static let all: [AiringStatus] = [.toBeAnnounced, .finishedAiring, .currentlyAiring]

		/// The string value of an airing status.
		var stringValue: String {
			switch self {
			case .toBeAnnounced:
				return "To Be Announced"
			case .currentlyAiring:
				return "Currently Airing"
			case .finishedAiring:
				return "Finished Airing"
			}
		}

		/// The color value of an airing status.
		var colorValue: UIColor {
			switch self {
			case .toBeAnnounced:
				return .toBeAnnounced
			case .currentlyAiring:
				return .currentlyAiring
			case .finishedAiring:
				return .finishedAiring
			}
		}
	}

	//	enum AiringStatus: Int {
	//		/// No airing date has been announced.
	//		case toBeAnnounced = 0
	//
	//		/// The show is currently airing its episodes.
	//		case currentlyAiring = 1
	//
	//		/// The show finished airing all of its episodes.
	//		case finishedAiring = 2
	//
	//		/// An array containing all airing statuses.
	//		static let all: [AiringStatus] = [.toBeAnnounced, .finishedAiring, .currentlyAiring]
	//
	//		/// The string value of an airing status.
	//		var stringValue: String {
	//			switch self {
	//			case .toBeAnnounced:
	//				return "To Be Announced"
	//			case .currentlyAiring:
	//				return "Currently Airing"
	//			case .finishedAiring:
	//				return "Finished Airing"
	//			default:
	//				return "To Be Announced"
	//			}
	//		}
	//
	//		/// The color value of an airing status.
	//		var colorValue: UIColor {
	//			switch self {
	//			case .toBeAnnounced:
	//				return .toBeAnnounced
	//			case .currentlyAiring:
	//				return .currentlyAiring
	//			case .finishedAiring:
	//				return .finishedAiring
	//			}
	//		}
	//	}
}
